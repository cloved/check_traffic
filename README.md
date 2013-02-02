#check_traffic.sh

*The original version of this help was written by gould. Thanks for Gould Chu.*

##This plugin checks traffic usage and jitter of:
- a single interface on a single network device
- multiple interfaces on a single network device
- interface(s) on a single or multiple network devices
	* The amount of interfaces is not limited. However, aggregation of too many interfaces might make impact on accuracy. 
	* The value of amount less than 8 interfaces is recommended.
- Both 32-bit and 64-bit counters are supported.

##Usage:
	check_traffic.sh [ -v ] [ -6 ] [ -i Suffix ] [ -F s|S ] [-p N] [ -r ] -V 1|2c|3 ( -C snmp-community | -A "AuthString" (when use snmp v3, U must give the AuthString)) -H host [ -L ] (-I interface|-N interface name) -w in,out-warning-value  -c in,out-critical-value -K/M -B/b

##Options:
- -h (help)
	* Get the help message
- -v (verbose)
	* Verbose mode, to debug some messages out to the /tmp directory with log file name check\_traffic.$$.
- -V (snmp version, protocol=[1|2c|3])
	* Specify the version of snmp
- -C (community)
	* Specify the Community
- -H (host)
	* Specify the host
- -6 (use 64 bit)
	* Use 64 bit counter, ifHC\*  instead of if\*.
- -r (range)
	* Use Range instead of single value in warning and critical Threshold
- -I (ifIndex of interface)
	* Specify ifIndex of each interface
- -N (interface name)
	* Specify the interface name
- -L (list)
	* List all Interfaces on specify host
- -B/b (Bps/bps)
	* Switch to Bps(B/s) or bps(b/s), default is -b, bps
- -K/M (kilo/mega)
	* Switch to K (kilo) or M (mega) Bps|bps, default is -K
- -w (warning)
	* Set inbound and outbound warning threshold for traffic usage or traffic jitter value
- -c (critical)
	* Set inbound and outbound critical threshold for traffic usage or traffic jitter value
- -F (format, type=[s|S])
	* -F s (simple output format)
	* -F S (simpler output format)
- -p (amount of traffic usage records preserved for comparison=INTEGER)
	* This option is the amount of traffic usage records preserved prior to current traffic usage check. The average of all these preserved values is compared with current check value to detect whether jitter happens. The value (amount) between 4 and 12 is suggested.
- -i	(suffix=STRING)
	* It's the individual suffix added to the CF/STAT_HIST_DATA if necessary.

##Example:

###List Interfaces on the host
use -L to list all interfaces on the host.
* `check_traffi.sh [ -v ] -V 1|2c|3 -C snmp-community -H host -L`

-------------------------------------

###Single Interface
####Default Check
Such as:
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -I 4 -w 200,100 -c 300,200 -K -B`
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -N FastEthernet0/1 -w 200,100 -c 300,200 -K -B`

####Range Check
with -r to use Range Value Options:
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -I 4 -r -w 200-300,100-200 -c 100-400,50-250 -K -B`
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -N eth0 -r -w 200-300,100-200 -c 100-400,50-250 -K -B`

####Jitter Check 
with -p N to use Traffic Jitter Options:
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -I 4 -p 8 -w 45,45 -c 55,55`
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -N eth0 -p 8 -w 45,45 -c 55,55`

-------------------------------------

###Multi Interfaces with Single Host
####Default Check
for single host and multiple interfaces checking (in the same host/device):
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -I 2,3,8,9 -w 200,100 -c 300,200 -K -B`
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -N FastEthernet0/1,FastEthernet0/2 -w 200,100 -c 300,200 -K -B`

####Range Check
with -r to use Range Value Options:
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -I 2,3,8,9 -r -w 200-300,100-200 -c 100-400,50-250 -K -B`

		check_traffi.sh -V 2c -C public -H 127.0.0.1 -I -N FastEthernet0/1,FastEthernet0/2 -r -w 200-300,100-200 -c 100-400,50-250 -K -B


####Jitter Check
with -p N to use Traffic Jitter Options:
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -I 2,3,8,9 -p 8 -w 45,45 -c 55,55`
* `check_traffi.sh -V 2c -C public -H 127.0.0.1 -N FastEthernet0/1,FastEthernet0/2 -p 8 -w 45,45 -c 55,55`

-------------------------------------

###Multi Interfaces with Multi Host
####Default Check
for multiple hosts and multiple interfaces checking (in the same host/device):
* `check_traffi.sh -V 2c,1 -C public,private -H 127.0.0.1,192.168.1.1 -I 2,3 -w 200,100 -c 300,200 -K -B`

		check_traffi.sh -V 2c,1 -C public,private -H 127.0.0.1,192,168.1.1 -N FastEthernet0/1,FastEthernet0/2 -w 200,100 -c 300,200 -K -B

####Range Check
with -r to use Range Value Options:
* `check_traffi.sh -V 2c,1 -C public,private -H 127.0.0.1,192.168.1.1 -I 2,3 -w 200-300,100-200 -c 100-400,50-250 -K -B`

		check_traffi.sh -V 2c,1 -C public,private -H 127.0.0.1,192.168.1.1 -N FastEthernet0/1,FastEthernet0/2 -r -w 200-300,100-200 -c 100-400,50-250 -K -B

####Jitter Check
with -p N to use Traffic Jitter Options:
* `check_traffi.sh -V 2c,1 -C public,private -H 127.0.0.1,192.168.1.1 -I 2,3 -p 8 -w 45,45 -c 55,55`

		check_traffi.sh -V 2c,1 -C public,private -H 127.0.0.1,192.168.1.1 -N FastEthernet0/1,FastEthernet0/2 -p 8 -w 45,45 -c 55,55

-------------------------------------

###Check with SNMP V3 Device
Use -A to check for snmp v3 device:
* with -I

		check_traffi.sh -V 3 -A "-u kschmidt -l authPriv -a MD5 -A mysecretpass -x DES -X mypassphrase" -H 127.0.0.1 -I 4 -w 200,100 -c 300,200 -K -B

* with -N

		check_traffi.sh -V 3 -A "-u kschmidt -l authPriv -a MD5 -A mysecretpass -x DES -X mypassphrase" -H 127.0.0.1 -N eth0 -w 200,100 -c 300,200 -K -B

##Note:
- If you don't use -K/M -B/b options, default -K -b, corresponding to Kbps.
<br>Combination:
	* -K -b (kbps, kilobits per second)
	* -K -B (KBps, kilobytes per second)
	* -M -b (Mbps, megabits per second)
	* -M -B (MBps, megabytes per second)
- Make sure that the check interval greater than 30 Seconds, or modify the Min_Interval's default value as you need. 
- And, if you want in Verbose mode, use "-v" to check the debug messages in the file /tmp/check_traffic.$$.

## Report bugs and get HELP
- Email to: cloved@gmail.com
- Home page: [http://bbs.itnms.info](http://bbs.itnms.info/forum.php?mod=viewthread&tid=767&extra=page%3D1)
