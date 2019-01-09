
 
 ****************************************************
 **Create Differences 
 ****************************************************

 
 use "${working}\Daily_Residuals_Crime.dta", clear
 

global outputfile1 "${analysis}\Event_GraphDay\"
*SD_violent_d SD_firearm_d D_HOMICIDE_d 
foreach crime in  S_HOMICIDE_d {
*S_violent_d SD_violent_d SD_firearm_d D_HOMICIDE_d
preserve

global crime `crime'

tab ${crime}_count
drop if ${crime}_ever_c >1 // gets ride of overlapping events 
drop if ${crime}_tdrop>0 // gets ride of all crimes with overlapping
tab ${crime}_count

gen time_ref = .   
forvalues i=1(1)15{
replace time_ref = `i' if ${crime}_after`i' >0
replace time_ref = -`i' if ${crime}_before`i' >0
}
replace time_ref =0 if ${crime}_count>0

keep if time_ref!= . 
global outcomes "  ln_rides_numb rides_numb "
collapse (mean) ${outcomes}, by(time_ref)

foreach out in $outcomes {
twoway (connected `out' time_ref , xline( 0) title("`out' $crime ",size(small)) , ytitle("") xtitle("")  name(`out', replace) nodraw)
}
graph combine  $outcomes ,  name(combined, replace) note( "Plot of Outcomes in ref to crime", size(vsmall) ) 
graph display combined
 graph export "${outputfile1}\${crime}_graphRAW.png" , replace  width(1000)  height(800) 

restore 
}
*Do regression version of this* 

*with restristions on which crimes and no restrictions on crimes. 

