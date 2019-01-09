use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

global outputfile1 "${analysis}\Paper\Regressions\JanuaryTaxi\"
set matsize 2000

merge 1:1 stat_id week using "${clean}\Taxi_Rides_PickupsCombined.dta"
drop if _merge !=3


drop if line_type =="Center"


**************
*regression 
***************

egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen lineByMonthFE = group( line_type year  month)
egen stationBYmonthFE = group(stat_id month)
egen monthFE = group(month)
egen lineByWeekFE = group( line_type weekFE) 
gen yeartrend = year-2000
gen yeartrend2 =  yeartrend*yeartrend
egen yearmonthFE = group(year month)
egen CrimeByweekFE = group(weekFE xm_crime_tile)

egen lineByYear = group(line_type year)
egen lineByTime = group( line_type time_dum)
egen stationByTime = group(stationFE time_dum)






global fileoutname "Taxi_StatOutside_Various.xml"
global clusterlevel "vce( cluster stat_id )"

global dependent  "taxi_pickups"

global totalTreat1  "S_violent_week_L2B  O_violent_week_L2B "
global note1 "TaxiUSAGE Station and OutsideProperty and Violent Crime"

global totalTreat2  "S_violent_week_L2B S_property_week_L2B O_violent_week_L2B O_property_week_L2B"
global note2 "TaxiUSAGE Station and OutsideProperty and Violent Crime"

global totalTreat3  "S_firearm_week_L2B O_firearm_week_L2B"
global note3 "TaxiUSAGE Station and Outside Firearm Crime"




reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  

foreach x in 1 2    {
foreach dependent in taxi_pickups taxi_late_pickups  taxi_pickups_wkend  taxi_late_pickups_wkend  {
global   dependent`x'  `dependent' 

di "${totalTreat`x'}"
di "${dependent}"
 
 
areg ${dependent`x'}  ${totalTreat`x'}  i.stationFE  $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("MAIN") addtext( WeekFE, "X", StationFE, "X", outcome, "${dependent`x'}" , note, "${note`x'}" )
sleep 2000

areg ${dependent`x'}  ${totalTreat`x'} i.stationFE $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep(${totalTreat`x'}) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", StationFE, "X", outcome, "${dependent`x'}" , note, "${note`x'}") 
sleep 2000  
}
}
