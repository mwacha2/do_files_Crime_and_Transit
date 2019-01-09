

global outputfile1 "${analysis}\Paper\Regressions\Just_Station\"
set matsize 2000

*global variables to get datasets 
global main_reg "use `"${clean}\Regression\Main_Regression_Data.dta"' ,clear"
global Line_reg "use `"${clean}\Regression\Line_Regression_Data.dta"' ,clear"
global Nearest_reg "use `"${clean}\Regression\Nearest_Regression_Data.dta"' ,clear"
global Taxi_reg "use `"${clean}\Regression\Taxi_Regression_Data.dta"' ,clear"
global Hourly_reg "use `"${clean}\Regression\Hourly_Regression_Data.dta"' ,clear"


cap drop mean_crime
cap drop mean_riders
cap drop percap 
cap drop xm_crime xm_crime_tile

sort stat_id time_dum 

by stat_id time_dum :egen mean_crime = mean( A_violent_week)
by stat_id time_dum :egen mean_riders = mean( rides_numb_mean)
gen percap = mean_crime/ mean_riders
xtile xm_crime = mean_crime if time_dum , n(4)
sort stat_id
by stat_id: egen  xm_crime_tile = max( xm_crime)




*********************
*Main
$main_reg
foreach block in   "A"   {
if "`block'"=="A" {
di "Block `block' running " 
***Week entire data set 
global fileoutname "Main_Stat_Viol.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global totalTreat  " S_violent_week_before5_6  S_violent_week_before3_4  S_violent_week_before1_2  S_violent_week  S_violent_week_after1_2  S_violent_week_after3_4  S_violent_week_after5_6 S_violent_week_a7decay S_violent_week_a7decay2 "
global title "Station Crime and Ridership, Main Robust"
*global weather "imput_avg_temp prcp " 
**
}

else if "`block'"=="B" {
di "Block `block' running " 
*
***Week entire data set 
global fileoutname "Main_StatOutside_Viol.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global totalTreat  "    c.S_violent_week_before9_10#i.time_dum  c.S_violent_week_before7_8#i.time_dum  c.S_violent_week_before5_6#i.time_dum  c.S_violent_week_before3_4#i.time_dum  c.S_violent_week_before1_2#i.time_dum        S_violent_week        c.S_violent_week_after1_2#i.time_dum  c.S_violent_week_after3_4#i.time_dum  c.S_violent_week_after5_6#i.time_dum  c.S_violent_week_after7_8#i.time_dum  c.S_violent_week_after9_10#i.time_dum "
global title "Station Crime and Ridership, Main with Time_Het"
*global weather "imput_avg_temp prcp " 
**
**
}
else{
di "None of the Blocks"
}

reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
areg $dependent  $totalTreat $weather i.stationFE $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN ") addtext( WeekFE, "X", StationFE, "X")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE  $demograph , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", StationFE, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE $demograph , absorb(IncByweekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Quint_By_Week") addtext( IncByweekFE, "X", StationFE, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE  i.stationFE#c.yeartrend  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Stat_Trend") addtext( WeekFE, "X", StationFE Trends, "X")
 sleep 2000 
 
areg $dependent  $totalTreat $weather  i.yearmonthFE  $demograph , absorb( stationBYmonthFE)
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH") addtext( yearmonthFE, "X", StationbyMonth FE , "X")
sleep 2000

}





************************************************************************
global fileoutname "Station_Treatment.xml"
global totalTreat  "A_HOMICIDE_week_after1 A_HOMICIDE_week_after2 A_HOMICIDE_week_after3 A_HOMICIDE_week_after4"
global clusterlevel  "vce( cluster stat_id )"
global note "Nothing"
*global time "keep if year>2008"
global time ""
/*
*Time Heterogenaity 
global fileoutname "Station_Treatment_Time_Het.xml"
global totalTreat  "c.S_violent_week_L2B#i.time_dum c.S_violent_week_L3_L6#i.time_dum c.S_violent_week_L7_L10#i.time_dum"
global clusterlevel  "vce( cluster stat_id )"
global note "Nothing"

*/


$main_reg
$time 
*initialize 
reg   rides_numb_sum
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  


areg rides_numb_sum  ${totalTreat}  i.stationFE $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreat}) ctitle("Main- Main") addtext( WeekFE, "X", StationFE, "X", note, "${note}" )
sleep 2000
areg rides_numb_sum  ${totalTreat} i.stationFE $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreat}) ctitle(" Main -LbyW") addtext( lineByWeekFE, "X", StationFE, "X", note, "${note}") 
sleep 2000  

$Line_reg
$time 
areg rides_numb_sum  ${totalTreat}  i.linetypeFE $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Line -Main") 
sleep 2000
 

$Nearest_reg
$time 
areg rides_numb_sum  ${totalTreat}  i.stationFE $demograph, absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Nearest-Main") addtext( WeekFE, "X", StationFE, "X", note, "${note}" )
sleep 2000
areg rides_numb_sum  ${totalTreat} i.stationFE $demograph, absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Nearest-LbyW") addtext( lineByWeekFE, "X", StationFE, "X", note, "${note}") 
sleep 2000  


$Taxi_reg
$time 
areg taxi_pickups  ${totalTreat}  i.stationFE  $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Taxi") addtext( WeekFE, "X", StationFE, "X",  note, "${note}" )
sleep 2000
areg taxi_pickups ${totalTreat} i.stationFE $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Taxi-LbyW") addtext( lineByWeekFE, "X", StationFE, "X", note, "${note}") 
sleep 2000  

$Hourly_reg
$time 
areg week_entries_late  ${totalTreat}  rides_numb_sum i.stationFE  $demograph , absorb(yearmonthFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Hourly") addtext( WeekFE, "X", StationFE, "X",Control Ridership, "X", note, "${note}" )
sleep 2000
areg week_entries_late  ${totalTreat}  rides_numb_sum i.stationFE $demograph  , absorb(lineBymonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat}) ctitle("Hourly-LbyW") addtext( lineByWeekFE, "X", StationFE, "X", Control Ridership, "X", note, "${note}") 
sleep 2000  













***********************************
*Weekend 



************************************************************************
