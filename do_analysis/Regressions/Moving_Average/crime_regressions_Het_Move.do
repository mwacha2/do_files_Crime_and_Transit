
*new
*use "${clean}\CTA_Crime_Final_w_Crime.dta", clear 

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\"
global fileoutname "Prelim_Reg.xml"

keep $keep_vars $interesting_vars

merge 1:1 stat_id datem using "${clean}\CTA_Crime_w_CrimeMoverAVGTreatments.dta", 
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
egen stationBYYEAR = group(stat_id year)
egen lineBydayFE = group( line_type datem)
egen monthFE = group(month) 

/*
description of treatments 
*trt* number of crimes that happened within X days ago not including today
*_sep7_14 number of crimes that happened between 7 and 14 days ago 
*violent_sep14_21 number of crimes that happened between 14 and 21 days ago
the sep variables allow for disipation effect. 
*/




global set0 "  S_SEX_OFFENSE  S_firearm"
global set1  "S_violentNSEX "
global set2 " $set1  O_violentNSEX "
global set3 "$set2 S_CRIM_SEXUAL_ASSAULT"
global set4 "$set3 O_CRIM_SEXUAL_ASSAULT"
global set5 "$set4 S_property"
global set6 "$set5 O_property"
global set7 "$set6 S_ASSAULTsimp S_BATTERYsimp"
global set8 "$set7 O_ASSAULTsimp O_BATTERYsimp"
global set9 "$set8 S_qual_life"


global totalTreat S_violentNSEX_count
reg   rides_numb $totalTreat
outreg2 using "${outputfile1}\${fileoutname}" , title("CTA Ridership and Crime")   replace  slow(1000) 
  
foreach case in  1 2 3 4 5 6 7 {

TreatCreateMovingAverage "${set`case'}"
  
  /*
areg rides_numb $totalTreat , absorb(dayFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat) ctitle("NAIVE")  addtext( DayFE, "X", Set , "`case'")   slow(1000)

areg rides_numb $totalTreat , absorb(stationFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append keep($totalTreat) ctitle("NAIVE")  addtext( stationFE, "X", Set , "`case'")   slow(1000)
  */
  
  
areg rides_numb $totalTreat i.stationFE, absorb(dayFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN") addtext( DayFE, "X", StationFE, "X", Set , "`case'")

areg rides_numb $totalTreat  i.monthFE i.stationFE, absorb(dayFE) robust 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN2") addtext( DayFE, "X", StationFE, "X", monthFE, "X", Set , "`case'")

areg rides_numb $totalTreat  i.dayofWeekFE  i.year , absorb(stationBYmonthFE) robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH") addtext( DayoftheWeekFE, "X", , Year FE, "X", Station by Month FE , "X", Set , "`case'")

areg rides_numb $totalTreat i.stationFE  , absorb(lineBydayFE)  robust
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_DAY") addtext( LinebyDayFE, "X", StationFE, "X", Set , "`case'")
  
  
  
}  
  
****





/*
/*


 
areg rides_numb $totalTreat , absorb(dayFE) cl(stationFE)
outreg2 using "${outputfile1}\${fileoutname}" , append  addtext( DayFE, "X", NextSet, "X")   slow(1000)
 
  
areg rides_numb $totalTreat i.stationFE, absorb(dayFE) cl(stationFE)
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) addtext( DayFE, "X", StationFE, "X", NextSet, "X")

areg rides_numb $totalTreat  i.dayofWeekFE i.year , absorb(stationBYmonthFE) cl(stationFE)
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) addtext( DayoftheWeekFE, "X", YearFE, "X", Station by Month FE , "X", NextSet, "X")

areg rides_numb $totalTreat i.stationFE  , absorb(lineBydayFE) cl(stationFE)
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) addtext( LinebyDatFE, "X", StationFE, "X", NextSet, "X")
  
  





global treatSet1 "violentNSEXtrt7 propertytrt7 qual_lifetrt7 CRIM_SEXUAL_ASSAULTtrt7"
global treatSet2  "violentNSEX_count property_count qual_life_count CRIM_SEXUAL_ASSAULT_count"  
global treatSet3 "violentNSEX_sep7_14 property_sep7_14 qual_life_sep7_14 CRIM_SEXUAL_ASSAULT_sep7_14"
global treatSet4 "violentNSEX_sep14_21 property_sep14_21 qual_life_sep14_21 CRIM_SEXUAL_ASSAULT_sep14_21"

global totalTreat "$treatSet1  $treatSet2 $treatSet3 $treatSet4"


*creates treatment list 
global crimelist "AASSAULT ABATTERY AASSAULTsimp ACRIM_SEXUAL_ASSAULT " 
global treatSet1 ""
global treatSet2 ""
global treatSet3 ""
global treatSet4 ""
foreach crime in $crimelist {
local var1  "`crime'trt7"
local var2  "`crime'_count"
local var3  "`crime'_sep7_14"
local var4  "`crime'_sep14_21"
global treatSet1 "$treatSet1 `var1'"
global treatSet2 "$treatSet2 `var2'"
global treatSet3 "$treatSet3 `var3'"
global treatSet4 "$treatSet4  `var4'"
} 
global totalTreat "$treatSet1  $treatSet2 $treatSet3 $treatSet4 "
  


*/

egen violentNSEX_count= rowtotal(ROBBERY_count BATTERY_count  /*HOMICIDE_count */  ASSAULT_count)

foreach crime in "violentNSEX_count"{
forvalues i=1(1)30{
local crimename =subinstr("`crime'","_count","",.)  
gen `crimename'_c_daym`i' = `crimename'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
replace `crimename'_c_daym`i' =0 if  `crimename'_c_daym`i' ==. 
}
}
*copy and pasted what is above
sort stat_id datem 
ds *_count
foreach crime in "violentNSEX_count"{
forvalues i=-10(1)0{
local j = -`i'
local crimename =subinstr("`crime'","_count","",.)  
gen `crimename'_c_daymN`j' = `crimename'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
replace `crimename'_c_daymN`j' =0 if  `crimename'_c_daymN`j' ==. 
}
}

foreach crime in "violentNSEX_count"{
foreach j in  7 9 14 21{
local crimename =subinstr("`crime'","_count","",.)
global sumlist ""
forvalues i=1(1)`j'{
global sumlist " $sumlist `crimename'_c_daym`i'"
}
egen `crimename'trt`j' = rowtotal($sumlist)

}

gen `crimename'_sep7_14 = `crimename'trt14 - `crimename'trt7
gen `crimename'_sep14_21 = `crimename'trt21 - `crimename'trt14
}


areg rides_numb violent_trt14 property_trt14 qual_life_trt14  i.stationFE , absorb(dayFE) 

areg rides_numb *trt14  i.stationFE , absorb(dayFE) 

areg rides_numb  CRIM_SEXUAL_ASSAULTtrt14  i.stationFE , absorb(dayFE) 

areg rides_numb   violent_count violenttrt14  i.stationFE , absorb(dayFE) 


areg rides_numb crime_c_daym1- crime_c_daym9  i.stationFE , absorb(dayFE) 
areg rides_numb violent_count CRIM_SEXUAL_ASSAULTtrt7 CRIM_SEXUAL_ASSAULTtrt7 i.linetypeFE , absorb(dayFE) 



areg rides_numb c.violenttrt7#i.linetypeFE   c.violent_sep7_14#i.linetypeFE c.violent_sep14_21#i.linetypeFE  ///
  i.stationFE , absorb(dayFE) 


areg rides_numb   CRIM_SEXUAL_ASSAULT_count CRIM_SEXUAL_ASSAULTtrt7 CRIM_SEXUAL_ASSAULT_sep7_14 CRIM_SEXUAL_ASSAULT_sep14_21 ///
SEX_OFFENSEtrt7 SEX_OFFENSE_sep7_14 SEX_OFFENSE_sep14_21 i.stationFE, absorb(dayFE) 

ds *count 

foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_count","",.)
gen `crimename'_sep7_14 = `crimename'trt14 - `crimename'trt7
gen `crimename'_sep14_21 = `crimename'trt21 - `crimename'trt14
}


title("CTA Ridership and Crime")


*/
 
