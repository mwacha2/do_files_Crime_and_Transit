/*
Event study framework. Compare the same station before and after 


*/


use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\OST_sug\"
set matsize 2000

drop if year>=2016

*ds *_week ,
foreach crime in "S_violent_week"{
local crimename =subinstr("`crime'","_week","",.)
di "`crimename'"

sort stat_id weekFE

gen `crimename'_week_l1 =  `crimename'_week[_n+1] if stat_id[_n]==stat_id[_n+1] & weekFE[_n] ==  weekFE[_n+1]-1
gen `crimename'_week_l2 =  `crimename'_week[_n+2] if stat_id[_n]==stat_id[_n+2] & weekFE[_n] ==  weekFE[_n+2]-2
}


gen time  = . 




***********

sort stat_id year 
by stat_id year :egen mean_crime = mean( A_violent_week)
xtile xm_crime = mean_crime if year ==2009, n(5)
sort stat_id
by stat_id: egen  xm_crime_tile = max( xm_crime)


**************
*regression 
***************
gen time_dum = 1 if year<2006
replace time_dum = 2 if  year>=2006 & year< 2011
replace time_dum =3 if year>=2011  & year<= 2016
count if time_dum==.

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

global conditionA "year<2006 "
global conditionB "year>2005 & year< 2011"
global conditionC "year>2010  & year< 2016 "
global conditionD "year<2016"


global nameA "2005"
global nameB "2010"
global nameC "2015"
global nameD "All"


*global weather " i.linetypeFE#c.imput_avg_temp i.linetypeFE#c.prcp"
global weather " " 
global totalTreat  "i.time_dum#c.S_violent_week_f1 i.time_dum#c.S_violent_week_f2"
*global clusterlevel "vce( cluster stat_id )"
global clusterlevel "robust"

***Change model*****************
***Week entire data set 
global fileoutname "Prelim_Reg_weekEvent.xml"
global dependent "rides_numb_sum"
**

**Firearm
*global fileoutname "Prelim_Reg_weekOSTFire.xml"
*global dependent "rides_numb_sum"
*global totalTreat  "S_firearm_week_f1 S_firearm_week_f2"

**

**Week low crime areas 
*global fileoutname "Prelim_Reg_week_LOW.xml"
*drop  if low_crime == 0 
*global dependent "rides_numb_sum"
**

***Weekend  entire data set 
*global fileoutname "Prelim_Reg_weekendFriOST.xml"
*global dependent "rides_numb_wkendFr"
**




reg   $dependent $totalTreat
outreg2 using "${outputfile1}\${fileoutname}" , title("CTA Ridership and Crime,Weekly")   replace  slow(1000) 
  
  
* vce(cluster stat_id)

local case " D"
*"A" "B" "C"
foreach let in  "D" {

areg $dependent  $totalTreat $weather i.stationFE if  ${condition`let'} , absorb(weekFE)   robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN ${name`let'}") addtext( WeekFE, "X", StationFE, "X", Set , "`case'", weather, "X", clusterlevel, "Robust")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE  if  ${condition`let'} , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week ${name`let'}") addtext( lineByWeekFE, "X", StationFE, "X", Set , "`case'", weather, "X", clusterlevel, "$clusterlevel" ) 
sleep 2000  
 
areg $dependent  $totalTreat $weather i.stationFE  if  ${condition`let'} , absorb(CrimeByweekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Quint_By_Week ${name`let'}") addtext( CrimeByweekFE, "X", StationFE, "X", Set , "`case'", weather, "X", clusterlevel, "$clusterlevel") 
sleep 2000   
 
areg $dependent  $totalTreat $weather  i.yearmonthFE if  ${condition`let'} , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH ${name`let'}") addtext( yearmonthFE, "X", Station by Month FE , "X",  Set , "`case'", weather, "X", clusterlevel, "$clusterlevel")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE i.stationFE#c.yeartrend  if  ${condition`let'} , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Stat_Trend ${name`let'}") addtext( WeekFE, "X", StationFE Trends, "X", Set , "`case'", weather, "X", clusterlevel, "$clusterlevel")
 sleep 2000

}

