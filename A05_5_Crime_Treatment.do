
use "${working}\Week_Level_Crime.dta", clear 
******
sort stat_id week 
tsset stat_id week //set as panel data with time structure 

*lagged outcome for testing some lagged models 
/*
foreach outcome in  rides_numb_sum rides_numb_wkend rides_numb_wkendFr rides_numb_mean bad_flag {
gen `outcome'_L1 = l1.`outcome'
gen `outcome'_L2 = l2.`outcome'
gen `outcome'_L3 = l3.`outcome'
gen `outcome'_L4 = l4.`outcome'

gen `outcome'_L26 = l26.`outcome'
gen `outcome'_L52 = l52.`outcome'

*gen `outcome'_F1 = f1.`outcome'
*gen `outcome'_F2 = f2.`outcome'
gen `outcome'_F3 = f3.`outcome'
gen `outcome'_F4 = f4.`outcome'
gen `outcome'_F52 = f52.`outcome'
gen `outcome'_F26 = f26.`outcome'
}
*/


*global list1 just limits the data to crimes I care about. 
global listB " S_randomA_week S_randomB_week S_randomC_week S_randtempA_week S_randtempB_week S_randtempC_week  "
global listA " D_violent_week D_property_week D_firearm_week SD_violent_week SD_property_week SD_firearm_week D_HOMICIDE_week C_violent_week C_property_week C_firearm_week SS_violent_week SS_property_week SS_firearm_week  S_SimpleCrime_week A_SimpleCrime_week O_SimpleCrime_week"
global list1 " $listB  $listA A_ROBBERY_week S_ROBBERY_week O_ROBBERY_week  S_CRIM_SEX_ASLT_week O_CRIM_SEX_ASLT_week  A_CRIM_SEX_ASLT_week A_HOMICIDE_week  O_firearm_week A_firearm_week S_firearm_week S_violent_week S_property_week S_qual_life_week O_violent_week O_property_week O_qual_life_week A_violent_week A_property_week A_qual_life_week"


****************************
*Choose options 

*Changes to indicator 
ds  *_week 
foreach var in  `r(varlist)' {
quietly replace `var' = 1 if `var'>0  
}
*If I want an indicator 

preserve 
run "${main}\do_files\Week_Crime_Treatment_w_overlap.do"
rename *_week*  *_wkOV*
save  "${clean}\CTA_Crime_Final_w_CrimeWEEK_overlapp.dta", replace
restore 



run "${main}\do_files\Week_Crime_Treatment_no_overlap.do"
save  "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", replace

*use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
