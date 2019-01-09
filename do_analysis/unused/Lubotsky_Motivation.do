
/*summary charts for lubotsky
Want to include tend of crime and ridership over time * collapse by week 

day of the week trend for ridership and crime for two years 
*nice and simple 
*/

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 
run "${main}\do_files\Restrict_Station.do"

keep $keep_vars $interesting_vars



**************************
*first do over time 
**************************
cap drop year_month
gen year_month = ym(year, month)
format year_month %tm
keep year_month rides_numb S_violent_count  O_violent_count  O_property_count S_property_count
collapse (sum)  rides_numb S_violent_count  O_violent_count  O_property_count S_property_count   ,by(year_month)
sort year_month

replace  rides_numb= rides_numb/100000

twoway (line rides_numb year_month, yaxis(1)) ///
 (line S_violent_count year_month, yaxis(2)) , title( "Ridership and Crime Over Time")
graph export "${main}\analysis\motivation_graph\Lubotsky_Descriptive\Ridership_Crime_overTime.png"

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
graph export "${main}\analysis\motivation_graph\Lubotsky_Descriptive\Ridership_ViolentCrime_dow${year}.png" , replace

twoway (line rides_numb day_of_week if year ==$year, yaxis(1)) ///
(line O_CRIM_SEXUAL_ASSAULT_count day_of_week if year ==$year, yaxis(2)) , title( "Ridership/Sex Crime and day_of_week in $year")
graph export "${main}\analysis\motivation_graph\Lubotsky_Descriptive\Ridership_SEXCrime_dow${year}.png" , replace



















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
