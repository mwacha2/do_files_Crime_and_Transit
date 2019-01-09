


clear
set obs 1 
gen CTA_crime= . 
forvalue year=2001(1)2017{
append using "${working}\CTACrimedataVIS_`year'.dta" , force 

replace CTA_crime = 1 if  inlist(locationdescript , "CTA PLATFORM" ,"CTA TRAIN", "CTA L TRAIN", "CTA L PLATFORM", "CTA STATION")
replace CTA_crime = 0 if CTA_crime== .
keep if CTA_crime==1
}


rename_primary // program 

merge m:1 station_id using "${working}\CTA_StationXY.dta"
drop if _merge==2
drop _merge  

merge m:1   primarytype description  using "${working}\CTACrime_Prob.dta"  
drop if _merge==2
drop _merge 

merge m:1   primarytype description  using "${working}\CTACrime_Prob_Entire_City.dta"



gen violent_ind = 1 if inlist(primarytype, "ROBBERY", "BATTERY", "HOMICIDE", "ASSAULT", "CRIM_SEX_ASLT") // broken
keep if violent_ind==1

drop datem 
gen date2 = subinstr( date1,"0:00:00", "", .)
gen datem = date(date2, "MDY",2000)
format %td datem

keep stat_id datem  prob_of_crime prop_of_prime prob_of_crime_city prop_of_prime_city

merge m:m datem using "${clean}\Week_reference.dta"

*least likely crime 
collapse (min) prob_of_crime prop_of_prime prob_of_crime_city prop_of_prime_city, ///
by(stat_id week_unscaled)

foreach var in prob_of_crime prop_of_prime prob_of_crime_city prop_of_prime_city{
replace `var' = 1-`var' // makes the least probable crimes close to 1 
}


save "${working}\Crime_Probabilities.dta" , replace  
*****************************************
