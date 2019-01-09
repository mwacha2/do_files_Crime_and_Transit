************************
*Graphs for Kaestner 
************************

*Crime treatment, all homicide, all violent, station violent
**general crime trends 
**by pop growth vs pop decline 




use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"
replace rides_numb_sum = . if rides_numb_sum<=10

gen mean_ridership = rides_numb_sum



collapse (mean) mean_ridership (sum)  rides_numb_sum S_violent_week  A_violent_week  A_HOMICIDE_week   ,by(year)

replace  rides_numb_sum= rides_numb_sum/1000000

twoway (line rides_numb_sum year, yaxis(1)) ///
 (line S_violent_week year, yaxis(2))  ///
 , title( "Ridership (in hundred thousands) and Station ViolentCrime Over Time", size(small)) legend(label(1 "Ridership") label(2 " Station Violent Crime") )
 graph export "${main}\analysis\Kaestner\Ridership_StationCrime.png" , replace
 
 
 
twoway (line rides_numb_sum year, yaxis(1)) ///
 (line A_violent_week year, yaxis(2))  ///
 , title( "Ridership (in hundred thousands) and Violent Crime Near Stations Over Time", size(small)) legend(label(1 "Ridership") label(2 "Near Station Violent Crime") )
 graph export "${main}\analysis\Kaestner\Ridership_AllCrime_overTime.png" , replace
 
 
twoway (line rides_numb year, yaxis(1)) ///
 (line A_HOMICIDE_week year, yaxis(2))  ///
 , title( "Ridership (in hundred thousands) and Violent Crime Near Stations Over Time", size(small)) legend(label(1 "Ridership") label(2 "Homicides") )
 graph export "${main}\analysis\Kaestner\Ridership_Homicide_overTime.png" , replace
 
 
****************************************************************************************
*Pop Change 
****************************************************************************************
 
 
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"
replace rides_numb_sum = . if rides_numb_sum<=10

gen mean_ridership = rides_numb_sum

/*
merge m:1 year stat_id using "${working}\demographic_info.dta"
drop if _merge ==2
rename _merge mergedemo
*/

 gen m_pop_2001 = population   if year ==2001
gen m_pop_2015 = population   if year ==2015
bysort stat_id : egen pop_2001 = max(m_pop_2001)
bysort stat_id : egen pop_2015 = max(m_pop_2015)
gen pop_change = pop_2015- pop_2001
gen pop_gain = "Gain" if pop_change>=0
replace pop_gain = "Loss" if pop_change<0 

collapse (mean) mean_ridership (sum)  rides_numb_sum S_violent_week  A_violent_week  A_HOMICIDE_week   ,by(year pop_gain)

replace  rides_numb_sum= rides_numb_sum/1000000

twoway (line rides_numb_sum year, yaxis(1)) ///
 (line S_violent_week year, yaxis(2))  ///
 , by(pop_gain, title( "Ridership (in hundred thousands) and Station ViolentCrime Over Time", size(small)) ) legend(label(1 "Ridership") label(2 " Station Violent Crime") )
 graph export "${main}\analysis\Kaestner\Ridership_StationCrime_PopGain.png" , replace
 
 
 
twoway (line rides_numb_sum year, yaxis(1)) ///
 (line A_violent_week year, yaxis(2))  ///
 , by(pop_gain, title( "Ridership (in hundred thousands) and Violent Crime Near Stations Over Time", size(small))) legend(label(1 "Ridership") label(2 "Near Station Violent Crime") )
 graph export "${main}\analysis\Kaestner\Ridership_AllCrime_PopGain.png" , replace
 
 
twoway (line rides_numb year, yaxis(1)) ///
 (line A_HOMICIDE_week year, yaxis(2))  ///
 ,  by(pop_gain, title( "Ridership (in hundred thousands) and Violent Crime Near Stations Over Time", size(small))) legend(label(1 "Ridership") label(2 "Homicides") )
 graph export "${main}\analysis\Kaestner\Ridership_Homicide_PopGain.png" , replace
 


 
****************************************************************************************
*Crime Quintile  
****************************************************************************************
 
 
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"
replace rides_numb_sum = . if rides_numb_sum<=10

gen mean_ridership = rides_numb_sum


preserve 
collapse (mean) mean_ridership (sum)  rides_numb_sum S_violent_week  A_violent_week  A_HOMICIDE_week   ,by(year stat_id )
keep if year ==2001
drop year 
xtile violent_quart2001 = A_violent_week , n(4)
save "${working}\Crime_quartile", replace 
restore 

merge m:1 stat_id using  "${working}\Crime_quartile"
collapse (mean) mean_ridership (sum)  rides_numb_sum S_violent_week  A_violent_week  A_HOMICIDE_week   ,by(year violent_quart2001)

replace  rides_numb_sum= rides_numb_sum/1000000




twoway (line rides_numb_sum year if violent_quart2001==1  ) ///
(line rides_numb_sum year if violent_quart2001==2  ) ///
(line rides_numb_sum year if violent_quart2001==3  ) ///
(line rides_numb_sum year if violent_quart2001==4  ) ///
 , title( "Ridership by Crime Quartile ", size(small)) legend(label(1 "Lowest 1") label(2 "Low 2")  label(3 "High 3")  label(4 "Highest 4")  )
 graph export "${main}\analysis\Kaestner\Ridership__QuartileCrime.png" , replace
 

**************************************
*Crime Change 
***************************************

use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"
replace rides_numb_sum = . if rides_numb_sum<=10

gen mean_ridership = rides_numb_sum



preserve 
collapse (mean) mean_ridership (sum)  rides_numb_sum S_violent_week  A_violent_week  A_HOMICIDE_week   ,by(year stat_id )

 gen m_viol_2001 = A_violent_week   if year ==2001
gen m_viol_2015 = A_violent_week   if year ==2015
bysort stat_id : egen viol_2001 = max(m_viol_2001)
bysort stat_id : egen viol_2015 = max(m_viol_2015)
gen viol_change = viol_2015- viol_2001
 keep if year ==2001 
xtile violent_change = viol_change , n(4)
drop year 
save "${working}\Crime_quartile", replace 
restore 



merge m:1 stat_id using  "${working}\Crime_quartile"
collapse (mean) mean_ridership (sum)  rides_numb_sum S_violent_week  A_violent_week  A_HOMICIDE_week   ,by(year violent_change)


replace  rides_numb_sum= rides_numb_sum/1000000

twoway (line rides_numb_sum year if violent_change==1  ) ///
(line rides_numb_sum year if violent_change==2  ) ///
(line rides_numb_sum year if violent_change==3  ) ///
(line rides_numb_sum year if violent_change==4  ) ///
 , title( "Ridership by Crime Change Quartile ", size(small)) legend(label(1 "Largest Drop 1") label(2 "Large Drop 2")  label(3 "Drop 3")  label(4 "No Drop 4")  )
 graph export "${main}\analysis\Kaestner\Ridership__QuartileChangeCrime.png" , replace
 

 
 
 ****************************************************
 *Descriptives
 ***************************************************
 use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear


cap drop mean_crime
cap drop mean_riders
cap drop percap 
cap drop xm_crime xm_crime_tile

sort stat_id time_dum 

by stat_id time_dum :egen mean_crime = mean( A_violent_week)
by stat_id time_dum :egen mean_riders = mean( rides_numb_mean)

xtile xm_crime = mean_crime if time_dum , n(4)
sort stat_id
by stat_id: egen  xm_crime_tile = max( xm_crime)

*****Descriptive Table********
 *find a better way to create these statistics 
 
 ds *_week*
foreach var in   S_firearm_week O_firearm_week A_HOMICIDE_week S_violent_week /// 
 O_violent_week S_property_week O_property_week  {
replace `var' = 1 if `var'>0  
}
 
 preserve 
 gen count = 1 
 collapse (sum) count  S_firearm_week O_firearm_week A_HOMICIDE_week S_violent_week /// 
 O_violent_week S_property_week O_property_week ,by( time_dum) 
  export excel using   "${main}\analysis\Kaestner\SummaryStat", firstrow(variables) replace
 restore
 
 preserve 
 gen count = 1 
 collapse (sum) count  S_firearm_week O_firearm_week A_HOMICIDE_week S_violent_week /// 
 O_violent_week S_property_week O_property_week ,by( line_type) 
  export excel using  "${main}\analysis\Kaestner\SummaryStat_Line_type" , firstrow(variables) replace
 restore

 preserve 
 gen count = 1 
 collapse (sum) count  S_firearm_week O_firearm_week A_HOMICIDE_week S_violent_week /// 
 O_violent_week S_property_week O_property_week ,by( month) 
  export excel using  "${main}\analysis\Kaestner\SummaryStat_Month" , firstrow(variables) replace
 restore

 
 

 ***********************************
 ****Dispersion throughout the city 
 ***********************************
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 ***************************************************
 *Regressions  Not telling me anything 
 ***************************************************
 
 
  
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"
replace rides_numb_sum = . if rides_numb_sum<=10

gen mean_ridership = rides_numb_sum

collapse (mean) mean_ridership (sum)  rides_numb_sum S_violent_week O_violent_week A_violent_week  A_HOMICIDE_week S_property_week O_property_week A_property_week  ,by(year stat_id )

rename *week *year


tset stat_id year
gen dif1_ridesum = rides_numb_sum- l1.rides_numb_sum
gen dif1_ridemean = mean_ridership -l1.mean_ridership

foreach crime in S_violent_year O_violent_year A_violent_year  A_HOMICIDE_year S_property_year O_property_year A_property_year {
gen diff2_`crime' = l1.`crime' -l2.`crime'
}

reg dif1_ridemean  diff2_S_violent_year diff2_O_violent_year diff2_S_property_year diff2_O_property_year diff2_A_HOMICIDE_year 

reg dif1_ridemean  diff2_A_violent_year  diff2_A_property_year 
reg dif1_ridemean  diff2_A_HOMICIDE_year  


*drop in crime is negative x,
*negative coefficent , means that a drop in crime lead to an increase in ridership
*positive coefficent , means that a drop in crime lead to a drop in ridership 

*negative coefficen, means that an increase in crime lead to decrease in ridership 

