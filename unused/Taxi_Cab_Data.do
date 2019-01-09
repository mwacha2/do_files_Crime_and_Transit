


/*
* from demographic_info do file
import delimited "${raw_data}\CTA_Tract_Buffered.csv", clear 
*import delimited "${raw_data}\Census_CTA_Tract.csv", clear 

keep tractce10 station_id longname

gen tractce10aa = string( tractce10, "%06.0f")
*manually adding old stations that were closed down, just using nearest station 
replace tractce10aa= if stat_id == 40640
replace tractce10aa= if stat_id == 40200


save "${working}\CTA_Census_tract.dta", replace 


*/

 cd "${main}"
 
 foreach int in 000 001 002 003 004 005 005 007 008 009 010 011 012{

 di "`int'"
 
 import delimited "${main}\Taxi_Trips\Split_Up\Taxi_Trips-`int'.csv" , clear
 
 
drop tripid taxiid
drop fare tips tolls extras triptotal paymenttype

drop if pickupcentroidlongitude== .

save "${main}\Taxi_Trips\Split_Up\TaxiTrips`int'.dta" , replace 

}

use "${main}\Taxi_Trips\Split_Up\TaxiTrips000.dta" , clear
 foreach int in 001 002 003 004 005 005 007 008 009 010 011 012{

 append using "${main}\Taxi_Trips\Split_Up\TaxiTrips`int'.dta" , force
 }
 
 *keep if pickupcommunityarea==8
 /*
 gen month = substr(tripstarttimestamp, 1, 2) 
 gen day=  substr(tripstarttimestamp, 4, 2)
 gen year= substr(tripstarttimestamp, 7, 4)
 gen hour = substr(tripstarttimestamp, 12, 2)
 gen minute = substr(tripstarttimestamp, 15, 2)
 */
	gen date1 = substr(tripstarttimestamp,1, 10)
gen datem = date(date1, "MDY")
 format datem %td

 
 format pickupcensustract %13.0f
gen tractce10 = pickupcensustract - 17031000000



* format tractce10 %13.0f
*Think this is the buffered set that has multiple cass. 
 merge m:m tractce10 using "${working}\CTA_Census_tract.dta"
drop if _merge !=3 
drop _merge 
gen stat_id = station_id +40000 // check this 
gen taxi_pickups =1 
 drop if stat_id == .
 
collapse (sum) taxi_pickups , by( stat_id datem)
 
 merge 1:1 stat_id datem using   "${clean}\CTA_Crime_Final_w_Crime.dta"
 drop _merge 
 
 
replace taxi_pickups = 0 if taxi_pickups ==. 
 
sort datem
gen week = cond(dow(datem) == 0, datem - 6, datem - dow(datem) + 1)
*format week %tw
*gen week = week(datem) *gives week of the year 
sum week, d
replace week = week -`r(min)'
replace week = round(week/7, 1)

collapse (sum) taxi_pickups  , by( stat_id week)



save "${clean}\Taxi_Rides_2013.dta" , replace 



*additions to regression 
merge 1:1 week stat_id using "${clean}\Taxi_Rides_2013.dta"

keep if week>643 & week<=665



global fileoutname "MainResultsOst_Taxi.xml"
global dependent "taxi_pickups"
*global clusterlevel "vce( cluster stat_id )"
global clusterlevel "robust"
global totalTreat  "S_violent_week_L1 O_violent_week_L1"
global title "Station Crime and Taxi, Main"

