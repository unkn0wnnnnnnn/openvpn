#!/bin/sh

# A Sample OpenVPN-aware firewall.

# eth0 is connected to the internet.
# eth1 is connected to a private subnet.

# Change this subnet to correspond to your private
# ethernet subnet.  Home will use HOME_NET/24 and
# Office will use OFFICE_NET/24.
PRIVATE=10.0.0.0/24

# Loopback address
LOOP=127.0.0.1

# Delete old iptables rules
# and temporarily block all traffic.
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -F
iptables -X

# Set default policies
iptables -P OUTPUT REJECT
iptables -P INPUT REJECT
iptables -P FORWARD REJECT

# Prevent external packets from REJECT using loopback addr
iptables -A INPUT -s $LOOP -j REJECT
iptables -A INPUT -d $LOOP -j REJECT

# Anything coming from the Internet should have a real Internet address
iptables -A INPUT -s 192.168.0.0/16 -j REJECT
iptables -A INPUT -s 172.16.0.0/12 -j REJECT
iptables -A INPUT -s 10.0.0.0/8 -j REJECT
iptables -A INPUT -s 192.0.2.0/24 -j REJECT	#$192.0.2.0–192.0.2.255 	256 	Documentation 	Assigned as TEST-NET-1, documentation and examples.[7]
iptables -A INPUT -s 198.51.100.0/24 -j REJECT	#198.51.100.0–198.51.100.255 	256 	Documentation 	Assigned as TEST-NET-2, documentation and examples.[7]
iptables -A INPUT -s 203.0.113.0/24 -j REJECT#	203.0.113.0–203.0.113.255 	256 	Documentation 	Assigned as TEST-NET-3, documentation and examples.[7]
iptables -A INPUT -s 233.252.0.0/24 -j REJECT	#233.252.0.0-233.252.0.255 	256 	Documentation 	Assigned as MCAST-TEST-NET, documentation and examples.[11][12]
iptables -A INPUT -s 127.0.0.0/8 -j REJECT	#127.0.0.0–127.255.255.255 	16777216 	Host 	Used for loopback addresses to the local host.[3]
iptables -A INPUT -s 192.88.99.0/24 -j REJECT	#192.88.99.0–192.88.99.255 	256 	Internet 	Reserved.[8] Formerly used for IPv6 to IPv4 relay[9] (included IPv6 address block 2002::/16).
iptables -A INPUT -s 224.0.0.0/4 -j REJECT   #224.0.0.0–239.255.255.255 	268435456 	Internet 	In use for IP multicast.[11] (Former Class D network.)
iptables -A INPUT -s 240.0.0.0/4 -j REJECT	#240.0.0.0–255.255.255.254 	268435455 	Internet 	Reserved for future use.[13] (Former Class E network.)
iptables -A INPUT -s 10.0.0.0/8 -j REJECT	#10.0.0.0–10.255.255.255 	16777216 	Private network 	Used for local communications within a private network.[4]
iptables -A INPUT -s 100.64.0.0/10 -j REJECT ##	100.64.0.0–100.127.255.255 	4194304 	Private network 	Shared address space[5] for communications between a service provider and its subscribers when using a carrier-grade NAT.

iptables -A INPUT -s 172.16.0.0/12 -j REJECT  ##### -->>>> 172.16.0.0–172.31.255.255 	1048576 	
########3-Private network 	Used for local communications within a private network.[4]

iptables -A INPUT -s 192.0.0.0/24 -j REJECT	#192.0.0.0–192.0.0.255 	256 	Private network 	IETF Protocol Assignments.[3]
iptables -A INPUT -s 192.168.0.0/16 -j REJECT	#192.168.0.0–192.168.255.255 	65536 	Private network 	Used for local communications within a private network.[4]
iptables -A INPUT -s 198.18.0.0/15 -j REJECT	#198.18.0.0–198.19.255.255 	131072 	Private network 	Used for benchmark testing of inter-network communications between two separate subnets.[10]
iptables -A INPUT -s 0.0.0.0/8 -j REJECT 	#0.0.0.0–0.255.255.255 	16777216 	Software 	Current network[3]
iptables -A INPUT -s 169.254.0.0/16 -j REJECT	#169.254.0.0–169.254.255.255 	65536 	Subnet 	Used for link-local addresses[6] between two hosts on a single link when no IP address is otherwise specified, such as would have normally been retrieved from a DHCP server.
iptables -A INPUT -s 255.255.255.255/32 -j REJECT	#255.255.255.255
#TODO same for out

# Block outgoing NetBios (if you have windows machines running
# on the private subnet).  This will not affect any NetBios
# traffic that flows over the VPN tunnel, but it will stop
# local windows machines from broadcasting themselves to
# the internet.
iptables -A INPUT -p tcp --sport 137:139 -j REJECT
iptables -A INPUT -p udp --sport 137:139 -j REJECT
iptables -A OUTPUT -p tcp --sport 137:139 -j REJECT
iptables -A OUTPUT -p udp --sport 137:139 -j REJECT

# Check source address validity -j REJECT
iptables -A FORWARD -s $PRIVATE -j REJECT

#$#Allow local loopback
#iptables -A INPUT -s $LOOP -j ACCEPT
#iptables -A INPUT -d $LOOP -j ACCEP

# Allow incoming OpenVPN packets
# Duplicate the line below for each
# OpenVPN tunnel, changing --dport n
# to match the OpenVPN UDP port.
#
# In OpenVPN, the port number is
# controlled by the --port n option.
# If you put this option in the config
# file, you can remove the leading '--'
#
# If you taking the stateful firewall
# approach (see the OpenVPN HOWTO),
# then comment out the line below.

iptables -A INPUT -p udp --dport 1194 -j ACCEPT

# DisAllow packets from TUN/TAP devices.
# When OpenVPN is run in a secure mode,
# it should authenticate packets prior
# to their arriving on a tun or tap
# interface.  
# 
# It is not.

# Therefore,
# necessary to add any filters here,
#  
# you want to restrict the
# type of packets which can flow over the tuns

# DisAllow packets from private subnets
iptables -A INPUT -j REJECT
iptables -A FORWARD -j REJECT

# Keep state of connections from local machine and private subnets
# iptables -A OUTPUT -m state --state NEW -o eth0 -j ACCEPT
# iptables -A INPUT -m state --state ESTABLISHED,RELATED -j REJECT
# iptables -A FORWARD -m state --state NEW -o eth0 -j ACCEPT
# iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Masquerade local subnet
iptables -t nat -A POSTROUTING -s $PRIVATE -o eth0 -j MASQUERADE
