#!/bin/bash

# Create a new network namespace
ip netns add ns2

# Create two veth interfaces
ip link add veth0 type veth peer name veth1

# Move veth1 to the new namespace
ip link set veth1 netns ns2

# Assign IP addresses to the veth interfaces
ip addr add 192.168.1.1/24 dev veth0
ip netns exec ns2 ip addr add 192.168.1.2/24 dev veth1

# Enable the veth interfaces
ip link set veth0 up
ip netns exec ns2 ip link set veth1 up

# Setup TC
# ip netns exec ns2 tc qdisc add dev veth1 root handle 1: htb default 1
# ip netns exec ns2 tc qdisc add dev veth1 root fq
ip netns exec ns2 tc qdisc add dev veth1 root etf clockid CLOCK_TAI delta 1000000
ip netns exec ns2 tc qdisc show dev veth1

# Test connectivity between the two IP addresses
ping -c 3 -I 192.168.1.1 192.168.1.2
ip netns exec ns2 ping -c 3 192.168.1.1

# Remove the veth interfaces and network namespace
ip link delete veth0
ip netns delete ns2