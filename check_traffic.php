<?php
$opt[1] = "--vertical-label \"Traffic $UNIT[1]\" --title \"Traffic $UNIT[1] ($servicedesc) at $hostname\" ";

$def[1] = "DEF:var1=$rrdfile:$DS[1]:MAX " ;
$def[1] .= "DEF:var2=$rrdfile:$DS[2]:MAX " ;
$def[1] .= "DEF:var3=$rrdfile:$DS[3]:MAX " ;
#$def[1] = "DEF:var1=$rrdfile:$DS[1]:AVERAGE " ;
#$def[1] .= "DEF:var2=$rrdfile:$DS[2]:AVERAGE " ;
#$def[1] .= "DEF:var3=$rrdfile:$DS[3]:AVERAGE " ;
$def[1] .= "LINE1:var1#3F5EAB:\"in\" " ;
$def[1] .= "GPRINT:var1:LAST:\"%7.2lf $UNIT[1] last\" " ;
$def[1] .= "GPRINT:var1:AVERAGE:\"%7.2lf $UNIT[1] avg\" " ;
$def[1] .= "GPRINT:var1:MAX:\"%7.2lf $UNIT[1] max\\n\" " ;
$def[1] .= "LINE1:var2#00ff00:\"out\" " ;
$def[1] .= "GPRINT:var2:LAST:\"%7.2lf $UNIT[2] last\" " ;
$def[1] .= "GPRINT:var2:AVERAGE:\"%7.2lf $UNIT[2] avg\" " ;
$def[1] .= "GPRINT:var2:MAX:\"%7.2lf $UNIT[2] max\\n\" ";
#$def[1] .= "LINE1:var3#aaee00:\"total\" " ;
#$def[1] .= "GPRINT:var3:LAST:\"%7.2lf $UNIT[3] last\" " ;
#$def[1] .= "GPRINT:var3:AVERAGE:\"%7.2lf $UNIT[3] avg\" " ;
#$def[1] .= "GPRINT:var3:MAX:\"%7.2lf $UNIT[3] max\" ";
?>
