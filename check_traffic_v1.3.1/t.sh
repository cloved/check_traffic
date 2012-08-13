#!/bin/sh
while true
do
	echo "------SS------"
	echo '------G 2'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I2 -w200,300 -c400,500 -Fs -Mb
	echo '------P'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I2 -w200,300 -c400,500 -Fs -Mb -p 12
	echo '------R'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I2 -w200-900,300-1000 -c100-1000,200-1100 -Fs -Mb -r
	echo '------G 3'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I3 -w200,300 -c400,500 -Fs -Mb
	echo '------P'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I3 -w200,300 -c400,500 -Fs -Mb -p 12
	echo '------R'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I3 -w200-900,300-1000 -c100-1000,200-1100 -Fs -Mb -r
	echo "------SM------"
	echo '------G'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I2,3 -w200,300 -c400,500 -Fs -Mb 
	echo '------P'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I2,3 -w200,300 -c400,500 -Fs -Mb -p 12 
	echo '------R'
	bash check_traffic.sh  -H 60.214.208.53 -V 2c -CDu0M1 -I2,3 -w200-900,300-1000 -c100-1000,200-1100 -Fs -Mb -r
	#sleep 5
done
