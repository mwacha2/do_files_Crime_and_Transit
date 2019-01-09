
use "${working}\Month_Level_Crime.dta", clear 
******


sort stat_id modate 
tsset stat_id modate //set as panel data with time structure 



*global list1 just limits the data to crimes I care about. 
global listB " S_randomA_week S_randomB_week S_randomC_week S_randtempA_week S_randtempB_week S_randtempC_week  "
global listA " D_violent_week D_property_week D_firearm_week SD_violent_week SD_property_week SD_firearm_week D_HOMICIDE_week C_violent_week C_property_week C_firearm_week SS_violent_week SS_property_week SS_firearm_week  S_SimpleCrime_week A_SimpleCrime_week O_SimpleCrime_week"
global list1 " $listB  $listA A_ROBBERY_week S_ROBBERY_week O_ROBBERY_week  S_CRIM_SEX_ASLT_week O_CRIM_SEX_ASLT_week  A_CRIM_SEX_ASLT_week A_HOMICIDE_week  O_firearm_week A_firearm_week S_firearm_week S_violent_week S_property_week S_qual_life_week O_violent_week O_property_week O_qual_life_week A_violent_week A_property_week A_qual_life_week"


****************************
*Choose options 

*Changes to indicator 

*If I want an indicator 


foreach crime in $list1 {
local c =subinstr("`crime'","_week","",.)

gen `c'_month_after1 =  l1.`c'_month
gen `c'_month_after2 =  l2.`c'_month

gen `c'_month_before1 = f1.`c'_month
gen `c'_month_before2 =  f2.`c'_month
}


save  "${clean}\CTA_Crime_Final_w_CrimeMONTH.dta", replace

*use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
