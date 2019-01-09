
*imports data 
 run "${main}\do_files\do_analysis\Earl_Presentation\Create_Data_WeekEARL.do"


 
global outputfile2 "${main}\EARL\EARL_OUTPUT\Regressions\"
set matsize 2000
global fileoutname "Main_Stat_ViolTreatents.xml"


foreach var in SD_violent_wkOV  SD_firearm_wkOV SS_firearm_wkOV D_HOMICIDE_week {
gen `var'_POST =  `var'_after1 + `var'_after2 + `var'_after3 + `var'_after4
replace  `var'_POST =1 if `var'_POST>0
}



global fileoutname "CoeffONE_SD_violent_wkOV.xml"
global totalTreata " SD_violent_wkOV SD_violent_wkOV_POST "



global dependent "ln_rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"

global title "Station Crime and Ridership, Main Robust"




*****************



cap program drop create_Treat 
program create_Treat
cap drop  ${CRIME_ENT}_Hi ${CRIME_ENT}_Lo ${CRIME_ENT}_POST_Hi ${CRIME_ENT}_POST_Lo
cap drop ${CRIME_ENT}_a7decay_Hi ${CRIME_ENT}_a7decay2_Hi    ${CRIME_ENT}_a7decay_Lo ${CRIME_ENT}_a7decay2_Lo 

 gen ${CRIME_ENT}_Hi = ${CRIME_ENT}
 replace  ${CRIME_ENT}_Hi =  0 if ${HET}==0
 gen ${CRIME_ENT}_Lo = ${CRIME_ENT}
 replace  ${CRIME_ENT}_Lo =  0 if ${HET}==1
 
  gen ${CRIME_ENT}_POST_Hi = ${CRIME_ENT}_POST
 replace  ${CRIME_ENT}_POST_Hi =  0 if ${HET}==0
 gen ${CRIME_ENT}_POST_Lo = ${CRIME_ENT}_POST
 replace  ${CRIME_ENT}_POST_Lo =  0 if ${HET}==1
 
  gen  ${CRIME_ENT}_a7decay_Hi =${CRIME_ENT}_a7decay
 replace  ${CRIME_ENT}_a7decay_Hi =  0 if ${HET}==0
   gen  ${CRIME_ENT}_a7decay_Lo = ${CRIME_ENT}_a7decay
 replace  ${CRIME_ENT}_a7decay_Lo =  0 if ${HET}==1
 
  
  gen  ${CRIME_ENT}_a7decay2_Hi = ${CRIME_ENT}_a7decay2
 replace  ${CRIME_ENT}_a7decay2_Hi =  0 if ${HET}==0
   gen  ${CRIME_ENT}_a7decay2_Lo = ${CRIME_ENT}_a7decay2
 replace  ${CRIME_ENT}_a7decay2_Lo =  0 if ${HET}==1
 

 global totalTreat "  ${CRIME_ENT}_Hi ${CRIME_ENT}_Lo ${CRIME_ENT}_POST_Hi ${CRIME_ENT}_POST_Lo  ${CRIME_ENT}_a7decay_Hi ${CRIME_ENT}_a7decay2_Hi    ${CRIME_ENT}_a7decay_Lo ${CRIME_ENT}_a7decay2_Lo "
local spot: word 1 of $totalTreat
di "`spot'"

*global crime= subinstr("`spot'" , "_week_before4" ,"", .)
global crime= subinstr("`spot'" , "_wkOV_before4" ,"", .)
di "$crime"
global crime_l =subinstr("`spot'" , "_before4" ,"", .)
di "$crime_l"
 
end 
 

 
 
 
global outputfile2 "${main}\EARL\EARL_OUTPUT\TheoryTest\"
set matsize 2000
global fileoutname "Main_Stat_ViolTreatents.xml"



global dependent "ln_rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"

global title "Station Crime and Ridership, Main Robust"



*global controls " O_property_week  O_property_week_after1   O_qual_life_week   O_qual_life_week_after1  S_property_week  S_property_week_after1   S_qual_life_week   S_qual_life_week_after1   S_SimpleCrime_week O_SimpleCrime_week S_qual_life_week_after1   S_SimpleCrime_week_after1  O_SimpleCrime_week_after1 "
global control1 "  O_property_week O_qual_life_week S_property_week  S_SimpleCrime_week O_SimpleCrime_week "
global control2 "  O_property_week_before1  S_property_week_before1  S_SimpleCrime_week_before1 O_SimpleCrime_week_before1 "
global control3 "  O_property_week_after1  S_property_week_after1  S_SimpleCrime_week_after1 O_SimpleCrime_week_after1 "
global control4 "  O_property_week_after2  S_property_week_after2  S_SimpleCrime_week_after2 O_SimpleCrime_week_after2 "
global control5 "  O_property_week_before2  S_property_week_before2  S_SimpleCrime_week_before2 O_SimpleCrime_week_before2 "

global control " $control1 $control2 $control3 $control4 $control5 " 
global othercontrol "  "


global dependentA "ln_rides_numb_sum"
global controlsA " "
global fileoutnameA "NoCControlWeek"
global titleA "Week Ridership"


global dependentB "ln_rides_numb_sum"
global controlsB " ${controls} "
global fileoutnameB "CControl_Week"
global titleB "Coefficents on Treatment with Log Entire Week Ridership Outcome"

global dependentC "ln_rides_numb_wkend"
global controlsC " "
global fileoutnameC "NoCControl_WeekEND"
global titleC "Log Weekend Ridershidership"

global dependentD "ln_rides_numb_wkend"
global controlsD "  ${controls}"
global fileoutnameD "CControl_WeekEND"
global titleD "Coefficents on Treatment with Log Entire Weekend Ridership Outcome"


global dependentE "ln_rides_numb_wkday"
global controlsE "  ${controls}"
global fileoutnameE "CControl_WeekDAY"
global titleE "Coefficents on Treatment with Log Entire Weekday Ridership Outcome"



gen INCOME_split = 1 if  xm_inc_tile>2
replace INCOME_split = 0 if  xm_inc_tile<=2
gen white_split = 1 if  xm_white_hh>2
replace white_split = 0 if  xm_white_hh<=2


gen weekend_split = 1 if  xm_wk_ratio>2
replace weekend_split = 0 if  xm_wk_ratio<=2

gen crime_split = 1 if xm_basic_crime>2
replace crime_split = 0 if xm_basic_crime<=2


global HET  weekend_split

 foreach i in B D     {  


global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}"
global title "${title`i'}"

reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , title("$title")   replace  slow(1000) 


global CRIME_ENT SD_violent_wkOV
 create_Treat
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$crime ") addtext( WeekFE, "X", StationFE, "X", HET , "$HET" )
sleep 2000

 

global CRIME_ENT SS_firearm_wkOV
 create_Treat
areg $dependent  $totalTreat  i.stationFE  $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$crime ") addtext( WeekFE, "X", StationFE, "X", HET , "$HET" )
sleep 2000  


global CRIME_ENT  SD_firearm_wkOV
 create_Treat
areg $dependent  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$crime ") addtext( WeekFE, "X", StationFE, "X", HET , "$HET" )
sleep 2000  


global CRIME_ENT D_HOMICIDE_week
 create_Treat
areg $dependent  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$crime ") addtext( WeekFE, "X", StationFE, "X", HET , "$HET" )
sleep 2000


} 



