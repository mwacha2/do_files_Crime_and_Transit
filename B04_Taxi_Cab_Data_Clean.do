



*creates data sets to be used. 
foreach year in 2014 {
foreach m in  9  {

 import delimited "${main}\Taxi_Trips\AutoDownload\Year`year'\TaxiData_M`m'Y`year'.csv" , clear

drop tripid taxiid
drop fare tips tolls extras triptotal paymenttype

drop if pickupcentroidlongitude== . & dropoffcommunityarea== .

save "${main}\Taxi_Trips\TAXI_DATA\TaxiData_M`m'Y`year'.dta" , replace 

}
} 



 
* manually switch years to make it usable #slow as shit
foreach year in 2014 2015 {

clear 
gen x= .

foreach m in 1 2 3 4 5 6 7 8 9 10 11 12   {
append using "${main}\Taxi_Trips\TAXI_DATA\TaxiData_M`m'Y`year'.dta"

}


gen year= substr(tripstarttimestamp, 7, 4)
gen hour = substr(tripstarttimestamp, 12, 2)

gen PM = substr(tripstarttimestamp, 21, 2)
gen date1 = substr(tripstarttimestamp,1, 10)
gen datem = date(date1, "MDY")
gen dayofweek = dow(datem)
format datem %td

encode hour, gen(time)
replace time = 0 if time==12 & PM=="AM" // order matters 
replace time = time+12 if PM=="PM"

 
format pickupcensustract %13.0f
gen tractce10 = pickupcensustract - 17031000000


merge m:m tractce10 using "${working}\CTA_Census_tract.dta"
drop if _merge !=3 
drop _merge


gen taxi_pickups= 1 
gen taxi_late_pickups= 1 if (time>=8 | time<=4)
gen taxi_pickups_wkend= 1  if inlist(dayofweek, 0, 6)
gen taxi_late_pickups_wkend= 1 if (time>=8 | time<=4) & inlist(dayofweek, 0, 6)


*just does pickups 
collapse (sum) taxi_pickups taxi_late_pickups taxi_pickups_wkend  taxi_late_pickups_wkend , by( stat_id datem)
 
 merge m:1  datem using   "${clean}\Week_reference.dta"
 drop _merge 

 foreach var in taxi_pickups taxi_late_pickups taxi_pickups_wkend  taxi_late_pickups_wkend{
 replace `var' = 0 if `var' ==. 
 }
 
sort datem
*gen week_unscaled = cond(dow(datem) == 0, datem - 6, datem - dow(datem) + 1)
*format week %tw
*gen week = week(datem) *gives week of the year 
/*
sum week, d
replace week = week -`r(min)'
replace week = round(week/7, 1)
*/
*need week to be unscaled 
collapse (sum)  taxi_pickups taxi_late_pickups taxi_pickups_wkend  taxi_late_pickups_wkend  , by( stat_id week)



save "${clean}\Taxi_Rides_Pickups`year'.dta" , replace 
}


clear 
gen x =. 
foreach year in 2013 2014 2015 {
append using  "${clean}\Taxi_Rides_Pickups`year'.dta"
}
drop x 
sort stat_id week
duplicates drop stat_id week, force
drop if stat_id ==.
save  "${clean}\Taxi_Rides_PickupsCombined.dta", replace

/*
use "${clean}\Taxi_Rides_PickupsCombined.dta", clear
*/
