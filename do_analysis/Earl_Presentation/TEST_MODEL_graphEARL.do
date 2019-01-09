
*keep treatment constant 
*arbitrarly choose station daytime violent 

*models 
*set of models - main, line-type, hhincome, station-month  
* control no/control , weekend and weekday 
********************************************




*****************************************************
cap program drop save_coeff 
program save_coeff

cap drop  id coeff_Hi sd_Hi sd_high_Hi sd_low_Hi coeff_Lo sd_Lo sd_high_Lo sd_low_Lo

gen id = _n - 5 in 1/9
gen coeff_Hi = . 
gen sd_Hi = .
gen sd_high_Hi = .
gen sd_low_Hi = . 

gen coeff_Lo = . 
gen sd_Lo = .
gen sd_high_Lo = .
gen sd_low_Lo = . 



forvalues i=1(1)4 {
replace coeff_Hi = _b[ ${crime_l}_after`i'_Hi ] if  id >0 & id==`i'
replace coeff_Hi = _b[ ${crime_l}_before`i'_Hi ] if  id <0 & id==-`i'
replace sd_Hi = _se[ ${crime_l}_after`i'_Hi ] if  id >0 & id==`i'
replace sd_Hi = _se[ ${crime_l}_before`i'_Hi ] if  id <0 & id==-`i'

replace coeff_Lo = _b[ ${crime_l}_after`i'_Lo ] if  id >0 & id==`i'
replace coeff_Lo = _b[ ${crime_l}_before`i'_Lo ] if  id <0 & id==-`i'
replace sd_Lo = _se[ ${crime_l}_after`i'_Lo ] if  id >0 & id==`i'
replace sd_Lo = _se[ ${crime_l}_before`i'_Lo ] if  id <0 & id==-`i'

}

replace coeff_Hi = _b[ ${crime_l}_Hi] if  id ==0
replace sd_Hi = _se[ ${crime_l}_Hi] if  id ==0
replace coeff_Lo = _b[ ${crime_l}_Lo] if  id ==0
replace sd_Lo = _se[ ${crime_l}_Lo] if  id ==0


replace sd_high_Lo = coeff_Lo+1.96*sd_Lo 
replace sd_low_Lo = coeff_Lo-1.96*sd_Lo


replace sd_high_Hi = coeff_Hi+1.96*sd_Hi 
replace sd_low_Hi = coeff_Hi-1.96*sd_Hi

end 

*****************************************************
cap prog drop graph_coeff
prog graph_coeff
*rely on name1 model
twoway (connected coeff_Hi id , lwidth(medthick) lcolor(blue) xline( 0) ) ///
 (line sd_high_Hi id , lcolor(red) lpattern(dash)) ///
 (line sd_low_Hi id, lcolor(red) lpattern(dash) ) ///
 , name("${name1}_Hi", replace)  title(" $model HIGH",size(small))  ytitle(" ", size(vsmall)) xtitle("week", size(vsmall)) legend(off) 

 twoway (connected coeff_Lo id , lwidth(medthick) lcolor(blue) xline( 0) ) ///
 (line sd_high_Lo id , lcolor(red) lpattern(dash)) ///
 (line sd_low_Lo id, lcolor(red) lpattern(dash) ) ///
 , name("${name1}_Lo", replace)  title(" $model LOW",size(small))  ytitle("", size(vsmall)) xtitle("week", size(vsmall)) legend(off) 
 
 
 end 


*****************



*****************************************************
cap program drop create_Treat 
program create_Treat
 
global totalTreatb " ${CRIME_ENT}_before4  ${CRIME_ENT}_before3  ${CRIME_ENT}_before2  ${CRIME_ENT}_before1  ${CRIME_ENT}"
global totalTreata "${CRIME_ENT}_after1 ${CRIME_ENT}_after2  ${CRIME_ENT}_after3 ${CRIME_ENT}_after4  ${CRIME_ENT}_a7decay ${CRIME_ENT}_a7decay2 "

 global totalTreat "${totalTreatb} ${totalTreata}  "

 global add_var " " 
 foreach var in $totalTreat{
 cap  gen `var'_Hi = . 
 cap   gen `var'_Lo = . 
 replace  `var'_Hi = . 
 replace   `var'_Lo = . 

 replace `var'_Hi = `var' if ${HET}==1
 replace  `var'_Hi = 0 if ${HET}==0
 
 replace `var'_Lo = `var' if ${HET}==0
 replace  `var'_Lo = 0 if ${HET}==1
 global add_var " $add_var `var'_Lo   `var'_Hi  " 
 
 }
 global totalTreat "$add_var"
 
 local spot: word 1 of $totalTreat
di "`spot'"

*global crime= subinstr("`spot'" , "_week_before4" ,"", .)
*global crime= subinstr("`spot'" , "_wkOV_before4" ,"", .)
global crime= subinstr("${CRIME_ENT}" , "_wkOV_" ,"", .)

di "$crime"
*global crime_l =subinstr("`spot'" , "_before4" ,"", .)
global crime_l = "${CRIME_ENT}"

di "$crime_l"
 
end 
 

 
 
*imports data 
 run "${main}\do_files\do_analysis\Earl_Presentation\Create_Data_WeekEARL.do"


 
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


global dependentF "ln_weekend_revenue"
global controlsF "  ${controls}"
global fileoutnameF "CControl_WeekDEND_REV"
global titleF "Coefficents on Treatment with Log Entire WeekEND REVENUE Ridership Outcome"



gen INCOME_split = 1 if  xm_inc_tile>2
replace INCOME_split = 0 if  xm_inc_tile<=2
gen white_split = 1 if  xm_white_hh>2
replace white_split = 0 if  xm_white_hh<=2


gen weekend_split = 1 if  xm_wk_ratio>2
replace weekend_split = 0 if  xm_wk_ratio<=2

gen crime_split = 1 if xm_basic_crime>2
replace crime_split = 0 if xm_basic_crime<=2

gen time_split = 1 if year>2009
replace time_split = 0 if year<=2009


gen FEMALE_LABOR_FORCE_split = 1 if xm_fem_lab_force>2
replace FEMALE_LABOR_FORCE_split = 0 if xm_fem_lab_force<=2

gen dist_split = 1   if center_ref>2 
replace dist_split = 0 if center_ref<=2

global HET  time_split


*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*FEMALE_LABOR_FORCE_split
foreach type in dist_split   INCOME_split weekend_split crime_split   {
global HET "`type'" 
 foreach i in K     {  



global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}"
global title "${title`i'}"




reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , title("$title")   replace  slow(1000) 


global CRIME_ENT SD_violent_wkOV
global name1 "One" 
global model "Day Time Violent Crime" 
 create_Treat
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 

graph_coeff



global CRIME_ENT SS_firearm_wkOV
global name1 "Two" 
global model "Firearm Crime" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE  $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff



graph combine  One_Hi One_Lo  Two_Hi Two_Lo ,  name(combined, replace) note( "Heterogenaity by ${HET} ", size(small) )  title( "$title", size(small) )
*ysize(8) xsize(8) ycommon
graph save "${outputfile2}\Coeff_graph_${fileoutname}_${HET}.gph"  , replace     

graph export "${outputfile2}\Coeff_graph_${fileoutname}_${HET}.png"  , replace    width(1100)  height(800) 
} 
}







/*
global CRIME_ENT  SD_firearm_wkOV
global name1 "Three" 
global model "Day Time Firearm Crime" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff 



global CRIME_ENT D_HOMICIDE_week
global name1 "Four" 
global model "Homicides Near Stations" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 
global name1 "Four" 
global model "Homicides Near Stations" 
graph_coeff
*/
*
