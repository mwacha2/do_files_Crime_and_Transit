/*
runs regression analysis at the week level. 
This file can be augmented to run for weekend and low crime rates
Simpler to understand less resuts 
*/
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

global outputfile1 "${analysis}\Paper\Regressions\JanuaryReg\"
set matsize 2000

drop if line_type =="Center"


**************
*FIXED EFFECTS USED  
***************

egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen lineByMonthFE = group( line_type year  month)
egen stationBYmonthFE = group(stat_id month)
egen monthFE = group(month)
egen lineByWeekFE = group( line_type weekFE) 
gen yeartrend = year-2000
gen yeartrend2 =  yeartrend*yeartrend
egen yearmonthFE = group(year month)
egen CrimeByweekFE = group(weekFE xm_crime_tile)

egen lineByYear = group(line_type year)
egen lineByTime = group( line_type time_dum)
egen stationByTime = group(stationFE time_dum)



*global weather " i.linetypeFE#c.imput_avg_temp i.linetypeFE#c.prcp"
global weather " " 



**********************************
*Regression Tables Full
**********************************
** "G"
foreach block in "A" "B"  {


if "`block'"=="A" {
di "Block `block' running " 
***Week entire data set 
global fileoutname "Main_Stat_Viol.xml"
global dependent "rides_numb_sum"
*global clusterlevel "vce( cluster stat_id )"
global clusterlevel "robust"
global totalTreat  "S_violent_week_L2B"
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
global totalTreat  "S_violent_week_L2B O_violent_week_L2B"
global title "Station Crime and Ridership, Main with OutsideCrime"
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

*
areg $dependent  $totalTreat $weather  i.stationFE i.lineByTime  $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_TIME") addtext( WeekFE, "X", StationFE, "X",LinebyTime ,"X")
sleep 2000


areg $dependent  $totalTreat $weather i.stationFE $demograph , absorb(CrimeByweekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Quint_By_Week") addtext( CrimeByweekFE, "X", StationFE, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE  i.stationFE#c.yeartrend  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Stat_Trend") addtext( WeekFE, "X", StationFE Trends, "X")
 sleep 2000 
 
areg $dependent  $totalTreat $weather  i.yearmonthFE  $demograph , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH") addtext( yearmonthFE, "X", Station by Month FE , "X")
sleep 2000


}


**********************************

*Regression Tables Main and Line_Type 

**********************************


global fileoutname "Main_StatOutside_Various.xml"
global clusterlevel "vce( cluster stat_id )"

global dependent  "rides_numb_sum"

global dependent1 "rides_numb_sum"
global totalTreat1  "S_violent_week_L2B S_property_week_L2B O_violent_week_L2B O_property_week_L2B"
global note1 "Station and Outside:Property and Violent Crime"

global dependent2 "rides_numb_sum"
global totalTreat2  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B"
global note2 "Station and Outside: Violent Crime w/ Time Heterogenaity"

global dependent3 "rides_numb_sum"
global totalTreat3  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note3 "Station and Outside: Violent and Property Crime w/ Time Heterogenaity"

global dependent4 "rides_numb_wkend"
global totalTreat4  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note4 "WeekendRidership with Station and Outside: Violent and Property Crime w/ Time Heterogenaity"

global dependent5 "rides_numb_wkend"
global totalTreat5  "i.time_dum#c.S_firearm_week i.time_dum#c.O_firearm_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note5 "WeekendRidership with Station and Outside: Violent and Property Crime w/ Time Heterogenaity"



reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
 
foreach x in 1 2 3 4 {  

areg ${dependent`x'}  ${totalTreat`x'}  i.stationFE  $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreat`x'}) ctitle("MAIN") addtext( WeekFE, "X", StationFE, "X", note, "${note`x'}" )
sleep 2000
 
areg ${dependent`x'}  ${totalTreat`x'} i.stationFE $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreat`x'}) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", StationFE, "X", note, "${note`x'}") 
sleep 2000  

}


/*
******************************
*LAGGED
******************************

global fileoutname "Lagged_StatOutside_Various.xml"
reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
 
foreach x in 1 2 3 4 5 {  

areg ${dependent`x'}  ${totalTreat`x'} rides_numb_sum_L3 rides_numb_sum_L52  $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("MAIN") addtext( WeekFE, "X", Lagged, "X", note, "${note`x'}" )
sleep 2000

areg ${dependent`x'}  ${totalTreat`x'}  rides_numb_sum_L3  rides_numb_sum_L52  $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", Lagged, "X", note, "${note`x'}") 
sleep 2000  

}

*replace rides_numb_sum_L3 = ln(rides_numb_sum_L3) 
*replace rides_numb_sum_L52 = ln( rides_numb_sum_L52)
*replace rides_numb_wkend = ln( rides_numb_wkend)

*/


