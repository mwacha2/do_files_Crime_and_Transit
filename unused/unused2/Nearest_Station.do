/*
The goal is to give the treatment to the nearest station too. 
drop center areas 


*/


import delimited "${raw_data}\NearestFiveStations.csv", clear
rename from_y cta_y
rename from_x cta_x

save "${working}\NearestStation_XY.dta" , replace  

use "${working}\CTA_StationXY.dta" , clear 
*keep this for merging 
rename cta_x near_x
rename cta_y near_y
rename stat_id near_stat_id 
rename longname near_stat_name
rename lines near_lines
keep near*
save "${working}\Near_XYmergin.dta" , replace  


**********
**********
use "${working}\NearestStation_XY.dta", clear 
merge m:1 cta_x cta_y using  "${working}\CTA_StationXY.dta"
drop _merge
merge m:1 near_x near_y using  "${working}\Near_XYmergin.dta"
drop _merge

forvalues i=1(1)4{
gen near_stat_id_`i' = near_stat_id if near_rank==`i'
gen near_statname_`i' = near_stat_name if near_rank==`i' 
gen near_lines_`i' = near_lines if near_rank==`i'
}

forvalues i=1(1)4 { 
 bysort  stat_id (near_stat_id_`i') : replace  near_stat_id_`i' =  near_stat_id_`i'[_n-1] if   near_stat_id_`i'  ==. 
 }

forvalues i=1(1)4 {  
replace near_statname_`i' ="ZZZZZZZZZZZ" if  near_statname_`i'==""
sort stat_id near_statname_`i' 
bysort stat_id  : replace near_statname_`i' = near_statname_`i'[_n-1] if  near_statname_`i' =="ZZZZZZZZZZZ"

replace near_lines_`i' = "ZZZZZZZZZZZ" if  near_lines_`i'==""
sort stat_id near_lines_`i'
bysort stat_id  : replace near_lines_`i' = near_lines_`i'[_n-1] if  near_lines_`i' =="ZZZZZZZZZZZ"
}
 
 collapse (first) near*    ,by(stat_id) 
 drop near_fid near_dist near_rank near_x near_y
 save "${working}\CTA_Near_Station.dta" , replace  

 
 /*
 what do I want:
 for each station I want to get the crimes of its nearest station. 
 It should be a one to one merge 
 
 */
 use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"
 
keep *_violent_week* *_firearm_week* *_property_week* *_qual_life_week* ///
stat_id week stationname line_type
 *rename stat_id near_stat_id_2
 rename stationname stationname_merge
 rename  line_type line_type_nerge 
 
save  "${clean}\CTA_Crime_small_WEEK.dta", replace
 

 
 use  "${working}\CTA_Near_Station.dta" , clear 
 
 merge m:m near_stat_id_2 using "${clean}\CTA_Crime_small_WEEK.dta"
