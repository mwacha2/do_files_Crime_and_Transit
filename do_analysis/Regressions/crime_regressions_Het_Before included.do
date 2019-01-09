
*allows for before crime effect. 
*use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\"
global fileoutname "Prelim_RegB.xml"

keep $keep_vars $interesting_vars

merge 1:1 stat_id datem using "${clean}\CTA_Crime_w_CrimeBeforeTreatments .dta"
drop _merge 


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

***Creates Before Treatements



cap program drop TreatCreateB 

program define TreatCreateB
*creates treatment list 
args v1
*global crimelist "AASSAULT ABATTERY AASSAULTsimp ACRIM_SEXUAL_ASSAULT " 
global crimelist "`v1'"
global treatSet1 ""
global treatSet2 ""
global treatSet3 ""
global treatSet4 ""
foreach crime in $crimelist {
local var1  "`crime'_count" 
local var2  "`crime'trt7"
local var3  "`crime'_sep7_14" 
local var4  "`crime'_sep14_21"
global var0 "`crime'Btrt7"
global treatSet1 "$treatSet1 `var1'"
global treatSet2 "$treatSet2 `var2'"
global treatSet3 "$treatSet3 `var3'"
global treatSet4 "$treatSet4  `var4'"
global treatSet0 "$treatSet0 `var0'"
} 
global totalTreat "$treatSet0  $treatSet1  $treatSet2 $treatSet3 $treatSet4 "
  
end   



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
outreg2 using "${outputfile1}\${fileoutname}" , title("CTA RidershipCriime Before Treatement")   replace  slow(1000) 
  
foreach case in 1 2 3 4 5 6 7 {

TreatCreateB "${set`case'}"
  
areg rides_numb $totalTreat , absorb(dayFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat)  addtext( DayFE, "X", Set , "`case'")   slow(1000)
 
areg rides_numb $totalTreat i.stationFE, absorb(dayFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) addtext( DayFE, "X", StationFE, "X", Set , "`case'")

areg rides_numb $totalTreat  i.dayofWeekFE i.year , absorb(stationBYmonthFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) addtext( DayoftheWeekFE, "X", YearFE, "X", Station by Month FE , "X", Set , "`case'")

areg rides_numb $totalTreat i.stationFE  , absorb(lineBydayFE)  robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) addtext( LinebyDatFE, "X", StationFE, "X", Set , "`case'")
  
  

}  
  
****
