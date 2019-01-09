*shift station violent crime over by 2 months 

$main_reg
$time 

sort stat_id week 
tsset stat_id week

ds S_violent_week*, 

foreach var in `r(varlist)' {
gen p`var' = l8.`var' // shift 
gen f`var' = f8.`var'
}


global fileoutname "Station_TreatmendPlacebo.xml"
global outputfile1 "${analysis}\Paper\Regressions\Just_Station\"
global totalTreat  " S_violent_week_before3_4 S_violent_week_before1_2 S_violent_week   S_violent_week_after1_2 S_violent_week_after3_4"
global totalTreatP " pS_violent_week_before3_4 pS_violent_week_before1_2 pS_violent_week   pS_violent_week_after1_2 pS_violent_week_after3_4"
global totalTreatf " fS_violent_week_before3_4 fS_violent_week_before1_2 fS_violent_week   fS_violent_week_after1_2  fS_violent_week_after3_4" 

global dependent "rides_numb_wkend "


global clusterlevel  "vce( cluster stat_id )"
global note "Nothing"
*global time "keep if year>2008"
global time ""
  
  
  
  
*initialize 
reg   rides_numb_sum
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  


areg rides_numb_sum  ${totalTreat}  i.stationFE $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreat}) ctitle("Main- Main") addtext( WeekFE, "X", StationFE, "X", note, "${note}" )
sleep 2000
areg rides_numb_sum  ${totalTreat} i.stationFE $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreat}) ctitle(" Main -LbyW") addtext( lineByWeekFE, "X", StationFE, "X", note, "${note}") 
sleep 2000  


areg rides_numb_sum  ${totalTreatf}  i.stationFE $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreatf}) ctitle("Shift Back 8 - Main") addtext( WeekFE, "X", StationFE, "X", note, "${note}" )
sleep 2000
areg rides_numb_sum  ${totalTreatf} i.stationFE $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreatf}) ctitle("Shift Back 8-LbyW") addtext( lineByWeekFE, "X", StationFE, "X", note, "${note}") 
sleep 2000  



areg rides_numb_sum  ${totalTreatP}  i.stationFE $demograph , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreatP}) ctitle("Shift Forward 8- Main") addtext( WeekFE, "X", StationFE, "X", note, "${note}" )
sleep 2000
areg rides_numb_sum  ${totalTreatP} i.stationFE $demograph  , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) label keep(${totalTreatP}) ctitle("Shift Forward 8-LbyW") addtext( lineByWeekFE, "X", StationFE, "X", note, "${note}") 
sleep 2000  


