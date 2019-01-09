
*Creating Counts 


local list1  S_violent_week  D_violent_week SS_violent_week SD_violent_week 
local list2  S_property_week  D_property_week SS_property_week SD_property_week 
local list3  S_firearm_week  D_firearm_week SS_firearm_week SD_firearm_week 
local list4  A_HOMICIDE_week D_HOMICIDE_week

global list_all " `list1' `list2' `list3' `list4' "


clear 
set obs 40
gen id =_n
gen crime = "                     " 
gen time1 =  .
gen time2 = . 
gen time3 = . 

di "$list_all"
local i = 1
foreach var in $list_all{
di  "`var'"
replace crime = "`var'" if id==`i'  
local i =`i'+1
di  "`i'"
}
replace crime = "Count" if id==`i' 
save "${working}\counts.dta", replace 


use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"
drop if line_type=="Center"

foreach value in 1 2 3 {
foreach var in $list_all {
count if `var'>0 & time_dum==`value'
global `var'_g`value' = `r(N)'
 
}
}


use "${working}\counts.dta", clear 
foreach value in 1 2 3 {
foreach var in $list_all {
replace time`value' = ${`var'_g`value'} if crime =="`var'"
}
}


save "${working}\counts.dta", replace 

