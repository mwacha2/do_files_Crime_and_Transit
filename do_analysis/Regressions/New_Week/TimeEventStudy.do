

use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\Regressions\OST_sug\"
set matsize 2000



sum week,  
gen timeint = week - `r(min)'
replace timeint = timeint/7

tsset stat_id timeint

gen event = . 
local crime "S_violent_week"

forvalues i=1(1)3{
replace event = -`i' if f`i'.`crime' >0
}
replace event =0 if `crime' >0
forvalues i=1(1)3{
replace event = `i' if l`i'.`crime' >0
}
keep if year <2015 & year>2001
*check if overlapping  *yes it is overlapping 
count  if S_violent_week>0 & event != . & event != 0
tab   event  if S_firearm_week>0 & event != . & event != 0
tab month  line_type if S_violent_week>0


gen post = 1 if event>0
replace post = 0 if event<=0

sort event
egen event_group = group( event )

preserve 
char event_group[omit]4
drop if event ==. 
collapse   (first) rides_numb_sum event_group post , by(stat_id  event)

reg  rides_numb_sum post i.stat_id 
reg  rides_numb_sum i.event_group
reg  rides_numb_sum i.event_group i.stat_id 

restore 
