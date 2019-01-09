


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




 use "${working}\CTA_Ridership.dta", clear
 gen day_type = "WK" if inlist(day_of_week, 1,2, 3, 4, 5)
 replace day_type = "SA" if day_of_week == 6
 replace day_type = "SU" if day_of_week== 0 
 
*duplicates drop stationname year month day_type , force  
expand 24 , gen(hour) 
sort stationname year month day_type
replace hour = mod(_n, 24)

 drop rides rides_numb
 *why the fuck fuck fuck am I doing ti like this 
 merge m:1 stationname year month day_type hour using "${working}\Rail_Hourlyafter2008.dta" 
 
 
 drop if _merge==2 
 drop _merge 

 
 
 use "${working}\Rail_Hourlyafter2008.dta" , clear 
 drop if inlist(day_type, "SA", "SU")
 merge 1:m stationname year month using "${working}\CTA_Ridership.dta"
