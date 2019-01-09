*** Event study*****
***No Loops*****

*pick crimes in areas you think that may be the most sensitive 



use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\motivation_graph\"


/*
*use resid1 instead of rides_numb 
egen dayFE = group(datem)
egen dayofWeekFE = group(day_of_week)
egen stationBYmonthFE = group(stat_id month)
areg rides_numb   i.dayofWeekFE i.year , absorb(stationBYmonthFE) robust
predict resid1 , resid 
*/

******************
/*
Outside Homicide near Rockwell Brown
station_id ==41010
 O_HOMICIDE_count
 07/09/2007
09/28/2008  
*/
di mdy(9,28,2008)
twoway (line rides_numb datem ) if station_id ==41010  & inrange(datem,   td(01jul2007), td(20jul2007)) ,xline(17356)

local crimedate= mdy(9,28,2008) 
local crimef10= `crimedate' +15
local crimeb10=  `crimedate' -15
twoway (line rides_numb datem ) if station_id ==41010  & inrange(datem, `crimeb10',`crimef10' ) ,xline(`crimedate')





*****
/*
*criminal sexual assualt
 Damen-Brown Fullerton North/Clybourn  18th 
  S_CRIM_SEXUAL_ASSAULT
 */
 levelsof stationname if S_CRIM_SEXUAL_ASSAULT_count==1, local(stationname)
 di `stationname'
 
 
 levelsof station_id if S_CRIM_SEXUAL_ASSAULT_count==1, local(stat_id )
 foreach var in `stat_id'{
 levelsof datem if station_id ==`var' & S_CRIM_SEXUAL_ASSAULT_count==1, local(datecrime)
local datecrime :word 1 of `datecrime' 
local crimedate= `datecrime'
local crimef10= `crimedate' +15
local crimeb10=  `crimedate' -15
twoway (line rides_numb datem ) if station_id ==`var' & inrange(datem, `crimeb10',`crimef10' ) ,xline(`crimedate')
sleep 5000
}



*********************************************
/*
Repeat for Homicides 

*/
preserve 
keep if inlist(line_type , "Blue North", "Brown", "Red North") & year >2007 
 *keep if inlist(line_type , "Blue West", "Red South")
 levelsof stationname if O_HOMICIDE_count==1, local(stationname)
 di `stationname'
  
levelsof station_id if O_HOMICIDE_count==1, local(stat_id )
foreach var in `stat_id'{
levelsof datem if station_id ==`var' & O_HOMICIDE_count==1, local(datecrime)
foreach crime in  `datecrime' {
local crimedate= `crime'
local crimef10= `crimedate' +15
local crimeb10=  `crimedate' -15
*
twoway (line resid1 datem ) if station_id ==`var' & inrange(datem, `crimeb10',`crimef10' ) ,xline(`crimedate')
sleep 3000
twoway (line rides_numb datem ) if station_id ==`var' & inrange(datem, `crimeb10',`crimef10' ) ,xline(`crimedate')
sleep 5000
}
}

restore 

*********************************************
/*
Repeat for battery 

*/
preserve 
*keep if inlist(line_type , "Blue North", "Brown", "Red North") & year >2007 
keep if inlist(line_type , "Brown",  "Blue North") & year >2007 
 *keep if inlist(line_type , "Blue West", "Red South")
 levelsof stationname if S_BATTERY_count==1, local(stationname)
 di `stationname'
  
levelsof station_id if S_BATTERY_count==1, local(stat_id )
foreach var in `stat_id'{
levelsof datem if station_id ==`var' & S_BATTERY_count==1, local(datecrime)
foreach crime in  `datecrime' {
local crimedate= `crime'
local crimef10= `crimedate' +15
local crimeb10=  `crimedate' -15
twoway (line resid1 datem ) if station_id ==`var' & inrange(datem, `crimeb10',`crimef10' ) ,xline(`crimedate')
sleep 2000
twoway (line rides_numb datem ) if station_id ==`var' & inrange(datem, `crimeb10',`crimef10' ) ,xline(`crimedate')
sleep 5000
}
}

restore 










*****************************
*reg before and afters 

*runs a regression of before and after a crime 
gen treat_ind= 0
 levelsof stationname if S_CRIM_SEXUAL_ASSAULT_count==1, local(stationname)
 di `stationname'
 levelsof station_id if S_CRIM_SEXUAL_ASSAULT_count==1, local(stat_id )
 foreach var in `stat_id'{
 levelsof datem if station_id ==`var' & S_CRIM_SEXUAL_ASSAULT_count==1, local(datecrime)
foreach crime in  `datecrime' {
local crimedate= `crime'
local crimef10= `crimedate' +15
local crimeb10=  `crimedate' -15
replace treat_ind= 1 if station_id ==`var' & inrange(datem, `crime',`crimef10' )
reg rides_numb treat_ind  if station_id ==`var' & inrange(datem, `crimeb10',`crimef10' ) 
replace treat_ind = 0
sleep 2000
}
}


preserve 
keep if inlist(line_type , "Brown",  "Blue North", "Red North") & year >2007 

gen treat_ind= 0
 levelsof stationname if O_BATTERY_count==1, local(stationname)
 di `stationname'
 levelsof station_id if O_BATTERY_count==1, local(stat_id )
 foreach var in `stat_id'{
 levelsof datem if station_id ==`var' & S_BATTERY_count==1, local(datecrime)
foreach crime in  `datecrime' {
local crimedate= `crime'
local crimef10= `crimedate' +15
local crimeb10=  `crimedate' -15
replace treat_ind= 1 if station_id ==`var' & inrange(datem, `crime',`crimef10' )
reg rides_numb treat_ind  if station_id ==`var' & inrange(datem, `crimeb10',`crimef10' ) 
replace treat_ind = 0
sleep 2000
}
}

restore 
