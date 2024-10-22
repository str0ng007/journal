## This playbook will install Kubernetes cluster

## Prepare the nodes

I use  one master node and 2 workers nodes, using RockyLinux9.

## Make sure that the nodes has the correct entry in /etc/hosts

```
192.168.100.2 rmaster1
192.168.100.3 rworker01
192.168.100.4 rworker02
```
## Create the inventory file
```
[all]
rmaster1
rworker01
rworker02

[master]
rmaster1

[workers]
rworker01
rworker02

[all:vars]
ansible_user = ansible
```

## Update your nodes
```
ansible-playbook -i inventory Update_os.yml
```

## Execute kubernetes install
```
ansible-playbook -i inventory install_k8s.yml
```

## Wait for the playbook to complete

### Verify

login to the master node
```
ssh user@rmaster1
```
check if the nodes

```
kubectl get nodes
```

### References:
* Kubernetes releases: https://kubernetes.io/releases/
* Calico releases: https://github.com/projectcalico/calico/releases

### TODO:
- Update playbook to be more idempotent
- Remove Hardcoded values from the play, use VAR
