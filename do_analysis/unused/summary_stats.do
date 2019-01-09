
***************
*Summary Statistics 
***************


use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 
*restricting to crimes I care about 

global keep_vars "rides_numb year stat_id line_type lines stationname day_of_week"

global interesting_vars "THEFT_count  BURGLARY_count  ARSON_count ROBBERY_count  BATTERYsimp_count BATTERY_count ASSAULTsimp_count  ASSAULT_count  CRIM_SEXUAL_ASSAULT_count  violentSTD_count violentNSEX_count property_count qual_life_count crime_count"
di "$interesting_vars"
keep $keep_vars $interesting_vars
aorder 
*number of treatments by type for each year 
preserve 
collapse (mean) rides_numb (sum) *_count , by( year) 
gen notes = "number of treatments by type for each year " if _n==1 
export excel using "${analysis}\Count_By_Year.xls",firstrow(variables) replace
restore 

*number of treatments by type by day of the week for  one year 
preserve 
collapse (mean) rides_numb (sum) *_count if year==2010 , by(day_of_week line_type ) 
gen notes = "*number of treated by day of week in 2010 by line_type" if _n==1 
export excel using "${analysis}\Count_By_Day.xls",firstrow(variable) replace
restore 

*number of treated by station in a given year
preserve 
collapse (first) stationname line_type lines (mean) rides_numb (sum) *_count  if year ==2010, by( stat_id)  
gen notes = "*number of treated by station in 2010" if _n==1 
export excel using "${analysis}\Count_By_Station.xls",firstrow(variables) replace
restore 

*number of treated by station for all years 
preserve 
collapse (first) stationname line_type lines (mean) rides_numb (sum) *_count  , by( stat_id year)  
gen notes = "*number of crimes  by station for each year " if _n==1 
export excel using "${analysis}\Count_By_StationYear.xls",firstrow(variables) replace
restore 


*number of treatments by type for each year by line 

preserve 
collapse (mean) rides_numb (sum) *_count  if year ==2010, by( line_type)
gen notes = "number of treatments by type for 2010 by line " if _n==1    
export excel using "${analysis}\Count_By_Line.xls",firstrow(variables) replace
restore 


