
***********************

 *use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta",clear 
 
 run "${main}\do_files\Restrict_Station.do"
 
keep *wkOV ///
stat_id week stationname line_type year month 
 *rename stat_id near_stat_id_2
 rename stationname stationname_merge
 rename  line_type line_type_nerge 
 
save  "${clean}\CTA_Crime_small_WEEK.dta", replace
 
********************



import excel "${raw_data}\StationLines.xlsx", firstrow clear

******************
*shift one up
gen stat_id_up = stat_id[_n+1] if Line==Line[_n+1]
gen stat_id_dn = stat_id[_n-1] if Line==Line[_n-1]
rename stat_id base_stat_id  

preserve 
rename stat_id_up stat_id
drop stat_id_dn
save "${working}\station_up.dta" , replace
restore 

preserve 
rename stat_id_dn stat_id
drop stat_id_up
save "${working}\station_dn.dta" , replace
restore 


*******************
use "${working}\station_up.dta", clear
merge m:m stat_id using "${clean}\CTA_Crime_small_WEEK.dta"
drop if _merge !=3
drop _merge 

collapse (sum) *_wkOV* ,by(base_stat_id week)
rename base_stat_id stat_id
rename *wkOV* *weekup
save "${working}\station_up_collapsed.dta" , replace 


*****************
use "${working}\station_dn.dta", clear
merge m:m stat_id using "${clean}\CTA_Crime_small_WEEK.dta"
drop if _merge !=3
drop _merge 
drop *CRIM_SEX_ASLT_wkOV*
collapse (sum) *wkOV* ,by(base_stat_id week)
rename base_stat_id stat_id
rename *wkOV* *weekdn
save "${working}\station_dn_collapsed.dta", replace 



**********************
*merging all the datasets 

use "${clean}\CTA_Crime_small_WEEK.dta", clear
merge 1:1 week stat_id  using   "${working}\station_dn_collapsed.dta"
drop _merge 

merge 1:1 week stat_id  using   "${working}\station_up_collapsed.dta"
drop _merge 

drop if line_type=="Center"

ds *wkOV*, 
foreach var in `r(varlist)'{
replace `var'= 0 if `var' ==. 
}

*From weekly cleaning 
 
sort stat_id week 
tsset stat_id week 

global listz " SD_violent_week SS_firearm_week SD_firearm_week A_HOMICIDE_week"
foreach crime in $listz {
local c =subinstr("`crime'","_week","",.)


gen `c'_weekT_after1 =  0
gen `c'_weekT_after2 =  0
gen `c'_weekT_after3 =  0
gen `c'_weekT_after4 =  0


gen `c'_weekT_before1 =  0
gen `c'_weekT_before2 =  0
gen `c'_weekT_before3=  0
gen `c'_weekT_before4 =  0


*order matters here
****After 

replace `c'_weekT_after1 =  l1.`c'_weekdn + l1.`c'_weekup
replace `c'_weekT_after2 = l2.`c'_weekdn + l2.`c'_weekup 
replace `c'_weekT_after3 =  l3.`c'_weekdn + l3.`c'_weekup
replace `c'_weekT_after4 =  l4.`c'_weekdn + l4.`c'_weekup

****Before

replace `c'_weekT_before1 =  f1.`c'_weekdn + f1.`c'_weekup 
replace `c'_weekT_before2 =  f2.`c'_weekdn + f2.`c'_weekup 
replace `c'_weekT_before3 =  f3.`c'_weekdn + f3.`c'_weekup 
replace `c'_weekT_before4 =  f4.`c'_weekdn + f4.`c'_weekup 


replace `c'_weekT_after1 =  0 if `c'_weekT_after1 ==.  
replace `c'_weekT_after2 =  0  if `c'_weekT_after2 ==. 
replace `c'_weekT_after3 =  0  if `c'_weekT_after3 ==. 
replace `c'_weekT_after4 =  0  if `c'_weekT_after4 ==. 
replace `c'_weekT_before1 =  0 if  `c'_weekT_before1 ==. 
replace `c'_weekT_before2 =  0 if  `c'_weekT_before2 ==.
replace `c'_weekT_before3=  0  if  `c'_weekT_before3 ==.
replace `c'_weekT_before4 =  0  if  `c'_weekT_before4 ==.

}


keep stat_id  week *weekT*
save "${working}\spillover_treatment.dta" ,replace 




*************
/*

global list1 "SS_firearm_week  SD_firearm_week SD_violent_week   S_HOMICIDE_week      "
foreach crime in $list1 {
local crimename =subinstr("`crime'","_week","",.)

di "`crimename'"
sort stat_id week

gen `crimename'_wkT = `crimename'_weekdn + `crimename'_weekup+`crimename'_week

**Treatments
 
*dont need now 
forvalues i=1(1)8 {
gen `crimename'_wkT_before`i' = f`i'.`crimename'_wkT
gen `crimename'_wkT_after`i' =  l`i'.`crimename'_wkT 
}
di "Made it here 1 "
forvalues j2 = 2(2)12{
local j1 = `j2'-1
gen `crimename'_wkT_after`j1'_`j2' =  0
gen `crimename'_wkT_before`j1'_`j2' =  0
forvalues i= `j1'(1)`j2' {
replace `crimename'_wkT_after`j1'_`j2' =l`i'.`crimename'_wkT + `crimename'_wkT_after`j1'_`j2'
replace  `crimename'_wkT_before`j1'_`j2'  =f`i'.`crimename'_wkT + `crimename'_wkT_before`j1'_`j2'
}
label var  `crimename'_wkT_after`j1'_`j2' "Nearby After`j1'-`j2' a `crimename'"  
label var  `crimename'_wkT_before`j1'_`j2' " NearbyBefore`j1'-`j2' a `crimename'"
}
}
*/
