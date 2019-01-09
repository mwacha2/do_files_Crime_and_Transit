


use "${working}\Week_Level_Crime.dta", clear 
sort stat_id week 
tsset stat_id week

keep stat_id week A_property_week  O_violent_week A_qual_life_week  O_SimpleCrime_week S_SimpleCrime_week  S_property_week   S_qual_life_week  O_property_week   O_qual_life_week 

foreach var in  A_property_week  O_violent_week A_qual_life_week  O_SimpleCrime_week S_SimpleCrime_week  S_property_week   S_qual_life_week  O_property_week   O_qual_life_week  {

gen `var'_before1 =  f1.`var'
gen `var'_after1 =  l1.`var'
replace `var'_before1 =0 if `var'_before1 ==.
replace `var'_after1 =0 if `var'_after1 ==.
}

save "${working}\Week_Level_CrimeTemp.dta", replace  


use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"
drop if line_type=="Center"

drop  A_property_week*  O_violent_week* A_qual_life_week*  O_SimpleCrime_week* S_SimpleCrime_week*  S_property_week*   S_qual_life_week*  O_property_week*   O_qual_life_week

merge 1:1 stat_id week using "${working}\Week_Level_CrimeTemp.dta", update
drop if _merge ==2 
drop _merge

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


gen rides_numb_wkday =  rides_numb_sum - rides_numb_wkend

gen ln_rides_numb_wkday = ln( rides_numb_wkday)
