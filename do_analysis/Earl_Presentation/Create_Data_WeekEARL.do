


use "${working}\Week_Level_Crime.dta", clear 
sort stat_id week 
tsset stat_id week

keep stat_id week  A_property_week  O_violent_week A_qual_life_week  O_SimpleCrime_week S_SimpleCrime_week  S_property_week   S_qual_life_week  O_property_week   O_qual_life_week 

foreach var in   A_property_week  O_violent_week A_qual_life_week  O_SimpleCrime_week S_SimpleCrime_week  S_property_week   S_qual_life_week  O_property_week   O_qual_life_week  {

gen `var'_before1 =  f1.`var'
gen `var'_after1 =  l1.`var'
replace `var'_before1 =0 if `var'_before1 ==.
replace `var'_after1 =0 if `var'_after1 ==.

gen `var'_before2 =  f2.`var'
gen `var'_after2 =  l2.`var'
replace `var'_before2 =0 if `var'_before2 ==.
replace `var'_after2 =0 if `var'_after2 ==.


gen `var'_before3 =  f3.`var'
gen `var'_after3 =  l3.`var'
replace `var'_before3 =0 if `var'_before3 ==.
replace `var'_after3 =0 if `var'_after3 ==.

gen `var'_before4 =  f4.`var'
gen `var'_after4 =  l4.`var'
replace `var'_before4 =0 if `var'_before4 ==.
replace `var'_after4 =0 if `var'_after4 ==.
}

save "${working}\Week_Level_CrimeTemp.dta", replace  

 


use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

merge 1:1 stat_id week using "${working}\Week_Level_CrimeTemp.dta", update 

collapse  (sum)  rides_numb_wkend rides_numb_sum A_property_week  O_SimpleCrime_week S_SimpleCrime_week  ,by( stat_id year)

gen ratio_end_to_week = rides_numb_wkend /rides_numb_sum
gen basic_crime =  A_property_week +  O_SimpleCrime_week + S_SimpleCrime_week

xtile xm_wk_ratio_a= ratio_end_to_week if year ==2002,  n(4) 
bysort stat_id : egen  xm_wk_ratio =max(xm_wk_ratio_a)

xtile xm_basic_crime_a= basic_crime if year ==2002,  n(4) 
bysort stat_id : egen  xm_basic_crime =max(xm_basic_crime_a)

collapse (first)   xm_wk_ratio xm_basic_crime, by(stat_id)
save   "${clean}\CTA_Crime_Final_w_CrimeWEEK_info.dta", replace




use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear


drop if line_type ==""
drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"
drop if line_type=="Center"

drop  A_property_week*  O_violent_week* A_qual_life_week*  O_SimpleCrime_week* S_SimpleCrime_week*  S_property_week*   S_qual_life_week*  O_property_week*   O_qual_life_week

merge 1:1 stat_id week using "${working}\Week_Level_CrimeTemp.dta", update
drop if _merge ==2 
drop _merge

merge m:1 stat_id using "${clean}\CTA_Crime_Final_w_CrimeWEEK_info.dta"
drop if _merge ==2 
drop _merge

*xtile made elsewhere 

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

cap drop ln_rides_numb_sum ln_rides_numb_wkend

gen rides_numb_wkday =  rides_numb_sum - rides_numb_wkend

gen ln_rides_numb_wkday = ln( rides_numb_wkday)
gen ln_rides_numb_sum = ln( rides_numb_sum)
gen ln_rides_numb_wkend = ln( rides_numb_wkend)





merge 1:1 stationname week using "${clean}\Revenue_FOIA_add.dta"
drop if _merge==2
drop _merge

gen ln_week_revenue = ln(week_revenue +1)
gen ln_weekend_revenue = ln(weekend_revenue+1) 
gen ln_student_revenue = ln(student_revenue+1)
gen ln_senior_revenue = ln(senior_revenue+1)

 merge 1:1 stat_id week using  "${clean}\Taxi_Rides_PickupsCombined.dta"
 drop if _merge==2 
 drop _merge 
 

 gen ln_taxi_late_pickups =ln(taxi_late_pickups+1)
 gen ln_taxi_late_pickups_wkend = ln(taxi_late_pickups_wkend+1)
 gen ln_taxi_pickups_wkend = ln(taxi_pickups_wkend+1)
 gen ln_taxi_pickups = ln(taxi_pickups+1)
