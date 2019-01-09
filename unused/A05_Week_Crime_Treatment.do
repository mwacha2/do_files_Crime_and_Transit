/*
Creating data set for week. 
*/


use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"

keep $keep_vars $interesting_vars //defined in library 


merge m:1 datem using "${working}\weather.dta" 
drop if _merge ==2
drop _merge 



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
replace rides_numb ==. if rides_numb==0 

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


******
sort stat_id week 
tsset stat_id week //set as panel data with time structure 

*global list1 just limits the data to crimes I care about. 
global list1 "  A_CRIM_SEX_ASLT_week A_HOMICIDE_week O_firearm_week A_firearm_week S_firearm_week S_violent_week S_property_week S_qual_life_week O_violent_week O_property_week O_qual_life_week A_violent_week A_property_week A_qual_life_week"
foreach crime in $list1 {
local crimename =subinstr("`crime'","_week","",.)

di "`crimename'"
sort stat_id week

**Treatments
 
*dont need now 
forvalues i=1(1)8 {
gen `crimename'_week_before`i' = f`i'.`crimename'_week
gen `crimename'_week_after`i' =  l`i'.`crimename'_week 
}

forvalues j2 = 2(2)12{
local j1 = `j2'-1
gen `crimename'_week_after`j1'_`j2' =  0
gen `crimename'_week_before`j1'_`j2' =  0
forvalues i= `j1'(1)`j2' {
replace `crimename'_week_after`j1'_`j2' =l`i'.`crimename'_week + `crimename'_week_after`j1'_`j2'
replace  `crimename'_week_before`j1'_`j2'  =f`i'.`crimename'_week + `crimename'_week_before`j1'_`j2'
}
label var  `crimename'_week_after`j1'_`j2' "After`j1'-`j2' a `crimename'"  
label var  `crimename'_week_before`j1'_`j2' "Before`j1'-`j2' a `crimename'"

}
}

*lagged outcome for testing some lagged models 
foreach outcome in  rides_numb_sum rides_numb_wkend rides_numb_wkendFr rides_numb_mean bad_flag {
gen `outcome'_L1 = l1.`outcome'
gen `outcome'_L2 = l2.`outcome'
gen `outcome'_L3 = l3.`outcome'
gen `outcome'_L4 = l4.`outcome'

gen `outcome'_L26 = l26.`outcome'
gen `outcome'_L52 = l52.`outcome'

*gen `outcome'_F1 = f1.`outcome'
*gen `outcome'_F2 = f2.`outcome'
gen `outcome'_F3 = f3.`outcome'
gen `outcome'_F4 = f4.`outcome'
gen `outcome'_F52 = f52.`outcome'
gen `outcome'_F26 = f26.`outcome'

}


ds *_week*
foreach var in  `r(varlist)' {
replace `var' = 1 if `var'>0  
}

*math is bad and also how does it match with multiple crime treatments. 
gen temp_indicator =0 
global list1 "  A_CRIM_SEX_ASLT_week A_HOMICIDE_week O_firearm_week A_firearm_week S_firearm_week S_violent_week S_property_week S_qual_life_week O_violent_week O_property_week O_qual_life_week A_violent_week A_property_week A_qual_life_week"
foreach crime in $list1 {
local crimename =subinstr("`crime'","_week","",.)

di "`crimename'"
sort stat_id week

gen `crimename'_week_a7decay= 0 
local L =27 //decay time period 
forvalues i=7(1)`L' {
replace temp_indicator = 1 if l`i'.`crimename'_week>=1 
local j= `L'-`i'+7
replace `crimename'_week_a7decay =  l`i'.`crimename'_week*(`j'/(`L'))  if temp_indicator>=1
replace temp_indicator= 0
}
gen  `crimename'_week_a7decay2 = `crimename'_week_a7decay*`crimename'_week_a7decay
}


save  "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", replace

*use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
