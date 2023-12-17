#!/bin/bash

# Remove the veth interfaces and network namespace
ip link delete veth0
ip netns delete ns2