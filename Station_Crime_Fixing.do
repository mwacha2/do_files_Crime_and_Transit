/*
Goal is to Restrict Crime to Just hours people may care about 

*/



use "${working}\RAW_CTA_CrimeTOTAL.dta", clear 


gen daytime = 1 if inrange(hour, 7, 20)
replace daytime= 0 if daytime==. 

gen commute_time = 1 if inrange(hour, 7,9) | inrange(hour, 4,6)

gen Station_Station_ind = 1 if  inlist(locationdescript, "CTA STATION", "CTA PLATFORM", "CTA L PLATFORM")
replace Station_Station_ind=0 if Station_Station_ind==. 


egen violent_count= rowtotal(ROBBERY_count BATTERY_count  HOMICIDE_count   ASSAULT_count  CRIM_SEX_ASLT_count)
label var violent_count "Violent Crime- No Simple" 
egen property_count = rowtotal(THEFT_count  BURGLARY_count  ARSON_count  MOTOR_V_THEFT_count)
egen qual_life_count = rowtotal( CRIMINAL_DAMAGE_count  PROSTITUTION_count  NARCOTICS_count )

gen robbery_count = ROBBERY_count
*Daytime Crime, Commute Crime, Just Station-Station

global caseD `" "D" " daytime==1" "'
global caseC `" "C" " commute_time==1" "'
global caseSS `" "SS" " Station_Station_ind==1" "'
global caseSD `" "SD" " Station_Station_ind==1 & daytime==1" "'

foreach case in caseD  caseC caseSS caseSD {
local acro: word 1 of ${`case'} 
local condition: word 2 of ${`case'}
di "`acro'"
di "`condition'"
foreach crime in  violent_count property_count firearm_count robbery_count {
gen `acro'_`crime' =`crime' if `condition'
replace `acro'_`crime' =0 if `acro'_`crime'==. 
}
}
cap drop datem 
cap drop date2
cap drop year 
gen date2 = subinstr( date1,"0:00:00", "", .)
gen datem = date(date2, "MDY",2000)
format %td datem
gen year= year(datem)
gen month = month(datem)
gen day_of_week = dow(datem)

collapse (sum) D_*_count C_*_count SS_*_count SD_*_count ,by (station_id datem )
gen stat_id = station_id +40000
save "${working}\CTA_OtherCrimeFinal.dta", replace 






use "${working}\RAW_homicide_CrimeTotal.dta", clear

cap drop datem 
cap drop date2
cap drop year 
gen date2 = subinstr( date1,"0:00:00", "", .)
gen datem = date(date2, "MDY",2000)
format %td datem
gen year= year(datem)
gen month = month(datem)
gen day_of_week = dow(datem)

gen daytime = 1 if inrange(hour, 7, 20)
replace daytime= 0 if daytime==. 
gen commute_time = 1 if inrange(hour, 7,9) | inrange(hour, 4,6)
gen Station_Station_ind = 1 if  inlist(locationdescript, "CTA STATION", "CTA PLATFORM", "CTA L PLATFORM")
replace Station_Station_ind=0 if Station_Station_ind==. 

gen D_HOMICIDE_count = HOMICIDE_count if daytime==1

collapse (sum) D_HOMICIDE_count ,by (station_id datem )
gen stat_id = station_id +40000
save "${working}\CTA_OtherHomFinal.dta", replace 

