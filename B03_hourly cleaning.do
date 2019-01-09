
foreach var in "thru2008" "after2008" {
import delimited "${raw_data}\Raw_Data_CTA\rail_station_hourly_history_monthly_`var'.csv", clear

gen dateS = string(yyyymm)
gen year = substr(dateS, 1, 4)
gen month = substr(dateS, 5, 2)

destring year, replace 
destring month, replace

rename station stationname 

save "${working}\Rail_Hourly`var'.dta" ,replace
}
*******************

use  "${working}\Rail_Hourlyafter2008.dta" , clear 
append using "${working}\Rail_Hourlythru2008.dta"

save "${working}\Rail_Hourly_Full.dta", replace 


********************



*use "${working}\Rail_Hourly.dta" , clear

 use "${working}\CTA_Ridership.dta", clear
 gen day_type = "WK" if inlist(day_of_week, 1,2, 3, 4, 5)
 replace day_type = "SA" if day_of_week == 6
 replace day_type = "SU" if day_of_week== 0 
 gen bad_flag =1 if rides_numb< 5
 replace bad_flag =0 if bad_flag ==.
*duplicates drop stationname year month day_type , force  
/*
expand 24 , gen(hour) 
sort stationname year month day_type
replace hour = mod(_n, 24)
*/
 duplicates drop  stationname year month day_type, force 

 drop rides rides_numb
 *why the fuck fuck fuck am I doing ti like this 
 merge 1:m stationname year month day_type  using "${working}\Rail_Hourly_Full.dta"
 drop if _merge!=3
 drop _merge 

 drop if entries == .
 
 sort year month stat_id day_type hour
 gen m_weekday_entries = entries if day_type=="WK"
 gen m_weekend_entries = entries if day_type == "SA" | day_type =="SU" 
 sort month year stat_id hour 
by month year stat_id hour : egen weekday_entries = max(m_weekday_entries)
 by month year stat_id hour : egen weekend_entries = max(m_weekend_entries)
gen week_entries = 5*(5/7)*weekday_entries + (2/7)*weekend_entries
 
 
duplicates drop month year stat_id hour, force // gets ride of daytype 

 save "${working}\Rail_Hourly_w_Ridership.dta", replace 
 
 
 *******************************
 *Hourly indicator 
 *******************************
 
use "${working}\Rail_Hourly_w_Ridership.dta", clear 

gen late = 1 if hour>= 20 | hour <= 4 // late travelesrs between 8 and 4 am
replace late =0 if late== .

gen super_late = 1 if hour>= 22 | hour <= 4 // super late travelesrs between 10 and 4 am
replace super_late =0 if super_late== .

gen commute = 1 if hour>= 7 | hour <= 18 // number of commuters between 7am and 6pm 
replace commute =0 if commute== .

*week_entries weekend_entries
sort stat_id year month 
foreach time in late super_late commute {
foreach rider in weekend_entries week_entries  weekday_entries {

bysort stat_id year month `time' : egen m_`rider'_`time' = mean( `rider')  
replace m_`rider'_`time' = . if `time' == 0
bysort stat_id year month: egen `rider'_`time' = max(m_`rider'_`time')   
}
}
cap drop m_*
drop late super_late commute 
duplicates drop year month stat_id  , force
drop if stat_id ==. 

save  "${working}\Rail_Hourly_w_Ridership_merge.dta", replace  
 
 
 
*************************** 
 
*use  "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear 
*still using weekly data for this but that is fine for now. 
sort  stat_id year month
collapse (first) line_type stationname longname hinc  pov_rate mrent mhmval multi crime_age white_hh hispanic_hh black_hh  fem_lab_force unemploy_rate population poverty_int_flabor ///
 (mean) imput_avg_temp prcp (sum) bad_flag rides_numb_wkend rides_numb_wkendFr rides_numb_sum *week* ,by(stat_id year month)


sort year month
egen year_month =group( year month)


drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"
*drop if rides_numb_sum <200

gen time_dum = 1 if year<2006
replace time_dum = 2 if  year>=2006 & year< 2011
replace time_dum =3 if year>=2011  & year<= 2016
count if time_dum==.

save "${working}\CTA_Crime_HourlyFinal.dta", replace 
 

 

* need to create weekly average and 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 /*
 collapse (first) station_id ,by(stationname)
 rename station_id stat_id
 
 preserve 
 merge 1:m stationname using "${working}\Rail_Hourlythru2008.dta"
 drop if _merge!=3
 drop _merge
 
 save "${working}\Rail_Hourlythru2008.dta", replace
 restore
 
 
 merge 1:m stationname using "${working}\Rail_Hourlyafter2008.dta"
 
 save "${working}\Rail_Hourlyafter2008.dta", replace
 
 
 
*use "${working}\Rail_Hourly.dta" , clear

 use "${working}\CTA_Ridership.dta", clear
 gen day_type = "WK" if inlist(day_of_week, 1,2, 3, 4, 5)
 replace day_type = "SA" if day_of_week == 6
 replace day_type = "SU" if day_of_week== 0 
 gen bad_flag =1 if rides_numb< 5
 replace bad_flag =0 if bad_flag ==.
*duplicates drop stationname year month day_type , force  
expand 24 , gen(hour) 
sort stationname year month day_type
replace hour = mod(_n, 24)

 drop rides rides_numb
 *why the fuck fuck fuck am I doing ti like this 
 merge m:1 stationname year month day_type hour using "${working}\Rail_Hourly_Full.dta"
 drop if _merge==2 
 drop _merge 


 
 sort year month stat_id day_type hour

 
 
 gen entries_need = entries 
 replace entries_need = entries_need*5 if day_type=="WK"
 bysort month year stat_id hour : egen week_entries = mean(entries_need)
 replace week_entries = week_entries *(3/7)
 
 
 gen entries_weekend = entries if day_type == "SA" | day_type =="SU" 
 bysort month year stat_id hour : egen weekend_entries = mean(entries_weekend)
 
 gen weekday_entries = entries if day_type=="WK"

 
 drop if entries == .
 
 collapse  (median) weekday_entries (first)  weekend_entries week_entries , by( month year stat_id hour) 
 /*
 insted of collapse can use 
 duplicates drop month year stat_id hour, force 
 keep 
 
 */
 save "${working}\Rail_Hourly_w_Ridership.dta", replace 
 
 
 *******************************
 *Hourly indicator 
 *******************************
 
use "${working}\Rail_Hourly_w_Ridership.dta", clear 

gen late = 1 if hour>= 20 | hour <= 4 // late travelesrs between 8 and 4 am
replace late =0 if late== .

gen super_late = 1 if hour>= 22 | hour <= 4 // super late travelesrs between 10 and 4 am
replace super_late =0 if super_late== .

gen commute = 1 if hour>= 7 | hour <= 18 // number of commuters between 7am and 6pm 
replace commute =0 if commute== .

*week_entries weekend_entries
sort stat_id year month 
foreach time in late super_late commute {
foreach rider in weekend_entries week_entries  weekday_entries {

bysort stat_id year month `time' : egen m_`rider'_`time' = mean( `rider')  
replace m_`rider'_`time' = . if `time' == 0
bysort stat_id year month: egen `rider'_`time' = max(m_`rider'_`time')   
}
}
cap drop m_*
drop late super_late commute 
duplicates drop year month stat_id  , force
drop if stat_id ==. 

save  "${working}\Rail_Hourly_w_Ridership_merge.dta", replace  
 
 
 
 
 */
 
 
