/*
runs regression analysis at the week level. 
This file can be augmented to run for weekend and low crime rates
Simpler to understand less resuts 
*/
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\Simple\"
set matsize 2000

*keep $keep_vars $interesting_vars

/*
merge 1:1 stat_id datem using "${clean}\CTA_Week_Indicator.dta", 
drop _merge 
*/


**************
*regression 
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


global set1  "S_violent"
global set2 " $set1  O_violent "
global set3 "$set2 S_property"
global set4 "$set3 O_property"
global set5 "$set4 S_qual_life O_qual_life"




global conditionA "year<2006 "
global conditionB "year>2005 & year< 2011"
global conditionC "year>2010  "
global conditionD "year<2017"

global nameA "2005"
global nameB "2010"
global nameC "2015"
global nameD "All"


global weather " i.linetypeFE#c.imput_avg_temp i.linetypeFE#c.prcp"

***Change model*****************
***Week entire data set 
*global fileoutname "Prelim_Reg_week.xml"
*global dependent "rides_numb_sum"
**

**Week low crime areas 
*global fileoutname "Prelim_Reg_week_LOW.xml"
*drop  if low_crime == 0 
*global dependent "rides_numb_sum"
**

***Weekend  entire data set 
global fileoutname "Prelim_Reg_weekendFri.xml"
global dependent "rides_numb_wkendFr"
**




global totalTreat S_violentNSEX_week
reg   $dependent $totalTreat
outreg2 using "${outputfile1}\${fileoutname}" , title("CTA Ridership and Crime,Weekly")   replace  slow(1000) 
  

  
foreach case in   2  4 5 {

TreatCreateWeek "${set`case'}"
 
foreach let in "A" "B" "C" "D" {

 
areg $dependent  $totalTreat $weather i.stationFE if  ${condition`let'} , absorb(weekFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN ${name`let'}") addtext( WeekFE, "X", StationFE, "X", Set , "`case'", weather, "X")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE  if  ${condition`let'} , absorb(lineByWeekFE)  robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week ${name`let'}") addtext( lineByWeekFE, "X", StationFE, "X", Set , "`case'", weather, "X") 
sleep 2000  
  
areg $dependent  $totalTreat $weather  i.yearmonthFE if  ${condition`let'} , absorb( stationBYmonthFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH ${name`let'}") addtext( yearmonthFE, "X", Station by Month FE , "X",  Set , "`case'", weather, "X")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE#c.yeartrend i.stationFE#c.yeartrend2 if  ${condition`let'} , absorb(weekFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Stat_Trend ${name`let'}") addtext( WeekFE, "X", StationFE Quadratic, "X", Set , "`case'", weather, "X")
 sleep 2000
}  




}



