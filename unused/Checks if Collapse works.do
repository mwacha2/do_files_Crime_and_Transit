
*testing collapse function 


*run top part 


foreach var in S_violent_count SS_violent_count A_property_count S_firearm_count SS_firearm_count A_HOMICIDE_count S_HOMICIDE_count D_HOMICIDE_count {

quietly sum `var' 
local mean = round(`r(mean)',0.001)
di "`var' `r(sum)' and  `mean'"
}




sort stat_id week
collapse (first) week_unscaled   longname weekFE year month line_type stationname ///
  (sum) *_count*  prcp  rides_numb_sum ///
 (mean) bad_flag  imput_avg_temp rides_numb_mean , by( stat_id week)

foreach var in S_violent_count SS_violent_count A_property_count S_firearm_count SS_firearm_count A_HOMICIDE_count S_HOMICIDE_count D_HOMICIDE_count {
quietly sum `var' 
local mean = round(`r(mean)',0.001)
di "WEEK Col `var' `r(sum)' and  `mean'"
}
