
use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"


keep $keep_vars $interesting_vars

**********************************
*14 day crime average 
*is zero for the day the crime happened 
*moving average is almost the same as an indicator since there is no weight on past terms. 

***NOT AN ACUTAL MOVING AVERAGE 

sort stat_id datem
tsset stat_id datem

local varlist "S_violentNSEX_count O_violentNSEX_count S_CRIM_SEXUAL_ASSAULT_count O_CRIM_SEXUAL_ASSAULT_count S_property_count O_property_count S_ASSAULTsimp_count S_BATTERYsimp_count O_ASSAULTsimp_count O_BATTERYsimp_count"   

*local varlist "S_violentNSEX_count O_violentNSEX_count"
foreach crime in `varlist'{
local crimename =subinstr("`crime'","_count","",.)
global sum1 ""
forvalues i=1(1)14 {
global sum1 "$sum1 + L`i'.`crimename'_count"
}
global sum1 =subinstr("$sum1", "+", "",1) 
generate `crimename'_mov_avg = $sum1 / 14
}


tsset ,clear 
preserve
keep stat_id datem   *_mov_avg
save "${clean}\CTA_Crime_w_CrimeMoverAVGTreatments.dta" ,replace 
restore






***************************************
*Before Treatment
*************************************** 
sort stat_id datem 
ds *_count
foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_count","",.)
foreach j in 7 14 21 {
gen `crimename'Btrt`j' = 0
forvalues i=1(1)`j'{
replace `crimename'Btrt`j' = `crimename'Btrt`j' + `crimename'_count[_n+`i']   if stat_id[_n] == stat_id[_n+`i'] & datem[_n] ==datem[_n+`i'] -`i' 
}
}
gen `crimename'_Bsep7_14 = `crimename'Btrt14 - `crimename'Btrt7
gen `crimename'_Bsep14_21 = `crimename'Btrt21 - `crimename'Btrt14
}

keep stat_id datem *Btrt14 *Btrt7  *Bsep7_14 *Bsep14_21 *_mov_avg
save "${clean}\CTA_Crime_w_CrimeBeforeTreatments.dta"






*********************************************
*runs a regression of before and after a crime 
********************************************

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"

keep $keep_vars $interesting_vars


*creates an indicator if 15 days after a crime. 
gen treat_ind= 0

 *iterates over stations 
 levelsof station_id if S_violentSTD_count>=1, local(stat_id )
 foreach var in `stat_id'{
 levelsof datem if station_id ==`var' & S_violentSTD_count>=1, local(datecrime)
foreach crime in  `datecrime' {
local crimedate= `crime'
local crimef10= `crimedate' +15
local crimeb10=  `crimedate' -15
replace treat_ind= 1 if station_id ==`var' & inrange(datem, `crime',`crimef10' )

}
}

keep stat_id datem treat_ind
save "${clean}\CTA_Treat_Indicator.dta"




**********************************************
*Before 15 and after 15 
**********************************************

*before count 
*after count 
sort stat_id datem 

foreach crime in "S_violentSTD_count"{
local crimename =subinstr("`crime'","_count","",.)
foreach j in 7 14 21 {
gen `crimename'Btrt`j' = 0
forvalues i=1(1)`j'{
replace `crimename'Btrt`j' = `crimename'Btrt`j' + `crimename'_count[_n+`i']   if stat_id[_n] == stat_id[_n+`i'] & datem[_n] ==datem[_n+`i'] -`i' 
}
}

}


ds *_count
foreach crime in "S_violentSTD_count"{
foreach j in  7 9 14 21{
local crimename =subinstr("`crime'","_count","",.)
global sumlist ""
forvalues i=1(1)`j'{
global sumlist " $sumlist `crimename'_c_daym`i'"
}
egen `crimename'trt`j' = rowtotal($sumlist)
}

}


/*

backup doesn't work 
*********************************

ds *_count ,
foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_count","",.)
gen `crimename'_mov_sum = 0
sort stat_id datem
replace `crimename'_mov_sum=     `crimename'_count[_n-4] `crimename'_count[_n-5] `crimename'_count[_n-6]+`crimename'_count[_n-7]+`crimename'_count[_n-8] ///
+`crimename'_count[_n-9]+ `crimename'_count[_n-10]+`crimename'_count[_n-11]+`crimename'_count[_n-12]+`crimename'_count[_n-13]+`crimename'_count[_n-14] ///
 if stat_id[_n] == stat_id[_n-14] & datem[_n] ==datem[_n-14] +14 

replace `crimename'_mov_avg =  `crimename'_mov_avg/14 
}
****************************
preserve
keep stat_id datem   *_mov_avg
save "${clean}\CTA_Crime_w_CrimeMoverAVGTreatments.dta" ,replace 
restore



**********************************
*moving Avgs
*is zero for the day the crime happened 
*moving average is almost the same as an indicator since there is no weight on past terms. 

ds *_count ,
foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_count","",.)
gen `crimename'_mov_avg = `crimename'_count
forvalues i=1(1)14 {
sort stat_id datem
replace `crimename'_mov_avg= (`crimename'_mov_avg + `crimename'_mov_avg[_n-`i'])  if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
}
replace `crimename'_mov_avg =  `crimename'_mov_avg/14 
*moving average void of the current crime. 
replace  `crimename'_mov_avg = `crimename'_mov_avg -  `crimename'_count
}
****************************
preserve
keep stat_id datem   *_mov_avg
save "${clean}\CTA_Crime_w_CrimeMoverAVGTreatments.dta" ,replace 
restore



*/
