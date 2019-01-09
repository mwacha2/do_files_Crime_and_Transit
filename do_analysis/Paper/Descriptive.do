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

bysort time_dum: sum S_violent_week O_violent_week S_property_week O_property_week  rides_numb_sum A_HOMICIDE_week

*bad 
foreach var in S_violent_week O_violent_week S_property_week O_property_week A_HOMICIDE_week  {
gen `var'_cnt = 1 if `var'>0
replace  `var'_cnt =0 if `var'_cnt==. 
bysort time_dum:  egen `var'_sum = sum(`var'_cnt)
}

*gives mean number of weeks that are treated 
bysort time_dum: sum A_HOMICIDE_week S_violent_week_cnt S_property_week_cnt  O_violent_week_cnt O_property_week_cnt

*gives number of weeks that they are treated
bysort time_dum: sum A_HOMICIDE_week S_violent_week_sum S_property_week_sum  O_violent_week_sum O_property_week_sum rides_numb_sum

est clear


*gang statistics by area of the city and section 8 usage. 

 estpost tabstat A_HOMICIDE_week S_violent_week_sum S_property_week_sum   O_violent_week_sum  ///
 O_property_week_sum rides_numb_sum  , by(time_dum) statistics(mean sd n) columns(statistics) listwise
 
 esttab using "${outputfile1}\Counts_Summary.csv",  cells("mean sd count") title("Counts by Time")   replace
  
  ***********************************************
  
  
  *************************************************
  *by xtile 
  
  
  cap drop *week_sum
  *bad 
foreach var in S_violent_week O_violent_week S_property_week O_property_week  {
gen `var'_cnt = 1 if `var'>0
replace  `var'_cnt =0 if `var'_cnt==. 
bysort xm_crime:  egen `var'_sum = sum(`var'_cnt)
}

*gives mean number of weeks that are treated 
bysort xm_crime: sum S_violent_week_cnt S_property_week_cnt  O_violent_week_cnt O_property_week_cnt

*gives number of weeks that they are treated
bysort xm_crime: sum S_violent_week_sum S_property_week_sum  O_violent_week_sum O_property_week_sum rides_numb_sum

est clear


*gang statistics by area of the city and section 8 usage. 

 estpost tabstat S_violent_week_sum S_property_week_sum   O_violent_week_sum  ///
 O_property_week_sum rides_numb_sum  , by(xm_crime) statistics(mean sd n) columns(statistics) listwise
 
 esttab using "${outputfile1}\Counts_Summary_xm_crime.csv",  cells("mean sd count") title("Counts by CrimeTile")   replace
 
  
  
  
  
  
  
  
  
  
  
  
  
  
/*

Station Weeks w/ Station Violence Crime
StationWeek w/ Station Property Crime 
Station Weeks w/ Outside Violent Crime
Station Weeks w/ Outside Property  Crime
Mean Sum of Riders in a week.
Observations 

drop if year>=2016
drop if rides_numb_sum ==0 
drop if bad_flag>0

*keep $keep_vars $interesting_vars

/*
merge 1:1 stat_id datem using "${clean}\CTA_Week_Indicator.dta", 
drop _merge 
*/


gen time_dum = 1 if year<2006
replace time_dum = 2 if  year>=2006 & year< 2011
replace time_dum =3 if year>=2011  & year<= 2016
count if time_dum==.

(*/
