
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
drop if line_type =="Center"
run "${main}\do_files\Restrict_Station.do"
gen mean_ridership = rides_numb_sum

drop if year<2001
drop if year>2017

collapse (mean) mean_ridership (sum)  rides_numb_sum A_violent_week O_violent_week  SS_violent_week  A_HOMICIDE_week   ,by(year)

replace rides_numb_sum = rides_numb_sum/1000000
replace  mean_ridership= mean_ridership/1000
drop if year<2001
drop if year>2017


twoway (line rides_numb_sum year, yaxis(1) , ytitle(" Total Ridership (Millions)",axis(1) )) ///
 (line SS_violent_week year, yaxis(2) , ytitle("Sum of Violent Crimes ",axis(2) ))   ///
 , title( "Total Ridership and Near Station Violent Crime", size(medium)) legend(label(1 "Ridership") label(2 "Violent Crime") )  ///
 xtitle( "Year") note("Near Station Violent Crime is violent crime at Stations and within 0.3 miles of Stations" )
 graph export "${main}\Poster\Poster_Presentation_Results\Ridership_StationCrime.png" , replace     width(1950)  height(1200) 
 


*********************************************
*********************************************
use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
drop if line_type =="Center"
run "${main}\do_files\Restrict_Station.do"

drop if year>2015
gen rides_numb_sum = rides_numb
gen mean_ridership = rides_numb_sum


gen quarter = . 
replace quarter= 1 if inlist(month, 1,2,3)
replace quarter= 2 if inlist(month, 4,5,6)
replace quarter= 3 if inlist(month, 7,8,9)
replace quarter= 4 if inlist(month, 10,11,12)
gen quarter_year = yq(year, quarter)
format quarter_year %tq 

collapse (mean) mean_ridership (sum)  rides_numb_sum A_violent_count O_violent_count  SS_violent_count  A_HOMICIDE_count   ,by(quarter_year)

 replace  rides_numb_sum= rides_numb_sum/1000
 
 
 twoway (line rides_numb_sum quarter_year, yaxis(1)) ///
 (line SS_violent_count quarter_year, yaxis(2) )   ///
 , title( "Ridership and Violent Crime at Stations", size(Medium)) subtitle("Aggregated to Quarters", size(small)) legend(label(1 "Ridership") label(2 " Violent Crime At Stations") )  ytitle(" Total Ridership (Thousands per Quarter)", axis(1)) ytitle("Sum of Violent Crimes ", axis(2))
 graph export "${main}\Poster\Poster_Presentation_Results\Ridership_NearStationCrimequarterly.png" , replace   width(1950)  height(1200) 
 



































/*

collapse (mean) mean_ridership (sum)  rides_numb_sum A_violent_week O_violent_week  SS_violent_week  A_HOMICIDE_week   ,by(year)

replace  mean_ridership= mean_ridership/1000

twoway (line mean_ridership year, yaxis(1)) ///
 (line SS_violent_week year, yaxis(2))  ///
 , title( "Mean Weekly Ridership (in thousands) and Violent Crime", size(small)) legend(label(1 "Ridership") label(2 " Station Violent Crime") )
 graph export "${main}\EARL\EARL_OUTPUT\Descriptive\Ridership_StationCrime.png" , replace
 
 
twoway (line mean_ridership year, yaxis(1)) ///
 (line O_violent_week year, yaxis(2))  ///
 , title( "Mean Weekly Ridership (in thousands) and Violent Crime Near Stations", size(small)) legend(label(1 "Ridership") label(2 " Near Station Violent Crime") )
 graph export "${main}\EARL\EARL_OUTPUT\Descriptive\Ridership_NearStationCrime.png" , replace
 
 
 replace  rides_numb_sum= rides_numb_sum/1000000
 
 twoway (line rides_numb_sum year, yaxis(1)) ///
 (line A_violent_week year, yaxis(2))  ///
 , title( "Ridership and Violent Crime", size(Medium)) legend(label(1 "Ridership") label(2 " Violent Crime Near Stations") )  ytitle("Ridership (Million)", axis(1)) ytitle("Crime at Station-Weeks", axis(2))
 graph export "${main}\EARL\EARL_OUTPUT\Descriptive\Ridership_NearStationCrime.png" , replace width(1100)  height(800) 
 

 
 
 
 
 *******************************************
 *******************************************
 
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
drop if line_type =="Center"
run "${main}\do_files\Restrict_Station.do"

drop if year>2015
gen mean_ridership = rides_numb_sum


 gen Month_year = ym(year,month)
     format Month_year %tmMCY
collapse (mean) mean_ridership (sum)  rides_numb_sum A_violent_week O_violent_week  SS_violent_week  A_HOMICIDE_week   ,by(Month_year)

 replace  rides_numb_sum= rides_numb_sum/1000
 
 twoway (line rides_numb_sum Month_year, yaxis(1)) ///
 (line SS_violent_week Month_year, yaxis(2))  ///
 , title( "Ridership and Violent Crime at Stations", size(Medium)) legend(label(1 "Ridership") label(2 " Violent Crime At Stations") )  ytitle("Ridership (Thousands)", axis(1)) ytitle("Crime at Station-Weeks", axis(2))
 graph export "${main}\EARL\EARL_OUTPUT\Descriptive\Ridership_NearStationCrimeMoonth.png" , replace width(1100)  height(800) 
 

 
 
   
use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
drop if line_type =="Center"
run "${main}\do_files\Restrict_Station.do"

drop if year>2015
gen rides_numb_sum = rides_numb
gen mean_ridership = rides_numb_sum


gen quarter = . 
replace quarter= 1 if inlist(month, 1,2,3)
replace quarter= 2 if inlist(month, 4,5,6)
replace quarter= 3 if inlist(month, 7,8,9)
replace quarter= 4 if inlist(month, 10,11,12)
gen quarter_year = yq(year, quarter)
format quarter_year %tq 

collapse (mean) mean_ridership (sum)  rides_numb_sum A_violent_count O_violent_count  SS_violent_count  A_HOMICIDE_count   ,by(quarter_year)

 replace  rides_numb_sum= rides_numb_sum/1000
 
 
 twoway (line rides_numb_sum quarter_year, yaxis(1)) ///
 (line SS_violent_count quarter_year, yaxis(2))  ///
 , title( "Ridership and Violent Crime at Stations", size(Medium)) legend(label(1 "Ridership") label(2 " Violent Crime At Stations") )  ytitle("Ridership (Thousands)", axis(1)) ytitle("Crime at Station-Weeks", axis(2))
 graph export "${main}\EARL\EARL_OUTPUT\Descriptive\Ridership_NearStationCrimequarterly.png" , replace width(1100)  height(800) 

 
 
 ****************************************************
 ****************************************************
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear

merge m:1 year stat_id using "${working}\demographic_info.dta"
drop if _merge ==2
rename _merge mergedemo
drop if line_type =="Center"
run "${main}\do_files\Restrict_Station.do"
replace rides_numb_sum = . if rides_numb_sum<=10
drop if year>2015
gen mean_ridership = rides_numb_sum


gen m_pop_2001 = population   if year ==2001
gen m_pop_2015 = population   if year ==2015
bysort stat_id : egen pop_2001 = max(m_pop_2001)
bysort stat_id : egen pop_2015 = max(m_pop_2015)
gen pop_change = pop_2015- pop_2001
gen pop_gain = "Gain" if pop_change>=0
replace pop_gain = "Loss" if pop_change<0 

collapse (mean) mean_ridership (sum)  rides_numb_sum SS_violent_week  A_violent_week  A_HOMICIDE_week   ,by(year pop_gain)

replace  mean_ridership= mean_ridership/1000

twoway (line mean_ridership year, yaxis(1)) ///
 (line A_violent_week year, yaxis(2))  ///
 , by(pop_gain, title( "Mean Weekly Ridership (in thousands) and Station ViolentCrime Over Time", size(small)) ) legend(label(1 "Ridership") label(2 " Station Violent Crime") )
 graph export "${main}\EARL\EARL_OUTPUT\Descriptive\Ridership_PopGain.png" , replace
 
 */
