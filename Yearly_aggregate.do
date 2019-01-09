
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear 

sort stat_id week
collapse (first)   longname    line_type stationname ///
 (max) rides_numb_wkend rides_numb_wkendFr (sum) *_week  prcp  rides_numb_sum ///
 (mean) bad_flag  imput_avg_temp rides_numb_mean , by( stat_id year )

 
 
sort stat_id year 
tsset stat_id year  


drop if line_type =="Center"
drop if line_type =="Brown"
drop if line_type =="Pink"

rename *week* *year*

global list1 "O_firearm_year A_firearm_year S_firearm_year S_violent_year S_property_year S_qual_life_year O_violent_year O_property_year O_qual_life_year A_violent_year A_property_year A_qual_life_year"
foreach crime in $list1 {
local crimename =subinstr("`crime'","_year","",.)

di "`crimename'"
sort stat_id year 

**Treatments

*dont need now 
forvalues i=1(1)2 {
gen `crimename'_year_F`i' = f`i'.`crimename'_year
gen `crimename'_year_L`i' =  l`i'.`crimename'_year 
}

}


gen ln_rides_numb_sum =ln(rides_numb_sum)

egen lineFE = group(line_type)

reg ln_rides_numb_sum   i.stat_id  i.lineFE#c.year S_violent_year_L1  S_property_year_L1  S_violent_year_L2  S_property_year_L2
