use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\"
global fileoutname "Prelim_Reg_weekend.xml"

keep $keep_vars $interesting_vars



/*
merge 1:1 stat_id datem using "${clean}\CTA_Week_Indicator.dta", 
drop _merge 
*/
sort  datem
gen week = week(datem)
egen weekFE = group(week year)
*should be same since denominator is the same 
gen rides_numb_mean = rides_numb
gen rides_numb_sum = rides_numb

sort stat_id datem day_of_week  weekFE
gen weekend = 1 if day_of_week ==0 | day_of_week ==6
sort stat_id weekFE weekend 
by  stat_id weekFE weekend : egen rides_numb_wkend =  sum (rides_numb)
replace  rides_numb_wkend = . if weekend==. 

collapse (first) week *_count* year month line_type (max) rides_numb_wkend (sum)  rides_numb_sum (mean) rides_numb_mean , by( stat_id weekFE)

rename *_count *_week 

ds *_week ,
foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_week","",.)
di "`crimename'"

sort stat_id weekFE

gen `crimename'_week_f1 =  `crimename'_week[_n-1] if stat_id[_n]==stat_id[_n-1] & weekFE[_n] ==  weekFE[_n-1]+1
gen `crimename'_week_f2 =  `crimename'_week[_n-2] if stat_id[_n]==stat_id[_n-2] & weekFE[_n] ==  weekFE[_n-2]+2
}



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

global set0 "  S_SEX_OFFENSE  S_firearm"
global set1  "S_violentNSEX"
global set2 " $set1  O_violentNSEX "
global set3 "$set2 S_CRIM_SEXUAL_ASSAULT"
global set4 "$set3 O_CRIM_SEXUAL_ASSAULT"
global set5 "$set4 S_property"
global set6 "$set5 O_property"
global set7 "$set6 S_ASSAULTsimp S_BATTERYsimp"
global set8 "$set7 O_ASSAULTsimp O_BATTERYsimp"
global set9 "$set8 S_qual_life_count"
global dependent "rides_numb_wkend"


global totalTreat S_violentNSEX_week
reg   $dependent $totalTreat
outreg2 using "${outputfile1}\${fileoutname}" , title("CTA Ridership and Crime,Weekend")   replace  slow(1000) 
  

  
foreach case in 0 1 2 3 4 5 6 7 {

TreatCreateWeek "${set`case'}"
 
 /*
areg $dependent  $totalTreat , absorb(stationFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat) ctitle("NAIVE_Stat")  addtext( WeekFE, "X", Set , "`case'")   slow(1000)
  
areg $dependent  $totalTreat , absorb(weekFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat) ctitle("NAIVE Week")  addtext( WeekFE, "X", Set , "`case'")   slow(1000)
 */
 
 
areg $dependent  $totalTreat i.stationFE, absorb(weekFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN") addtext( WeekFE, "X", StationFE, "X", Set , "`case'")


*areg $dependent  $totalTreat  i.stationBYmonthFE  i.year , absorb(weekFE) robust
*outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH") addtext( WeekFE, "X", YearFE, "X", Station by Month FE , "X", Set , "`case'")

areg $dependent  $totalTreat i.stationFE  , absorb(lineByWeekFE)  robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week") addtext( lineByWeekFE, "X", StationFE, "X", Set , "`case'") 
  
}  



