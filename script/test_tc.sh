#!/bin/bash


UE0=192.168.1.1
UE1=192.168.1.2
VETH0_ETH_ADDR=aa:bb:cc:dd:ee:ff
VETH1_ETH_ADDR=aa:bb:cc:dd:ee:f1

# Create a new network namespace
ip netns add ns2

# Create two veth interfaces
ip link add veth0 type veth peer name veth1

# Move veth1 to the new namespace
ip link set veth1 netns ns2

echo "====Assign IP addresses to the veth interfaces===="
ip addr add 192.168.1.1/24 dev veth0
ip netns exec ns2 ip addr add 192.168.1.2/24 dev veth1

echo "====Setup mac address===="
ip link set dev veth0 address ${VETH0_ETH_ADDR}
ip netns exec ns2 ip link set dev veth1 address ${VETH1_ETH_ADDR}

echo "====Enable the veth interfaces===="
ip link set veth0 up
ip netns exec ns2 ip link set veth1 up

echo "====Setup arp address===="
arp -s ${UE1} ${VETH1_ETH_ADDR}
ip netns exec ns2 arp -s ${UE0} ${VETH0_ETH_ADDR}
# arp -a -n

# Setup TC
# echo "====Setup TC===="
# ip netns exec ns2 ethtool -L veth1 tx 3
# ip netns exec ns2 ethtool -l veth1
# ip netns exec ns2 tc qdisc add dev veth1 root prio bands 3
# ip netns exec ns2 tc qdisc add dev veth1 root pfifo_fast
# ip netns exec ns2 tc qdisc add dev veth1 root etf clockid CLOCK_TAI skip_sock_check deadline_mode
# ip netns exec ns2 tc qdisc show dev veth1


# Setup TC ETF
tc qdisc add dev veth0 root etf clockid CLOCK_TAI skip_sock_check deadline_mode

# Test connectivity between the two IP addresses
ping -c 3 -I 192.168.1.1 192.168.1.2
ip netns exec ns2 ping -c 3 192.168.1.1

# Remove the veth interfaces and network namespace
# ip link delete veth0
# ip netns delete ns2
