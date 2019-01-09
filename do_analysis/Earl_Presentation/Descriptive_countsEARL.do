
*Creating Counts 


local list1   SS_violent_week SD_violent_week 
local list2   SS_property_week SD_property_week 
local list3   SS_firearm_week   SD_firearm_week 
local list4   D_HOMICIDE_week

global list_all " `list1' `list2' `list3' `list4' count "

 
 ***********************************************
 *By Line 
 ************************************************
 
 
 
use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type=="Center"
drop if line_type==""

gen count =1 

collapse (mean) rides_numb_sum (sum) $list_all ,by(line_type)

foreach var in $list_all {
gen `var'_per = round(`var'/ count, 0.001)
}


export excel using "${main}\EARL\EARL_OUTPUT\Descriptive\Crime_Counts_Line.xls", firstrow(varlabels) replace



*********************************************************************
*By Time 
*********************************************************************

 
use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type=="Center"
drop if line_type==""

gen count =1 

collapse (mean) rides_numb_sum (sum) $list_all ,by(time_dum)

gen time_dum_name= "              " 
replace  time_dum_name = "2001-2005" if time_dum==1
replace  time_dum_name = "2006-2010" if time_dum==2
replace  time_dum_name = "2011-2015" if time_dum==3

foreach var in $list_all {
gen `var'_per = round(`var'/ count, 0.001)
}


export excel using "${main}\EARL\EARL_OUTPUT\Descriptive\Crime_Counts_time.xls", firstrow(varlabels) replace


*********************************************************************
*By Month
*********************************************************************

 
use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type=="Center"
drop if line_type==""

gen count =1 
collapse (mean) rides_numb_sum (sum) $list_all ,by(month)


foreach var in $list_all {
gen `var'_per = round(`var'/ count, 0.001)
}


export excel using "${main}\EARL\EARL_OUTPUT\Descriptive\Crime_Counts_month.xls", firstrow(varlabels) replace



*********************************************************************
*By Income
*********************************************************************

 
use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type=="Center"
drop if line_type==""

gen count =1 
collapse (mean) rides_numb_sum (sum) $list_all ,by(xm_inc_tile)


foreach var in $list_all {
gen `var'_per = round(`var'/ count, 0.001)
}


export excel using "${main}\EARL\EARL_OUTPUT\Descriptive\Crime_Counts_IncomeQuartile.xls", firstrow(varlabels) replace





















/*
clear 
set obs 40
gen id =_n
gen crime = "                     " 
gen time1 =  .
gen time2 = . 
gen time3 = . 
label var time1 "2001-2005"
label var time2 "2006-2010"
label var time3 "2011-2015"

gen Percent_time1 =  .
gen Percent_time2 = . 
gen Percent_time3 = . 




di "$list_all"
local i = 1
foreach var in $list_all{
di  "`var'"
replace crime = "`var'" if id==`i'  
local i =`i'+1
di  "`i'"
}
replace crime = "Ridership" if id==`i' 
save "${working}\counts.dta", replace 


use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"
drop if line_type=="Center"
gen count =1 

foreach value in 1 2 3 {
*global count`value' if  time_dum==`value'
foreach var in $list_all {
count if `var'>0 & time_dum==`value'
global `var'_g`value' = `r(N)'
 
}
sum rides_numb_sum if   time_dum==`value'
global rides`value' = `r(mean)'
}


use "${working}\counts.dta", clear 
foreach value in 1 2 3 {
*replace  time`value' = count`value'  if crime =="count" 
foreach var in $list_all {
replace time`value' = ${`var'_g`value'} if crime =="`var'"
}
replace time`value' = rides`value' if crime =="Ridership"
}

foreach value in 1 2 3 { 
foreach var in $list_all {
replace Percent_time`value' = round(${`var'_g`value'}/${count_g`value'}, 0.001)  if crime =="`var'"
}
}

save "${working}\counts.dta", replace 
 export excel using "${main}\EARL\EARL_OUTPUT\Crime_Counts.xls", firstrow(varlabels) replace

*/
 




















/*
replace line_type = subinstr(line_type," ","_", . )

gen id = _n  in 1/40
gen crime = "                          " 

levelsof line_type, local(LINES)
di "`r(levels)'"
global LINES `LINES' 
global LINES= subinstr("$LINES" ,"`","", . )

foreach value in $LINES{
di "`value'"
}

di "$list_all" //gen crimes side
local i = 1
foreach var in $list_all{
di  "`var'"
replace crime = "`var'" if id==`i'  
local i =`i'+1
di  "`i'"
}



foreach value in $LINES {  // gen counts 
foreach var in $list_all {
count if `var'>0  & line_type=="`value'"
global `var'_g`value' = `r(N)'
replace  `value' =  `r(N)' if crime == "`var'"
}
}



foreach value in 1 2 3 {
*replace  time`value' = count`value'  if crime =="count" 
foreach var in $list_all {
replace time`value' = ${`var'_g`value'} if crime =="`var'"
}
} 
*/
