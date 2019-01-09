
*"${clean}\CTA_Crime_Final_w_CrimeWEEK.dta"
use "${working}\RAW_CTA_CrimeTOTAL.dta", clear 
gen myd = subinstr(date1," 0:00:00","",1)
cap drop datem year
gen datem = date(myd, "MDY",2000)
format %td datem
gen year= year(datem)
gen month = month(datem)

format month %02.0f
gen yyyymm = string(year) + string(month,"%02.0f" ) 



gen Station_Station_ind = 1 if  inlist(locationdescript, "CTA STATION", "CTA PLATFORM", "CTA L PLATFORM")
replace Station_Station_ind=0 if Station_Station_ind==. 
keep if Station_Station_ind==1 

collapse (first) longname stationname (sum) *_count ,by( yyyymm hour stat_id)  

egen violent_count= rowtotal(ROBBERY_count BATTERY_count  HOMICIDE_count   ASSAULT_count  CRIM_SEX_ASLT_count)
label var violent_count "Violent Crime- No Simple" 
egen property_count = rowtotal(THEFT_count  BURGLARY_count  ARSON_count  MOTOR_V_THEFT_count)
egen qual_life_count = rowtotal( CRIMINAL_DAMAGE_count  PROSTITUTION_count  NARCOTICS_count )

save "${working}\Hourly_month_crime.dta", replace 




use "${working}\Rail_Hourly_w_Ridership.dta", clear
*I shouldn't have to do this 

duplicates drop year month stat_id  hour , force
rename yyyymm yyyymm_long 
gen yyyymm = string(yyyymm_long)

merge 1:1  yyyymm stat_id hour  using "${working}\Hourly_month_crime.dta" , update 
drop if _merge ==2 


ds *_count, 
foreach var in `r(varlist)' {
quietly replace `var' =0 if `var'==. 
} 


*outcomes : violent_count property_count
global outcome  "property_count" // violent_count property_count qual_life_count 
global rides "entries" // entries weekday_entries weekend_entries week_entries 

egen yyyymmFE= group(yyyymm)

gen time_dum=.
replace time_dum =1 if inrange(year, 2000,2005)
replace time_dum =2 if inrange(year, 2006,2010)
replace time_dum=3 if inrange(year, 2011, 2017)


areg violent_count  week_entries  i.hour i.stat_id#i.time_dum ,  absorb(yyyymmFE) 
areg qual_life_count  week_entries  i.hour i.stat_id#i.time_dum  ,  absorb(yyyymmFE) 





