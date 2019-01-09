
*keep treatment constant 
*arbitrarly choose station daytime violent 

*models 
*set of models - main, line-type, hhincome, station-month  
* control no/control , weekend and weekday 
********************************************


 run "${main}\do_files\do_analysis\Paper\March_April\Create_Data_Week.do"

 
 

global outputfile1 "${analysis}\One_event\"
set matsize 2000
global fileoutname "Main_Stat_ViolTreatents.xml"



global dependent "ln_rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"

global title "Station Crime and Ridership, Main Robust"


foreach var in SD_violent_wkOV  SD_firearm_wkOV D_HOMICIDE_week {
gen `var'_POST =  `var'_after1 + `var'_after2 + `var'_after3 + `var'_after4
replace  `var'_POST =1 if `var'_POST>0
}



global fileoutname "CoeffONE_SD_violent_wkOV.xml"
global totalTreata " SD_violent_wkOV SD_violent_wkOV_POST "



/*
global fileoutname "CoeffONE_SD_violent_wkOV.xml"
global totalTreata " SD_violent_wkOV SD_violent_wkOV_POST "

global fileoutname "CoeffONE_SD_firearm_wkOV.xml"
global totalTreata " SD_firearm_wkOV SD_firearm_wkOV_POST "

global fileoutname "CoeffONE_D_HOMICIDE_week.xml"
global totalTreata " D_HOMICIDE_week D_HOMICIDE_week_POST "

*/



global controls " O_property_week  O_property_week_after1   O_qual_life_week   O_qual_life_week_after1  S_property_week  S_property_week_after1   S_qual_life_week   S_qual_life_week_after1   S_SimpleCrime_week O_SimpleCrime_week"




global dependentA "ln_rides_numb_sum"
global controlsA " "
global NoteA "NoControlWeek"
global titleA "Week Ridership"


global dependentB "ln_rides_numb_sum"
global controlsB " ${controls} "
global NoteB "ControlWeek"
global titleB "Week Ridership with outside crime control"

global dependentC "ln_rides_numb_wkend"
global controlsC " "
global NoteC "NoControlWeekEND"
global titleC "Weekend Ridershidership"

global dependentD "ln_rides_numb_wkend"
global controlsD "  ${controls}"
global NoteD "ControlWeekEND"
global titleD "Weekend Ridershidership with crime controls"



global title "One Treatment, SD_Violent"
global totalTreat "${totalTreata}   "
reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 


 foreach i in A B C D   {  
 

global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global NOTE "${Note`i'} & ${dependent`i'}"
di "$NOTE"

areg $dependent  $totalTreat $weather i.stationFE $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) dec(4) ctitle("MAIN ") addtext( WeekFE, "X", StationFE, "X", note, "$NOTE " )
sleep 2000


areg $dependent  $totalTreat $weather i.stationFE $control  $demograph , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) dec(4) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", StationFE, "X", note, "$NOTE " ) 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE $control  $demograph , absorb(IncByweekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) dec(4) ctitle("Income ") addtext( IncByweekFE, "X", StationFE, "X", note, "$NOTE " ) 
sleep 2000  
 
areg $dependent  $totalTreat $weather i.stationFE $control  $demograph , absorb(distanceWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) dec(4) ctitle("distanceWeekFE ") addtext( distanceWeekFE, "X", StationFE, "X", note, "$NOTE " ) 
sleep 2000   
 
 *i. $control  $demograph , absorb( stationBYmonthFE)
areg $dependent  $totalTreat $weather  i.yearmonthFE  $control  $demograph , absorb(stationBYmonthFE)
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) dec(4) ctitle("STAT_MONTH ") addtext( yearmonthFE, "X", StationbyMonth FE , "X", note, "$NOTE " )
sleep 2000
}



