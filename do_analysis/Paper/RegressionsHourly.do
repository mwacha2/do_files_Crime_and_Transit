/*
runs regression analysis at the week level. 
This file can be augmented to run for weekend and low crime rates
Simpler to understand less resuts 
*/
use "${working}\CTA_Crime_HourlyFinal.dta", clear

global outputfile1 "${analysis}\Paper\Regressions\JanuaryReg\"
set matsize 2000


merge 1:1 stat_id year month using "${working}\Rail_Hourly_w_Ridership_merge.dta"
*_merge no 2001 and 2017 in the crime data 
drop if _merge !=3
drop if line_type =="Center"

 



**************
*FIXED EFFECTS USED  
***************

egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen lineByMonthFE = group( line_type year  month)
egen stationBYmonthFE = group(stat_id month)
egen monthFE = group(month)
egen lineBymonthFE = group( line_type monthFE) 

egen lineByYear = group(line_type year)
egen lineByTime = group( line_type time_dum)
egen stationByTime = group(stationFE time_dum)



*global weather " i.linetypeFE#c.imput_avg_temp i.linetypeFE#c.prcp"
global weather " " 






global fileoutname "Hourly_StatOutside_Various.xml"
global clusterlevel "vce( cluster stat_id )"

global dependent  "week_entries_late"

global dependent1 "week_entries_late"
global totalTreat1  "S_violent_week_L2B S_property_week_L2B O_violent_week_L2B O_property_week_L2B"
global note1 "Outocome week late entry-Station and Outside:Property and Violent Crime"

global dependent2 "week_entries_late"
global totalTreat2  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B"
global note2 "Outocome week late entry-Station and Outside: Violent Crime w/ Time Heterogenaity"

global dependent3 "week_entries_late"
global totalTreat3  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note3 "Outocome week late entry-Station and Outside: Violent and Property Crime w/ Time Heterogenaity"

global dependent4 "week_entries_super_late"
global totalTreat4  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note4 "Outocome week super late entry-Station and Outside: Violent and Property Crime w/ Time Heterogenaity"


global dependent5 "weekday_entries_late"
global totalTreat5  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note5 "Outocome weekday entry-Station and Outside: Violent and Property Crime w/ Time Heterogenaity"



global dependent6 "weekend_entries_super_late"
global totalTreat6  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note6 "WeekendRidership super late with Station and Outside: Violent and Property Crime w/ Time Heterogenaity"


global dependent7 "weekend_entries_super_late"
global totalTreat7  "i.time_dum#c.S_firearm_week i.time_dum#c.O_firearm_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note7 "WeekendRidership with Station and Outside: Violent and Property Crime w/ Time Heterogenaity"

reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
 
foreach x in  1 2 3 4 5 6  {  

areg ${dependent`x'}  ${totalTreat`x'}  i.stationFE  $demograph , absorb(monthFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("MAIN") addtext( WeekFE, "X", StationFE, "X", note, "${note`x'}" )
sleep 2000
 
areg ${dependent`x'}  ${totalTreat`x'} i.stationFE $demograph  , absorb(lineBymonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", StationFE, "X", note, "${note`x'}") 
sleep 2000  

}


