
/*
preserve 
use "${clean}\Week_reference.dta", clear 
gen week_of_year = week(datem)
save "${clean}\Week_reference.dta", replace 
collapse (first) week_of_year, by(week)
save "${working}\Week_reference1.dta" , replace
restore 
*/


use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

xtile xm_inc_tile= hinc,  n(4)
egen IncByweekFE = group(weekFE xm_inc_tile)
egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen stationBYmonthFE = group(stat_id month)
egen lineByWeekFE = group( line_type weekFE) 
gen yeartrend = year-2000
egen yearmonthFE = group(year month)
egen clusterWeekFE = group(Cluster_id weekFE)
egen clusterWeek2FE = group(Cluster_id2 weekFE) 
egen distanceWeekFE = group(center_ref weekFE)


merge m:1 week using "${working}\Week_reference1.dta"
drop if _merge==2 
drop _merge

egen stat_week_of_year = group(stat_id week_of_year)
/*
gen ln_rides_numb_sum = ln(rides_numb_sum)
gen ln_rides_numb_wkend = ln(rides_numb_wkend)
*/


global outputfile1 "${analysis}\Paper\Regressions\Just_Station\"
global fileoutname "Testing_other.xml"
global dependent "ln_rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"

global totalTreatb1 " S_violent_week_before6  S_violent_week_before5 S_violent_week_before4  S_violent_week_before3  S_violent_week_before2  S_violent_week_before1  S_violent_week"
global totalTreata1 "S_violent_week_after1 S_violent_week_after2  S_violent_week_after3 S_violent_week_after4  S_violent_week_after5 S_violent_week_after6 S_violent_week_a7decay S_violent_week_a7decay2 "

global totalTreatb2 " SD_violent_week_before6  SD_violent_week_before5 SD_violent_week_before4  SD_violent_week_before3  SD_violent_week_before2  SD_violent_week_before1  SD_violent_week"
global totalTreata2 "SD_violent_week_after1 SD_violent_week_after2  SD_violent_week_after3 SD_violent_week_after4   SD_violent_week_after5 SD_violent_week_after6 SD_violent_week_a7decay SD_violent_week_a7decay2 "

global totalTreatb3 " SD_firearm_week_before6  SD_firearm_week_before5 SD_firearm_week_before4  SD_firearm_week_before3  SD_firearm_week_before2  SD_firearm_week_before1  SD_firearm_week"
global totalTreata3 "SD_firearm_week_after1 SD_firearm_week_after2   SD_firearm_week_after3 SD_firearm_week_after4   SD_firearm_week_after5 SD_firearm_week_after6  SD_firearm_week_a7decay SD_firearm_week_a7decay2 "

global totalTreatb4 " D_HOMICIDE_week_before6  D_HOMICIDE_week_before5 D_HOMICIDE_week_before4  D_HOMICIDE_week_before3  D_HOMICIDE_week_before2  D_HOMICIDE_week_before1  D_HOMICIDE_week"
global totalTreata4 "D_HOMICIDE_week_after1 D_HOMICIDE_week_after2   D_HOMICIDE_week_after3  D_HOMICIDE_week_after4  D_HOMICIDE_week_after5 D_HOMICIDE_week_after6 D_HOMICIDE_week_a7decay D_HOMICIDE_week_a7decay2 "

global totalTreatb5 " S_violent_wkOV_before6  S_violent_wkOV_before5 S_violent_wkOV_before4  S_violent_wkOV_before3  S_violent_wkOV_before2  S_violent_wkOV_before1  S_violent_wkOV"
global totalTreata5 "S_violent_wkOV_after1 S_violent_wkOV_after2  S_violent_wkOV_after3 S_violent_wkOV_after4  S_violent_wkOV_after5 S_violent_wkOV_after6 S_violent_wkOV_a7decay S_violent_wkOV_a7decay2 "

global totalTreatb6 " SD_violent_wkOV_before6  SD_violent_wkOV_before5 SD_violent_wkOV_before4  SD_violent_wkOV_before3  SD_violent_wkOV_before2  SD_violent_wkOV_before1  SD_violent_wkOV"
global totalTreata6 "SD_violent_wkOV_after1 SD_violent_wkOV_after2  SD_violent_wkOV_after3 SD_violent_wkOV_after4   SD_violent_wkOV_after5 SD_violent_wkOV_after6 SD_violent_wkOV_a7decay SD_violent_wkOV_a7decay2 "

global totalTreatb7 " SD_firearm_wkOV_before6  SD_firearm_wkOV_before5 SD_firearm_wkOV_before4  SD_firearm_wkOV_before3  SD_firearm_wkOV_before2  SD_firearm_wkOV_before1  SD_firearm_wkOV"
global totalTreata7 "SD_firearm_wkOV_after1 SD_firearm_wkOV_after2   SD_firearm_wkOV_after3 SD_firearm_wkOV_after4   SD_firearm_wkOV_after5 SD_firearm_wkOV_after6  SD_firearm_wkOV_a7decay SD_firearm_wkOV_a7decay2 "

global totalTreatb8 " D_HOMICIDE_wkOV_before6  D_HOMICIDE_wkOV_before5 D_HOMICIDE_wkOV_before4  D_HOMICIDE_wkOV_before3  D_HOMICIDE_wkOV_before2  D_HOMICIDE_wkOV_before1  D_HOMICIDE_wkOV"
global totalTreata8 "D_HOMICIDE_wkOV_after1 D_HOMICIDE_wkOV_after2   D_HOMICIDE_wkOV_after3  D_HOMICIDE_wkOV_after4  D_HOMICIDE_wkOV_after5 D_HOMICIDE_wkOV_after6 D_HOMICIDE_wkOV_a7decay D_HOMICIDE_wkOV_a7decay2 "




global depA " rides_numb_sum"
global depB "ln_rides_numb_sum"
global depC "ln_rides_numb_wkend"

reg   rides_numb_sum 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 

foreach let in "C" {
foreach i in  4 5   {

global dependent "${dep`let'}"
global totalTreat " ${totalTreatb`i'}  ${totalTreata`i'}"


areg $dependent  $totalTreat   i.yearmonthFE  , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat)  addtext( note , "Station by Month")
sleep 2000

areg $dependent  $totalTreat  i.stationFE  , absorb(clusterWeekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat)  addtext(  note , "ClusterWeek", Case, "`i' `let'")
sleep 2000

areg $dependent  $totalTreat  i.stationFE i.stationFE#c.imput_avg_temp i.stationFE#c.imput_avg_temp#c.imput_avg_temp  , absorb(yearmonthFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat)  addtext(  note , "temperature quadratic", Case, "`i' `let'")
sleep 2000

areg $dependent  $totalTreat i.year $demograph i.stationFE , absorb(week_of_year)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) addtext( note , "week of year", Case, "`i' `let'")
sleep 2000

areg $dependent  $totalTreat i.year  $demograph , absorb(stat_week_of_year)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) addtext( note , "station Week of year", Case, "`i' `let'")
sleep 2000
}
}


/*

areg $dependent  $totalTreat  i.stationFE   , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat)  addtext( note , "Main", Case, "`i' `let'")
sleep 2000




*/
