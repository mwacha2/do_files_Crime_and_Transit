/*
Creating data set for week. 
*/


run "${main}\do_files\Random_crime_generate.do"

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"

keep $keep_vars $interesting_vars //defined in library 


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

*creates week indicatore starts monday ends Sunday 
gen week = cond(dow(datem) == 0, datem - 6, datem - dow(datem) + 1)
gen week_unscaled = week 
sum week, d
replace week = week -`r(min)'
replace week = round(week/7, 1)
*
egen weekFE = group(week)


preserve
*creates reference dataset for weeks 
keep week week_unscaled  datem 
duplicates drop  datem, force 
save  "${clean}\Week_reference.dta" ,replace 
restore 

*Bad flag indicator of days that had zero entries. 
gen bad_flag = 1 if rides_numb==0
replace bad_flag=0 if bad_flag==.
*replace rides_numb =. if rides_numb==0 

*should be same since denominator is the same 
gen rides_numb_mean = rides_numb // used later in collapse 
gen rides_numb_sum = rides_numb

*creates weekend indicator to count weekend ridership
sort stat_id datem day_of_week  weekFE
gen weekend = 1 if day_of_week ==0 | day_of_week ==6 // sunday satruday 
gen weekendFr = 1 if day_of_week ==0 | day_of_week ==6 | day_of_week ==5 // sunday satruday and friday
*
sort stat_id week weekend 
by  stat_id week weekend : egen rides_numb_wkend =  sum (rides_numb)
replace  rides_numb_wkend = . if weekend==. 
*
sort stat_id week weekendFr 
by  stat_id week weekendFr : egen rides_numb_wkendFr =  sum (rides_numb)
replace  rides_numb_wkendFr = . if weekend==. 



sort stat_id week
collapse (first) week_unscaled   longname weekFE year month line_type stationname ///
 (max) rides_numb_wkend rides_numb_wkendFr (sum) *_count*  prcp  rides_numb_sum ///
 (mean) bad_flag  imput_avg_temp rides_numb_mean , by( stat_id week)

rename *_count *_week 

save "${working}\Week_Level_Crime.dta", replace 

