## Configure Network Manager for Redhat8 and above
check the interfaces
```
root@localhost ~]# ip a                                                                                                                                                                                           │
│1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000                                                                                                                        │
│    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00                                                                                                                                                          │
│    inet 127.0.0.1/8 scope host lo                                                                                                                                                                                 │
│       valid_lft forever preferred_lft forever                                                                                                                                                                     │
│    inet6 ::1/128 scope host                                                                                                                                                                                       │
│       valid_lft forever preferred_lft forever                                                                                                                                                                     │
│2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000                                                                                                              │
│    link/ether 52:54:00:64:f6:e3 brd ff:ff:ff:ff:ff:ff                                                                                                                                                             │
│    inet 192.168.122.254/24 brd 192.168.122.255 scope global dynamic noprefixroute enp1s0                                                                                                                          │
│       valid_lft 3594sec preferred_lft 3594sec                                                                                                                                                                     │
│    inet6 fe80::5054:ff:fe64:f6e3/64 scope link noprefixroute                                                                                                                                                      │
│       valid_lft forever preferred_lft forever                                                                                                                                                                     │
│3: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000                                                                                                              │
│    link/ether 52:54:00:1e:90:bd brd ff:ff:ff:ff:ff:ff                                                                                                                                                             │
│    inet 192.168.100.2/24 brd 192.168.100.255 scope global noprefixroute enp2s0                                                                                                                                    │
│       valid_lft forever preferred_lft forever                                                                                                                                                                     │
│    inet6 fe80::5054:ff:fe1e:90bd/64 scope link noprefixroute                                                                                                                                                      │
│       valid_lft forever preferred_lft forever
```
Change the IP address say, enp2s0 using `nmcli` tool
```
nmcli con mod enp2s0 ipv4.addr "192.168.100.2/24" method manual
```
You can restart the interface
```
nmcli con down enp2s0
nmcli con up enp2s0
```

## Changing hostname
one way to change hostname is to use `nmcli` tool
```
nmcli general hostname
nmcli general hostname <hostname>
```

