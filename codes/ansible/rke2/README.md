# RKE2 Ansible Playbook

Automated installation of RKE2 Kubernetes cluster on Rocky Linux using Ansible.

## Prerequisites

- Rocky Linux 9 nodes
- SSH access to all nodes
- Ansible installed on control machine
- Python 3 on all nodes

## Quick Start

1. **Update inventory file** with your node IPs:
```bash
nano inventory.ini
```

2. **Configure variables** (optional):
```bash
nano group_vars/all.yml
```

3. **Run the playbook**:
```bash
ansible-playbook -i inventory.ini site.yml
```

## Inventory Configuration

Edit `inventory.ini` to specify your nodes:

```ini
[master]
192.168.56.10 ansible_user=vagrant

[workers]
192.168.56.11 ansible_user=vagrant
192.168.56.12 ansible_user=vagrant
```

## Configuration Variables

Edit `group_vars/all.yml` to customize:

- `rke2_version`: RKE2 version (empty = latest)
- `rke2_cluster_token`: Shared secret for cluster
- `rke2_cni`: CNI plugin (canal, calico, cilium)
- `enable_firewall`: Enable and configure firewall (true/false)
- `disable_selinux`: Disable SELinux (true/false)
- `system_upgrade`: Upgrade packages before install (true/false)
- `install_rancher`: Install Rancher Manager (true/false)
- `rancher_hostname`: Hostname for Rancher (default: master-ip.sslip.io)
- `rancher_bootstrap_password`: Initial admin password for Rancher

### Firewall Configuration

To enable firewall protection:

```yaml
# In group_vars/all.yml
enable_firewall: true
```

When enabled, the playbook will:
- Install and enable firewalld
- Open required ports for RKE2
- Configure Canal CNI specific ports
- Allow SSH access

**Ports opened:**

Common ports (all nodes):
- 6443/tcp - Kubernetes API
- 9345/tcp - RKE2 supervisor API
- 10250/tcp - kubelet metrics
- 30000-32767/tcp - NodePort range

Master-only ports:
- 2379/tcp - etcd client
- 2380/tcp - etcd peer
- 2381/tcp - etcd metrics

Canal CNI ports (all nodes):
- 8472/udp - VXLAN
- 9099/tcp - Health checks
- 51820/udp - WireGuard IPv4
- 51821/udp - WireGuard IPv6

## What the Playbook Does

The playbook is organized into roles for maintainability and reusability.

### Roles Structure

```
roles/
├── system-prepare/     # Prepare all nodes
├── firewall-configure/ # Configure firewall (optional)
├── rke2-server/        # Install master node
├── rke2-agent/         # Install worker nodes
├── rke2-verify/        # Verify cluster
└── rancher-install/    # Install Rancher Manager (optional)
```

### Preparation (All Nodes) - `system-prepare` role
1. System package upgrade (with reboot)
2. Disable SELinux (with reboot)
3. Optionally configure firewalld (if enable_firewall: true)
4. Load required kernel modules (br_netfilter, overlay, xt_CHECKSUM)
5. Configure sysctl parameters
6. Install required packages
7. Configure NetworkManager for Canal CNI

### Master Node Installation - `rke2-server` role
1. Create RKE2 configuration (bound to NIC2)
2. Install RKE2 server
3. Start rke2-server service
4. Setup kubeconfig in user's home directory
5. Configure kubectl access
6. Generate node token for workers

### Rancher Installation - `rancher-install` role (optional)

To install Rancher Manager on your RKE2 cluster:

```yaml
# In group_vars/all.yml
install_rancher: true
rancher_hostname: "192.168.56.10.sslip.io"  # Or your custom domain
rancher_bootstrap_password: "YourSecurePassword123!"
```

The role will:
1. Install Helm if not present
2. Add Rancher and Jetstack Helm repositories
3. Install cert-manager with CRDs
4. Install Rancher with self-signed certificates
5. Wait for all components to be ready

Access Rancher at: `https://{{ rancher_hostname }}`

**Note:** For production, use a real domain name and proper SSL certificates.

### Worker Nodes Installation - `rke2-agent` role
1. Configure connection to master
2. Install RKE2 agent
3. Start rke2-agent service
4. Join cluster

### Verification - `rke2-verify` role
1. Check all nodes are Ready
2. Display cluster status
3. Show all running pods

## Accessing the Cluster

After installation, copy kubeconfig from master:

```bash
# Copy kubeconfig
scp vagrant@192.168.56.10:/etc/rancher/rke2/rke2.yaml ~/.kube/config

# Update server address
sed -i 's/127.0.0.1/192.168.56.10/g' ~/.kube/config

# Verify access
kubectl get nodes
```

## Rocky Linux Specific Fixes

The playbook handles known Rocky Linux issues:

1. **NetworkManager interference with Canal CNI**
   - Creates `/etc/NetworkManager/conf.d/rke2-canal.conf`
   - Configures NetworkManager to ignore Canal interfaces

2. **SELinux conflicts**
   - Disables SELinux (required for RKE2)

3. **Required packages**
   - Installs `container-selinux`, `iptables`, etc.

## Troubleshooting

### Check RKE2 server status
```bash
ssh vagrant@192.168.56.10
sudo systemctl status rke2-server
sudo journalctl -u rke2-server -f
```

### Check RKE2 agent status
```bash
ssh vagrant@192.168.56.11
sudo systemctl status rke2-agent
sudo journalctl -u rke2-agent -f
```

### Check cluster nodes
```bash
ssh vagrant@192.168.56.10
sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get nodes
```

### Check pods
```bash
ssh vagrant@192.168.56.10
sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -A
```

## Uninstall RKE2

### Master node
```bash
sudo /usr/local/bin/rke2-uninstall.sh
```

### Worker nodes
```bash
sudo /usr/local/bin/rke2-agent-uninstall.sh
```

## References

- [RKE2 Quick Start](https://docs.rke2.io/install/quickstart)
- [RKE2 Requirements](https://docs.rke2.io/install/requirements)
- [RKE2 Known Issues](https://docs.rke2.io/known_issues)
- [Canal CNI Configuration](https://docs.rke2.io/install/requirements?cni-rules=Canal)

## License

MIT
