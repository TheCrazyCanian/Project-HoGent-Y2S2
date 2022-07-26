
| Connectie   | LAN 1 R/64     | LAN 2 R1/64    | VLAN 10 R2/64  | VLAN 20 R2/64  | Seriële link R1-R2/64 |
| ----------- | -------------- | -------------- | -------------- | -------------- | --------------------- |
| IPV6 Addres | 2001:db8:A:7:: | 2001:db8:B:7:: | 2001:db8:C:7:: | 2001:db8:D:7:: | 2001:db8:ACDC:7::     |

# Cisco labo 2
## Configuratie Routers

### Configuratie R1
* ```R1(config)#hostname R1```

* ```R1(config)#banner motd & Toegang voor onbevoegden is verboden! &```

* ```R1(config)#ipv6 unicast-routing```

* ```R1(config)#int g0/0/0```

* ```R1(config-if)#ipv6 enable```

* ```R1(config-if)#ipv6 address 2001:db8:A:7::1/64```

* ```R1(config-if)#ipv6 address FE80::1 link-local```

* ```R1(config-if)#no shutdown```

* ```R1(config)#int g0/0/1```

* ```R1(config-if)#ipv6 enable``

* ```R1(config-line)#ipv6 address 2001:db8:B:7::1/64```

* ```R1(config-line)#ipv6 address FE80::1 link-local```

* ```R1(config-if)#no shutdown```

* ```R1(config)#ipv6 dhcp pool IPV6-STATELESS```

* ```R1(config-dhcpv6)# dns-server 2001:db8:1000::10```

* ```R1(config-dhcpv6)# domain-name SystemEngeneeringProject```

* ```R1(config-if)#int g0/0/1```

* ```R1(config-if)#ipv6 nd other-config-flag```

* ```R1(config-if)#ipv6 dhcp server IPV6-STATELESS```

* ```R1(config)#int s0/1/0```

* ```R1(config-if)#ipv6 enable```

* ```R1(config-if)#no shut```

### Configuratie R2

* ```R2(config)#hostname R2```
* ```R2(config)#banner motd & Toegang voor onbevoegden is verboden! &```
* ```R2(config)#ipv6 unicast-routing```
* ```R2(config)#int g0/0/0```
* ```R2(config-if)#no shut```
* ```R2(config)#int g0/0/0.10```
* ```R2(config-subif)#encapsulation dot1Q 10```
* ```R2(config-subif)#ipv6 address 2001:db8:C:7::1/64```
* ```R2(config-subif)#ipv6 address FE80::2 link-local```
* ```R2(config-subif)#no shutdown```
* ```R2(config)#int g0/0/0.20```
* ```R2(config-subif)#encapsulation dot1Q 20```
* ```R2(config-subif)#ipv6 address 2001:db8:D:7::1/64```
* ```R2(config-subif)#ipv6 address FE80::2 link-local```
* ```R2(config-subif)#no shutdown```
* ```R2(config-dhcpv6)# ipv6 dhcp pool TIENTJE```
* ```R2(config-dhcpv6)#address prefix 2001:db8:C:7::/64```
* ```R2(config-dhcpv6)# dns-server 2001:db8:1000::10```
* ```R2(config-dhcpv6)# domain-name SystemEngeneeringProject```
* ```R2(config-dhcpv6)# ipv6 dhcp pool TWINTIGJE```
* ```R2(config-dhcpv6)#address prefix 2001:db8:D:7::/64```
* ```R2(config-dhcpv6)# dns-server 2001:db8:1000::10```
* ```R2(config-dhcpv6)# domain-name SystemEngeneeringProject```
* ```R2(config-dhcpv6)# ipv6 dhcp pool SERIETJE```
* ```R2(config-dhcpv6)#address prefix 2001:db8:ACDC:7::/64```
* ```R2(config-dhcpv6)# dns-server 2001:db8:1000::10```
* ```R2(config-dhcpv6)# domain-name SystemEngeneeringProject```
* ```R2(config)#int g0/0/0.10```
* ```R2(config-subif)#ipv6 nd managed-config-flag```
* ```R2(config-subif)#ipv6 dhcp server TIENTJE```
* ```R2(config)#int g0/0/0.20```
* ```R2(config-subif)#ipv6 nd managed-config-flag```
* ```R2(config-subif)#ipv6 dhcp server TWINTIGJE```
* ```R2(config)#int s0/1/0```
* ```R2(config-if)#ipv6 enable```
* ```R2(config-if)#ipv6 address 2001:db8:acdc:7::1/64```
* ```R2(config-if)#ipv6 address fe80::2 link-local```
* ```R2(config-if)#ipv6 dhcp server SERIETJE```
* ```R2(config-if)#ipv6 nd managed-config-flag```
* ```R2(config-if)#no shut```

### config R1 Stateful

* ```R1(config)#int s0/1/0```
* ```R1(config-if)#ipv6 enable```
* ```R1(config-if)#ipv6 address dhcp```

### Configuratie S3

* ```S3(config)#hostname S3```
* ```S3(config)#vlan 10```
* ```S3(config-vlan)#name tien```
* ```S3(config)#vlan 20```
* ```S3(config-vlan)#name twintig```
* ```S3(config)#int range f0/1-10```
* ```S3(config-if-range)#switchport mode access```
* ```S3(config-if-range)#switchport access vlan 10```
* ```S3(config)#int range f0/11-20```
* ```S3(config-if-range)#switchport mode access```
* ```S3(config-if-range)#switchport access vlan 20```
* ```S3(config)#int g0/1```
* ```S3(config-if)#switchport mode trunk```
* ```S3(config-if)#switchport trunk allowed vlan 10,20```

## Routering

### R1

* ```ipv6 route 0::/0 s0/1/0 FE80::2 -> default route```

### R2

* ```R2(config)#ipv6 route 2001:db8:a:7::/64 s0/1/0```
* ```R2(config)#ipv6 route 2001:db8:b:7::/64 s0/1/0```
* ```R2(config)#ipv6 route ::/0 2001:db8:2000::1```



### router ISP

* ```ISP(config)#ipv6 route 2001:db8:a:7::/64 2001:db8:2000::2```
* ```ISP(config)#ipv6 route 2001:db8:b:7::/64 2001:db8:2000::2```
* ```ISP(config)#ipv6 route 2001:db8:c:7::/64 2001:db8:2000::2```
* ```ISP(config)#ipv6 route 2001:db8:d:7::/64 2001:db8:2000::2```
