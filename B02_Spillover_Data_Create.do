


/*
runs regression analysis at the week level. 
This file can be augmented to run for weekend and low crime rates
Simpler to understand less resuts 
*/
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"

merge m:1 year stat_id using "${working}\demographic_info.dta"
****************
drop if _merge ==2
rename _merge mergedemo

set matsize 2000
drop if year>=2016
*figure out why this is 
drop if rides_numb_sum ==0 
drop if bad_flag>0
drop if year<2005 & line_type=="Pink"
*drop if rides_numb_sum <200
*keep $keep_vars $interesting_vars
drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"

*drop if rides_numb_sum <200
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



****************
merge 1:1 week stat_id using  "${working}\spillover_treatment.dta" 


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
egen CrimeByweekFE = group(weekFE xm_crime_tile)

egen lineByYear = group(line_type year)
egen lineByTime = group( line_type time_dum)
egen stationByTime = group(stationFE time_dum)





save "${clean}\CTA_Crime_Final_Nearest.dta", replace 

*****************************************





use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"
merge m:1 year stat_id using "${working}\demographic_info.dta"
****************
drop if _merge ==2
rename _merge mergedemo


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
collapse (first) year  weekFE month time_dum  (mean) rides_numb_wkend rides_numb_wkendFr rides_numb_sum rides_numb_mean ///
 imput_avg_temp hinc  pov_rate mrent mhmval multi crime_age white_hh hispanic_hh black_hh  fem_lab_force unemploy_rate population poverty_int_flabor ///
  (sum) *_week* ,by (line_type week)
  
  
  save "${clean}\CTA_Crime_Final_w_Line_WEEK.dta", replace 
