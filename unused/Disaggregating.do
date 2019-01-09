/*
breakup crimes by intensity and time 

*/



forvalue year=2005(1)2010{

/*
use "${working}\CTA_StationXY.dta", clear 
cross using "${working}\CTACrimedataVIS_`year'.dta"
*/
local year 2006
use "${working}\CTACrimedataVIS_`year'.dta" ,clear 
merge m:1 station_id using "${working}\CTA_StationXY.dta"
drop _merge  
rename latitude crime_y
rename longitude crime_x
 * geodist lat1 lon1 lat2 lon2 [if] [in] , generate(newvar) [options]
keep if inlist(locationdescript , "CTA PLATFORM" ,"CTA TRAIN")

 geodist cta_y cta_x crime_y crime_x ,  generate(dist_to_station) 

*some double counting some missed observations 

*restricting to crimes people care about #subjective 
drop if domestic =="true"

*drop duplicates 
duplicates tag casenumber ,gen(dup_tag)
sort casenumber dist_to_station
by casenumber : egen min_dist = min(dist_to_station)

replace min_dist =round(min_dist,0.001)
replace dist_to_station=round(dist_to_station,0.001)
drop if dup_tag>0  & min_dist!= dist_to_station


/*
Splitting simple and aggressive stuff subjective 
*/
replace primarytype ="ASSAULTsimp"  if primarytype =="ASSAULT" & description == "SIMPLE"
replace primarytype ="BATTERYsimp"  if primarytype =="BATTERY" & description == "SIMPLE"
replace primarytype ="SEX_OFFENSEdec"  if primarytype =="SEX_OFFENSE" & description == "PUBLIC INDECENCY" 
*rename shorter names 
replace primarytype = "OFF_INV_CHILD"  if primarytype =="OFFENSE_INVOLVING_CHILDREN"  
replace primarytype =" OTHER_NARCOTIC" if primarytype =="OTHER_NARCOTIC_VIOLATION" 
replace primarytype =" PUBLIC_PEACE_V" if primarytype =="PUBLIC_PEACE_VIOLATION" 
replace primarytype ="WEAPONS_V" if primarytype =="WEAPONS_VIOLATION" 
replace primarytype ="CC__LICENSE_V" if primarytype =="CC__LICENSE_VIOLATION" 
replace primarytype ="LIQUOR_LAW_V"   if primarytype =="LIQUOR_LAW_VIOLATION" 
*cop related assaults 
gen proemp = strpos("description", "PRO EMP")
drop if proemp>0 
drop proemp

**************************
*http://gis.chicagopolice.org/clearmap_crime_sums/crime_types.html

levelsof primarytype, local(crime_list)
foreach crime in `crime_list' {
di "`crime'"
gen `crime'_count = 1 if primarytype== "`crime'"
replace `crime'_count = 0 if  `crime'_count==.
} 

gen crime_count = 1 




collapse (sum) *_count ,by (station_id date1 CTA_crime)

gen date2 = subinstr( date1,"0:00:00", "", .)
gen datem = date(date2, "MDY",2000)
format %td datem
gen year= year(datem)
gen month = month(datem)
gen day_of_week = dow(datem)

**********************************
/*
preserve 
keep if CTA_crime ==1 
collapse (sum) *_count ,by (station_id date1 )
rename *_count S_*_count
save "${working}\CTA_StationCrime`year'.dta", replace 
restore 


preserve 
keep if CTA_crime ==0 
collapse (sum) *_count ,by (station_id date1 )
rename *_count O_*_count
save "${working}\CTA_OutsideCrime`year'.dta", replace 
restore 

preserve 
*saves all crimes 
collapse (sum) *_count ,by (station_id date1 )
rename *_count A_*_count
save "${working}\CTA_AllNearCrime`year'.dta", replace 
restore 



*save "${working}\CTA_StationCrime`year'.dta", replace 
}
*

*saves 3 different data sets 

use "${working}\CTA_StationCrime2005.dta", clear 
forvalues year=2006(1)2010{
append using  "${working}\CTA_StationCrime`year'.dta"
}
gen stat_id = station_id +40000
*

save "${working}\CTA_StationCrimeAll.dta", replace


****
use "${working}\CTA_AllNearCrime2005.dta", clear 
forvalues year=2006(1)2010{
append using  "${working}\CTA_AllNearCrime`year'.dta"
}
*

gen stat_id = station_id +40000
save "${working}\CTA_AllNearCrimeALL.dta", replace

****
use "${working}\CTA_OutsideCrime2005.dta", clear 
forvalues year=2006(1)2010{
append using  "${working}\CTA_OutsideCrime`year'.dta"
}


gen stat_id = station_id +40000
save "${working}\CTA_OutsideCrimeALL.dta", replace

