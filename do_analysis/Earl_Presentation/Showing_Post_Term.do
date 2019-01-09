



*imports data 
* run "${main}\do_files\do_analysis\Earl_Presentation\Create_Data_WeekEARL.do"

 
*use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
use  "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear

drop if line_type=="Center"

 
 collapse (first) stationname line_type (sum) SS_violent_week SD_violent_week SS_firearm_week, by(stat_id year)
 
 foreach var in  SS_violent_week SD_violent_week SS_firearm_week {
 local base_year 2001
 
 gen `var'_`base_year' = `var' if year ==`base_year'
 replace `var'_`base_year' = 0 if `var'_`base_year'==.
 replace `var'_`base_year' = 1 if `var'_`base_year'>0
  
sort  stat_id 
by stat_id: egen `var'_`base_year'_post = max(`var'_`base_year')
}




 foreach var in  SS_violent_week SD_violent_week SS_firearm_week {
local base_year 2001
 
sum `var'_`base_year'_post if year ==2015
}
* ok so 64% treated 




 foreach var in  SS_violent_week SD_violent_week SS_firearm_week {
 local below_year 2014

 
gen `var'_`below_year'b = `var' if year <`below_year'
replace `var'_`below_year'b = 0 if `var'_`below_year'b ==.
replace `var'_`below_year'b = 1 if `var'_`below_year'b >0
  
sort  stat_id 
by stat_id: egen `var'_`below_year'b_post = max(`var'_`below_year'b)
}



 foreach var in  SS_violent_week SD_violent_week SS_firearm_week {
 local below_year 2014
sum `var'_`below_year'b_post if year ==2015
}



/*


 gen SD_violent_week_2005 = SD_violent_week  if year ==2005
 gen SS_firearm_week_2005 = SS_firearm_week  if year ==2005
 replace SS_firearm_week_2005 = 0 if SS_firearm_week_2005==.
 replace SD_violent_week_2005 =0 if SD_violent_week_2005==.
 
 replace SS_firearm_week_2005 = 1 if SS_firearm_week_2005>0
 replace SD_violent_week_2005 =1 if SD_violent_week_2005>0
 
 
 
 sort  stat_id 
 by  stat_id : egen SD_violent_week_2005_post = max(SD_violent_week_2005)
 by  stat_id : egen SS_firearm_week_2005_post = max(SS_firearm_week_2005)
 
 
 
 */
