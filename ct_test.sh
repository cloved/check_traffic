#!/bin/bash

# Testing hosts
host_1=192.168.1.1
host_2=10.76.2.15
host_3=10.7.4.18
host_4=172.16.3.3
# Testing community
community=public

# Source my test config
if [ -f ./ct_test.conf ]; then
	. ./ct_test.conf
fi

echo '------List Interface------'
bash check_traffic.sh  -H $host_1 -V 2c -C$community -L

echo '------Use Interface Index------'

#single host singel interface
echo '------SS------'

#classic mode
echo '------G'
bash check_traffic.sh  -H $host_1 -V 2c -C$community -I2 -w200,300 -c400,500 
#use -i, add a suffix to check_traffic history data file,
#for conflict avoidance of same host/same interface checks.
bash check_traffic.sh  -H $host_1 -V 2c -C$community -I2 -w200,300 -c400,500  -i another-check

#use -p for traffic jitter check
echo '------P'
bash check_traffic.sh  -H $host_1 -V 2c -C$community -I2 -w200,300 -c400,500 -Fs -Kb -p 12

#use -r for traffic range check
echo '------R'
bash check_traffic.sh  -H $host_1 -V 2c -C$community -I2 -w200-900,300-1000 -c100-1000,200-1100 -FS -Mb -r


#single host multi interfaces
echo "------SM------"
echo '------G'
bash check_traffic.sh  -H $host_1 -V 2c -C$community -I2,3 -w200,300 -c400,500 -Fs -Mb 
echo '------P'
bash check_traffic.sh  -H $host_1 -V 2c -C$community -I2,3 -w200,300 -c400,500 -Fs -Kb -p 12 
echo '------R'
bash check_traffic.sh  -H $host_1 -V 2c -C$community -I2,3 -w200-900,300-1000 -c100-1000,200-1100 -FS -Mb -r



#mult hosts multi interfaces
echo "------MM------"
echo '------G'
bash check_traffic.sh  -H $host_1,$host_2 -V 2c,2c -C $community,$community -I2,2 -w200,300 -c400,500 
echo '------P'
bash check_traffic.sh  -H $host_1,$host_2 -V 2c,2c -C $community,$community -I2,2 -w200,300 -c400,500 -Fs -Kb  -p 12
echo '------R'
bash check_traffic.sh  -H $host_1,$host_2 -V 2c,2c -C $community,$community -I2,2 -w200-900,300-1000 -c100-1000,200-1100 -FS -Mb  -r
sleep 5


echo '------Use Interface Name------'
echo "------SS------"

#use InterfaceName instead of interface index value
echo '------G'
bash check_traffic.sh  -H $host_3 -V 2c -C$community -N FastEthernet0/1 -w200,300 -c400,500 -Fs -Mb
echo '------P'
bash check_traffic.sh  -H $host_3 -V 2c -C$community -N FastEthernet0/1  -w200,300 -c400,500 -Fs -Mb -p 12
echo '------R'
bash check_traffic.sh  -H $host_3 -V 2c -C$community -N FastEthernet0/1  -w200-900,300-1000 -c100-1000,200-1100 -Fs -Mb -r

echo "------SM------"
echo '------G'
bash check_traffic.sh  -H $host_3 -V 2c -C$community -N FastEthernet0/1,FastEthernet0/2 -w200,300 -c400,500 -Fs -Mb 
echo '------P'
bash check_traffic.sh  -H $host_3 -V 2c -C$community -N FastEthernet0/1,FastEthernet0/2 -w200,300 -c400,500 -Fs -Mb -p 12 
echo '------R'
bash check_traffic.sh  -H $host_3 -V 2c -C$community -N FastEthernet0/1,FastEthernet0/2 -w200-900,300-1000 -c100-1000,200-1100 -Fs -Mb -r

echo "------MM------"
echo '------G'
bash check_traffic.sh  -H $host_4,$host_3 -V 2c,2c -C $community,$community -N eth0,FastEthernet0/1 -w200,300 -c400,500 -Fs -Mb 
echo '------P'
bash check_traffic.sh  -H $host_4,$host_3 -V 2c,2c -C $community,$community -Neth0,FastEthernet0/1 -w200,300 -c400,500 -Fs -Mb  -p 12
echo '------R'
bash check_traffic.sh  -H $host_4,$host_3 -V 2c,2c -C $community,$community -Neth0,FastEthernet0/1 -w200-900,300-1000 -c100-1000,200-1100 -Fs -Mb  -r
