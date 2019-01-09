/*
runs regression analysis at the week level. 
This file can be augmented to run for weekend and low crime rates
Simpler to understand less resuts 
*/
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\December\"
set matsize 2000
drop if year>=2016
*figure out why this is 
drop if rides_numb_sum ==0 
drop if bad_flag>0
drop if year<2005 & line_type=="Pink"
*drop if rides_numb_sum <200
*keep $keep_vars $interesting_vars

/*
merge 1:1 stat_id datem using "${clean}\CTA_Week_Indicator.dta", 
drop _merge 
*/


gen time_dum = 1 if year<2006
replace time_dum = 2 if  year>=2006 & year< 2011
replace time_dum =3 if year>=2011  & year<= 2016
count if time_dum==.


sort stat_id time_dum 

by stat_id time_dum :egen mean_crime = mean( A_violent_week)
by stat_id time_dum :egen mean_riders = mean( rides_numb_mean)
gen percap = mean_crime/ mean_riders
xtile xm_crime = percap if time_dum ==2, n(4)
sort stat_id
by stat_id: egen  xm_crime_tile = max( xm_crime)



****************
merge 1:1 week stat_id using  "${working}\spillover_treatment.dta" 


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

**************************************************
*OST CHANGES
***************************************************
***Change model*****************
***Week entire data set 
global fileoutname "MainResultsOst.xml"
global dependent "rides_numb_sum"
*global clusterlevel "vce( cluster stat_id )"
global clusterlevel "robust"
global totalTreat  "S_violent_week_L1_t"
global title "Station Crime and Ridership, Main Spillover"
*global weather "imput_avg_temp prcp " 
**



global fileoutname "Mainfirearmost.xml"
global dependent "rides_numb_sum"
*global clusterlevel "vce( cluster stat_id )" 
global clusterlevel "vce( robust )"
global totalTreat  "S_firearm_week_L1"
global title "Station Crime and Ridership, Main Firearm crime"
*global weather "imput_avg_temp prcp " 
**

global fileoutname "FULLMODEL_OST.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )" 
*global clusterlevel "vce( robust )"
global totalTreat  "S_violent_week_L1_t O_violent_week_L1_t S_property_week_L1_t O_property_week_L1_t S_qual_life_week_L1_t O_qual_life_week_L1_t"
global title "Station Crime and Ridership, Main ALL crime"
*global weather "imput_avg_temp prcp " 
**






*DONE WITH OST CHANGES 
**************************************************


***Change model*****************
***Week entire data set 
global fileoutname "MainResults.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global totalTreat  " i.time_dum#c.S_violent_week_L1 i.time_dum#c.S_violent_week_L2 "
global title "Station Crime and Ridership, Main"
*global weather "imput_avg_temp prcp " 
**


global fileoutname "MainNoTime.xml"
global dependent "rides_numb_sum"
global clusterlevel "robust"
*global clusterlevel "robust"
global totalTreat  "S_violent_week_L1 S_violent_week_L2 "
global title "Station Crime and Ridership, Main Effect does not vary over time"
*global weather "imput_avg_temp prcp " 
**


***Week entire data set 

global fileoutname "Mainfirearm.xml"
global dependent "rides_numb_sum"
*global clusterlevel "vce( cluster stat_id )" 
global clusterlevel "vce( robust )"
global totalTreat  " i.time_dum#c.S_firearm_week_L1 i.time_dum#c.S_firearm_week_L2"
global title "Station Crime and Ridership, Main Firearm crime"
*global weather "imput_avg_temp prcp " 
**


***SEX entire data set 

global fileoutname "MainSEXxml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )" 
global totalTreat  " i.time_dum#c.A_CRIM_SEXUAL_ASSAULT_week_L1 i.time_dum#c.A_CRIM_SEXUAL_ASSAULT_week_L2 i.time_dum#c.A_violentNSEX_week_L1 i.time_dum#c.A_violentNSEX_week_L2"
global title "Station Crime and Ridership, Main Sex  crime"
*global weather "imput_avg_temp prcp " 
**






***Change model*****************
***Week entire data set 
global fileoutname "Main_Outside.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_L1_t i.time_dum#c.S_violent_week_L2_t i.time_dum#c.O_violent_week_L1_t i.time_dum#c.O_violent_week_L2_t"
global title "Station and Outside Crime and Ridership, spillover"
*global weather "imput_avg_temp prcp " 

**Weekend split
global fileoutname "Main_Weekend.xml"
global dependent "rides_numb_wkend"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_L1 i.time_dum#c.S_violent_week_L2 i.time_dum#c.O_violent_week_L1 i.time_dum#c.O_violent_week_L2"
global title "Station and Outside Crime and Ridership, Weekend"
*global weather "imput_avg_temp prcp " 

****Placebo
global fileoutname "PlaceboYear_Outside.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_P1 i.time_dum#c.S_violent_week_P2 i.time_dum#c.O_violent_week_P1 i.time_dum#c.O_violent_week_P2"
global title "Placebo Test 1 year ahead"
*global weather "imput_avg_temp prcp "  

****Placebo
global fileoutname "PlaceboLag_Outside.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_F1 i.time_dum#c.S_violent_week_F2 i.time_dum#c.O_violent_week_F1 i.time_dum#c.O_violent_week_F2"
global title "Placebo Test future week ahead"
*global weather "imput_avg_temp prcp " 


***Get ride of center
global fileoutname "Main_OutsideNoCenter.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_L1 i.time_dum#c.S_violent_week_L2 i.time_dum#c.O_violent_week_L1 i.time_dum#c.O_violent_week_L2"
global title "Station and Outside Crime and Ridership No Center"
*global weather "imput_avg_temp prcp " 
*drop if line_type =="Center"


********Validation
global totalTreat " O_violent_week O_property_week S_property_week S_qual_life_week O_qual_life_week"
global fileoutname "Validation.xml"
global dependent "S_violent_week"
global clusterlevel "vce( cluster stat_id )"
global title "Station_Crime predicted using other crime"
*global weather "imput_avg_temp prcp " 
**

********Validation
global totalTreat " i.time_dum#c.O_violent_week i.time_dum#c.O_property_week i.time_dum#c.S_property_week i.time_dum#c.S_qual_life_week i.time_dum#c.O_qual_life_week"
global fileoutname "Validation1.xml"
global dependent "S_violent_week"
global clusterlevel "vce( cluster stat_id )"
global title "Station_Crime predicted using other crime"
*global weather "imput_avg_temp prcp " 
**

********Validation2
global totalTreat " O_property_week S_property_week S_qual_life_week O_qual_life_week "
global fileoutname "Validation2.xml"
global dependent "A_violent_week"
global clusterlevel "vce( cluster stat_id )"
global title "All_Violent_Crime predicted using other crime"
*global weather "imput_avg_temp prcp " 
**

************validation3 
global totalTreat " O_property_week S_property_week S_qual_life_week O_qual_life_week "
global fileoutname "Validation3.xml"
global dependent "A_violent_week_L1"
global clusterlevel "vce( cluster stat_id )"
global title "Station_Crime predicted using other crime"
*global weather "imput_avg_temp prcp " 
**


global fileoutname "MainResults_AllTreat.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global treat1 "i.time_dum#c.S_ASSAULT_week_L1 i.time_dum#c.S_BATTERY_week_L1 i.time_dum#c.S_ROBBERY_week_L1 i.time_dum#c.S_SEX_OFFENSE_week_L1 "
global treat2 "i.time_dum#c.S_ASSAULT_week_L2 i.time_dum#c.S_BATTERY_week_L2 i.time_dum#c.S_ROBBERY_week_L2 i.time_dum#c.S_SEX_OFFENSE_week_L2 "

global treat3 "i.time_dum#c.O_ASSAULT_week_L1 i.time_dum#c.O_BATTERY_week_L1 i.time_dum#c.O_ROBBERY_week_L1 i.time_dum#c.O_SEX_OFFENSE_week_L1 "
global treat4 "i.time_dum#c.O_ASSAULT_week_L2 i.time_dum#c.O_BATTERY_week_L2 i.time_dum#c.O_ROBBERY_week_L2 i.time_dum#c.O_SEX_OFFENSE_week_L2 "
global treat5 "i.time_dum#c.S_property_week_L1 i.time_dum#c.S_qual_life_week_L1"
global treat6 "i.time_dum#c.S_property_week_L2 i.time_dum#c.S_qual_life_week_L2"

global treat7 "i.time_dum#c.O_property_week_L1 i.time_dum#c.O_qual_life_week_L1"
global treat8 "i.time_dum#c.O_property_week_L2 i.time_dum#c.O_qual_life_week_L2"

global totalTreat  "$treat1 $treat2 $treat3 $treat4 $treat5 $treat6 $treat7 $treat8"
global title "Station Crime and Ridership, Several Treatments"
*global weather "imput_avg_temp prcp " 
**



****
*Checking which observations are driving the positive coefficents in the nonclusterd


**

reg   $dependent A_qual_life_week
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 
  

local case " D"
*"A" "B" "C"
foreach let in  "D" {

local let "D"
areg $dependent  $totalTreat $weather i.stationFE if  ${condition`let'} , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN ${name`let'}") addtext( WeekFE, "X", StationFE, "X", Set , "`case'", weather, "X")
sleep 2000

areg $dependent  $totalTreat $weather i.stationFE  if  ${condition`let'} , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week ${name`let'}") addtext( lineByWeekFE, "X", StationFE, "X", Set , "`case'", weather, "X") 
sleep 2000  

*
areg $dependent  $totalTreat $weather  i.stationFE i.lineByTime  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_TIME ${name`let'}") addtext( WeekFE, "X", StationFE, "X",LinebyTime ,"X" , Set , "`case'", weather, "X")
sleep 2000


areg $dependent  $totalTreat $weather i.stationFE  if  ${condition`let'} , absorb(CrimeByweekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Quint_By_Week ${name`let'}") addtext( CrimeByweekFE, "X", StationFE, "X", Set , "`case'", weather, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE i.stationFE#c.yeartrend  if  ${condition`let'} , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Stat_Trend ${name`let'}") addtext( WeekFE, "X", StationFE Trends, "X", Set , "`case'", weather, "X")
 sleep 2000 
 
areg $dependent  $totalTreat $weather  i.yearmonthFE if  ${condition`let'} , absorb( stationBYmonthFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH ${name`let'}") addtext( yearmonthFE, "X", Station by Month FE , "X",  Set , "`case'", weather, "X")
sleep 2000
/*
areg $dependent  $totalTreat $weather i.linetypeFE  if  ${condition`let'} , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE ${name`let'}") addtext( linetypeFE, "X",WeekFE, "X", Set , "`case'", weather, "X") 
sleep 2000  
*/
}


/*
**********
*Naive regressions 

reg   rides_numb_sum i.time_dum#c.S_violent_week_L1 i.time_dum#c.S_violent_week_L2
outreg2 using "${outputfile1}\Naive_Reg.xml" , title("Naive Regressions")   replace  slow(1000) 
  
  
reg   rides_numb_sum i.time_dum#c.S_violent_week_L1 i.time_dum#c.S_violent_week_L2 ,absorb(stationFE)
outreg2 using "${outputfile1}\Naive_Reg.xml" , append slow(1000)ctitle("stationFE")


areg   rides_numb_sum i.time_dum#c.S_violent_week_L1 i.time_dum#c.S_violent_week_L2, absorb(weekFE)
outreg2 using "${outputfile1}\Naive_Reg.xml" , append slow(1000) ctitle("TimeFE")



*/








**Firearm
*global fileoutname "Prelim_Reg_weekOSTFire.xml"
*global dependent "rides_numb_sum"
*global totalTreat  "S_firearm_week_L1 S_firearm_week_L2"

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

/*
****************
*gen placebo var 
foreach crime in "S_violent_week" "O_violent_week" {
local crimename =subinstr("`crime'","_week","",.)
di "`crimename'"

sort stat_id weekFE

gen `crimename'_week_P1 =  `crimename'_week[_n-1+52] if stat_id[_n]==stat_id[_n-1+52] & week[_n] ==  weekFE[_n-1 +52]+1 -52
gen `crimename'_week_P2 =  `crimename'_week[_n-2+52] if stat_id[_n]==stat_id[_n-2+52] & week[_n] ==  weekFE[_n-2+52]+2 -52
}

foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_week","",.)
di "`crimename'"

sort stat_id weekFE

gen `crimename'_week_L1 =  `crimename'_week[_n+1] if stat_id[_n]==stat_id[_n+1] & weekFE[_n] ==  weekFE[_n+1]-1
gen `crimename'_week_L2 =  `crimename'_week[_n+2] if stat_id[_n]==stat_id[_n+2] & weekFE[_n] ==  weekFE[_n+2]-2
}
*/
