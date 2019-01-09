

*imports crime data and prepares it to merge. easier to work with. 

import delimited using "${crime}\Crimes_-_2001_to_present.csv", clear

*insheet using Crimes_-_2001_to_present.csv, clear

drop if latitude==.
/*keep if  primarytype=="ASSAULT" | ///
primarytype=="BATTERY" | primarytype=="BURGLARY" |  ///
primarytype=="HOMICIDE" | primarytype=="KIDNAPPING"  ///
| primarytype=="ROBBERY"  | primarytype=="WEAPONS VIOLATION" */

drop if domestic=="true"
/*
drop casenumber date block iucr description arrest ///
 communityarea fbicode xcoordinate ycoordinate updatedon location
*/
 
gen date1 = substr(date,1,10)
gen time = substr(date,-11,11)

gen datem = date(date, "MDY",2001)
format %td datem
****time of day
gen time_pm_am = substr(time,-2,2)
gen hour =substr(time,1,2)
destring hour, replace

replace hour = hour+12 if time_pm_am=="PM" & hour!=12
replace hour = 0 if hour ==12 & time_pm_am=="AM"


gen minute = substr(time,4,2)
destring minute, replace 

gen timeADD = hour*100+minute


g daym =day(datem)
g monthm =month(datem)
g yearm =year(datem)
 
 
 
forvalues year =2001(1)2016 {

preserve  
 drop if year != `year'
 
*outsheet using "C:\Users\MAC\Dropbox\RAwork\gangs\Gang Map 2004\Stata_Data_Block\Crime\Crimedata_`year'.csv",comma replace
outsheet using "${crime}\Crimedata_`year'.csv" ,comma replace


restore 
}
 
