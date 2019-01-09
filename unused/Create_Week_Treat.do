

use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\"
global fileoutname "Prelim_Reg_Median.xml"

keep $keep_vars $interesting_vars



**************************
*This code is very dependent on sorting
**************************
/*
sort  datem
gen week = week(datem)
egen weekFE = group(week year)

*ds S_*_count ,
ds *_count ,
foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_count","",.)
di "`crimename'"
sort stat_id  weekFE datem
by stat_id weekFE: egen  `crimename'_week = sum( `crimename'_count)
sort stat_id datem 

gen `crimename'_week_f1 =  `crimename'_week[_n-7] if stat_id[_n]==stat_id[_n-7] & weekFE[_n] ==  weekFE[_n-7]+7 
gen `crimename'_week_f2 =  `crimename'_week[_n-14] if stat_id[_n]==stat_id[_n-14] & weekFE[_n] ==  weekFE[_n-14]+14 
}
*/
******************

*I could have just made this by collpasing 


sort  datem
gen week = week(datem)
egen weekFE = group(week year)

collapse  (first) week year month line_type (sum)  *_count (mean)  , by( stat_id weekFE)
rename *_count _week 

ds *_week ,
foreach crime in `r(varlist)'{
local crimename =subinstr("`crime'","_week","",.)
di "`crimename'"

sort stat_id year week 


gen `crimename'_week_f1 =  `crimename'_week[_n-1] if stat_id[_n]==stat_id[_n-1] & weekFE[_n] ==  weekFE[_n-1]+1
gen `crimename'_week_f2 =  `crimename'_week[_n-2] if stat_id[_n]==stat_id[_n-2] & weekFE[_n] ==  weekFE[_n-2]+2
}


keep stat_id datem *_week* week weekFE
save "${clean}\CTA_Week_Indicator.dta", replace 



