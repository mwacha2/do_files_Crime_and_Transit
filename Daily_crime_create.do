
global listA " D_violent_week D_property_week D_firearm_week SD_violent_week SD_property_week SD_firearm_week D_HOMICIDE_week    SS_violent_week SS_property_week SS_firearm_week S_SimpleCrime_week A_SimpleCrime_week O_SimpleCrime_week"
global list1 "  $listA A_ROBBERY_week S_ROBBERY_week O_ROBBERY_week  S_CRIM_SEX_ASLT_week O_CRIM_SEX_ASLT_week  A_CRIM_SEX_ASLT_week A_HOMICIDE_week O_firearm_week A_firearm_week S_firearm_week S_violent_week S_property_week S_qual_life_week O_violent_week O_property_week O_qual_life_week A_violent_week A_property_week A_qual_life_week"


run "${main}\do_files\Random_crime_generate.do"

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"

keep $keep_vars $interesting_vars //defined in library 


merge m:1 datem using "${working}\weather.dta" 
drop if _merge ==2
drop _merge 

sort stat_id datem
tsset stat_id datem

run "${main}\do_files\Daily_Crime_Treatment_w_overlap.do"


ds *_count, 
foreach var in `r(varlist)'{
replace `var' =0 if `var'==.  
}

rename *_count *_d_count

merge m:1  datem using   "${clean}\Week_reference.dta"  
drop _merge 


*Bad flag indicator of days that had zero entries. 
gen bad_flag = 1 if rides_numb==0
replace bad_flag=0 if bad_flag==.
*replace rides_numb =. if rides_numb==0 


merge m:1 year stat_id using "${working}\demographic_info.dta"
drop if _merge ==2
rename _merge mergedemo

merge  m:1 stat_id using "${working}\CTA_StationXY_Quartile.dta"
drop if _merge==2
drop _merge

merge m:1 stat_id using "${working}\CTA_StationXY_Cluster.dta"
drop if _merge==2
drop _merge


save "${working}\Daily_Level_Crime.dta", replace 



