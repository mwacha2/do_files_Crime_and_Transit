/*
Merges all the crime data sets into one  

*/

*saves 3 different data sets 

use "${working}\CTA_StationCrime2001.dta", clear 
forvalues year=2002(1)2017{
append using  "${working}\CTA_StationCrime`year'.dta"
}
gen stat_id = station_id +40000
save "${working}\CTA_StationCrimeAll.dta", replace


****
use "${working}\CTA_AllNearCrime2001.dta", clear 
forvalues year=2002(1)2017{
append using  "${working}\CTA_AllNearCrime`year'.dta"
}
gen stat_id = station_id +40000
save "${working}\CTA_AllNearCrimeALL.dta", replace

****
use "${working}\CTA_OutsideCrime2001.dta", clear 
forvalues year=2002(1)2017{
append using  "${working}\CTA_OutsideCrime`year'.dta"
}
gen stat_id = station_id +40000
save "${working}\CTA_OutsideCrimeALL.dta", replace



foreach dataset in  "CTA_OutsideCrimeALL"  "CTA_AllNearCrimeALL"  "CTA_StationCrimeAll" {
use "${working}\CTA_Ridership.dta" ,clear 
di "dataset"
cap gen stat_id = station_id +4000
merge 1:1 datem stat_id using "${working}\\`dataset'.dta", update
drop _merge 

ds *_count 
foreach var in `r(varlist)'{
quietly replace `var' =0 if `var' ==. 
}
save   "${working}\\`dataset'_Final.dta" , replace
}



use  "${working}\\CTA_OutsideCrimeALL_Final.dta" , clear  
merge 1:1 stat_id datem using  "${working}\\CTA_AllNearCrimeALL_Final.dta", update
drop _merge 
merge 1:1 stat_id datem using  "${working}\\CTA_StationCrimeAll_Final.dta", update
drop _merge 
merge 1:1 stat_id datem using  "${working}\CTA_OtherCrimeFinal.dta", update // Created from Fixing 
drop _merge 
merge 1:1 stat_id datem using  "${working}\CTA_OtherHomFinal.dta", update // Created from Fixing 
drop _merge 
merge m:1  stat_id using "${working}\CTA_StationXY.dta", update
drop _merge 

*******************
*creates the violent crime and property crime indexes.

foreach acro in "S_" "O_" "A_" {
egen `acro'violent_count= rowtotal(`acro'ROBBERY_count `acro'BATTERY_count  `acro'HOMICIDE_count   `acro'ASSAULT_count  `acro'CRIM_SEX_ASLT_count)
label var `acro'violent_count "Violent Crime- No Simple" 
egen `acro'property_count = rowtotal(`acro'THEFT_count  `acro'BURGLARY_count  `acro'ARSON_count  `acro'MOTOR_V_THEFT_count)
egen `acro'qual_life_count = rowtotal( `acro'CRIMINAL_DAMAGE_count  `acro'PROSTITUTION_count  `acro'NARCOTICS_count )
}

save  "${clean}\CTA_Crime_Final_w_Crime.dta", replace
