


*****************************
*Line Level 
*****************************

  
use "${clean}\CTA_Crime_Final_w_Line_WEEK.dta" , clear
global outputfile1 "${analysis}\Paper\Regressions\JanuaryReg\"
set matsize 2000
  
drop if line_type=="Center"
  
  
egen linetypeFE = group(line_type)

  
  
global fileoutname "Line_Level_Reg.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster linetypeFE )"
*global clusterlevel "robust"
global title "Crime and Ridership,LineLevel"



global dependent1 "rides_numb_sum"
global totalTreat1  "S_violent_week_L2B S_property_week_L2B O_violent_week_L2B O_property_week_L2B"
global note1 "Station and Outside:Property and Violent Crime"

global dependent2 "rides_numb_sum"
global totalTreat2  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B"
global note2 "Station and Outside: Violent Crime w/ Time Heterogenaity"

global dependent3 "rides_numb_sum"
global totalTreat3  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note3 "Station and Outside: Violent and Property Crime w/ Time Heterogenaity"

global dependent4 "rides_numb_wkend"
global totalTreat4  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note4 "WeekendRidership with Station and Outside: Violent and Property Crime w/ Time Heterogenaity"


*global weather "imput_avg_temp prcp " 
  
  
  
  reg   $dependent A_qual_life_week
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  

foreach x in 1 2 3 4  {
areg ${dependent`x'}  ${totalTreat`x'}  i.linetypeFE $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("MAIN")
sleep 2000

areg ${dependent`x'}  ${totalTreat`x'} i.linetypeFE#i.time_dum $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("Line_By_Time")
sleep 2000
  
  }
 
 
 *************************
 *Line heterogenaity
  global fileoutname "Line_Heterogen_Reg.xml"
  
 global dependent5 "rides_numb_sum"
global totalTreat5  "i.linetypeFE#c.S_violent_week_L2B i.linetypeFE#c.O_violent_week_L2B"
global note5 "Station and Outside: Violent Crime w/ LineHeterogenaty"


 global dependent6 "rides_numb_sum"
global totalTreat6  "i.linetypeFE#c.S_violent_week_L2B i.linetypeFE#c.O_violent_week_L2B i.linetypeFE#c.S_property_week_L2B i.linetypeFE#c.O_property_week_L2B"
global note6 "Station and Outside: Violent Crime w/ LineHeterogenaty"


 global dependent7 "rides_numb_sum"
 global fileoutname "Line_Heterogen_Reg.xml"
global totalTreat7  "i.linetypeFE#c.S_firearm_week_L2B i.linetypeFE#c.O_firearm_week_L2B"
global note7 "Station and Outside: Violent Crime w/ LineHeterogenaty"


  
  reg   $dependent A_qual_life_week
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  

foreach x in 5 6 7   {
 areg ${dependent`x'}  ${totalTreat`x'}  i.linetypeFE $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("MAIN") 
sleep 2000
 
 }
 
 
preserve
collapse ( first) linetypeFE ,by(line_type)
list

restore 
 
 
 ********************************
 *Nearest Station Regressions
 ********************************
 
 use "${clean}\CTA_Crime_Final_Nearest.dta", clear 
 drop if line_type =="Center"
 
global outputfile1 "${analysis}\Paper\Regressions\JanuaryReg\"
global fileoutname "Nearest_StatOutside_Various.xml"
global clusterlevel "vce( cluster stat_id )"


global dependent1 "rides_numb_sum"
global totalTreat1  "S_violent_week_L2B_t S_property_week_L2B_t O_violent_week_L2B_t O_property_week_L2B_t"
global note1 "Station and Outside:Property and Violent Crime"

global dependent2 "rides_numb_sum"
global totalTreat2  "i.time_dum#c.S_violent_week_L2B_t i.time_dum#c.O_violent_week_L2B_t"
global note2 "Station and Outside: Violent Crime w/ Time Heterogenaity"

global dependent3 "rides_numb_sum"
global totalTreat3  "i.time_dum#c.S_violent_week_L2B_t i.time_dum#c.O_violent_week_L2B_t i.time_dum#c.S_property_week_L2B_t i.time_dum#c.O_property_week_L2B_t"
global note3 "Station and Outside: Violent and Property Crime w/ Time Heterogenaity"

global dependent4 "rides_numb_wkend"
global totalTreat4  "i.time_dum#c.S_violent_week_L2B_t i.time_dum#c.O_violent_week_L2B_t i.time_dum#c.S_property_week_L2B_t i.time_dum#c.O_property_week_L2B_t"
global note4 "WeekendRidership with Station and Outside: Violent and Property Crime w/ Time Heterogenaity"

global dependent5 "rides_numb_wkend"
global totalTreat5  "i.time_dum#c.S_firearm_week i.time_dum#c.O_firearm_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B"
global note5 "WeekendRidership with Station and Outside: Violent and Property Crime w/ Time Heterogenaity"



reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
 
foreach x in 1 2 3 4 5{   
areg ${dependent`x'}  ${totalTreat`x'}  i.stationFE $demograph, absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("MAIN") addtext( WeekFE, "X", StationFE, "X", outcome, "${dependent`x'}", note, "${note`x'}" )
sleep 2000

areg ${dependent`x'}  ${totalTreat`x'} i.stationFE $demograph, absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", StationFE, "X", outcome, "${dependent`x'}", note, "${note`x'}") 
sleep 2000  

}

/*
***********
*lagged
**********


******************************
*LAGGED
******************************

global fileoutname "Lagged_Nearest_StatOutside_Various.xml"
reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
 
foreach x in 1 2 3 4 5 {  

areg ${dependent`x'}  ${totalTreat`x'} rides_numb_sum_L3 rides_numb_sum_L52  $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("MAIN") addtext( WeekFE, "X", Lagged, "X", note, "${note`x'}" )
sleep 2000
 
areg ${dependent`x'}  ${totalTreat`x'}  rides_numb_sum_L3  rides_numb_sum_L52  $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", Lagged, "X", note, "${note`x'}") 
sleep 2000  

}

*/
 
 
