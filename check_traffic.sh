#!/bin/bash
#########################################################################
#
# File:         check_traffic.sh
# Description:  Nagios check plugins to check network interface traffic with SNMP run in *nix.
# Language:     GNU Bourne-Again SHell
# Version:	1.2.6
# Date:		2011-12-13
# Corp.:	Chenlei
# Author:	chnl@163.com (U can msn me with this), QQ 31017671
# WWW:		http://www.itnms.info
# PerlVersion:	U Can find the perl/Net::SNMP Version in the same site.
#########################################################################
# Bugs:
# The Latest Version will be released in http://bbs.itnms.info.
# You can send bugs to http://bbs.itnms.info,
# or email to me directly: chnl@163.com
#########################################################################
# Todo:
# Do not use unit at performance data, for pnp/rrd graphing better.
# Add the History performance data file support.(maybe)
# Also support the -n args, with interface name to check the traffic.
#########################################################################
# ChangeLog:
#
# Version 1.2.6
# 2011-12-13
# Spelling fix, from itnms.net to itnms.info.
#
# Version 1.2.5
# 2011-10-18
# Spelling fix.
#
# Version 1.2.4
# 2011-10-12
# Add snmp v3 support.
#
# Version 1.2.3
# 2011-09-05
# Fix bugs when high traffic occurs -- ifSpeed check error
#
# Version 1.2.2
# 2011-03-11
# Fix bugs with overflow detection. Thanks for jans1086.
#
# Version 1.2.1
# 2010-11-19
# Fix some spelling mistake;
#
# Version 1.2.0
# 2010-04-26
# Change default Scale value from 4 to 2, for more friendly output. If you want more excat value, U can change it for youself.
# Fix the Min Interval check bugs, move the check before write the current data to data hist file.
# Add the Max Interval var, default value is 1800, if the hist data file is too old, drop the result.
# Fix the for output "Maybe 32 bit counter overflow, because we got a negative value here." when check too frequent. And set Min_Interval to 30 as default.
# Add the -F option for simple or more simple(s/S) output format.
# Add the -i option for the individual suffix with the CF/STAT_HIST_DATA if necessary.
# Use the 64bit counter as default, when snmp version is v2c. If the system not support it, use 32bit counter instead.
# Get the interface's IF-MIB::ifSpeed, if the traffic value is bigger than it, drop it and output with OOPS and exit with Unkown.
# Modify the CF_HIST_DATA file name  from "/var/tmp/check_traffic_${Host}_${Interface}.hist_dat" to 
#       "/var/tmp/check_traffic_${Host}_${Interface}.hist_dat_${USER}_64|32" for resolving 
#	1)user and 
#	2)64/32bit 
#	transfer problem which make 
#	1)the hist data file read/write error and
#       2)with huge error traffic value.
# Add the function for testing Traffic Jitter(The orginal idea come from msn chat wiht wjks@hotmail.com). 
#	Add a option -p N, N(from 1 to 12) is a number that we comare this time value with the average value of previos N times we had been checked. 
#	If the value we checked this time is not in our defined scope(a % value) with -w/-c option specified(such as -w 20,20 -c30,30 ), 
#	we think that it is a traffic jitter.
#	For this option, add a file for storing the hist data to stat: /var/tmp/check_traffic_${Host}_${Interface}.hist_dat_${USER}_64|32_ctj_$Num"
#
# Version 1.1.6
# 2009-02-20
# Fix some mistake at perfdata output format with Warning and Critical Value. (thanks for Jiang Shan)
# Remove the redundant code, merge code for --range option. 
# Write data before the exit(for the reason of IsFirst), for the next time use.
# When write or read file error, use Unknow instead of Warning severity.
# If get a negative netflow or time interval value here, exit with unknow.
#
# Version 1.1.5
# 2008-09-28
# Fix bug on perfdata output format;
# Fix some spelling mistake;
# Add the Default Value for UseRange as "False";
#
# Version 1.1.4
# 2008-09-18
# Add -r  options, Use Range instead of single value in warning and critical Threshold;
# This option suggestion by zhgypg@hotmail.com at http://www.itnms.info/thread-1220-1-1.html
#
# Version 1.1.3
# 2008-09-17
# Set the default Interval as 12 seconds;
#
# Version 1.1.2
# 2008-08-19
# Check the snmp agent support the 64 bit counter or not;
# Check the interface status, if not OK, exit with Critical status;
# Get the interface name with Interface Index Value;
#
# Version 1.1.1
# 2008-08-06
# Fix some bugs in version compare.
# Use -6 option, use 64 bit counter.
#
# Version 1.1.0
# 2008-06-11
# In snmp v2c, use counters ifHC*  instead of if*;
#
# Version 1.0.9
# 2008-04-22
# More friendly output when getting snmp info error.
#
# Version 1.0.8
# 2008-03-31
# Correct some spelling mistake
#
# Version 1.0.7
# 2008-03-28
# If it's the first time to touch hist_dat, echo OK and Tips out;
# Test the hist_dat can be read and write;
# Use the Vars for $OutPut and $PerfData
# Fix some output format.
#
# Version 1.0.6
# 2008-03-25
# Correct Performance data output with Warning and Critical Value of Total and Interval for pnp graphing.
#
# Version 1.0.5
# 2008-03-24
# Correct Performance data output for pnp graphing.
#
# Version 1.0.4
# 2008-03-21
# Correct Performance data output to "Nagios plug-in development guidelines", 
# for Graphing the performance data in the web with PNP.
# The standard is: 'label'=value[UOM];[warn];[crit];[min];[max]
#
# Version 1.0.3
# 2008-03-20
# More friendly output with function list_interface().
#
# Version 1.0.2
# 2008-03-06
# Fix some coding bugs;
# Add the -L support;
# -K/-M to speicify in K or M (bps,B/s);
# -B/-b switch to B/s or bps;
# Add Total traffic value in output
#
# Version 1.0.1
# 2008-02-28
# Fix two cacl bugs at line 212 and 244.
# In print_full_help_msg(), '$$' instead $$.
#
# Version 1.0
# 2008-02-27
# Original Version.
#########################################################################
# Heh, just a ad here :), for my honey.
# http://shop35165045.taobao.com/
############################
#
# Exit values:
# ------------
#    0		OK
#    1		Warning
#    2		Cirital
#    3		Unknown
#    Others	Unknown
#
# ----------------------------------------------------------------------
# These are Parameters from external
# -h 
#	Get the help message
#
# -v 
#	Verbose mode, to debug some messages out to the /tmp directory with log file name check_traffic.$$.
#
# -V    1|2c|3
#	Specify the version of snmp
#
# -C    Community
#	Specify the Community
#
# -H    host
#	Specify the host
#
# -6    Use 64 bit counter, ifHC*  instead of if*.
#
# -r    Use Range instead of single value in warning and critical Threshold;
#
# -I    interface
#	Specify the interface
#
# -L    List all Interfaces on specify host
#
# -B/b  Switch to B/s or bps, default is -b, bps
#
# -K/M  Switch to K or M (bsp,B/s), default is -K 
#
# -w    Warning value Kbps, in and out
# -c    Critical value Kbps, in and out
# 	Set Warning and Critical Traffic value
# -F    s/S 
#	Simple or more simple output format
#
# -p    number
#	It is a number that we comare this time value with the average value of previos N times we had been checked.
#
# -i	suffix
#	It's the individual suffix with the CF/STAT_HIST_DATA if necessary.

unset LANG

Scale=2
Unit_1="K"
Unit_2="bps"

UseRange="False"	

ifIn32="ifInOctets"
ifOut32="ifOutOctets"

ifIn64="ifHCInOctets"
ifOut64="ifHCOutOctets"
# Set the Min Interval of Check.
Min_Interval=30
Max_Interval=1800

print_help_msg(){
	$Echo "Usage: $0 -h to get help."
}

print_full_help_msg(){
	$Echo "Usage:"
	$Echo "$0 [ -v ] [ -6 ] [ -i Suffix ] [ -F s|S ] [-p N] [ -r ] -V 1|2c|3 ( -C snmp-community | -A \"AuthString\" (when use snmp v3, U must give the AuthString)) -H host [ -L ] -I interface -w in,out-warning-value  -c in,out-critical-value -K/M -B/b "
	$Echo "Example:"
	$Echo "${0} -V 2c -C public -H 127.0.0.1 -I 4 -w 200,100 -c 300,200 -K -B"
	$Echo "Or -r to use Range Value Options:"
	$Echo "${0} -V 2c -C public -H 127.0.0.1 -I 4 -r -w 200-300,100-200 -c 100-400,50-250 -K -B"
	$Echo "Or -p N to use Traffic Jitter Options:"
	$Echo "${0} -V 2c -C public -H 127.0.0.1 -I 4 -p 2 -w 45,45 -c 55,55"
	$Echo "If you don't use -K/M -B/b options, default -K -b, corresponding to Kbps."
	$Echo "Make sure that the check interval greater than 5 Seconds."
	$Echo "Or modify the Min_Interval var in this file Line 180."
	$Echo 'And, if you want in Verbose mode, use -v, to check the debug messages in the file /tmp/check_traffic.$$.'
	$Echo "Or use $0 [ -v ] -V 1|2c|3 -C snmp-community -H host -L "
	$Echo "To list all interfaces on specify host."
	$Echo "Or check for snmp v3 device:"
	$Echo "${0} -V 3 -A \"-u kschmidt -l authPriv -a MD5 -A mysecretpass -x DES -X mypassphrase\" -H 127.0.0.1 -I 4 -w 200,100 -c 300,200 -K -B"
}

print_err_msg(){
	$Echo "Error."
	print_full_help_msg
}

check_record_cnt(){
	echo $2 | awk -F "$1" '{print NF}'
}

list_interface(){
	$SNMPWALK -v $Version $Community $Host "IF-MIB::ifDescr" |sed 's/IF-MIB::ifDescr./Interface index /g' | sed 's/= STRING:/orresponding to /g'
	exit 3

}

gen_string(){
	string_num=$1
	string_i=1
	string_t=""
	string_p="NA "
	while [ $string_i -le $string_num ]
	do
		string_t="$string_t$string_p"
		string_i=`expr $string_i + 1`
	done
}

#adjust_value(){
#	if [ `echo "$1 < 1" | bc` -eq 1 ]; then
#		return "0"${$1} # if -lt 1, will error at: return: 0.1: numeric argument required
#	else
#		return $1
#	fi
#}

to_debug(){
if [ "$Debug" = "true" ]; then
	$Echo "$*" >> /tmp/check_traffic.log.$$ 2>&1
	#$Echo "$*" >> /tmp/check_traffic.log 2>&1
fi
}


case "$(uname -s)"
	in
	SunOS)
	Echo="echo"
	;;
	Linux)
	Echo="echo -e"
	;;
	*)
	Echo="echo"
	;;
esac


if [ $# -lt 1 ]; then
	print_help_msg
	exit 3
else
	while getopts :v6rhi:p:F:V:C:A:H:I:LKMBbw:c: OPTION
	do
		case $OPTION
			in
			v)
			#$Echo "Verbose mode."
			Debug=true
			;;
			V)
			Version=$OPTARG
			if [ $Version == "3" ]; then
				SnmpVersion=3
			fi
			;;
			C)
			Community=$OPTARG
			;;
			A)
			AuthString=$OPTARG
			;;
			i)
			Suffix="$OPTARG"	
			;;
			F)
			Format="$OPTARG"	
			;;
			6)
			Bit64="True"	
			;;
			p)
			Num="$OPTARG"	
			TrafficJitter="True"	
			;;
			r)
			UseRange="True"	
			;;
			H)
			Host=$OPTARG
			;;
			L)
			ListInt="True"
			;;
			I)
			Interface=$OPTARG
			;;
			w)
			WarningV=$OPTARG
			;;
			c)
			CriticalV=$OPTARG
			;;
			M)
			isM="True"
			Unit_1="M"
			;;
			K)
			;;
			B)
			isB="True"
			Unit_2="B"
			;;
			b)
			;;
			h)
			print_full_help_msg
			exit 3
			;;
			?)
			$Echo "Error: Illegal Option."
			print_help_msg
			exit 3
			;;
		esac
	done
fi


if [ -z "$Version" -o -z "$Host" ] ; then
	$Echo "Args Error."
	print_full_help_msg
	exit 3
fi

if [ "$SnmpVersion" = "3" ]; then
	if [ -z "$AuthString" ]; then
		$Echo "Args Error."
		print_full_help_msg
		exit 3
	else
		Community="$AuthString"
	fi
else
	if [ -z "$Community" ]; then
		$Echo "Args Error."
		print_full_help_msg
		exit 3
	else
		Community=" -c $Community"
	fi
fi


SNMPWALK=`which snmpwalk 2>&1`
if [ $? -ne 0 ];then
	$Echo $SNMPWALK
	$Echo "Can not found command snmpwalk in you system PATH: $PATH, pleas check it"
	exit 3
fi
to_debug Use $SNMPWALK to check traffic

if [ "$ListInt" = "True" ]; then
	$Echo "List Interface for host $Host."
	list_interface
	exit 3
fi



if [ -z "$Interface" -o -z "$WarningV" -o -z "$CriticalV" ] ; then
	$Echo "Args Error."
	print_full_help_msg
	exit 3
fi

to_debug All Values  are \" Warning: "$WarningV" and Critical: "$CriticalV" \".
WVC=`check_record_cnt "," "$WarningV"`
CVC=`check_record_cnt "," "$CriticalV"`
to_debug WVC is $WVC and CVC is $CVC

if [ $UseRange = "True" ] ;then
	to_debug UseRange is True
	#####################
	if [ $WVC -ne 2 -o $CVC -ne 2 ] ; then
		$Echo "Warning and Critical Value error."
		print_full_help_msg
		exit 3
	else
		W1=`echo $WarningV| awk -F "," '{print $1}'`
		W1b=`echo $W1| awk -F "-" '{print $1}'`
		W1e=`echo $W1| awk -F "-" '{print $2}'`

		W2=`echo $WarningV| awk -F "," '{print $2}'`
		W2b=`echo $W2| awk -F "-" '{print $1}'`
		W2e=`echo $W2| awk -F "-" '{print $2}'`

		Wtb=`echo "$W1b + $W2b"|bc`
		Wte=`echo "$W1e + $W2e"|bc`
		to_debug Warning Value is $W1 $W2 $Wtb $Wte
	
		C1=`echo $CriticalV| awk -F "," '{print $1}'`
		C1b=`echo $C1| awk -F "-" '{print $1}'`
		C1e=`echo $C1| awk -F "-" '{print $2}'`

		C2=`echo $CriticalV| awk -F "," '{print $2}'`
		C2b=`echo $C2| awk -F "-" '{print $1}'`
		C2e=`echo $C2| awk -F "-" '{print $2}'`

		Ctb=`echo "$C1b + $C2b"|bc`
		Cte=`echo "$C1e + $C2e"|bc`

		to_debug Critical Value is $C1 $C2 $Ctb $Cte
		
		check_1b=`echo "$C1b < $W1b" | bc`
		check_1e=`echo "$C1e > $W1e" | bc`

		check_2b=`echo "$C2b < $W2b" | bc`
		check_2e=`echo "$C2e > $W2e" | bc`
		to_debug check_1 is $check_1b , $check_1e check_2 is $check_2b $check_2e
	
		if [ $check_1b -ne 1 -o $check_1e -ne 1 -o  $check_2b -ne 1 -o  $check_2e -ne 1 ] ; then
			$Echo "Error, the corresponding Critical End value must greater than Warning End value, And Critical Begin value must less than Warning End value"
			print_full_help_msg
			exit 3
		fi
	
	fi

	#####################
	
	
else
	to_debug Use Range is False

	if [ $WVC -ne 2 -o $CVC -ne 2 ] ; then
		$Echo "Warning and Critical Value error."
		print_full_help_msg
		exit 3
	else
		W1=`echo $WarningV| awk -F "," '{print $1}'`
		W2=`echo $WarningV| awk -F "," '{print $2}'`
		Wt=`echo "$W1 + $W2"|bc`
		to_debug Warning Value is $W1 $W2 $Wt
	
		C1=`echo $CriticalV| awk -F "," '{print $1}'`
		C2=`echo $CriticalV| awk -F "," '{print $2}'`
		Ct=`echo "$C1 + $C2"|bc`
		to_debug Critical Value is $C1 $C2 $Ct
		
		check_1=`echo "$C1 > $W1" | bc`
		check_2=`echo "$C2 > $W2" | bc`
		to_debug check_1 is $check_1 , check_2 is $check_2 
	
		if [ $check_1 -ne 1 -o  $check_2 -ne 1 ] ; then
			$Echo "Error, the corresponding Critical value must greater than Warning value."
			print_full_help_msg
			exit 3
		fi
	
	fi
fi

# This file will save the traffic data from previos check.
# Make sure it will never be deleted.
CF_HIST_DATA="/var/tmp/check_traffic_${Host}_${Interface}.hist_dat_${USER}_${Suffix}"


Time=`date +%s`

ifName=`$SNMPWALK -v $Version  $Community $Host IF-MIB::ifDescr.${Interface}| awk -F ":" '{print $4}'`
ifSpeed=`$SNMPWALK -v $Version $Community $Host IF-MIB::ifSpeed.${Interface}| awk -F ":" '{print $4}'`

$SNMPWALK -v $Version $Community $Host IF-MIB::ifHCOutOctets |grep Counter64 >/dev/null 2>&1 
Flag64=$?

if [ $Flag64 -eq 0  -a "$Version" = "2c" ];then
	ifIn=$ifIn64
	ifOut=$ifOut64
	CF_HIST_DATA="${CF_HIST_DATA}_64"
	STAT_HIST_DATA="${CF_HIST_DATA}ctj_$Num"
else
	ifIn=$ifIn32
	ifOut=$ifOut32
	CF_HIST_DATA="${CF_HIST_DATA}_32"
	STAT_HIST_DATA="${CF_HIST_DATA}ctj_$Num"
	if [ "$Bit64" = "True" ] ;then
		$Echo "Maybe your Host(device) not support 64 bit counter. Please confirm your ARGS and re-check it with Verbose mode, then to check the log.(If you snmp not support 64 bit counter, do not use -6 option)"
		exit 3
	fi
fi


if [ ! -f $CF_HIST_DATA ]; then
	IsFirst="True"
	touch $CF_HIST_DATA
	if [ $? -ne 0 ];then
		Severity=3
		Msg="Unknown"
		OutPut="Create File $CF_HIST_DATA Error with user `id`."
		$Echo "$Msg" "-" $OutPut
		exit $Severity
	fi

fi

if [ ! -r  $CF_HIST_DATA -o ! -w  $CF_HIST_DATA ]; then
	Severity=3
	Msg="Unknown"
	OutPut="Read or Write File $CF_HIST_DATA Error with user `id`."
	$Echo "$Msg" "-" $OutPut
	exit $Severity
fi

if [ $TrafficJitter"AA" = "TrueAA" ]; then
	if [ ! -f $STAT_HIST_DATA ]; then
		touch $STAT_HIST_DATA
		IsStatFirst="True"
		if [ $? -ne 0 ];then
			Severity=3
			Msg="Unknown"
			OutPut="Create File $STAT_HIST_DATA Error with user `id`."
			$Echo "$Msg" "-" $OutPut
			exit $Severity
		fi
		if [ ! -r  $STAT_HIST_DATA -o ! -w  $STAT_HIST_DATA ]; then
			Severity=3
			Msg="Unknown"
			OutPut="Read or Write File $STAT_HIST_DATA Error with user `id`."
			$Echo "$Msg" "-" $OutPut
			exit $Severity
		fi
		gen_string $Num
		to_debug string_t $string_t
		TC=0
		TRI=($string_t)
		TRO=($string_t)
		echo $TC >$STAT_HIST_DATA
		echo ${TRI[@]} >>$STAT_HIST_DATA
		echo ${TRO[@]} >>$STAT_HIST_DATA
	fi
	C=(`head -n 1 $STAT_HIST_DATA`)
	RI=(`head -n 2 $STAT_HIST_DATA |tail -n 1 `)
	RO=(`tail -n 1 $STAT_HIST_DATA`)
	to_debug C RI RO $C $RI $RO
	to_debug C RI RO $C ${RI[@]} ${RO[@]}
	to_debug C N $C $Num
fi

_result_status=`$SNMPWALK -v $Version $Community $Host "IF-MIB::ifOperStatus.${Interface}"| awk '{print $4}' | awk -F '(' '{print $1}'`
if [ "$_result_status" != "up" ]; then
	$Echo "The Interface name:${ifName} -- index:${Interface} you checked seems not up."
	exit 2
fi


_result_in=`$SNMPWALK -v $Version $Community $Host "IF-MIB::${ifIn}"|grep "IF-MIB::${ifIn}.""$Interface"`
_result_out=`$SNMPWALK -v $Version $Community $Host "IF-MIB::${ifOut}"|grep "IF-MIB::${ifOut}.""$Interface" `
to_debug time is $Time, $SNMPWALK check result in is $_result_in, out is $_result_out

_result_in=`echo $_result_in |awk '{print $4}'`
_result_out=`echo $_result_out|awk '{print $4}'`
to_debug time is $Time, $SNMPWALK check result in is $_result_in, out is $_result_out

if [ -z "$_result_in" -o -z "$_result_out" ] ; then
	$Echo "No Data been get here. Please confirm your ARGS and re-check it with Verbose mode, then to check the log.(If you snmp not support 64 bit counter, do not use -6 option)"
	exit 3
fi

In=`echo "$_result_in * 8 " |bc`
Out=`echo "$_result_out * 8 " |bc`

to_debug Time is $Time, In is $In, Out is $Out

HistData=`cat $CF_HIST_DATA| head -n 1`
HistTime=`echo $HistData| awk -F "|" '{print $1}'|sed 's/ //g'`
HistIn=`echo $HistData| awk -F "|" '{print $2}'|sed 's/ //g'`
HistOut=`echo $HistData| awk -F "|" '{print $3}'|sed 's/ //g'`
to_debug HistTime is $HistTime, HistIn is $HistIn, HistOut is $HistOut
	

if [ -z "$HistTime" -o -z "$HistIn" -o -z "$HistOut" ] ; then
	echo "$Time|$In|$Out" > $CF_HIST_DATA
	if [ "$IsFirst" = "True" ]; then
		Severity="0"
		Msg="OK"
		OutPut="It's the first time for this plugins run. We'll get the data from the next time."
	else
		Severity="3"
		Msg="Unknown"
		OutPut="Can not found data in the history data file. \
		Please to check the file $CF_HIST_DATA ,or use use verbose mode and check the debug file" 
	fi
	$Echo "$Msg" "-" $OutPut
	exit $Severity
fi


Interval=`echo "$Time - $HistTime" | bc`

if [ $Interval -lt $Min_Interval ] ; then
	$Echo "The check interval must greater than $Min_Interval Seconds. But now it's $Interval. \
	Please retry it later."
	exit 3
fi

#If there is a null hist file, can write the data before exit(for the reason of IsFirst),
# the data can be used for next time.
echo "$Time|$In|$Out" > $CF_HIST_DATA
if [ $? -ne 0 ];then
	Severity=3
	Msg="Unknown"
	OutPut="Write File $CF_HIST_DATA Error with user `id`."
	$Echo "$Msg" "-" $OutPut
	exit $Severity
fi

if [ $Interval -gt $Max_Interval ] ; then
	$Echo "The check interval is too large(It\'s greate than $Max_Interval). The result is droped. We\'ll use the fresh data at the next time."
	exit 3
fi

to_debug HistIn/Out $HistIn $HistOut

DiffIn=`echo "$In - $HistIn" | bc`
DiffOut=`echo "$Out - $HistOut" | bc`

if [ ` echo " $Interval > 0 " |bc ` -eq 0 ] ; then
	$Echo  "we got a negative time interval value here."
	exit 3
fi

if [ ` echo " $DiffOut >= 0 " |bc ` -eq 0 -o  ` echo " $DiffIn >= 0 " |bc ` -eq 0 ] ; then
	$Echo  "Maybe 32 bit counter overflow, because we got a negative value here."
	exit 3
fi

to_debug DiffIn/Out Interval $DiffIn $DiffOut $Interval

In=`echo "$DiffIn / $Interval" | bc`
Out=`echo "$DiffOut / $Interval" | bc`

to_debug In/Out/ifSpeed $In $Out $ifSpeed
#Comment to fix the bug when high traffic occurs
#if [ $In -gt $ifSpeed -o $Out -gt $ifSpeed ]; then
#	$Echo  "OOPS. We get a value bigger than ifSpeed here. Something is wrong. Maybe a check from 32bit to 64bit transfer, or any other error here."
#	exit 3
#fi

if [ $TrafficJitter"AA" = "TrueAA" ]; then
	if [ $C -lt $Num ]; then
		echo "OK - But there was only $C hist data before this check. We need the $Num hist data to use for calculating. Please wait."
		RI[$C]=$In
		RO[$C]=$Out
		to_debug C $C 
		to_debug RI ${RI[@]}
		to_debug RO ${RO[@]}
		C=`expr $C + 1`
	
		echo $C >$STAT_HIST_DATA
		echo ${RI[@]} >>$STAT_HIST_DATA
		echo ${RO[@]} >>$STAT_HIST_DATA
		exit 0
	else
		to_debug we have the enough data to calculating.
		RIAVG=0
		ROAVG=0
	
		lenRI=${#RI[@]}
		rii=0
	
		while [ $rii -lt $lenRI ]
		do
			to_debug rii RI[rii] $rii ${RI[$rii]}
			to_debug rii RO[rii] $rii ${RO[$rii]}
			RIAVG=`echo "scale=$Scale; $RIAVG + ${RI[$rii]} " |bc`
			ROAVG=`echo "scale=$Scale; $ROAVG + ${RO[$rii]} " |bc`
			let rii++
			to_debug RIAVG $RIAVG
			to_debug ROAVG $ROAVG
		done
		to_debug RIAVG $RIAVG
		to_debug ROAVG $ROAVG
		RIAVG=`echo "scale=$Scale; $RIAVG / $Num " |bc`
		ROAVG=`echo "scale=$Scale; $ROAVG / $Num " |bc`
		to_debug RIAVG $RIAVG
		to_debug ROAVG $ROAVG
	
		rii=0
		while [ $rii -lt `expr $lenRI - 1` ]
		do
			RI[$rii]=${RI[`expr $rii + 1`]}
			RO[$rii]=${RO[`expr $rii + 1`]}
			to_debug rii RI[rii] $rii ${RI[`expr $rii + 1 `]}
			to_debug rii RO[rii] $rii ${RO[`expr $rii + 1 `]}
			let rii++
		done
		RI[$rii]=$In
		RO[$rii]=$Out
		echo $C >$STAT_HIST_DATA
		echo ${RI[@]} >>$STAT_HIST_DATA
		echo ${RO[@]} >>$STAT_HIST_DATA
		DiffRIAVG=`echo "scale=$Scale; $In - $RIAVG" |bc`	
		DiffROAVG=`echo "scale=$Scale; $Out - $ROAVG" |bc`	

		DiffRIAVG=`echo $DiffRIAVG | sed 's/-//'`
		DiffROAVG=`echo $DiffROAVG | sed 's/-//'`

		DiffRIAVG=`echo "scale=$Scale; $DiffRIAVG / $RIAVG * 100 " |bc`	
		DiffROAVG=`echo "scale=$Scale; $DiffROAVG / $ROAVG  * 100" |bc`	
		DiffAVGTotal=`echo "scale=$Scale; $DiffRIAVG  + $DiffROAVG" |bc`
		
	fi
fi

#to Kb
In=`echo "$In / 1024" | bc`
Out=`echo "$Out / 1024" | bc`

if [ "$isB" = "True" ]; then
	In=`echo "scale=$Scale; $In / 8" | bc`
	Out=`echo "scale=$Scale; $Out / 8" | bc`

fi
if [ "$isM" = "True" ]; then
	In=`echo "scale=$Scale; $In / 1024" | bc`
	Out=`echo "scale=$Scale; $Out / 1024" | bc`
fi

to_debug Unit_1 is $Unit_1, Unit_2 is $Unit_2
to_debug Interval is $Interval, DiffIn is $DiffIn, DiffOut is $DiffOut, In is $In, Out is $Out
	

if [ $UseRange = "True" ] ;then

	check_w1b=`echo "$In > $W1b" | bc`
	check_w1e=`echo "$In < $W1e" | bc`

	check_w2b=`echo "$Out > $W2b" | bc`
	check_w2e=`echo "$Out < $W2e" | bc`
	to_debug check_w1 is $check_w1b $check_w1e , check_w2 is $check_w2b $check_w2e
	
	check_c1b=`echo "$In > $C1b" | bc`
	check_c1e=`echo "$In < $C1e" | bc`

	check_c2b=`echo "$Out > $C2b" | bc`
	check_c2e=`echo "$Out < $C2e" | bc`
	to_debug check_c1 is $check_c1b $check_c1e, check_c2 is $check_c2b $check_c2e
	
	
	if [ $check_w1b -eq 1 -a $check_w1e -eq 1 -a $check_w2b -eq 1  -a $check_w2e -eq 1  ] ; then
		Severity="0";
		Msg="OK";
		to_debug Severity is $Severity , Msg is $Msg 
	elif [ $check_c1b -eq 1 -a $check_c1e -eq 1 -a $check_c2b -eq 1  -a $check_c2e -eq 1  ] ; then
		Severity="1";
		Msg="Warning";
		to_debug Severity is $Severity , Msg is $Msg 
	else
		Severity="2";
		Msg="Critical";
		to_debug Severity is $Severity , Msg is $Msg 
	fi
	
elif [ $TrafficJitter"AA" = "TrueAA" ] ; then
	check_w1=`echo "$DiffRIAVG < $W1" | bc`
	check_w2=`echo "$DiffROAVG < $W2" | bc`
	to_debug check_w1 is $check_w1 , check_w2 is $check_w2 
	
	check_c1=`echo "$DiffRIAVG < $C1" | bc`
	check_c2=`echo "$DiffROAVG < $C2" | bc`
	to_debug check_c1 is $check_c1 , check_c2 is $check_c2
	
	
	if [ $check_w1 -eq 1 -a $check_w2 -eq 1 ] ; then
		Severity="0";
		Msg="OK";
		to_debug Severity is $Severity , Msg is $Msg 
	elif [ $check_c1 -eq 1 -a $check_c2 -eq 1 ] ; then
		Severity="1";
		Msg="Warning";
		to_debug Severity is $Severity , Msg is $Msg 
	else
		Severity="2";
		Msg="Critical";
		to_debug Severity is $Severity , Msg is $Msg 
	fi
else
	check_w1=`echo "$In < $W1" | bc`
	check_w2=`echo "$Out < $W2" | bc`
	to_debug check_w1 is $check_w1 , check_w2 is $check_w2 
	
	check_c1=`echo "$In < $C1" | bc`
	check_c2=`echo "$Out < $C2" | bc`
	to_debug check_c1 is $check_c1 , check_c2 is $check_c2
	
	
	if [ $check_w1 -eq 1 -a $check_w2 -eq 1 ] ; then
		Severity="0";
		Msg="OK";
		to_debug Severity is $Severity , Msg is $Msg 
	elif [ $check_c1 -eq 1 -a $check_c2 -eq 1 ] ; then
		Severity="1";
		Msg="Warning";
		to_debug Severity is $Severity , Msg is $Msg 
	else
		Severity="2";
		Msg="Critical";
		to_debug Severity is $Severity , Msg is $Msg 
	fi


fi
	
	
Total=`echo "$In + $Out" | bc`

if [ `echo "$In < 1" | bc` -eq 1 ]; then
	In="0"${In}
	if [ "$In" = "00" ]; then
		In=0.0
	fi
fi

if [ `echo "$Out < 1" | bc` -eq 1 ]; then
	Out="0"${Out}
	if [ "$Out" = "00" ]; then
		Out=0.0
	fi
fi

if [ `echo "$Total < 1" | bc` -eq 1 ]; then
	Total="0"${Total}
	if [ "$Total" = "00" ]; then
		Total=0.0
	fi
fi


if [ $UseRange = "True" ] ;then

	if [ $Format"AA" = "SAA" ]; then
		$Echo "$Msg" "-" In/Out "$In"${Unit_1}${Unit_2}/"$Out"${Unit_1}${Unit_2}\|In\=${In}${Unit_1}${Unit_2}\;\;\;0\;0 Out\=${Out}${Unit_1}${Unit_2}\;\;\;0\;0
	elif [ $Format"AA" = "sAA" ]; then
		$Echo "$Msg" "-" In/Out/Total/Interval "$In"${Unit_1}${Unit_2}/"$Out"${Unit_1}${Unit_2}/"$Total"${Unit_1}${Unit_2}/"$Interval"s \|In\=${In}${Unit_1}${Unit_2}\;\;\;0\;0 Out\=${Out}${Unit_1}${Unit_2}\;\;\;0\;0 Total\=${Total}${Unit_1}${Unit_2}\;\;\;0\;0 Interval\=${Interval}s\;1200\;1800\;0\;0 
	else
		$Echo "$Msg" "-" The Traffic In is "$In"${Unit_1}${Unit_2}, Out is "$Out"${Unit_1}${Unit_2}, Total is "$Total"${Unit_1}${Unit_2}. The Check Interval is "$Interval"s \|In\=${In}${Unit_1}${Unit_2}\;\;\;0\;0 Out\=${Out}${Unit_1}${Unit_2}\;\;\;0\;0 Total\=${Total}${Unit_1}${Unit_2}\;\;\;0\;0 Interval\=${Interval}s\;1200\;1800\;0\;0 
	fi
	exit $Severity

elif [ $TrafficJitter"AA" = "TrueAA" ]; then

	if [ $Format"AA" = "SAA" ]; then
		$Echo "$Msg" "-" Traffic Jitter In/Out "$DiffRIAVG""%"/"$DiffROAVG""%"\|In\=$DiffRIAVG\;${W1}\;${C1}\;0\;0 Out\=$DiffROAVG\;${W2}\;${C2}\;0\;0
	elif [ $Format"AA" = "sAA" ]; then
		$Echo "$Msg" "-" Traffic Jitter In/Out/Total/Interval "$DiffRIAVG""%"/"$DiffROAVG""%"/"$DiffAVGTotal""%"/"$Interval"s \|In\=$DiffRIAVG\;${W1}\;${C1}\;0\;0 Out\=$DiffROAVG\;${W2}\;${C2}\;0\;0 Total\=$DiffAVGTotal\;${Wt}\;${Ct}\;0\;0 Interval\=${Interval}s\;1200\;1800\;0\;0 
	else
		$Echo "$Msg" "-" The Traffic Jitter In is "$DiffRIAVG""%", Out is "$DiffROAVG""%", Total is "$DiffAVGTotal""%". The Check Interval is "$Interval"s \|In\=$DiffRIAVG\;${W1}\;${C1}\;0\;0 Out\=$DiffROAVG\;${W2}\;${C2}\;0\;0 Total\=$DiffAVGTotal\;${Wt}\;${Ct}\;0\;0 Interval\=${Interval}s\;1200\;1800\;0\;0 
	fi

else

	if [ $Format"AA" = "SAA" ]; then
		$Echo "$Msg" "-" In/Out "$In"${Unit_1}${Unit_2}/"$Out"${Unit_1}${Unit_2}\|In\=${In}${Unit_1}${Unit_2}\;${W1}\;${C1}\;0\;0 Out\=${Out}${Unit_1}${Unit_2}\;${W2}\;${C2}\;0\;0
	elif [ $Format"AA" = "sAA" ]; then
		$Echo "$Msg" "-" In/Out/Total/Interval "$In"${Unit_1}${Unit_2}/"$Out"${Unit_1}${Unit_2}/"$Total"${Unit_1}${Unit_2}/"$Interval"s \|In\=${In}${Unit_1}${Unit_2}\;${W1}\;${C1}\;0\;0 Out\=${Out}${Unit_1}${Unit_2}\;${W2}\;${C2}\;0\;0 Total\=${Total}${Unit_1}${Unit_2}\;${Wt}\;${Ct}\;0\;0 Interval\=${Interval}s\;1200\;1800\;0\;0 
	else
		$Echo "$Msg" "-" The Traffic In is "$In"${Unit_1}${Unit_2}, Out is "$Out"${Unit_1}${Unit_2}, Total is "$Total"${Unit_1}${Unit_2}. The Check Interval is "$Interval"s \|In\=${In}${Unit_1}${Unit_2}\;${W1}\;${C1}\;0\;0 Out\=${Out}${Unit_1}${Unit_2}\;${W2}\;${C2}\;0\;0 Total\=${Total}${Unit_1}${Unit_2}\;${Wt}\;${Ct}\;0\;0 Interval\=${Interval}s\;1200\;1800\;0\;0 
	fi
	exit $Severity
fi

# End of check_traffic.sh
