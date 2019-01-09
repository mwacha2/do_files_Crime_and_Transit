

use "${clean}\Regression\Main_Regression_Data.dta", clear 


global outputfile1 "${analysis}\Paper\Regressions\Just_Station\"

global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global totalTreat  " S_violent_week_before5_6  S_violent_week_before3_4  S_violent_week_before1_2  S_violent_week  S_violent_week_after1_2  S_violent_week_after3_4  S_violent_week_after5_6 "
global title "Station Crime and Ridership, Other Robust"
*global totalTreat " A_HOMICIDE_week_before5_6  A_HOMICIDE_week_before3_4  A_HOMICIDE_week_before1_2  A_HOMICIDE_week      A_HOMICIDE_week_after1_2  A_HOMICIDE_week_after3_4  A_HOMICIDE_week_after5_6 "
global fileoutname "Testing_Stat_Viol2.xml"
*global fileoutname "Testing_Stat_Viol.xml"

reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
areg $dependent  $totalTreat $weather i.stationFE $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN ") addtext( WeekFE, "X", StationFE, "X")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE  $demograph , absorb(clusterWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Cluster 1") addtext( lineByWeekFE, "X", StationFE, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE  $demograph , absorb(clusterWeek2FE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("cluster 2 ") addtext( lineByWeekFE, "X", StationFE, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE  $demograph , absorb(distanceWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("distance") addtext( lineByWeekFE, "X", StationFE, "X") 
sleep 2000  


areg $dependent  $totalTreat $weather  i.yearmonthFE  $demograph , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH") addtext( yearmonthFE, "X", Station by Month FE , "X")
sleep 2000
 
 
 
 
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear 
replace rides_numb_wkend =. if rides_numb_wkend<10
replace rides_numb_sum =. if rides_numb_sum<10
drop if inlist(line_type,"Center",)
drop if 
drop if year<2008 & line_type=="Brown"
drop if year<2005 & line_type=="Pink"


collapse (first) $demograph_int stationname (sum) *week (mean) rides_numb_wkend  rides_numb_sum, by(year stat_id)


sort year 
tsset stat_id  year 

gen A_HOMICIDE_year_lag = l1.A_HOMICIDE_week
gen  S_violent_year_lag = l1.S_violent_week
gen  S_property_year_lag = l1.S_property_week
gen  O_violent_year_lag = l1.O_violent_week

reg rides_numb_sum  A_HOMICIDE_year_lag O_violent_year_lag S_property_year_lag  S_violent_year_lag  i.year 

areg rides_numb_sum   A_HOMICIDE_year_lag O_violent_year_lag S_property_year_lag  S_violent_year_lag  i.year if year <2011 ,absorb( stat_id)
