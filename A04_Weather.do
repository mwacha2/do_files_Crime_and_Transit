/*
Imports weather information. 
*/

import delimited "${raw_data}\WeatherChicago.csv" , clear
*ohare station
keep if station == "USW00094846" // ONLY  ohare station 

gen imput_avg_temp = (tmax+tmin) /2
 label var imput_avg_temp "TEMPERATURE"
 label var prcp "Percipitation"
 
keep date prcp tavg imput_avg_temp 

replace date= subinstr(date,"-","/",.)

gen datem = date(date, "YMD", 2000)
format datem %td

destring date, replace  force

save "${working}\weather.dta" , replace 


