
 

**************************
*Program 
**************************


cap program drop save_coeff 
program save_coeff

cap drop  id  coeff sd sd_high sd_low
gen id = _n - 16 in 1/31
gen coeff = . 
gen sd = .
gen sd_high = .
gen sd_low = . 


forvalues i=2(1)15 {
replace coeff = _b[ ${crime}_after`i' ] if  id >0 & id==`i'
replace coeff = _b[ ${crime}_before`i' ] if  id <0 & id==-`i'
}
replace coeff = 0 if  id ==-1
replace coeff = _b[ ${crime}_after1] if  id==1 
replace coeff = _b[ ${crime}_count] if  id ==0


forvalues i=2(1)15 {
replace sd = _se[ ${crime}_after`i' ] if  id >0 & id==`i'
replace sd = _se[ ${crime}_before`i' ] if  id <0 & id==-`i'
}
replace sd = . if  id ==-1
replace sd = _se[ ${crime}_after1] if  id==1
replace sd = _se[ ${crime}_count] if  id ==0

replace sd_high = coeff+1.96*sd 
replace sd_low = coeff-1.96*sd 

end 


 


 
 
 
 
 
 
 
 
 ****************************************************
 **Create Differences 
 ****************************************************

 
 use "${working}\Daily_Residuals_Crime.dta", clear
 

 
global outputfile1 "${analysis}\Event_GraphDay\"

foreach crime in SD_violent_d SD_firearm_d D_HOMICIDE_d {
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
global outcomes "  res_main_week res_inc_week res_line_week res_dist_week "
collapse (mean) ${outcomes}, by(time_ref)

foreach out in $outcomes {
twoway (connected `out' time_ref , xline( 0) title("`out' $crime ",size(small)) , ytitle("") xtitle("")  name(`out', replace) nodraw)
}
graph combine  $outcomes , ycommon name(combined, replace) note( "Plot of residuals in ref to crime", size(vsmall) ) 
graph display combined
 graph export "${outputfile1}\${crime}_graph.png" , replace  width(1000)  height(800) 

restore 
}
*Do regression version of this* 

*with restristions on which crimes and no restrictions on crimes. 




********************************
*Create Regressions 
*Create Regressions
********************************



 
 use "${working}\Daily_Residuals_Crime.dta", clear

 
global outputfile1 "${analysis}\Event_GraphDay\"

*S_violent_d SD_violent_d SD_firearm_d D_HOMICIDE_d

foreach crime in  SD_violent_d SD_firearm_d D_HOMICIDE_d {
preserve 

global crime `crime'

tab ${crime}_count
keep if ${crime}_ever_c >0 // keeps just crime events 
drop if ${crime}_tdrop>0 // gets ride of all crimes with overlapping
tab ${crime}_count



global treat " ${crime}_count "
forvalues i=1(1)15{
global treat "${crime}_before`i'  $treat  "
}
forvalues i=1(1)15{
global treat " $treat ${crime}_after`i' "
}

global treat = subinstr(" $treat " , "${crime}_before1 " ," " ,1) // gets rid of before 1 

global outcomes "  res_main_week res_inc_week res_line_week res_dist_week "

foreach out in $outcomes {
reg `out' $treat

save_coeff
twoway (line coeff id , lwidth(medthick) lcolor(blue) xline( 0) ) ///
 (line sd_high id , lcolor(red) lpattern(dash)) ///
 (line sd_low id, lcolor(red) lpattern(dash) ) ///
 , name(`out', replace) nodraw title("`out' $crime ",size(small))  ytitle("") xtitle("") legend(off)
}

graph combine  $outcomes , ycommon name(combined, replace)  note( "Residual outcome, coefficents", size(vsmall) ) 
graph display combined
 graph export "${outputfile1}Coeff${crime}_graph.png" , replace  width(1000)  height(800) 


restore 
}

