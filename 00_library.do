
set more off, permanently  
*global user "C:\Users\mwacha2"
*global user "C:\User\MAC
global username  "`c(username)'"
di "$username"
global user "C:\Users\\${username}"
global main "${user}\Dropbox\Fall2017research\CTA_Crime"
global raw_data "${user}\Dropbox\Fall2017research\CTA_Crime\raw_data"
global clean "${user}\Dropbox\Fall2017research\CTA_Crime\clean_data"
global crime "${user}\Dropbox\Fall2017research\CTA_Crime\raw_data\crime"
globa working "${user}\Dropbox\Fall2017research\CTA_Crime\working_data"

global analysis "${user}\Dropbox\Fall2017research\CTA_Crime\analysis"

global keep_vars " longname station_id stationname date1 daytype rides rides_numb stat_id datem year month day_of_week line_type"
global interesting_vars " *ROBBERY* *CRIM_SEX_ASLT* *_HOMICIDE_* *violent*  *property* *qual_life* *firearm*   *SimpleCrime* "

*local weather_int " c.imput_avg_temp#i.stat_id c.imput_avg_temp#c.imput_avg_temp#i.stat_id c.prcp#i.stat_id"
*local weather_int " c.imput_avg_temp#c.hinc c.imput_avg_temp#c.imput_avg_temp#c.hinc c.prcp#c.hinc"
local  weather_int " c.imput_avg_temp#i.xm_inc_tile c.imput_avg_temp#c.imput_avg_temp#i.xm_inc_tile c.prcp#i.xm_inc_tile"
*global demograph " `weather_int' hinc   pov_rate mrent mhmval multi crime_age white_hh hispanic_hh   fem_lab_force unemploy_rate population poverty_int_flabor"
global demograph " `weather_int' i.stat_id#c.yeartrend  "


global demograph_int "imput_avg_temp  hinc  pov_rate mrent mhmval multi crime_age white_hh hispanic_hh black_hh  fem_lab_force unemploy_rate population poverty_int_flabor"




/*
Programs to Create treatment
most are unuses 
*/ 






cap program drop TreatCreate 

program define TreatCreate
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
global treatSet1 "$treatSet1 `var1'"
global treatSet2 "$treatSet2 `var2'"
global treatSet3 "$treatSet3 `var3'"
global treatSet4 "$treatSet4  `var4'"
} 
global totalTreat "$treatSet1  $treatSet2 $treatSet3 $treatSet4 "
  
end   



cap program drop TreatCreateMovingAverage 

program define TreatCreateMovingAverage
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
local var2  "`crime'_mov_avg"
global treatSet1 "$treatSet1 `var1'"
global treatSet2 "$treatSet2 `var2'"

} 

global totalTreat "$treatSet1  $treatSet2 "
  
end   



cap program drop TreatCreateWeek 

program define TreatCreateWeek
*creates treatment list 
args v1
*global crimelist "AASSAULT ABATTERY AASSAULTsimp ACRIM_SEXUAL_ASSAULT " 
global crimelist "`v1'"
global treatSet1 ""
global treatSet2 ""
global treatSet3 ""
global treatSet4 ""
foreach crime in $crimelist {
local var1  "`crime'_week" 
local var2  "`crime'_week_f1"
local var3  "`crime'_week_f2"
global treatSet1 "$treatSet1 `var1'"
global treatSet2 "$treatSet2 `var2'"
global treatSet3 "$treatSet3 `var3'"

} 

global totalTreat "$treatSet1  $treatSet2 $treatSet3"
  
end   



cap program drop TreatCreateMonth 

program define TreatCreateMonth
*creates treatment list 
args v1
*global crimelist "AASSAULT ABATTERY AASSAULTsimp ACRIM_SEXUAL_ASSAULT " 
global crimelist "`v1'"
global treatSet1 ""
global treatSet2 ""
global treatSet3 ""
global treatSet4 ""
foreach crime in $crimelist {
local var1  "`crime'_month" 
local var2  "`crime'_month_f1"
local var3  "`crime'_month_f2"
global treatSet1 "$treatSet1 `var1'"
global treatSet2 "$treatSet2 `var2'"
global treatSet3 "$treatSet3 `var3'"

} 

global totalTreat "$treatSet1  $treatSet2 $treatSet3"
  
end   
