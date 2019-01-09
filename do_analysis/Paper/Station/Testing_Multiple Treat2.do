

global outputfile1 "${analysis}\Paper\Regressions\Just_Station\"
set matsize 2000

*global variables to get datasets 
global main_reg "use `"${clean}\Regression\Main_Regression_Data.dta"' ,clear"

$main_reg

gen ln_rides_numb_wkend = ln(rides_numb_wkend)



global fileoutname "Main_Stat_Viol.xml"
global dependent "ln_rides_numb_wkend"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global title "Station Crime and Ridership, Diff_Treat"
*global weather "imput_avg_temp prcp " 
**


*Daltime Homicide 
*SD violent crime 
*SD firearm crime 


global totalTreat  " S_violent_week_before5_6  S_violent_week_before3_4  S_violent_week_before1_2  S_violent_week  S_violent_week_after1_2  S_violent_week_after3_4  S_violent_week_after5_6 S_violent_week_a7decay S_violent_week_a7decay2 "


global totalTreat1 "D_HOMICIDE_wkOV_before5_6  D_HOMICIDE_wkOV_before3_4  D_HOMICIDE_wkOV_before1_2    D_HOMICIDE_wkOV      D_HOMICIDE_wkOV_after1_2  D_HOMICIDE_wkOV_after3_4  D_HOMICIDE_wkOV_after5_6  D_HOMICIDE_wkOV_a7decay D_HOMICIDE_wkOV_a7decay2"
global totalTreat2 "SD_violent_wkOV_before5_6  SD_violent_wkOV_before3_4  SD_violent_wkOV_before1_2      SD_violent_wkOV      SD_violent_wkOV_after1_2  SD_violent_wkOV_after3_4  SD_violent_wkOV_after5_6  SD_violent_wkOV_a7decay SD_violent_wkOV_wkOV_a7decay2" 
global totalTreat3 "SD_firearm_wkOV_before5_6  SD_firearm_wkOV_before3_4  SD_firearm_wkOV_before1_2      SD_firearm_wkOV      SD_firearm_wkOV_after1_2  SD_firearm_wkOV_after3_4  SD_firearm_wkOV_after5_6  SD_firearm_wkOV_a7decay SD_firearm_wkOV_wkOV_a7decay2 " 
global totalTreat4 "SS_violent_wkOV_before5_6  SS_violent_wkOV_before3_4  SS_violent_wkOV_before1_2      SS_violent_wkOV      SS_violent_wkOV_after1_2  SS_violent_wkOV_after3_4  SS_violent_wkOV_after5_6  SS_violent_wkOV_a7decay SS_violent_wkOV_wkOV_a7decay2 " 




reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
  
foreach i in 1 2 3 4 5 6 7  8 {  

global totalTreat " ${totalTreat`i'}"
  
areg $dependent  $totalTreat $weather i.stationFE $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN `i'") addtext( WeekFE, "X", StationFE, "X")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE  $demograph , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week `i'") addtext( lineByWeekFE, "X", StationFE, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather  i.yearmonthFE  $demograph , absorb( stationBYmonthFE)
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH `i'") addtext( yearmonthFE, "X", StationbyMonth FE , "X")
sleep 2000

}
