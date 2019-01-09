/*
runs regression analysis at the week level. 
This file can be augmented to run for weekend and low crime rates

*/
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\New_Week\"
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

global set0 "  O_firearm  S_firearm"
global set1  "S_violentNSEX"
global set2 " $set1  O_violentNSEX "
global set3 "$set2 S_CRIM_SEXUAL_ASSAULT"
global set4 "$set3 O_CRIM_SEXUAL_ASSAULT"
global set5 "$set4 S_property"
global set6 "$set5 O_property"
global set7 "$set6 S_ASSAULTsimp S_BATTERYsimp"
global set8 "$set7 O_ASSAULTsimp O_BATTERYsimp"
global set9 "$set8 S_qual_life O_qual_life"

global dependent "rides_numb_sum"


global conditionA "year<2007 "
global conditionB "year>2006 & year< 2012"
global conditionC "year>2011  "
global conditionD "year<2017"

global nameA "2006"
global nameB "2011"
global nameC "2015"
global nameD "All"


*
foreach let in "A" "B" "C" "D" {

preserve 

keep if  ${condition`let'}

*global fileoutname "Prelim_Reg_week_${name`let'}.xml"

global fileoutname "Prelim_Reg_week_LOW${name`let'}.xml"
drop  if low_crime == 0 


global totalTreat S_violentNSEX_week
reg   $dependent $totalTreat
outreg2 using "${outputfile1}\${fileoutname}" , title("CTA Ridership and Crime,Weekly${name`let'}")   replace  slow(1000) 
  

  
foreach case in 0 1 2 3 4 5 6 7 8 9 {

TreatCreateWeek "${set`case'}"
 
 /*
areg $dependent  $totalTreat , absorb(stationFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat) ctitle("NAIVE_Stat")  addtext( WeekFE, "X", Set , "`case'")   slow(1000)
  
areg $dependent  $totalTreat , absorb(weekFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat) ctitle("NAIVE Week")  addtext( WeekFE, "X", Set , "`case'")   slow(1000)
 */
 
 
areg $dependent  $totalTreat i.stationFE, absorb(weekFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN") addtext( WeekFE, "X", StationFE, "X", Set , "`case'")
sleep 2000

areg $dependent  $totalTreat i.stationFE  , absorb(lineByWeekFE)  robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", StationFE, "X", Set , "`case'") 
sleep 2000  
  
areg $dependent  $totalTreat  i.yearmonthFE , absorb( stationBYmonthFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH") addtext( yearmonthFE, "X", Station by Month FE , "X",  Set , "`case'")
sleep 2000

areg $dependent  $totalTreat i.stationFE#c.yeartrend i.stationFE#c.yeartrend2 , absorb(weekFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Stat_Trend") addtext( WeekFE, "X", StationFE Quadratic, "X", Set , "`case'")
 sleep 2000
}  

restore 


}



