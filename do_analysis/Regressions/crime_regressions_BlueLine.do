
*new
*use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\"
global fileoutname "Prelim_Reg_BlueNorth.xml"

keep $keep_vars $interesting_vars
keep if line_type=="Blue North"

*drops top most violent stations 
sort stat_id year 
by stat_id year: egen S_violentSTD_sum= sum( S_violentSTD_count) if year ==2007
by stat_id : egen S_violentSTD_sum1 = max( S_violentSTD_sum)
sum  S_violentSTD_sum if year == 2007, d 
keep if S_violentSTD_sum1 <`r(p50)'  
drop  S_violentSTD_sum S_violentSTD_sum1

*drop crime 



**************
*regression 
***************
egen dayFE = group(datem)
egen dayofWeekFE = group(day_of_week)
egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen lineByMonthFE = group( line_type year  month)
egen stationBYmonthFE = group(stat_id month)
egen stationBYDOWFE = group(stat_id day_of_week)
egen lineBydayFE = group( line_type datem)


/*
description of treatments 
*trt* number of crimes that happened within X days ago not including today
*_sep7_14 number of crimes that happened between 7 and 14 days ago 
*violent_sep14_21 number of crimes that happened between 14 and 21 days ago
the sep variables allow for disipation effect. 
*/





global set1  "S_violentNSEX"
global set2 " $set1  O_violentNSEX "
global set3 "$set2 S_CRIM_SEXUAL_ASSAULT"
global set4 "$set3 O_CRIM_SEXUAL_ASSAULT"
global set5 "$set4 S_property"
global set6 "$set5 O_property"
global set7 "$set6 S_ASSAULTsimp S_BATTERYsimp"
global set8 "$set7 O_ASSAULTsimp O_BATTERYsimp"
global set9 "$set8 S_qual_life_count"


global totalTreat S_violentNSEX_count
reg   rides_numb $totalTreat
outreg2 using "${outputfile1}\${fileoutname}" , title("CTA Ridership and Crime,Restricted to Low Crime Stations in 2007")   replace  slow(1000) 
  
foreach case in 1 2 3 4 5 6 7 {

TreatCreate "${set`case'}"
  
areg rides_numb $totalTreat , absorb(dayFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat)  addtext( DayFE, "X", Set , "`case'")   slow(1000)
 
areg rides_numb $totalTreat i.stationFE, absorb(dayFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) addtext( DayFE, "X", StationFE, "X", Set , "`case'")

areg rides_numb $totalTreat  i.dayofWeekFE i.year , absorb(stationBYmonthFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) addtext( DayoftheWeekFE, "X", YearFE, "X", Station by Month FE , "X", Set , "`case'")

areg rides_numb $totalTreat i.stationFE  , absorb(lineBydayFE)  robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) addtext( LinebyDatFE, "X", StationFE, "X", Set , "`case'")
  
  
  
}  
  
