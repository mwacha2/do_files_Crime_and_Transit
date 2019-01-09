
*less error prone way 
*uses more data on PC 

foreach dataset in  "CTA_OutsideCrimeALL"  "CTA_AllNearCrimeALL"  "CTA_StationCrimeAll" {
use "${working}\CTA_Ridership.dta" ,clear 

cap gen stat_id = station_id
drop if year<2005 | year >2010
merge 1:1 datem stat_id using "${working}\\`dataset'.dta"
drop _merge 


ds *_count 
foreach var in `r(varlist)'{
replace `var' =0 if `var' ==. 
}
save   "${working}\\`dataset'_Final.dta" , replace
}



foreach dataset in  "CTA_OutsideCrimeALL"  "CTA_AllNearCrimeALL"  "CTA_StationCrimeAll" {

local dataset "CTA_OutsideCrimeALL"
use  "${working}\\`dataset'_Final.dta" , clear 
drop if year<2005 | year >2010

egen violentSTD_count= rowtotal(*ROBBERY_count  *BATTERYsimp_count *BATTERY_count *ASSAULTsimp_count  /*HOMICIDE_count */  *ASSAULT_count  *CRIM_SEXUAL_ASSAULT_count)
egen violentNSEX_count= rowtotal(*ROBBERY_count *BATTERY_count  /*HOMICIDE_count */  *ASSAULT_count)
egen violent_count= rowtotal(*ROBBERY_count *BATTERY_count  /*HOMICIDE_count */  *ASSAULT_count  *CRIM_SEXUAL_ASSAULT_count)
egen property_count = rowtotal(*THEFT_count  *BURGLARY_count  *ARSON_count  /* MOTOR_VEHICLE_THEFT_count */)
egen qual_life_count = rowtotal( *CRIMINAL_DAMAGE_count  *PROSTITUTION_count  *NARCOTICS_count )


keep *_count stat_id datem
forvalues i=1(1)22{
preserve
replace datem = datem+`i' 
rename *_count *_c_daym`i'
save "${working}\\`dataset'Shift`i'.dta" ,replace 
restore 
}


use  "${working}\\`dataset'.dta", clear
forvalues i=1(1)22{
merge 1:1 datem stat_id using  "${working}\\`dataset'Shift`i'.dta" 
drop _merge 
}


ds *_count
foreach crime in `r(varlist)'{
foreach j in  7 9 14 21{
local crimename =subinstr("`crime'","_count","",.)
global sumlist ""
forvalues i=1(1)`j'{
global sumlist " $sumlist `crimename'_c_daym`i'"
}
egen `crimename'trt`j' = rowtotal($sumlist)
}
gen `crimename'_sep7_14 = `crimename'trt14 - `crimename'trt7
gen `crimename'_sep14_21 = `crimename'trt21 - `crimename'trt14
}



*drops all the unneeded variables
drop *daym*

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







/*
*************************
*By Line type 
run "${main}\do_files\Restrict_Station.do"
collapse (first) year  (sum) rides_numb *_count  *trt* ,by(line_type datem)
 
save  "${clean}\CTALine_Crime_Final_w_Crime.dta", replace 
*/
 




