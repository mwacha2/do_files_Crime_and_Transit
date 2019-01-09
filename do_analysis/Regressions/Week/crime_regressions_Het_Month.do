/*
runs regression analysis at the month  level. 
Doesn't seem to make sense 

*/
use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\"
global fileoutname "Prelim_Reg_Month.xml"

keep $keep_vars $interesting_vars

sort datem 
egen monthFE = group(month)

*should be same since denominator is the same 
gen rides_numb_mean = rides_numb
gen rides_numb_sum = rides_numb

collapse (first)  *_count* year month line_type (sum)  rides_numb_sum (mean) rides_numb_mean , by( stat_id monthFE)
rename *_count *_month


ds *_month ,
foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_month","",.)
di "`crimename'"

sort stat_id year month 
gen `crimename'_month_f1 =  `crimename'_month[_n-1] if stat_id[_n]==stat_id[_n-1] & monthFE[_n] ==  monthFE[_n-1]+1
gen `crimename'_month_f2 =  `crimename'_month[_n-2] if stat_id[_n]==stat_id[_n-2] & monthFE[_n] ==  monthFE[_n-2]+2
}






**************
*regression 
***************

egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen lineByMonthFE = group(line_type month)
egen stationBYyearFE = group( stat_id year)

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
global dependent "rides_numb_sum"


global totalTreat S_violentNSEX_month
reg   $dependent $totalTreat
outreg2 using "${outputfile1}\${fileoutname}" , title("CTA Ridership and Crime,Weekly")   replace  slow(1000) 
  

  
foreach case in 0 1 2 3 4 5 6 7 {

TreatCreateMonth "${set`case'}"
 
 /*
areg $dependent  $totalTreat , absorb(stationFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat) ctitle("NAIVE_Stat")  addtext( WeekFE, "X", Set , "`case'")   slow(1000)
  
areg $dependent  $totalTreat , absorb(monthFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat) ctitle("NAIVE Week")  addtext( WeekFE, "X", Set , "`case'")   slow(1000)
*/ 
 
areg $dependent  $totalTreat i.stationFE, absorb(monthFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN") addtext( monthFE, "X", StationFE, "X", Set , "`case'")

areg $dependent  $totalTreat    i.month , absorb(stationBYyearFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_Year") addtext( YearFE, "X", Station by Year FE , "X", MonthFE, "X", Set , "`case'")


areg $dependent  $totalTreat i.stationFE i.year  , absorb(lineByMonthFE)  robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Month") addtext( lineByMonthFE, "X", StationFE, "X", Year FE, "X", Set , "`case'") 
  
}  









