
*keep treatment constant 
*arbitrarly choose station daytime violent 

*models 
*set of models - main, line-type, hhincome, station-month  
* control no/control , weekend and weekday 
********************************************


global outputfile2   "${analysis}\RegressionsGraph\"

cap program drop save_coeff 
program save_coeff

cap drop  id  coeff sd sd_high sd_low
gen id = _n - 5 in 1/9
gen coeff = . 
gen sd = .
gen sd_high = .
gen sd_low = . 


forvalues i=1(1)4 {
replace coeff = _b[ ${crime_l}_after`i' ] if  id >0 & id==`i'
replace coeff = _b[ ${crime_l}_before`i' ] if  id <0 & id==-`i'
replace sd = _se[ ${crime_l}_after`i' ] if  id >0 & id==`i'
replace sd = _se[ ${crime_l}_before`i' ] if  id <0 & id==-`i'
}

replace coeff = _b[ ${crime_l}] if  id ==0
replace sd = _se[ ${crime_l}] if  id ==0

replace sd_high = coeff+1.96*sd 
replace sd_low = coeff-1.96*sd 
end 

cap prog drop graph_coeff
prog graph_coeff
*rely on name1 model
twoway (connected coeff id , lwidth(medthick) lcolor(blue) xline( 0) ) ///
 (line sd_high id , lcolor(red) lpattern(dash)) ///
 (line sd_low id, lcolor(red) lpattern(dash) ) ///
 , name("$name1", replace)  title(" $model",size(small))  ytitle(" ", size(vsmall)) xtitle("week", size(vsmall)) legend(off) 
 end 


*****************



cap program drop create_Treat 
program create_Treat
 
global totalTreatb " ${CRIME_ENT}_before4  ${CRIME_ENT}_before3  ${CRIME_ENT}_before2  ${CRIME_ENT}_before1  ${CRIME_ENT}"
global totalTreata "${CRIME_ENT}_after1 ${CRIME_ENT}_after2  ${CRIME_ENT}_after3 ${CRIME_ENT}_after4  ${CRIME_ENT}_a7decay ${CRIME_ENT}_a7decay2 "

 global totalTreat "${totalTreatb} ${totalTreata}  "
local spot: word 1 of $totalTreat
di "`spot'"

*global crime= subinstr("`spot'" , "_week_before4" ,"", .)
global crime= subinstr("`spot'" , "_wkOV_before4" ,"", .)
di "$crime"
global crime_l =subinstr("`spot'" , "_before4" ,"", .)
di "$crime_l"
 
end 
 

 
 
*imports data 
 run "${main}\do_files\do_analysis\Earl_Presentation\Create_Data_WeekEARL.do"


 
global outputfile2 "${main}\EARL\EARL_OUTPUT\Regressions\No_Controls\"
set matsize 2000
global fileoutname "Main_Stat_ViolTreatents.xml"



global dependent "ln_rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"

global title "Station Crime and Ridership, Main Robust"




*global controls " O_property_week  O_property_week_after1   O_qual_life_week   O_qual_life_week_after1  S_property_week  S_property_week_after1   S_qual_life_week   S_qual_life_week_after1   S_SimpleCrime_week O_SimpleCrime_week S_qual_life_week_after1   S_SimpleCrime_week_after1  O_SimpleCrime_week_after1 "
global control1 "   O_property_week O_qual_life_week S_property_week  S_SimpleCrime_week O_SimpleCrime_week "
global control2 "   O_property_week_before1  S_property_week_before1  S_SimpleCrime_week_before1 O_SimpleCrime_week_before1 "
global control3 "   O_property_week_after1  S_property_week_after1  S_SimpleCrime_week_after1 O_SimpleCrime_week_after1 "
global control4 "  O_property_week_after2  S_property_week_after2  S_SimpleCrime_week_after2 O_SimpleCrime_week_after2 "
global control5 "  O_property_week_before2  S_property_week_before2  S_SimpleCrime_week_before2 O_SimpleCrime_week_before2 "
global control6 "  O_property_week_after3  S_property_week_after3  S_SimpleCrime_week_after3 O_SimpleCrime_week_after3 "
global control7 "  O_property_week_before3  S_property_week_before3  S_SimpleCrime_week_before3 O_SimpleCrime_week_before3 "
global control8 "  O_property_week_after4  S_property_week_after4  S_SimpleCrime_week_after4 O_SimpleCrime_week_after4 "
global control9 "  O_property_week_before4  S_property_week_before4  S_SimpleCrime_week_before4 O_SimpleCrime_week_before4 "


global  controls " $control1 $control2 $control3 $control4 $control5 $control6 $control7 $control8 $control9 " 
global othercontrol "  "



global dependentA "ln_rides_numb_sum"
global controlsA " "
global fileoutnameA "NoCControlWeek"
global titleA "Week Ridership"


global dependentB "ln_rides_numb_sum"
global dependentTitleB "Log Entire Week Ridership"
global controlsB " ${controls} "
global fileoutnameB "CControl_Week"
global titleB "Coefficents on Treatment with Log Entire Week Ridership Outcome"

global dependentC "ln_rides_numb_wkend"
global controlsC " "
global fileoutnameC "NoCControl_WeekEND"
global titleC "Log Weekend Ridershidership"

global dependentD "ln_rides_numb_wkend"
global dependentTitleD "Log Weekend Ridership"
global controlsD "  ${controls}"
global fileoutnameD "CControl_WeekEND"
global titleD "Coefficents on Treatment with Log Entire Weekend Ridership Outcome"


global dependentE "ln_rides_numb_wkday"
global controlsE "  ${controls}"
global fileoutnameE "CControl_WeekDAY"
global titleE "Coefficents on Treatment with Log Entire Weekday Ridership Outcome"


global dependentF "ln_weekend_revenue"
global controlsF "  ${controls}"
global fileoutnameF "CControl_WeekDEND_REV"
global titleF "Coefficents on Treatment with Log Entire WeekEND REVENUE  Outcome"

*taxi_late_pickups taxi_late_pickups_wkend taxi_pickups_wkend taxi_pickups

global dependentG "ln_taxi_late_pickups"
global controlsG "  ${controls}"
global fileoutnameG "CControl_Taxi_LATE"
global titleG "Coefficents on Treatment with Taxi Night Pickups as Outcome"

global dependentH "ln_taxi_late_pickups_wkend"
global controlsH "  ${controls}"
global fileoutnameH "CControl_Taxi_Late_wkend"
global titleH "Coefficents on Treatment with Weekend Taxi Night Pickups"

global dependentI"ln_taxi_pickups"
global controlsI "  ${controls}"
global fileoutnameI "CControl_Taxi_Pick"
global titleI "Coefficents on Treatment with Log Taxi Pickups"



*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*
 foreach i in B D    {  


global demographic " "
global control " i.stat_id#c.yeartrend "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}"
global title "${title`i'}"
global dependentTitle "${dependentTitle`i'}"



reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}.xml" , title("$title")   replace  slow(1000) 


global CRIME_ENT SD_violent_wkOV
global name1 "One" 
global model "Day Time Violent Crime" 
 create_Treat
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 

graph_coeff
******************************
twoway (connected coeff id , lwidth(medthick) lcolor(blue) xline( 0) ) ///
 (line sd_high id , lcolor(red) lpattern(dash)) ///
 (line sd_low id, lcolor(red) lpattern(dash) ) ///
 ,  title("Coefficents on Before_Crime, Crime, and After_Crime",size(medium)) note( "Outcome: Log Entire Week Ridership" )  ytitle("coefficent", size(vsmall)) xtitle("week", size(vsmall)) legend(off)  
 ******************************
graph export "${outputfile2}\Coeff_graphOne_${fileoutname}.png"  , replace    width(1100)  height(800) 


global CRIME_ENT SS_firearm_wkOV
global name1 "Two" 
global model "Firearm Crime" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE  $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff



global CRIME_ENT  SD_firearm_wkOV
global name1 "Three" 
global model "Day Time Firearm Crime" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff 



global CRIME_ENT D_HOMICIDE_week
global name1 "Four" 
global model "Homicides Near Stations" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 
global name1 "Four" 
global model "Homicides Near Stations" 
graph_coeff

graph combine  One Two Three Four,  name(combined, replace) note( "Dependent: $dependentTitle , No Controls" , size(vsmall) )  title( "$title", size(small) )
*ysize(8) xsize(8) ycommon
graph save "${outputfile2}\Coeff_graph_${fileoutname}.ghp"  , replace    

graph export "${outputfile2}\Coeff_graph_${fileoutname}.png"  , replace    width(1300)  height(800) 
} 

* width(1100)  height(800)

