**********************************

**************
*import crimes 
**************

forvalues year=2001(1)2016{
import delimited "${crime}\Crimedata_`year'.csv" , clear
keep if inlist(locationdescription , "CTA PLATFORM" ,"CTA TRAIN")

*clean names 
replace primarytype = "NONCRIMINAL" if primarytype == "NON-CRIMINAL" | primarytype == "NON - CRIMINAL"
drop if primarytype == "NONCRIMINAL"
replace  primarytype = "CC_ LICENSE_VIOLATION" if  primarytype == "CONCEALED CARRY LICENSE VIOLATION" 
replace primarytype = subinstr(primarytype, " ", "_",.) 
replace  primarytype = "INTE_W_P_OFFICER" if primarytype == "INTERFERENCE_WITH_PUBLIC_OFFICER"
drop if primarytype == "NON-CRIMINAL_(SUBJECT_SPECIFIED)"


save "${working}\CTACrimedata_`year'.dta" , replace
}



 *************
 *prep for mergin  stations 
 ***************
 import delimited "${raw_data}\CTA_StationXY.csv", clear
 rename point_x cta_x 
 rename point_y cta_y 
 gen stat_id = station_id +40000
 
 *look at the map find the geocompas coordinates 
 *map the line  merge all central areas into one. 
 *one if yes 0 if no 
 foreach color in "Red" "Green" "Blue" "Yellow" "Orange" "Brown" "Pink" "Purple" {
 gen `color'_line_ind = strpos(lines, "`color'")
 replace `color'_line_ind =1 if `color'_line_ind>0
 }

/*
clark and lack cta_x	cta_y  -87.63089	41.88575
jackson blue cta_x	cta_y -87.6293	41.87819
jackson red cta_x	cta_y -87.6276	41.87816
state/lake red cta_x	cta_y  -87.62782	41.88482

 *use library or harison as a references 
 *going west the long gets more negative 
 *going north the lat gets larger 
 *gen airport= (stationname  "O'Hare Airport", "Midway Airport")
*several station lines and central station lines difficult to work with 
*/
 gen line_type = ""
 replace line_type ="Blue North" if cta_y >41.88575 &    Blue_line_ind==1 
 replace line_type = "Blue West" if cta_x <-87.63089 & cta_y <41.87819   & Blue_line_ind==1
 replace line_type = "Red North" if cta_y >41.88482  &   Red_line_ind==1
 replace line_type = "Red South" if cta_y <41.87816  & Red_line_ind==1
 replace line_type = "Green West" if cta_x <-87.63089 & Green_line_ind==1
 replace line_type = "Green South" if cta_y <41.87952 & Green_line_ind==1 & Orange_line_ind==0  

 replace line_type = "Pink" if Pink_line_ind==1 & Green_line_ind==0
 replace line_type = "Brown" if  Brown_line_ind==1 & Red_line_ind==0
 replace line_type = "Orange" if  Orange_line_ind==1 & Green_line_ind==0
 *Mix stations 
 replace line_type ="Mix" if (Pink_line_ind==1 & Green_line_ind==1) | ///
 (Brown_line_ind==1 & Red_line_ind==1) | Orange_line_ind==1 & Green_line_ind==1
 
 replace line_type = "Center" if inlist(longname, "Washington/Wabash", "State/Lake", "Adams/Wabash")
 replace line_type = "Center" if inlist(longname,"Library" , "Washington/Wells" , "LaSalle/Van Buren" , "Quincy/Wells" )
  replace line_type = "Center" if inlist(longname,"Clark/Lake", "Jackson/Dearborn" , "Lake/State", "Jackson/State" ) 
 replace line_type = "Center" if inlist(longname, "Monroe/Dearborn", "Washington/Dearborn" ,"Monroe/State")

 save  "${working}\CTA_StationXY.dta" ,replace 



/*
Crosses station and crime to attribute crime to a give stattion

*/ 
forvalue year=2001(1)2016{

use "${working}\CTA_StationXY.dta", clear 
cross using "${working}\CTACrimedata_`year'.dta"
rename latitude crime_y
rename longitude crime_x
 * geodist lat1 lon1 lat2 lon2 [if] [in] , generate(newvar) [options]
geodist cta_y cta_x crime_y crime_x ,  generate(dist_to_station) 

*some double counting some missed observations 
keep if dist_to_station<0.2

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
replace primarytype ="LIQUOR_LAW_VIOLATION"   if primarytype =="LIQUOR_LAW_VIOLATION" 
*cop related assaults 
gen proemp = strpos("description", "PRO EMP")
drop if proemp>0 
drop proemp

**************************

*too many types need to drop 
*drop if inlist(primarytype, "OBSCENITY OTHER_OFFENSE", "INTE_W_P_OFFICER" , "PUBLIC_INDECENCY", "LIQUOR_LAW_VIOLATION", "OTHER_NARCOTIC")
levelsof primarytype, local(crime_list)
foreach crime in `crime_list' {
di "`crime'"
gen `crime'_count = 1 if primarytype== "`crime'"
replace `crime'_count = 0 if  `crime'_count==.
} 

gen crime_count = 1 
 

collapse (sum) *_count ,by (station_id date1)

save "${working}\CTA_StationCrimeA`year'.dta", replace 
}
*


use "${working}\CTA_StationCrimeA2001.dta", clear 
forvalues year=2002(1)2016{
append using  "${working}\CTA_StationCrimeA`year'.dta"
}
gen stat_id = station_id +40000
save "${working}\CTA_StationCrimeAAll.dta", replace

/*
use "${working}\CTA_StationCrimeAAll.dta", clear
*/









/*
*old crime intersection only did counts 


 ************************************
 *Crime Intersections 
 ************************************
 
 
 forvalue year=2004(1)2012{
use "${working}\CTA_StationXY.dta", clear 
cross using "${working}\CTACrimedata_`year'.dta"
rename latitude crime_y
rename longitude crime_x
 * geodist lat1 lon1 lat2 lon2 [if] [in] , generate(newvar) [options]
geodist cta_y cta_x crime_y crime_x ,  generate(dist_to_station) 

*some double counting some missed observations 
keep if dist_to_station<0.2

*restricting to crimes people care about #subjective 
drop if domestic =="true"


keep if inlist(primarytype, "ASSAULT", "BATTERY", "BURGLARY", "CRIM SEXUAL ASSAULT", "ROBBERY")
drop if inlist(description, "SIMPLE", "STRONGARM - NO WEAPON", "UNLAWFUL ENTRY", ///
 "DOMESTIC BATTERY SIMPLE", "DOMESTIC BATTERY SIMPLE",  "NON-AGGRAVATED" ,   "FORCIBLE ENTRY")


*drop duplicates 
duplicates tag casenumber ,gen(dup_tag)
sort casenumber dist_to_station
by casenumber : egen min_dist = min(dist_to_station)

replace min_dist =round(min_dist,0.001)
replace dist_to_station=round(dist_to_station,0.001)
drop if dup_tag>0  & min_dist!= dist_to_station

gen crime_count = 1 


collapse (sum) crime_count ,by (station_id date1)

save "${working}\CTA_StationCrime`year'.dta", replace 
}



use "${working}\CTA_StationCrime2004.dta", clear 
forvalues year=2005(1)2012{
append using  "${working}\CTA_StationCrime`year'.dta"
}
save "${working}\CTA_StationCrimeAll.dta", replace
*merge station details just for info 
/*
merge m:1  station_id using "${working}\CTA_StationXY.dta"
drop _merge 
*/
*33 stations have not had a crime so maybe need to use a larger buffer. 
*gen stat_id = station_id +40000
 
*/
