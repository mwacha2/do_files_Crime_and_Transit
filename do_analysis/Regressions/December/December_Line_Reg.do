/*
runs regression analysis at the week level. 
The goal is to check for spillovers 
*/

use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\December\"
set matsize 2000
drop if year>=2016
*figure out why this is 
drop if rides_numb_sum ==0 
drop if bad_flag>0
drop if year<2005 & line_type=="Pink"
*drop if rides_numb_sum <200
*keep $keep_vars $interesting_vars

/*
merge 1:1 stat_id datem using "${clean}\CTA_Week_Indicator.dta", 
drop _merge 
*/


gen time_dum = 1 if year<2006
replace time_dum = 2 if  year>=2006 & year< 2011
replace time_dum =3 if year>=2011  & year<= 2016
count if time_dum==.


sort stat_id time_dum 

by stat_id time_dum :egen mean_crime = mean( A_violent_week)
by stat_id time_dum :egen mean_riders = mean( rides_numb_mean)
gen percap = mean_crime/ mean_riders
xtile xm_crime = percap if time_dum ==2, n(4)
sort stat_id
by stat_id: egen  xm_crime_tile = max( xm_crime)


sort line_type week
collapse (first) year weekOFyear weekFE month time_dum  (mean) rides_numb_wkend rides_numb_wkendFr rides_numb_sum rides_numb_mean ///
  (sum) *_week* ,by (line_type week)
  
  
  save "${clean}\CTA_Crime_Final_w_Line_WEEK.dta", replace 
  
  *****************************************************************
  *****************************************************************
  
  
  
use "${clean}\CTA_Crime_Final_w_Line_WEEK.dta" , clear
  
egen linetypeFE = group(line_type)
global weather ""
  
  
global fileoutname "MainResultsLine.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster linetypeFE )"
*global clusterlevel "robust"
global title "Station Crime and Ridership, Main Line"


global totalTreat0  "S_violent_week_L1"
global totalTreat1  "S_firearm_week_L1"
global totalTreat2  "S_violent_week_L1 O_violent_week_L1"
global totalTreat3  "S_firearm_week_L1 O_firearm_week_L1"
global totalTreat4  "S_violent_week_L1 O_violent_week_L1 S_property_week_L1 O_property_week_L1 S_qual_life_week_L1 O_qual_life_week_L1"
*global weather "imput_avg_temp prcp " 
  
  
  
  reg   $dependent A_qual_life_week
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  

foreach i in 0 1 2 3 4 {
areg $dependent  ${totalTreat`i'} $weather i.linetypeFE, absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`i'}) ctitle("MAIN ")
sleep 2000

areg $dependent  ${totalTreat`i'} $weather i.linetypeFE#i.time_dum, absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`i'}) ctitle("MAIN ")
sleep 2000
  
  }
 