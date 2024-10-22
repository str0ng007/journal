## Error `[ERROR Port-10250]: Port 10250 is in use`

Cause: This is likely that there are files created during my first `kubeadm --init`
Solution: Reset kubeadm
```
kubeadm reset
```
restart kubelet
```
systemctl restart kubelet
```
run kubeadm init
```
kubeadm init --pod-network-cidr=192.168.100.0/24 --apiserver-advertise-address=192.168.100.2
```

