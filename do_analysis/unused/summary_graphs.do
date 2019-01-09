

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 

sort year 


*number of treated by station in a given year

collapse (first) stationname line_type lines (mean) rides_numb (sum) *_count  if year ==2010, by( stat_id)  
gen notes = "*number of treated by station in 2010" if _n==1 
 
gen ride_numb_scale = rides_numb/
twoway (kdensity violent_count)  (kdensity qual_life_count )  (kdensity property_count)
 twoway (kdensity qual_life_count ) 
 twoway (kdensity property_count)

 
 
 use "${clean}\CTALine_Crime_Final_w_Crime.dta", clear
 sort datem
 gen year=year(datem)
 gen month=month(date)
 
 collapse   (mean) rides_numb (sum) *_count , by( month year line_type)  
 
 
 twoway (line  violent_count month if year==2008) (line  property_count month if year==2010)  , by(line_type) 
