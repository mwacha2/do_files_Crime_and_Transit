
use "${working}\Daily_Level_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
set matsize 2000

xtile xm_inc_tile= hinc,  n(4)

drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"
drop if line_type=="Center"
drop if year>=2016


	
egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen stationBYmonthFE = group(stat_id month)
gen yeartrend = year-2000
egen statDayofWeek = group(stat_id day_of_week)


egen DayFE = group(datem)
egen lineByDayFE = group(line_type datem)
egen IncByDayFE = group(xm_inc_tile datem)
egen distanceDayFE = group(center_ref datem)

gen  ln_rides_numb = ln( rides_numb)
gen  ln_rides_numb_wkend = ln( rides_numb) if inlist(day_of_week, 6, 0)


global controls1 " S_property_d_count S_property_d_after2 S_property_d_after3 S_property_d_after4 S_property_d_after5 S_property_d_after6 S_property_d_after7     "
global controls2 " O_property_d_count O_property_d_after2 O_property_d_after3 O_property_d_after4 O_property_d_after5 O_property_d_after6 O_property_d_after7     "

global controls3 " S_qual_life_d_count S_qual_life_d_after2 S_qual_life_d_after3 S_qual_life_d_after4 S_qual_life_d_after5 S_qual_life_d_after6 S_qual_life_d_after7     "
global controls4 " O_qual_life_d_count O_qual_life_d_after2 O_qual_life_d_after3 O_qual_life_d_after4 O_qual_life_d_after5 O_qual_life_d_after6 O_qual_life_d_after7     "

global controls5 " S_SimpleCrime_d_count S_SimpleCrime_d_after2 S_SimpleCrime_d_after3 S_SimpleCrime_d_after4 S_SimpleCrime_d_after5 S_SimpleCrime_d_after6 S_SimpleCrime_d_after7     "
global controls6 " O_SimpleCrime_d_count O_SimpleCrime_d_after2 O_SimpleCrime_d_after3 O_SimpleCrime_d_after4 O_SimpleCrime_d_after5 O_SimpleCrime_d_after6 O_SimpleCrime_d_after7     "


global controls " $controls1 $controls2 $controls3 $controls4 $controls5 $controls6 "  
*

*global other_control " i.stationFE#c.year i.stationFE#c.year#c.year "
global other_control " i.day_of_week  i.stationFE#c.year i.stationFE#c.year#c.year  " 
*i.statDayofWeek
   

areg ln_rides_numb  $controls  $other_control i.stationFE $demograph  , absorb(DayFE)   
predict  res_main_week, residuals

areg ln_rides_numb  $controls $other_control i.stationFE  $demograph , absorb(lineByDayFE) 
predict  res_line_week, residuals

areg ln_rides_numb $controls $other_control  i.stationFE  $demograph , absorb(IncByDayFE) 
predict  res_inc_week, residuals

areg ln_rides_numb $controls  $other_control i.stationFE  $demograph , absorb(distanceDayFE ) 
predict  res_dist_week, residuals

*********************************
/*

reg ln_rides_numb $controls   i.stationFE#c.imput_avg_temp i.stationFE#i.year  $demograph 
predict  res_other_week, residuals
 
areg ln_rides_numb_wkend  $controls $other_control  i.stationFE $demograph  , absorb(DayFE)   
predict  res_main_wkend , residuals

areg ln_rides_numb_wkend $controls $other_control  i.stationFE  $demograph , absorb(lineByDayFE) 
predict  res_line_wkend , residuals

areg ln_rides_numb_wkend  $controls $other_control i.stationFE  $demograph , absorb(IncByDayFE) 
predict  res_inc_wkend , residuals

areg ln_rides_numb_wkend  $controls $other_control i.stationFE  $demograph , absorb(distanceDayFE ) 
predict  res_dist_wkend , residuals
 */

 
cap drop *_d_aftersum
cap drop *_d_beforesum
cap drop *_ever_c
cap drop *_olap
cap drop *_tdrop 

 
foreach var in  A_CRIM_SEX_ASLT_d SS_violent_d SD_violent_d SD_firearm_d D_HOMICIDE_d {
global crime `var'
 sort stat_id datem 
replace ${crime}_count=0 if ${crime}_count==.
replace ${crime}_count=1 if ${crime}_count>0

forvalues v=1(1)15 { //Change to indicator variables 
replace  ${crime}_before`v' =  0 if  ${crime}_before`v' ==.
replace ${crime}_after`v' = 0 if ${crime}_after`v' ==.

replace  ${crime}_before`v' =  1 if  ${crime}_before`v' >0
replace ${crime}_after`v' = 1 if ${crime}_after`v' >0
}

global sumafter " " // create sum to tell me if another crime event happened there 
global sumbefore " "
 
forvalues v=1(1)15 {
global sumafter " $sumafter  ${crime}_after`v' "
global sumbefore " $sumbefore  ${crime}_before`v' "
}
di "right before sum $sumafter"
egen ${crime}_aftersum = rowtotal(  $sumafter )
egen ${crime}_beforesum = rowtotal(  $sumbefore )
egen ${crime}_ever_c = rowtotal(  $sumafter $sumbefore ${crime}_count   )


*******creates indicator if overlaping crime
gen ${crime}_olap = 0 
replace  ${crime}_olap= 1 if ${crime}_ever_c >1 & ${crime}_count>0
label var ${crime}_olap "indicator in overlappign crimes"

gen ${crime}_tdrop = ${crime}_olap
forvalues v=1(1)15 {
replace ${crime}_tdrop = l`v'.${crime}_olap if l`v'.${crime}_olap>0 
replace ${crime}_tdrop = f`v'.${crime}_olap if f`v'.${crime}_olap>0
}
replace ${crime}_tdrop =0 if ${crime}_tdrop==. 
label var ${crime}_tdrop "indicator in overlapping crimes periods "
}

 
save "${working}\Daily_Residuals_Crime.dta", replace

 
