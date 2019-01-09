*Run station_Regressions first 

global fileoutname "Month_By_Station_Multi.xml"
global totalTreat  "  A_HOMICIDE_week_before3_4  A_HOMICIDE_week_before1_2   A_HOMICIDE_week    A_HOMICIDE_week_after1_2  A_HOMICIDE_week_after3_4"
global clusterlevel  "vce( cluster stat_id )"
global note "Nothing"
*global time "keep if year>2008"
global time ""



$main_reg
$time 
areg rides_numb_sum $totalTreat   i.yearmonthFE  $demograph , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Staion Month") addtext( yearmonthFE, "X", Station by Month FE , "X")
sleep 2000
 
$Line_reg
$time 
areg rides_numb_sum  ${totalTreat}  i.yearmonthFE  $demograph , absorb(lineByMonthFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Line Month") addtext( yearmonthFE, "X", Line by Month FE , "X")
sleep 2000
 

$Nearest_reg
$time 
areg rides_numb_sum $totalTreat   i.yearmonthFE  $demograph , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Nearest Month") addtext( yearmonthFE, "X", Station by Month FE , "X")
sleep 2000


$Taxi_reg
$time  
areg taxi_pickups  $totalTreat   i.yearmonthFE  $demograph , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Taxi Month") addtext( yearmonthFE, "X", Station by Month FE , "X")
sleep 2000


$Hourly_reg
$time 
areg week_entries_late  ${totalTreat}  rides_numb_sum yearmonthFE $demograph , absorb( stationBYmonthFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Hourly Month ") addtext( WeekFE, "X", StationFE, "X",Control Ridership, "X" )

