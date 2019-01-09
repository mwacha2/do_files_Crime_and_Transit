


use "${working}\CTA_Crime_HourlyFinal.dta", clear


run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\Hours"
set matsize 2000
drop if year>=2016
*figure out why this is 
drop if rides_numb_sum ==0 
drop if bad_flag>2
drop if year<2005 & line_type=="Pink"



*************
*Create outcome
*************

gen late = 1 if hour>= 20 | hour <= 4 // late travelesrs between 8 and 4 am
replace late =0 if late== .

keep if late ==1 
collapse (first) line_type stationname longname  (mean) imput_avg_temp prcp (sum) bad_flag rides_numb_wkend rides_numb_wkendFr rides_numb_sum *week* ,by(stat_id year month late)



gen time_dum = 1 if year<2006
replace time_dum = 2 if  year>=2006 & year< 2011
replace time_dum =3 if year>=2011  & year<= 2016
count if time_dum==.


sort stat_id time_dum 

by stat_id time_dum :egen mean_crime = mean( A_violent_week)
by stat_id time_dum :egen mean_riders = mean( rides_numb_sum)
gen percap = mean_crime/ mean_riders
xtile xm_crime = percap if time_dum ==2, n(4)
sort stat_id
by stat_id: egen  xm_crime_tile = max( xm_crime)



****************



**************
*regression 
***************

egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen lineByMonthFE = group( line_type year  month)
egen stationBYmonthFE = group(stat_id month)
egen monthFE = group(month)
 
gen yeartrend = year-2000
gen yeartrend2 =  yeartrend*yeartrend
egen yearmonthFE = group(year month)
egen CrimeBymonthFE = group(yearmonthFE xm_crime_tile)

egen lineByYear = group(line_type year)
egen lineByTime = group( line_type time_dum)
egen stationByTime = group(stationFE time_dum)

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

global fileoutname "MainResultsOst.xml"
global dependent "weekend_entries"
*global clusterlevel "vce( cluster stat_id )"
global clusterlevel "robust"
global totalTreat  "S_violent_week_L1 O_violent_week_L1 rides_numb_wkend"
global title "Station Crime and Ridership, Main"







reg   $dependent A_qual_life_week
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  
areg $dependent  $totalTreat $weather i.stationFE , absorb(yearmonthFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN") addtext( MonthFE, "X", StationFE, "X", Set , "`case'", weather, "X")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE   , absorb(lineByMonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week") addtext( lineByMonthFE, "X", StationFE, "X", Set , "`case'", weather, "X") 
sleep 2000  

*
areg $dependent  $totalTreat $weather  i.stationFE i.lineByTime  , absorb(yearmonthFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_TIME") addtext( MonthFE, "X", StationFE, "X",LinebyTime ,"X" , Set , "`case'", weather, "X")
sleep 2000


areg $dependent  $totalTreat $weather i.stationFE  , absorb(CrimeBymonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Quint_By_Week") addtext( CrimeByFE, "X", StationFE, "X", Set , "`case'", weather, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE i.stationFE#c.yeartrend  , absorb(yearmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Stat_Trend") addtext( WeekFE, "X", StationFE Trends, "X", Set , "`case'", weather, "X")
 sleep 2000 
 
areg $dependent  $totalTreat $weather  i.yearmonthFE , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH ") addtext( yearmonthFE, "X", Station by Month FE , "X",  Set , "`case'", weather, "X")
sleep 2000
/*
areg $dependent  $totalTreat $weather i.linetypeFE  if  ${condition`let'} , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE") addtext( linetypeFE, "X",WeekFE, "X", Set , "`case'", weather, "X") 
sleep 2000  
*/

