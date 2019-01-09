
  **********************************************
  
 *EXTENSION
 
 ************************************************
 
 
 /*
runs regression analysis at the week level. 
This file can be augmented to run for weekend and low crime rates
Simpler to understand less resuts 
*/
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

global outputfile1 "${analysis}\Paper\Regressions\"
set matsize 2000

cap drop mean_crime
cap drop mean_riders
cap drop percap 
cap drop xm_crime xm_crime_tile

sort stat_id time_dum 

by stat_id time_dum :egen mean_crime = mean( A_violent_week)
by stat_id time_dum :egen mean_riders = mean( rides_numb_mean)

xtile xm_crime = mean_crime if time_dum , n(4)
sort stat_id
by stat_id: egen  xm_crime_tile = max( xm_crime)



*****Descriptive Table********

bysort time_dum: sum D_violent_week D_property_week D_firearm_week D_HOMICIDE_week SD_violent_week SD_property_week SD_firearm_week ///
  C_violent_week C_property_week C_firearm_week SS_violent_week SS_property_week SS_firearm_week

*bad 
foreach var in D_violent_week D_property_week D_firearm_week D_HOMICIDE_week SD_violent_week SD_property_week SD_firearm_week ///
  C_violent_week C_property_week C_firearm_week SS_violent_week SS_property_week SS_firearm_week ///
  {
gen `var'_cnt = 1 if `var'>0
replace  `var'_cnt =0 if `var'_cnt==. 
bysort time_dum:  egen `var'_sum = sum(`var'_cnt)
}

*gives mean number of weeks that are treated 
bysort time_dum: sum D_violent_week_cnt D_property_week_cnt D_firearm_week_cnt D_HOMICIDE_week_cnt SD_violent_week_cnt SD_property_week_cnt SD_firearm_week_cnt ///
  C_violent_week_cnt C_property_week_cnt C_firearm_week_cnt SS_violent_week_cnt SS_property_week_cnt SS_firearm_week_cnt




est clear

*gang statistics by area of the city and section 8 usage. 

 estpost tabstat  D_violent_week_sum D_property_week_sum D_firearm_week_sum D_HOMICIDE_week_sum SD_violent_week_sum SD_property_week_sum SD_firearm_week_sum ///
  C_violent_week_sum C_property_week_sum C_firearm_week_sum SS_violent_week_sum SS_property_week_sum SS_firearm_week_sum ///
  , by(time_dum) statistics(mean sd n) columns(statistics) listwise
 
 esttab using "${outputfile1}\Counts_Summary_New_Crime .csv",  cells("mean sd count") title("Counts by Time")   replace
  
  ***********************************************
  
  
  
