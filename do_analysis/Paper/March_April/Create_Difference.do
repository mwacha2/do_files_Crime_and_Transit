







*imports data 
 run "${main}\do_files\do_analysis\Paper\March_April\Create_Data_Week.do"

 
 


global controls " O_property_week  O_property_week_after1   O_qual_life_week   O_qual_life_week_after1  S_property_week  S_property_week_after1   S_qual_life_week   S_qual_life_week_after1   S_SimpleCrime_week O_SimpleCrime_week S_qual_life_week_after1   S_SimpleCrime_week_after1  O_SimpleCrime_week_after1 "



   

areg ln_rides_numb_sum  $controls  i.stationFE $demograph  , absorb(weekFE)   
predict  res_main_week, residuals

areg ln_rides_numb_sum  $controls  i.stationFE  $demograph , absorb(lineByWeekFE) 
predict  res_line_week, residuals

areg ln_rides_numb_sum $controls  i.stationFE  $demograph , absorb(IncByweekFE) 
predict  res_inc_week, residuals

areg ln_rides_numb_sum $controls  i.stationFE  $demograph , absorb(distanceWeekFE ) 
predict  res_dist_week, residuals

*********************************

areg ln_rides_numb_wkend  $controls  i.stationFE $demograph  , absorb(weekFE)   
predict  res_main_wkend , residuals

areg ln_rides_numb_wkend $controls   i.stationFE  $demograph , absorb(lineByWeekFE) 
predict  res_line_wkend , residuals

areg ln_rides_numb_wkend  $controls  i.stationFE  $demograph , absorb(IncByweekFE) 
predict  res_inc_wkend , residuals

areg ln_rides_numb_wkend  $controls  i.stationFE  $demograph , absorb(distanceWeekFE ) 
predict  res_dist_wkend , residuals
 




********************************************************************************


global outputfile1 "${analysis}\Event_Graph\"

*S_violent SD_violent SD_firearm D_HOMICIDE
*SD_firearm_wkOV


foreach crime in  SD_violent_wkOV SD_firearm_wkOV D_HOMICIDE_wkOV {
preserve

*wkOV
global crime `crime'

gen time_ref = .
replace time_ref =0 if ${crime}>=1   
forvalues i=4(-1)1{
replace time_ref = `i' if ${crime}_after`i'>=1
replace time_ref = -`i' if ${crime}_before`i'>=1
}

keep if time_ref!= . 
global outcomes " res_main_wkend res_inc_wkend res_dist_wkend  res_main_week res_inc_week res_dist_week "
collapse (mean) ${outcomes}, by(time_ref)

foreach out in $outcomes {
twoway (line `out' time_ref , xline(0, lwidth(vthin)) title("`out' $crime ",size(small))  , ytitle("") xtitle("")  name(`out', replace) nodraw)
}
graph combine  $outcomes , ycommon name(combined, replace) note( "Plot of residuals in ref to crime", size(vsmall) ) 
graph display combined
 graph export "${outputfile1}\${crime}_graph.png" , replace  width(1000)  height(800) 

restore 
}
