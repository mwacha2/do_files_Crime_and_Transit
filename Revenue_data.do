


import delimited using "${raw_data}\Raw_Data_CTA\Revenue_FOIA_20180214.txt", delimiters("|") clear

cap drop date_string
gen date_string = string(date, "%12.0f")

*

gen YEAR = substr(date_string,1,4)
gen MONTH = substr(date_string,5,2)
gen DAY = substr(date_string,7,2)
destring YEAR, replace 
destring MONTH, replace 
destring DAY, replace

cap drop datem
gen datem = mdy(MONTH, DAY, YEAR)
 
format datem %td 



save "${clean}\Revenue_FOIA.dta" , replace 



use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 
keep stat_id stationname 
rename stationname station

collapse (first) station , by(stat_id) 
save "${working}\CTA_Station_Reference_file.dta", replace 




use "${clean}\Revenue_FOIA.dta" , clear


merge m:1 station  using  "${working}\CTA_Station_Reference_file.dta"   
drop if _merge != 3
drop _merge 

save "${clean}\Revenue_FOIA.dta" , replace 

************************
*Weekly
************************


use "${clean}\Revenue_FOIA.dta" , clear

gen student =1 if inlist( product, "AV Student", "AV StudentChild")
gen student_value = value if student ==1 
gen senior_value = value if product=="AV Senior" 
collapse (first) date_string YEAR MONTH DAY (sum) senior_value student_value value, by(station datem)
 
drop if YEAR>2015 

merge m:1 datem using "${clean}\Week_reference.dta"

gen day_of_week = dow(datem)

gen weekend = 1 if inlist(day_of_week , 0, 6)
replace weekend = 0 if inlist(day_of_week, 1, 2, 3 ,4 ,5)

gen weekend_revenue = value if weekend==1
gen weekday_revenue = value if weekend==0 
gen week_revenue = value 

gen student_revenue= student_value
gen senior_revenue = senior_value

collapse (sum) student_revenue senior_revenue  week_revenue weekday_revenue weekend_revenue, by(station week)

rename station stationname 
save "${clean}\Revenue_FOIA_add.dta" , replace




***************************
*Daily
***************************


use "${clean}\Revenue_FOIA.dta" , clear

gen student =1 if inlist( product, "AV Student", "AV StudentChild")
gen student_value = value if student ==1 
gen senior_value = value if product=="AV Senior" 
collapse (first) date_string YEAR MONTH DAY (sum) senior_value student_value value, by(station datem)
 
drop if YEAR>2015 

gen daily_revenue = value 

gen student_revenue= student_value
gen senior_revenue = senior_value

rename station stationname 
save "${clean}\Revenue_FOIA_daily.dta" , replace



