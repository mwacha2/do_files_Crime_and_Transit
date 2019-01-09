*import types of crimes from CPD 

/*
foreach year in 2001 2002 2003 2004 2005 {
import delimited "${main}\raw_data\crime\Crimedata_`year'.csv", clear
save "${main}\working_data\Crimedata_`year'.dta", replace 
}

clear 
set obs  1
gen x = "blah blah"
foreach year in 2001 2002 2003 2004 2005 {
append  using "${main}\working_data\Crimedata_`year'.dta"
}

save "${main}\working_data\Crimedata_2001_2005.dta", replace
*/

use  "${main}\working_data\Crimedata_2001_2005.dta", clear 


rename_primary // program 

gen violent_ind = 1 if inlist(primarytype, "ROBBERY", "BATTERY", "HOMICIDE", "ASSAULT", "CRIM_SEX_ASLT") // broken


egen crime_type = group(primarytype description) //similar to iucr


gen count =1 


**************************************
*one set 
keep if inrange(year, 2001, 2005)
keep if violent_ind==1

collapse (sum) count (first) primarytype description violent_ind ,by(crime_type)

keep if violent_ind==1

sum count, d 
global total = `r(sum)'

gen prob_of_crime_city = count/ $total 

bysort primarytype: egen primary_count = sum(count)

gen prop_of_prime_city = primary_count/ $total

keep primarytype description   prob_of_crime_city prop_of_prime_city
save "${working}\CTACrime_Prob_Entire_City.dta" , replace  
*****************************************





