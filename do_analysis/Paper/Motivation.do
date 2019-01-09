







use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"





collapse  (sum)  rides_numb_sum S_violent_week  O_violent_week  O_property_week S_property_week A_violent_week   ,by(year)

replace  rides_numb_sum= rides_numb_sum/1000000

twoway (line rides_numb year, yaxis(1)) ///
 (line S_violent_week year, yaxis(2))  ///
 , title( "Ridership (in hundred thousands) and Crime Over Time") legend(label(1 "Ridership") label(2 "Station_Crime") )

 graph export "${main}\analysis\Paper\Motivation\Ridership_Crime_overTime.png" , replace


twoway (line rides_numb year, yaxis(1)) ///
 (line A_violent_week year, yaxis(2))  ///
 , title( "Ridership (in hundred thousands) and Crime Over Time") legend(label(1 "Ridership") label(2 "All Crime") )

 graph export "${main}\analysis\Paper\Motivation\Ridership_AllCrime_overTime.png" , replace




 
 
 
 ********************************************************************************
 
 *station violent crime
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"
drop if line_type =="Brown"
drop if line_type =="Pink"


sort stat_id time_dum 

by stat_id time_dum :egen mean_crime = mean( S_violent_week)

xtile xm_crime = mean_crime if time_dum , n(4)
sort stat_id
by stat_id: egen  xm_crime_tile = max( xm_crime)
gen  xm_crime_2001 = xm_crime if year ==2001 
by stat_id: egen  xm_crime_tile2001 = max(xm_crime_2001)


**************

collapse (mean) rides_numb_sum (sum) S_violent_week A_violent_week,  by( year stat_id )
*biggest reductiosn in crime
gen m_crime_2002 = A_violent_week if year ==2002
gen m_crime_2012 = A_violent_week if year ==2014

bysort stat_id : egen crime_2002 = max( m_crime_2002)
bysort stat_id : egen crime_2012 = max( m_crime_2012)
gen diff_1 = crime_2012 - crime_2002


xtile xm_crime = diff_1 , n(4)
by stat_id: egen  xm_crime_tile = max( xm_crime)
gen  xm_crime_2001 = xm_crime_tile if year ==2001 
by stat_id: egen  xm_crime_tile2001 = max(xm_crime_2001)



*collapse (mean) rides_numb_sum (sum) A_violent_week,  by( year xm_crime_tile2001)

collapse (sum) rides_numb_sum  A_violent_week diff_1,  by( year xm_crime_tile2001)


sort year 

twoway (line rides_numb_sum year if xm_crime_tile2001==1 ) ///
(line rides_numb_sum year if xm_crime_tile2001==2 ) ///
(line rides_numb_sum year if xm_crime_tile2001==3 )  ///
(line rides_numb_sum year if xm_crime_tile2001==4 ),  legend(label(1 "Quartile 1") label(2 "Quartile 2")  label(3 "Quartile 3" ) label(4 "Quartile 4" ))

























/*
/*summary charts for lubotsky
Want to include tend of crime and ridership over time * collapse by week 

day of the week trend for ridership and crime for two years 
*nice and simple 
*/

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 
run "${main}\do_files\Restrict_Station.do"

*keep $keep_vars $interesting_vars
drop if year>=2016
*figure out why this is 
drop if line_type =="Brown" | line_type =="Pink"



**************************
*first do over time 
**************************
cap drop year_month
gen year_month = ym(year, month)
format year_month %tm
keep year_month year month rides_numb S_violent_count  O_violent_count  O_property_count S_property_count A_violent_count
collapse (first) year month  (sum)  rides_numb S_violent_count  O_violent_count  O_property_count S_property_count A_violent_count   ,by(year_month)
sort year_month

/*
replace  rides_numb= rides_numb/100000

twoway (line rides_numb year_month, yaxis(1)) ///
 (line S_violent_count year_month, yaxis(2)) , title( "Ridership and Crime Over Time")
graph export "${main}\analysis\Paper\Motivation\Ridership_Crime_overTime.png" , replace

twoway (line rides_numb year_month) if year>2007 & year<2016 , name(rides, replace) title("Ridership Over Time")
twoway  (line A_violent_count year_month) if year>2007 & year<2016 , name(crime, replace)  title("Crime Near and At Stations")
graph  combine  rides crime  
graph export "${main}\analysis\Paper\Motivation\Ridership_Crime_overTimeCombined.png" ,replace 
*/
*************************************
*************************************

collapse  (sum)  rides_numb S_violent_count  O_violent_count  O_property_count S_property_count A_violent_count   ,by(year)



replace  rides_numb= rides_numb/100000

twoway (line rides_numb year, yaxis(1)) ///
 (line S_violent_count year, yaxis(2)) , title( "Ridership (in thousands) and Crime Over Time")
graph export "${main}\analysis\Paper\Motivation\Ridership_Crime_overTime.png" , replace

twoway (line rides_numb year) if year>=2007 & year<=2016 , name(rides, replace) title("Ridership Over Time")
twoway  (line A_violent_count year) if year>=2007 & year<=2016 , name(crime, replace)  title("Crime Near and At Stations")
graph  combine  rides crime  
graph export "${main}\analysis\Paper\Motivation\Ridership_Crime_overTimeCombined.png" ,replace 









*/
















/*

twoway (line rides_numb year_month) if  year<2016 , name(rides, replace) title("Ridership Over Time")
twoway  (line A_violent_count year_month) if  year<2016 , name(crime, replace)  title("Crime Near and At Stations")
graph  combine  rides crime  
graph export "${main}\analysis\Paper\Motivation\Ridership_Crime_overTimeCombined.png" ,replace 


*/

/*
*not needed
twoway (line O_property_count year_month, yaxis(1)) ///
 (line O_violent_count year_month, yaxis(2))
*/




****************
*Day of the week trends 

collapse (sum)  rides_numb S_violent_count  O_violent_count  O_property_count S_property_count ///
 S_CRIM_SEXUAL_ASSAULT_count O_CRIM_SEXUAL_ASSAULT_count O_violentNSEX_count S_violentNSEX_count  /// 
 ,by(day_of_week year )

replace rides_numb= rides_numb/10000
 
 sort year day_of_week 
 global year 2010

 
 twoway (line rides_numb day_of_week if year ==$year, yaxis(1)) ///
(line S_violentNSEX_count day_of_week if year ==$year, yaxis(2)) , title( "Ridership/ViolentCrime and day_of_week in $year")
graph export "${main}\analysis\analysis\Paper\Motivation\Ridership_ViolentCrime_dow${year}.png" , replace

/*
twoway (line rides_numb day_of_week if year ==$year, yaxis(1)) ///
(line O_CRIM_SEXUAL_ASSAULT_count day_of_week if year ==$year, yaxis(2)) , title( "Ridership/Sex Crime and day_of_week in $year")
graph export "${main}\analysis\motivation_graph\Lubotsky_Descriptive\Ridership_SEXCrime_dow${year}.png" , replace
*/














/*

sort  datem
gen week = week(datem)
egen weekFE = group(week year)

gen rides_numb_mean = rides_numb
gen rides_numb_sum = rides_numb


collapse (first) week *_count* year month line_type (sum)  rides_numb_sum (mean) rides_numb_mean , by( stat_id weekFE)

sort weekFE
twoway (bar  rides_numb_sum  weekFE  if year==2010)

  O_violent_count
*/
