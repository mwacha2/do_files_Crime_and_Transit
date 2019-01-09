 run "${main}\do_files\do_analysis\Paper\March_April\Create_Data_Week.do"

 

global outputfile1 "${analysis}\Event_Graph\"

*S_violent SD_violent SD_firearm D_HOMICIDE
*SD_firearm_wkOV


foreach crime in A_CRIM_SEX_ASLT_week  SD_violent_wkOV SD_firearm_wkOV D_HOMICIDE_wkOV {
preserve

*wkOV
global crime `crime'

gen time_ref = .
replace time_ref =0 if ${crime}>=1   
forvalues i=4(-1)1{
replace time_ref = `i' if ${crime}_after`i'>=1
replace time_ref = -`i' if ${crime}_before`i'>=1
}

keep if time_ref!= . 
global outcomes " rides_numb_sum rides_numb_wkend  ln_rides_numb_sum  ln_rides_numb_wkend   "
collapse (mean) ${outcomes}, by(time_ref)

foreach out in $outcomes {
twoway (line `out' time_ref , xline(0, lwidth(vthin)) title("`out' $crime ",size(small))  , ytitle("") xtitle("")  name(`out', replace) nodraw)
}
graph combine  $outcomes ,  name(combined, replace) note( "Plot of residuals in ref to crime", size(vsmall) ) 
graph display combined
 graph export "${outputfile1}\${crime}_graph.png" , replace  width(1000)  height(800) 

restore 
}
