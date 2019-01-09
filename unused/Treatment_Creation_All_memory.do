*less memory intensive version

*use "${working}\CTA_OutsideCrimeALL.dta" ,clear

foreach dataset in  "CTA_OutsideCrimeALL"  "CTA_AllNearCrimeALL"  "CTA_StationCrimeAll" {
use "${working}\CTA_Ridership.dta" ,clear 

cap gen stat_id = station_id

merge 1:1 datem stat_id using "${working}\\`dataset'.dta"
drop _merge 


ds *_count 
foreach var in `r(varlist)'{
replace `var' =0 if `var' ==. 
}
save   "${working}\\`dataset'_Final.dta" , replace
}







foreach dataset in  "CTA_OutsideCrimeALL"  "CTA_AllNearCrimeALL"  "CTA_StationCrimeAll" {


use  "${working}\\`dataset'_Final.dta" , clear 


ds *ROBBERY_count, 
local crime `r(varlist)'
di "`crime'"
local crime =subinstr("`crime'","_count","",.)
local acro =subinstr("`crime'","ROBBERY","",.)
di "`acro'"

egen `acro'violentSTD_count= rowtotal(*ROBBERY_count  *BATTERYsimp_count *BATTERY_count *ASSAULTsimp_count  /*HOMICIDE_count */  *ASSAULT_count  *CRIM_SEXUAL_ASSAULT_count)
egen `acro'violentNSEX_count= rowtotal(*ROBBERY_count *BATTERY_count  /*HOMICIDE_count */  *ASSAULT_count)
egen `acro'violent_count= rowtotal(*ROBBERY_count *BATTERY_count  /*HOMICIDE_count */  *ASSAULT_count  *CRIM_SEXUAL_ASSAULT_count)
egen `acro'property_count = rowtotal(*THEFT_count  *BURGLARY_count  *ARSON_count  /* MOTOR_VEHICLE_THEFT_count */)
egen `acro'qual_life_count = rowtotal( *CRIMINAL_DAMAGE_count  *PROSTITUTION_count  *NARCOTICS_count )

**NEEED TO SORT FOR IT TO WORK 
sort stat_id datem 
ds *_count
foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_count","",.)
foreach j in 7 14 21 {
gen `crimename'trt`j' = 0
forvalues i=1(1)`j'{
replace `crimename'trt`j' = `crimename'trt`j' + `crimename'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
}
}
gen `crimename'_sep7_14 = `crimename'trt14 - `crimename'trt7
gen `crimename'_sep14_21 = `crimename'trt21 - `crimename'trt14
}



*lagged week average 
sort stat_id datem
gen mov_ave_ridenumb = 0
forvalues i=1(1)7 {
replace mov_ave_ridenumb= mov_ave_ridenumb +rides_numb[_n-`i']  if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
}

*drop *_c_daym*
*drop if year<2005 | year >2014
save  "${clean}\\`dataset'_Final_w_Crime.dta", replace 

}





