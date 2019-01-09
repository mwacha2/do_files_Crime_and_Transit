
cd "${raw_data}\Raw_Data_CTA"

import delimited rail_station_hourly_history_monthly_thru2008.csv, clear

gen yearmonth = string(yyyymm)
gen year = substr(yearmonth, 1, 4 )
gen month =substr(yearmonth, 5, 2 )
destring year , replace 
destring month, replace 

save "${raw_data}\monthlyBEFORE2008.dta" , replace



import delimited rail_station_hourly_history_monthly_after2008.csv, clear

gen yearmonth = string(yyyymm)
gen year = substr(yearmonth, 1, 4 )
gen month =substr(yearmonth, 5, 2 )
destring year , replace 
destring month, replace 

save "${raw_data}\monthlyAFTER2008.dta" , replace



use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"

gen station = stationname
collapse (first) station  stationname longname  (sum) rides_numb* *week ,by(month year stat_id)
drop if year>=2016
save "${clean}\CTA_Crime_Final_w_CrimeMONTH.dta", replace 


*use "${clean}\CTA_Crime_Final_w_CrimeMONTH.dta", clear  

use "${raw_data}\monthlyBEFORE2008.dta", clear 
append using "${raw_data}\monthlyAFTER2008.dta" 

merge m:1 year month station using  "${clean}\CTA_Crime_Final_w_CrimeMONTH.dta"

gen night = 1 if hour> 12







set matsize 2000

*figure out why this is 
drop if rides_numb_sum ==0 
drop if bad_flag>0
*drop if rides_numb_sum <200
*keep $keep_vars $interesting_vars
