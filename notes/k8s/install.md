## Prepare the nodes
I use  one master node and 2 workers nodes, using RockyLinux9.

## update each /etc/hosts file with the corresponding name and IPs

```
192.168.100.2 rmaster1
192.168.100.3 rworker01
192.168.100.4 rworker02
```
## Disable swap memory
- edit /etc/fstab
or run the following
```
sudo swapoff -a 
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

## Adjust SELinux and Firewall Rules

```
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux
```

on the master node:

```
$ sudo firewall-cmd --permanent --add-port={22,6443,2379,2380,10250,10251,10252,10257,10259,179}/tcp
$ sudo firewall-cmd --permanent --add-port=4789/udp
$ sudo firewall-cmd --reload
```

on the worker nodes

```
$ sudo firewall-cmd --permanent --add-port={22,179,10250,30000-32767}/tcp
$ sudo firewall-cmd --permanent --add-port=4789/udp
$ sudo firewall-cmd --reload
```

## Add kernel modules and parameters (all nodes)

```
$ sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
```

run to apply

```
$ sudo modprobe overlay
$ sudo modprobe br_netfilter
```

Add the following kernel parameters

```
sudo vi /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
```

## Install containerd runtime

```
$ sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ dnf makecache
$ sudo dnf install containerd.io -y
```

create a temporary containerd config

```
$ containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
$ sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```

Restart containerd

```
$sudo systemctl restart containerd
$sudo systemctl enable containerd
```

## Install Kubernetes tools

add the kubernetes repo - PLEASE NOTE THE K8s VERSION

```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
```

update the dnf cache

```
sudo dnf makecache
```

Install the packages

```
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

start kubelet

```
sudo systemctl enable --now kubelet
```

## Install Kubernetes cluster

```
sudo kubeadm init --control-plane-endpoint=rmaster01
```

## Create the kubectl config

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Join the worker nodes

run the following from the master node to get the exact command to join the workers 

```
kubeadm token create --print-join-command
```

output is something like this.

```
[root@rmaster1 ~]# kubeadm token create --print-join-command
kubeadm join rmaster1:6443 --token 3mkc9s.w2eyw5qqc3qdelg9 --discovery-token-ca-cert-hash sha256:33a02707c4b5fad2eeb4ed29c4049237f2605abe39a90d82d19761359f213da4
[root@rmaster1 ~]#
```

Run the command to each worker nodes

```
# kubeadm join rmaster1:6443 --token 3mkc9s.w2eyw5qqc3qdelg9 --discovery-token-ca-cert-hash sha256:33a02707c4b5fad2eeb4ed29c4049237f2605abe39a90d82d19761359f213da4
```

## check the nodes

```
$ kubectl get nodes
```

## Install Calico Network

run the following commands - TAKE NOTE THE VERSION e.g. v3.26.1

```
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.37.2/manifests/calico.yaml
```
then monitor all the pods.

```
kubectl get pods --all-namespaces
```

