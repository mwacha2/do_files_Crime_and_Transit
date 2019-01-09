



*create a before and after indicator for treatment. 
use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\"
global fileoutname "Prelim_Reg_Median.xml"

keep $keep_vars $interesting_vars


global treatvar "S_CRIM_SEXUAL_ASSAULT"
**********************************************
*cap drop From_day *_c_daym*  drop_row1 drop_row2 rides_numb_mean


sort stat_id datem 
foreach var in "$treatvar"{
forvalues i=-15(1)-1{
local var= subinstr("`var'", "_count", "",.) 
local j= -`i'
gen `var'_c_daymN`j' = `var'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
}
}
*********

sort stat_id datem 
foreach var in "$treatvar"{
forvalues i=1(1)15{
local var= subinstr("`var'", "_count", "",.) 
gen `var'_c_daym`i' = `var'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
}
}
*********


egen drop_row1 = rowtotal( ${treatvar}_c_daymN15 - ${treatvar}_c_daymN1)
egen drop_row2 = rowtotal(  ${treatvar}_c_daym1 - ${treatvar}_c_daym15)
drop if  drop_row1==0 & drop_row2==0 & ${treatvar}_count==0
drop if ${treatvar}_c_daym15 ==. | ${treatvar}_c_daymN15 ==.



*****************************
***

gen From_day = . 
forvalues i=-15(1)-1 {
local j= -`i'
replace From_day = `i' if ${treatvar}_c_daymN`j' >=1
} 

forvalues i=15(-1)1 {
replace From_day = `i' if ${treatvar}_c_daym`i' >=1
} 
replace From_day = 0 if  ${treatvar}_count >=1 

********************************

sort From_day
cap drop rides_numb_mean
by From_day : egen rides_numb_mean = mean(rides_numb)
twoway (line rides_numb_mean From_day )
 
/*
collapse (mean)  rides_numb , by( From_day)

sort From_day
twoway (line rides_numb From_day )
*/
