

use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
merge 1:1 stat_id week using "${clean}\CTA_Crime_Final_w_CrimeWEEK_overlapp.dta", update 
drop _merge
run "${main}\do_files\Restrict_Station.do"

*drop if year>=2016
drop if bad_flag>0

drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"


gen time_dum = 1 if year<2006
replace time_dum = 2 if  year>=2006 & year< 2011
replace time_dum =3 if year>=2011  & year<= 2016
count if time_dum==.


sort stat_id time_dum 

gen ln_rides_numb_wkend = ln(rides_numb_wkend)
gen  ln_rides_numb_wkendFr=  ln(rides_numb_wkendFr)
gen  ln_rides_numb_sum = ln(rides_numb_sum)
gen  ln_rides_numb_mean = ln(rides_numb_mean)


merge m:1 year stat_id using "${working}\demographic_info.dta"
drop if _merge ==2
rename _merge mergedemo

merge  m:1 stat_id using "${working}\CTA_StationXY_Quartile.dta"
drop if _merge==2
drop _merge

merge m:1 stat_id using "${working}\CTA_StationXY_Cluster.dta"
drop if _merge==2
drop _merge

save "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", replace
