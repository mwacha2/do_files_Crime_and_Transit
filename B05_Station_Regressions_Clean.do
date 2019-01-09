/*
Prep datasets for regression all fixed effects 

*/


global demograph_used "imput_avg_temp  hinc  pov_rate mrent mhmval multi crime_age white_hh hispanic_hh black_hh  fem_lab_force unemploy_rate population poverty_int_flabor"
global FEs_used " time_dum stat_id stationname weekFE stationFE linetypeFE stationBYYearFE stationBYmonthFE lineByWeekFE yeartrend yearmonthFE IncByweekFE" 
global treatment_var " month year *CRIM_SEX_ASLT* *_HOMICIDE_*  *_violent_week* *_property* *_firearm*" 
/*
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
label define TIME 1 "2001-2005" 2 "2006-2010" 3 "20110-2015"
label values time_dum TIME

cap label var  $treatment_var   "Station Violent 2w"
cap label var O_violent_week_L2B "Outside Violent 2w"
cap label var S_property_week_L2B "Station Property 2w"
cap label var O_property_week_L2B "Outside Property 2w"
* 
save "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", replace
*/


**********************
*Main Regression 

use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"

*fixed effects 

xtile xm_inc_tile= hinc,  n(4)
egen IncByweekFE = group(weekFE xm_inc_tile)
egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen stationBYmonthFE = group(stat_id month)
egen lineByWeekFE = group( line_type weekFE) 
gen yeartrend = year-2000
egen yearmonthFE = group(year month)
egen clusterWeekFE = group(Cluster_id weekFE)
egen clusterWeek2FE = group(Cluster_id2 weekFE) 
egen distanceWeekFE = group(center_ref weekFE)

keep  $treatment_var line_type week  rides_numb_sum rides_numb_wkend clusterWeekFE  clusterWeek2FE distanceWeekFE $FEs_used $demograph_used
save  "${clean}\Regression\Main_Regression_Data.dta", replace



**********************
*Line Regression 

use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type=="Center"

*fixed effects   
egen linetypeFE = group(line_type)
egen lineByMonthFE = group( line_type month)
egen yearmonthFE = group(year month)
keep  $treatment_var  lineByMonthFE  yearmonthFE weekFE stat_id time_dum linetypeFE rides_numb_sum rides_numb_wkend $demograph_used
save  "${clean}\Regression\Line_Regression_Data.dta", replace



***********************
*Nearest Regression

use "${clean}\CTA_Crime_Final_Nearest.dta", clear 
drop if line_type =="Center"

xtile xm_inc_tile= hinc,  n(4)
egen IncByweekFE = group(weekFE xm_inc_tile)

keep  $treatment_var    rides_numb_sum rides_numb_wkend $FEs_used $demograph_used
save  "${clean}\Regression\Nearest_Regression_Data.dta", replace



************************
*Taxi Data 

use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
merge 1:1 stat_id week using "${clean}\Taxi_Rides_PickupsCombined.dta"
drop if _merge !=3
drop if line_type =="Center"


*fixed effects 
xtile xm_inc_tile= hinc,  n(4)
egen IncByweekFE = group(weekFE xm_inc_tile)
egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen stationBYmonthFE = group(stat_id month)
egen lineByWeekFE = group( line_type weekFE) 
gen yeartrend = year-2000
egen yearmonthFE = group(year month)

keep  $treatment_var    linetypeFE taxi_pickups ///
 taxi_late_pickups  taxi_pickups_wkend  taxi_late_pickups_wkend rides_numb_sum rides_numb_wkend $FEs_used $demograph_used
save  "${clean}\Regression\Taxi_Regression_Data.dta", replace





****************
*Hourly Data 

use "${working}\CTA_Crime_HourlyFinal.dta", clear
merge 1:1 stat_id year month using "${working}\Rail_Hourly_w_Ridership_merge.dta"
*_merge no 2001 and 2017 in the crime data 
drop if _merge !=3
drop if line_type =="Center"


*Fixed effects used 

xtile xm_inc_tile= hinc,  n(4)
egen IncByweekFE = group(weekFE xm_inc_tile)
egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen stationBYmonthFE = group(stat_id month)
egen lineByWeekFE = group( line_type weekFE) 
gen yeartrend = year-2000
egen yearmonthFE = group(year month)
egen lineBymonthFE = group(yearmonthFE line_type)


keep  $treatment_var    linetypeFE lineBymonthFE yearmonthFE ///
 week_entries_late weekend_entries_super_late weekday_entries_late week_entries_super_late ///
 rides_numb_sum rides_numb_wkend $FEs_used $demograph_used
save  "${clean}\Regression\Hourly_Regression_Data.dta", replace

 

