
*tools to create treatment 

*********
*create indicator 

ds *_week*
foreach var in  `r(varlist)' {
replace `var' = 1 if `var'>0  
}


*************
*Create Treatment 


global Treatment "" 
foreach var in  SS_violent_wkOV    {
local before " "
local after  " "

forvalues j2 = 2(2)6{
local j1 = `j2'-1
local before " `var'_before`j1'_`j2' `before' "
local after " `after' `var'_after`j1'_`j2' "
}

global Treatment " $Treatment `before' `var' `after' `var'_a7decay `var'_wkOV_a7decay2 " 
}

di "$Treatment"

global Treatment "" 
foreach var in  S_violent_week   {
local before " "
local after  " "

forvalues j2 = 2(2)10{
local j1 = `j2'-1
local before " i.`var'_before`j1'_`j2'#i.time_dum `before' "
local after " `after' i.`var'_after`j1'_`j2'#i.time_dum "
}

global Treatment " $Treatment `before' `var' `after' " 
}
di "$Treatment"



