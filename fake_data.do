clear
set obs 50 
gen week = _n 
/* 
expand 2 
sort week 
gen stat_id = mod(_n,2)
*/
gen stat_id =1 
gen  O_firearm_week = 0
replace O_firearm_week =1 if week==15 & stat_id==1 
replace O_firearm_week =1 if week==30 & stat_id==1 

sort stat_id week
tset stat_id week 

global list1 "O_firearm_week"

/*
*ok this works the way I want it to. but too messy. just do regular no loops.
*************just pre variable now 
cap drop temp_var3
cap drop temp_var
cap drop *_week_after*
cap drop *_week_before* 
foreach crime in $list1 {
local crimename =subinstr("`crime'","_week","",.)

gen temp_var3 = 0 
forvalues i= 1(1)6{ // no other post treatment turned on 
 replace temp_var3 = l`i'.`crimename'_week+temp_var3
 }

forvalues j2 = 2(2)6{
local j1 = `j2'-1
gen temp_var = 0 
 local f = `j1'-1
forvalues i= 1(1)`f'{ // no other post treatment turned on 
 replace temp_var = f`i'.`crimename'_week+temp_var
 }

*gen `crimename'_week_after`j1'_`j2' =  0
gen `crimename'_week_before`j1'_`j2' =  0
forvalues i= `j1'(1)`j2' {
*replace `crimename'_week_after`j1'_`j2' =l`i'.`crimename'_week + `crimename'_week_after`j1'_`j2' if temp_var==0
replace  `crimename'_week_before`j1'_`j2'  =f`i'.`crimename'_week + `crimename'_week_before`j1'_`j2' if temp_var==0 & `crimename'_week ==0 & temp_var3==0 
}
drop temp_var 

*label var  `crimename'_week_after`j1'_`j2' "After`j1'-`j2' a `crimename'"  
label var  `crimename'_week_before`j1'_`j2' "Before`j1'-`j2' a `crimename'"
}
drop temp_var3
}









**************Post variable works 
cap drop temp_var
cap drop *_week_after*
cap drop *_week_before* 
foreach crime in $list1 {
local crimename =subinstr("`crime'","_week","",.)

forvalues j2 = 2(2)6{
local j1 = `j2'-1
gen temp_var = 0 
 local f = `j1'-1
forvalues i= 1(1)`f'{ // no other post treatment turned on 
 replace temp_var = l`i'.`crimename'_week+temp_var
 }

gen `crimename'_week_after`j1'_`j2' =  0
*gen `crimename'_week_before`j1'_`j2' =  0
forvalues i= `j1'(1)`j2' {
replace `crimename'_week_after`j1'_`j2' =l`i'.`crimename'_week + `crimename'_week_after`j1'_`j2' if temp_var==0 & `crimename'_week ==0
*replace  `crimename'_week_before`j1'_`j2'  =f`i'.`crimename'_week + `crimename'_week_before`j1'_`j2'
}
drop temp_var 
label var  `crimename'_week_after`j1'_`j2' "After`j1'-`j2' a `crimename'"  
*label var  `crimename'_week_before`j1'_`j2' "Before`j1'-`j2' a `crimename'"
}
}



*********************************
*decay rate 
cap drop *a7decay*
cap drop  temp_var
foreach crime in $list1 {
local crimename =subinstr("`crime'","_week","",.)

di "`crimename'"
sort stat_id week

gen `crimename'_week_a7decay= 0 
local L =27 //decay time period end  
local l = 7 // decay time period begin 

gen temp_var = 0 
 local f = `l'-1
forvalues i= 1(1)`f'{ // no other post treatment turned on 
 replace temp_var = l`i'.`crimename'_week+temp_var
sum temp_var
 }

forvalues i= `L'(-1)`l'{
local j= `L'-`i'
replace `crimename'_week_a7decay =  l`i'.`crimename'_week*(`j'/(`L'- `l'))  if l`i'.`crimename'_week>=1 & temp_var==0
di "(`L'- `l')"
}
replace `crimename'_week_a7decay=0 if `crimename'_week_a7decay==. 
drop temp_var
gen  `crimename'_week_a7decay2 = `crimename'_week_a7decay*`crimename'_week_a7decay
}

****************************

ds *week*,
foreach var in `r(varlist)'{
replace `var' =0 if `var' ==.
}

export excel using "C:\Users\MAC\Dropbox\Fall2017research\CTA_Crime\analysis\Print_ost.xls", replace firstrow(variables)




/*

gen temp_indicator =0 


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
*/
*/
