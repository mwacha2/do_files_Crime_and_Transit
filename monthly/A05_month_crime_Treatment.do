/*
Creating data set for week. 
*/


run "${main}\do_files\Random_crime_generate.do"

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"

keep $keep_vars $interesting_vars //defined in library 

gen modate = ym(year, month) 
format %tm  modate


merge m:1 datem using "${working}\weather.dta" 
drop if _merge ==2
drop _merge 


merge 1:1 datem  stat_id using "${working}\random_crime.dta"
drop if _merge ==2
drop _merge 

ds *_count, 
foreach var in `r(varlist)'{
replace `var' =0 if `var'==.  
}





*Bad flag indicator of days that had zero entries. 
gen bad_flag = 1 if rides_numb==0
replace bad_flag=0 if bad_flag==.
*replace rides_numb =. if rides_numb==0 

*should be same since denominator is the same 
gen rides_numb_mean = rides_numb // used later in collapse 
gen rides_numb_sum = rides_numb


sort stat_id datem day_of_week  
gen weekend = 1 if day_of_week ==0 | day_of_week ==6 // sunday satruday 
gen weekendFr = 1 if day_of_week ==0 | day_of_week ==6 | day_of_week ==5 // sunday satruday and friday
*
 gen rides_numb_wkend =  rides_numb if weekend==1
 



sort stat_id modate
collapse (first)    longname  month year  line_type stationname ///
  (sum) *_count*  prcp  rides_numb_sum rides_numb_wkend ///
 (mean) bad_flag  imput_avg_temp rides_numb_mean , by( stat_id modate)

rename *_count *_month

save "${working}\Month_Level_Crime.dta", replace 

