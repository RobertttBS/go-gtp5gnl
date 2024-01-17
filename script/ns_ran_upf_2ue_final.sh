#!/bin/bash
source ./config
EXEC_NS2="sudo ip netns exec ${NS2}"

# Setup network namespace
sudo ip netns add ${NS2}

# Setup RAN part
sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth0 up
sudo ip addr add ${UE_IP} dev lo
sudo ip addr add ${UE2_IP} dev lo
sudo ip addr add ${RAN_IP}/24 dev veth0

sudo ip link set veth1 netns ${NS2}

# Setup UPF part
${EXEC_NS2} ip link set lo up
${EXEC_NS2} ip link set veth1 up
${EXEC_NS2} ip addr add ${DN_IP} dev lo
${EXEC_NS2} ip addr add ${UPF_IP}/24 dev veth1

if [ ${DUMP_NS} ]
then
    ${EXEC_NS2} tcpdump -i any -w ${NS2}.pcap &
    TCPDUMP_PID=$(sudo ip netns pids ${NS2})
fi

cd ${LIBGTP5GNL_TOOLS_PATH}

echo "############### RAN Part ###############"
sudo ./gtp5g-link add gtp5gtest --ran &
sleep 0.1
sudo ./gtp5g-tunnel add qer gtp5gtest 123 --qfi 9
sudo ./gtp5g-tunnel add qer gtp5gtest 321 --qfi 9
sudo ./gtp5g-tunnel add qer gtp5gtest 11 --qfi 1 --mbr-dl 400000 --mbr-ul 400000 --gbr-dl 350000 --gbr-ul 350000
sudo ./gtp5g-tunnel add qer gtp5gtest 12 --qfi 1 --mbr-dl 400000 --mbr-ul 400000 --gbr-dl 350000 --gbr-ul 350000
# the parameter after <ifname> is oid (object identifier)
sudo ./gtp5g-tunnel add far gtp5gtest 1 --action 2
# --hdr-creation <description> <o-teid> <peer-ipv4> <peer-port>
sudo ./gtp5g-tunnel add far gtp5gtest 2 --action 2 --hdr-creation 0 78 ${UPF_IP} 2152
sudo ./gtp5g-tunnel add pdr gtp5gtest 1 --pcd 1 --hdr-rm 0 --ue-ipv4 ${UE_IP} --f-teid 87 ${RAN_IP} --far-id 1 --qer-id 11 # --pcd <precedence>
sudo ./gtp5g-tunnel add pdr gtp5gtest 2 --pcd 2 --ue-ipv4 ${UE_IP} --far-id 2 --qer-id 12

sudo ./gtp5g-tunnel add qer gtp5gtest 124 --qfi 9
sudo ./gtp5g-tunnel add qer gtp5gtest 322 --qfi 9
sudo ./gtp5g-tunnel add qer gtp5gtest 13 --qfi 1 --mbr-dl 400000 --mbr-ul 400000 --gbr-dl 150000 --gbr-ul 150000
sudo ./gtp5g-tunnel add qer gtp5gtest 14 --qfi 1 --mbr-dl 400000 --mbr-ul 400000 --gbr-dl 150000 --gbr-ul 150000
sudo ./gtp5g-tunnel add far gtp5gtest 3 --action 2
sudo ./gtp5g-tunnel add far gtp5gtest 4 --action 2 --hdr-creation 0 79 ${UPF_IP} 2152
sudo ./gtp5g-tunnel add pdr gtp5gtest 3 --pcd 1 --hdr-rm 0 --ue-ipv4 ${UE2_IP} --f-teid 88 ${RAN_IP} --far-id 3 --qer-id 13
sudo ./gtp5g-tunnel add pdr gtp5gtest 4 --pcd 2 --ue-ipv4 ${UE2_IP} --far-id 4 --qer-id 14

sudo ip r add ${DN_CIDR} dev gtp5gtest # traffic from RAN to DN, route to gtp5gtest

echo "############### UPF Part ###############"
${EXEC_NS2} ./gtp5g-link add gtp5gtest &
sleep 0.1
${EXEC_NS2} ./gtp5g-tunnel add qer gtp5gtest 123 --qfi 9 # 123 map the RAN settup
${EXEC_NS2} ./gtp5g-tunnel add qer gtp5gtest 321 --qfi 9 # 321 map the RAN settup
${EXEC_NS2} ./gtp5g-tunnel add qer gtp5gtest 11 --qfi 1 --mbr-dl 400000 --mbr-ul 400000 --gbr-dl 350000 --gbr-ul 350000 # 11 is qer-id
${EXEC_NS2} ./gtp5g-tunnel add qer gtp5gtest 12 --qfi 1 --mbr-dl 400000 --mbr-ul 400000 --gbr-dl 350000 --gbr-ul 350000 # 12 is qer-id
${EXEC_NS2} ./gtp5g-tunnel add far gtp5gtest 1 --action 2 # add far <ifname> <oid> [options...]
${EXEC_NS2} ./gtp5g-tunnel add far gtp5gtest 2 --action 2 --hdr-creation 0 87 ${RAN_IP} 2152 # map to RAN f-teid
${EXEC_NS2} ./gtp5g-tunnel add pdr gtp5gtest 1 --pcd 1 --hdr-rm 0 --ue-ipv4 ${UE_IP} --f-teid 78 ${UPF_IP} --far-id 1 --qer-id 11
${EXEC_NS2} ./gtp5g-tunnel add pdr gtp5gtest 2 --pcd 2 --ue-ipv4 ${UE_IP} --far-id 2 --qer-id 12

${EXEC_NS2} ./gtp5g-tunnel add qer gtp5gtest 124 --qfi 9
${EXEC_NS2} ./gtp5g-tunnel add qer gtp5gtest 322 --qfi 9
${EXEC_NS2} ./gtp5g-tunnel add qer gtp5gtest 13 --qfi 1 --mbr-dl 400000 --mbr-ul 400000 --gbr-dl 150000 --gbr-ul 150000
${EXEC_NS2} ./gtp5g-tunnel add qer gtp5gtest 14 --qfi 1 --mbr-dl 400000 --mbr-ul 400000 --gbr-dl 150000 --gbr-ul 150000
${EXEC_NS2} ./gtp5g-tunnel add far gtp5gtest 3 --action 2
${EXEC_NS2} ./gtp5g-tunnel add far gtp5gtest 4 --action 2 --hdr-creation 0 88 ${RAN_IP} 2152
${EXEC_NS2} ./gtp5g-tunnel add pdr gtp5gtest 3 --pcd 1 --hdr-rm 0 --ue-ipv4 ${UE2_IP} --f-teid 79 ${UPF_IP} --far-id 3 --qer-id 13
${EXEC_NS2} ./gtp5g-tunnel add pdr gtp5gtest 4 --pcd 2 --ue-ipv4 ${UE2_IP} --far-id 4 --qer-id 14


${EXEC_NS2} ip r add ${UE_CIDR} dev gtp5gtest # traffic from UPF to UE, route to gtp5gtest

echo "############### Setup veth1 TC ###############"
echo "====Load ebpf program===="
${EXEC_NS2} tc qdisc add dev veth1 clsact
${EXEC_NS2} tc filter add dev veth1 egress bpf da obj /home/ubuntu/Desktop/ebpf_tc_setup_tstamp/tc-xdp-drop-tcp.o sec tc
${EXEC_NS2} tc qdisc add dev veth1 handle 1: root tbf rate 0.5mbit\
         burst 5kb latency 70ms peakrate 1mbit\
         minburst 1540

${EXEC_NS2} tc qdisc add dev veth1 parent 1:1 handle 10: skbprio

echo "############### Test UP ###############"
ping -c3 -I ${UE_IP} ${DN_IP} # ping -c3 -I 60.60.0.10 60.60.1.10
ping -c3 -I ${UE2_IP} ${DN_IP} # ping -c3 -I 60.60.0.11 60.60.1.10

echo "############## Stopping ##############"
sleep 1
sudo killall -15 gtp5g-link
sleep 1

if [ ${DUMP_NS} ]
then
   ${EXEC_NS2} kill -SIGINT ${TCPDUMP_PID}
fi

sudo ip link del gtp5gtest
sudo ip link del veth0
sudo ip netns del ${NS2}
sudo ip addr del ${UE_IP}/32 dev lo
sudo ip addr del ${UE2_IP}/32 dev lo