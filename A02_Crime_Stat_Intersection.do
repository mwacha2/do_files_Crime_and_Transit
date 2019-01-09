**********************************

**************
*import crimes 
**************
/*
*Just do it once 
forvalues year=2016(1)2017{

import delimited "${crime}\GIS\Station_Crime_Int_`year'.csv" , clear
*keep if inlist(locationdescription , "CTA PLATFORM" ,"CTA TRAIN")
cap rename primary_type primarytype
cap rename location_descrip locationdescript
cap rename case_number casenumber
cap gen date1 = substr(date,1,11)
*clean names 
replace primarytype = "NONCRIMINAL" if primarytype == "NON-CRIMINAL" | primarytype == "NON - CRIMINAL"
drop if primarytype == "NONCRIMINAL"
replace  primarytype = "CC_ LICENSE_VIOLATION" if  primarytype == "CONCEALED CARRY LICENSE VIOLATION" 
replace primarytype = subinstr(primarytype, " ", "_",.) 
replace  primarytype = "INTE_W_P_OFFICER" if primarytype == "INTERFERENCE_WITH_PUBLIC_OFFICER"
drop if primarytype == "NON-CRIMINAL_(SUBJECT_SPECIFIED)"


save "${working}\CTACrimedataVIS_`year'.dta" , replace
}
*ssc install geodist
*/


*imports CTA crime buffer categorizes it and collapses it on count 
forvalue year=2016(1)2017{

use "${working}\CTACrimedataVIS_`year'.dta" ,clear 
merge m:1 station_id using "${working}\CTA_StationXY.dta"
drop _merge  
rename latitude crime_y
rename longitude crime_x
geodist cta_y cta_x crime_y crime_x ,  generate(dist_to_station) 

keep if dist_to_station<0.25 // 1/4 of a mile 2 blocks

*restricting to non-domenstic crimes 
drop if domestic =="true"
gen domestic_word = strpos(description,"DOMESTIC")
drop if domestic_word>0

*drop duplicates ,assoicate each crime to its closest station
duplicates tag casenumber ,gen(dup_tag)
sort casenumber dist_to_station
by casenumber : egen min_dist = min(dist_to_station)

replace min_dist =round(min_dist,0.001) // rounding needed since far decimals get weird
replace dist_to_station=round(dist_to_station,0.001)
drop if dup_tag>0  & min_dist!= dist_to_station


/*
Splitting simple and aggressive crimes 
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
replace primarytype= "BATTERYsimp"  if inlist(description, "PRO EMP HANDS NO/MIN INJURY", "AGG PO HANDS NO/MIN INJURY", "STALKING AGGRAVATED", "STALKING CYBERSTALKING" )
replace primarytype= "ASSAULTsimp"   if inlist(description, "AGG: HANDS/FIST/FEET NO/MINOR INJURY" , "AGG PO HANDS NO/MIN INJURY", "PRO EMP HANDS NO/MIN INJURY" ,"AGGRAVATED OF A UNBORN CHILD")
replace primarytype="SimpleCrime" if primarytype=="ASSAULTsimp" | primarytype== "BATTERYsimp"

replace  primarytype= "CRIM_SEX_ASLT" if primarytype =="CRIM_SEXUAL_ASSAULT"
replace  primarytype = "CRIM_TRESPASS" if primarytype =="CRIMINAL_TRESPASS"
replace primarytype= "MOTOR_V_THEFT" if primarytype =="MOTOR_VEHICLE_THEFT"

**************************

**************************
*generate a variable to be used in collapsing 
levelsof primarytype, local(crime_list)
foreach crime in `crime_list' {
di "`crime'"
gen `crime'_count = 1 if primarytype== "`crime'"
replace `crime'_count = 0 if  `crime'_count==.
} 
******
*create gun crime indicator  
gen handgun_ind = strpos(description,"HANDGUN")
gen firearm_ind = strpos(description,"FIREARM")
gen firearm_count =1 if  firearm_ind>0 | handgun_ind>0 & primarytype !="WEAPONS_V" 
replace firearm_count = 0 if firearm_count== .

gen crime_count = 1 
gen CTA_crime = 1 if  inlist(locationdescript , "CTA PLATFORM" ,"CTA TRAIN", "CTA L TRAIN", "CTA L PLATFORM", "CTA STATION")
gen CTA_crime_in = strpos(locationdescript, "CTA")
replace  CTA_crime= 1 if CTA_crime_in>0 & dist_to_station<0.05
replace CTA_crime = 0 if CTA_crime== .
replace CTA_crime = 0 if inlist(locationdescript, "CTA GARAGE / OTHER PROPERTY", "CTA BUS", "CTA BUS STOP") 


preserve 
*just CTA Crimes in case I want to work with specific cases by detail  
keep if CTA_crime==1 
save "${working}\RAW_CTA_Crime`year'.dta", replace 
restore 

preserve 
*just CTA Crimes in case I want to work with specific cases by detail  
keep if primarytype=="HOMICIDE"
save "${working}\RAW_homicide_Crime`year'.dta", replace 
restore 


*collapses down to keep an indicator.
collapse (sum) *_count ,by (station_id date1 CTA_crime)
 
*gen date2  = substr(date1,1,11)
gen date2 = subinstr( date1,"0:00:00", "", .)
gen datem = date(date2, "MDY",2000)
format %td datem
gen year= year(datem)
gen month = month(datem)
gen day_of_week = dow(datem)


preserve 
keep if CTA_crime ==1 // just station crimes 
collapse (sum) *_count ,by (station_id datem )
rename *_count S_*_count
save "${working}\CTA_StationCrime`year'.dta", replace 
restore 


preserve 
keep if CTA_crime ==0 // Just outside crimes 
collapse  (sum) *_count ,by (station_id datem )
rename *_count O_*_count
save "${working}\CTA_OutsideCrime`year'.dta", replace 
restore 

preserve 
*saves all crimes  // Both station and outside crimes 
collapse (sum) *_count ,by (station_id datem )
rename *_count A_*_count
save "${working}\CTA_AllNearCrime`year'.dta", replace 
restore 

}
*
*********************************
clear
gen x=1
forvalue year=2001(1)2017{
 append using "${working}\RAW_CTA_Crime`year'.dta", force
}
save "${working}\RAW_CTA_CrimeTOTAL.dta", replace


clear
gen x=1
forvalue year=2001(1)2017{
 append using "${working}\RAW_homicide_Crime`year'.dta", force 
}
save "${working}\RAW_homicide_CrimeTotal.dta", replace 



run "${main}\do_files\Station_Crime_Fixing.do"




