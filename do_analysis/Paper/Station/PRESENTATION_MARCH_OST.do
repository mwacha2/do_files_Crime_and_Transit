
*keep treatment constant 
*arbitrarly choose station daytime violent 

*models 
*set of models - main, line-type, hhincome, station-month  
* control no/control , weekend and weekday 
********************************************


use "${working}\Week_Level_Crime.dta", clear 
sort stat_id week 
tsset stat_id week

keep A_property_week  O_violent_week A_qual_life_week stat_id week

foreach var in A_property_week O_violent_week A_qual_life_week {

gen `var'_before1 =  f1.`var'
gen `var'_after1 =  l1.`var'
replace `var'_before1 =0 if `var'_before1 ==.
replace `var'_after1 =0 if `var'_after1 ==.
}

save "${working}\Week_Level_CrimeTemp.dta", replace  


use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

xtile m_xm_inc_tile= hinc if year ==2005,  n(4)
bysort stat_id : egen xm_inc_tile = max(m_xm_inc_tile)


drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"


drop A_property_week*  O_violent_week* A_qual_life_week* 
merge 1:1 stat_id week using "${working}\Week_Level_CrimeTemp.dta", update 
drop _merge 

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
global outputfile1 "${analysis}\Presentation2\"
set matsize 2000
global fileoutname "Main_Stat_ViolTreatents.xml"



global dependent "ln_rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"

global title "Station Crime and Ridership, Main Robust"


/*
global totalTreatb " D_HOMICIDE_week_before4  D_HOMICIDE_week_before3  D_HOMICIDE_week_before2  D_HOMICIDE_week_before1  D_HOMICIDE_week"
global totalTreata "D_HOMICIDE_week_after1 D_HOMICIDE_week_after2  D_HOMICIDE_week_after3 D_HOMICIDE_week_after4  D_HOMICIDE_week_a7decay D_HOMICIDE_week_a7decay2 "
*/

/*
global totalTreatb "  SD_violent_week_before4  SD_violent_week_before3  SD_violent_week_before2  SD_violent_week_before1  SD_violent_week"
global totalTreata "SD_violent_week_after1 SD_violent_week_after2  SD_violent_week_after3 SD_violent_week_after4  SD_violent_week_a7decay SD_violent_week_a7decay2 "
*/



global totalTreatb "  SD_violent_wkOV_before4  SD_violent_wkOV_before3  SD_violent_wkOV_before2  SD_violent_wkOV_before1  SD_violent_wkOV"
global totalTreata "SD_violent_wkOV_after1 SD_violent_wkOV_after2  SD_violent_wkOV_after3 SD_violent_wkOV_after4  SD_violent_wkOV_a7decay SD_violent_wkOV_a7decay2 "




global controls " A_property_week A_property_week_before1 A_property_week_after1   A_qual_life_week  A_qual_life_week_before1 A_qual_life_week_after1"
*



global dependentA "ln_rides_numb_sum"
global controlsA " "
global fileoutnameA "NoControlWeek.xml"
global titleA "Alternative Models: Week Ridership"


global dependentB "ln_rides_numb_sum"
global controlsB " ${controls} "
global fileoutnameB "ControlWeek.xml"
global titleB "Alternative Models: Week Ridership with outside crime control"

global dependentC "ln_rides_numb_wkend"
global controlsC " "
global fileoutnameC "NoControlWeekEND.xml"
global titleC "Alternative Models: Weekend Ridershidership"

global dependentD "ln_rides_numb_wkend"
global controlsD "  ${controls}"
global fileoutnameD "ControlWeekEND.xml"
global titleD "Alternative Models: Weekend Ridershidership with crime controls"





 foreach i in A B C D   {  

global totalTreat "${totalTreatb} ${totalTreata}  "

global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}"
global title "${title`i'}"


reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 



areg $dependent  $totalTreat  $control i.stationFE  , absorb(clusterWeekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat)  ctitle("ClusterWeek")  addtext(  note , "ClusterWeek", Case, "`i' `let'")
sleep 2000

areg $dependent  $totalTreat $control i.stationFE i.stationFE#c.imput_avg_temp i.stationFE#c.imput_avg_temp#c.imput_avg_temp  , absorb(yearmonthFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Temp Quadr") addtext(  note , "temperature quadratic", Case, "`i' `let'")
sleep 2000

areg $dependent  $totalTreat  $control i.year i.stationFE , absorb(week_of_year)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Week of Year") addtext( note , "week of year", Case, "`i' `let'")
sleep 2000

areg $dependent  $totalTreat $control i.year   , absorb(stat_week_of_year)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("Station By Week") addtext( note , "station Week of year", Case, "`i' `let'")
sleep 2000
}



