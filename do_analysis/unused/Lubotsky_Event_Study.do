/*
*Take blue line stations and rescale so that violent crime 15 days before and 15 days after 
*Repeat study but do it for weeks. 
*/


use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 
run "${main}\do_files\Restrict_Station.do"

keep $keep_vars  S_violent_count O_violent_count
*$interesting_vars

keep if line_type=="Blue North"
tsset stat_id datem

areg rides_numb i.day_of_week i.month i.year, absorb(stat_id)
predict ride_num_res, res


cap drop time_event
gen time_event =. 
replace time_event = 0 if S_violent_count>=1

*the order it assignes matters because it does not allow overlapping. allows greater effect 
*for later. 
forvalues i=1(1)14{
replace time_event = `i' if L`i'.S_violent_count>=1 & time_event== . 
}

*think this through 
forvalues i=1(1)14{
local j=-`i'
replace time_event = `j' if F`i'.S_violent_count>=1
}
**************************************
*need to replace overlapping 
*get residuals 


preserve 
keep if year ==2013
drop if datem>mdy(12,19,2015)
drop if time_event==. | time_event==15 | time_event==-15
 collapse (mean) rides_numb ride_num_res  , by(time_event)
 ****
 summ ride_num_res rides_numb if  time_event>0
 summ ride_num_res rides_numb if  time_event<0 
 **
sort time_event
twoway (line rides_numb time_event) , title( "Event_Study Ridership") name(graph1, replace)
twoway (line ride_num_res time_event) , title( "Event_Study Residual ") name(graph2, replace)
graph combine graph1 graph2
graph export "${main}\analysis\motivation_graph\Lubotsky_Descriptive\Blue_Line_Event_study.png" , replace

restore 
