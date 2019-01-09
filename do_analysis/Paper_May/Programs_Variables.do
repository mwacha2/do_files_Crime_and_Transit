

*******************************************************************************
*GET DATA
*******************************************************************************
set matsize 2000






*******************************************************************************
*GLOBAL VARIALBES 
*******************************************************************************


global  weather_int " c.imput_avg_temp#i.xm_inc_tile c.imput_avg_temp#c.imput_avg_temp#i.xm_inc_tile c.prcp#i.xm_inc_tile"
global demograph " $weather_int i.stat_id#c.yeartrend  "

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
*global  controls " "
global othercontrol "  "


*********************
*log Rides 
global dependentA "ln_rides_numb_sum"
global controlsA " "
global fileoutnameA "NoCControlWeek"
global titleA "Week Ridership"


global dependentB "ln_rides_numb_sum"
global dependentTitleB "Log Entire Week Ridership"
global controlsB " ${controls} "
global fileoutnameB "Reg_Week"
global titleB "Coefficents on Treatment with Log Entire Week Ridership Outcome"

global dependentC "ln_rides_numb_wkend"
global controlsC " "
global fileoutnameC "NoReg_WeekEND"
global titleC "Log Weekend Ridershidership"

global dependentD "ln_rides_numb_wkend"
global dependentTitleD "Log Weekend Ridership"
global controlsD "  ${controls}"
global fileoutnameD "Reg_WeekEND"
global titleD "Coefficents on Treatment with Log Entire Weekend Ridership Outcome"


global dependentE "ln_rides_numb_wkday"
global controlsE "  ${controls}"
global fileoutnameE "Reg_WeekDAY"
global titleE "Coefficents on Treatment with Log Entire Weekday Ridership Outcome"



***************************************
*taxi Pickups

global dependentG "ln_taxi_late_pickups"
global controlsG "  ${controls}"
global fileoutnameG "Reg_Taxi_LATE"
global titleG "Coefficents on Treatment with Taxi Night Pickups as Outcome"

global dependentH "ln_taxi_late_pickups_wkend"
global controlsH "  ${controls}"
global fileoutnameH "Reg_Taxi_Late_wkend"
global titleH "Coefficents on Treatment with Weekend Taxi Night Pickups"

global dependentI " ln_taxi_pickups"
global controlsI "  ${controls}"
global fileoutnameI "Reg_Taxi_Pick"
global titleI "Coefficents on Treatment with Log Taxi Pickups"


***************************************
*Revenue  

global dependentF "ln_weekend_revenue"
global controlsF "  ${controls}"
global fileoutnameF "Reg_WeekDEND_REV"
global titleF "Coefficents on Treatment with Log Entire WeekEND REVENUE  Outcome"

global dependentK "ln_week_revenue"
global controlsK "  ${controls}"
global fileoutnameK "Reg_week_rev"
global titleK "Coefficents on Treatment with Log Total_Revenue"


global dependentJ "ln_student_revenue"
global controlsJ "  ${controls}"
global fileoutnameJ "Reg_student_rev"
global titleJ "Coefficents on Treatment with Log Student_Revenue"


global dependentL "ln_senior_revenue"
global controlsL "  ${controls}"
global fileoutnameL "Reg_senior_rev"
global titleL "Coefficents on Treatment with Log Senior Revenue"
















*********************************************************
*Programs 
**********************************************************



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
 , name("$name1", replace)  title(" $model",size(small))  ytitle(" ", size(vsmall)) xtitle("week", size(vsmall)) legend(off)  ylabel(,labsize(small)) xlabel(,labsize(medium))
 end 


*****************



cap program drop create_Treat 
program create_Treat
 
global totalTreatb " ${CRIME_ENT}_before4  ${CRIME_ENT}_before3  ${CRIME_ENT}_before2  ${CRIME_ENT}_before1  ${CRIME_ENT}"
global totalTreata "${CRIME_ENT}_after1 ${CRIME_ENT}_after2  ${CRIME_ENT}_after3 ${CRIME_ENT}_after4  "
*${CRIME_ENT}_a7decay ${CRIME_ENT}_a7decay2 
 global totalTreat "${totalTreatb} ${totalTreata}  "
local spot: word 1 of $totalTreat
di "`spot'"

*global crime= subinstr("`spot'" , "_week_before4" ,"", .)
global crime= subinstr("`spot'" , "_wkOV_before4" ,"", .)
di "$crime"
global crime_l =subinstr("`spot'" , "_before4" ,"", .)
di "$crime_l"
 
end 
 
