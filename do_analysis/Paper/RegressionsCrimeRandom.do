use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

global outputfile1 "${analysis}\Paper\Regressions\JanuaryReg\"
set matsize 2000

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
egen lineByWeekFE = group( line_type weekFE) 
gen yeartrend = year-2000
gen yeartrend2 =  yeartrend*yeartrend
egen yearmonthFE = group(year month)
egen CrimeByweekFE = group(weekFE xm_crime_tile)

egen lineByYear = group(line_type year)
egen lineByTime = group( line_type time_dum)
egen stationByTime = group(stationFE time_dum)



*global weather " i.linetypeFE#c.imput_avg_temp i.linetypeFE#c.prcp"
global weather " " 

global outputfile1 "${analysis}\Paper\Regressions\Show_Random\"
global fileoutname "Randomness.xml"

reg   S_violent_week
outreg2 using "${outputfile1}\${fileoutname}" , title("Showing Randomness,or At least Trying")   replace  slow(1000) 
  

reg S_violent_week O_violent_week S_property_week O_property_week rides_numb_sum  $demograph ,robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000)  ctitle("Simple ")
sleep 2000


areg S_violent_week O_violent_week S_property_week O_property_week   $demograph  i.stationFE ,absorb(week) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop( i.stationFE) ctitle("Fixed Effect ") addtext( WeekFE, "X", StationFE, "X")
sleep 2000

reg S_violent_week O_violent_week S_property_week O_property_week   ///
rides_numb_sum rides_numb_sum_L1 rides_numb_sum_L2 rides_numb_sum_F3 ///
O_violent_week_F1 O_violent_week_L1 O_violent_week_F2 O_violent_week_L2  ///
S_violent_week_L1 S_violent_week_L2 S_violent_week_F1 S_violent_week_F2 $demograph , robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("kitchen sink ")


/*

*******************************************
*Show Regression Crime is Random
*******************************************



global fileoutname "Crime_Random.xml"

reg   S_violent_week 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
reg S_violent_week   O_violent_week   S_property_week O_property_week   rides_numb_sum
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000)  ctitle("MAIN") 
reg S_violent_week   O_violent_week   S_property_week O_property_week   rides_numb_sum rides_numb_sum_L1  rides_numb_sum_L52  $demograph  
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000)  ctitle("MAIN") 

reg S_violent_week   O_violent_week   S_property_week O_property_week  rides_numb_sum rides_numb_sum_L1  rides_numb_sum_L52  $demograph   i.monthFE
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000)  ctitle("MAIN") 

areg S_violent_week   O_violent_week   S_property_week O_property_week  rides_numb_sum  $demograph i.monthFE, absorb( stationFE)
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000)  ctitle("MAIN") drop(stationFE)

*/
