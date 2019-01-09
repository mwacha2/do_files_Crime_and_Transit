

*imports data 
 run "${main}\do_files\do_analysis\Paper_May\Create_Data_Week.do"
 run "${main}\do_files\do_analysis\Paper_May\Programs_Variables.do"

 ******
 *for this drop if 
 
*keep if line_type=="Center"
*global outputfile2 "${main}\analysis\Paper_May\Main_Loop\"

drop if line_type=="Center"
global outputfile2 "${main}\analysis\Paper_May\Robustness\Longrun\"

global title "Robustness: Different Long Run Trends"



*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*
global demograph " " // only temp $weather_int included 
 foreach i in D   {  


global CRIME_ENT SS_firearm_wkOV

global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}_Rob_Long"
global title "${title`i'}"
global dependentTitle "${dependentTitle`i'}"



reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}.xml" , title("$title")   replace  slow(1000) 



global name1 "One" 
global model "D-in-D" 
 create_Treat
areg $dependent  $totalTreat i.stationFE  $weather_int , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff

global name1 "Two" 
global model "Station Year Trend" 
 create_Treat
areg $dependent  $totalTreat i.stationFE  $weather_int i.stat_id#c.yeartrend  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff


global name1 "Three" 
global model "5-year FE" 
 create_Treat
areg $dependent  $totalTreat i.stationFE  $weather_int i.stat_id#i.time_dum , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff


global name1 "Four" 
global model "Distance To Loop" 
 create_Treat
areg $dependent  $totalTreat i.stationFE  $weather_int i.center_ref#c.yeartrend  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff



global name1 "Five" 
global model "Demographic Trend" 
 create_Treat
areg $dependent  $totalTreat i.stationFE  $weather_int i.xm_inc_tile#c.yeartrend i.xm_inc_tile#c.yeartrend i.xm_white_hh#c.yeartrend  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff


global name1 "Six" 
global model "Line Trend" 
 create_Treat
areg $dependent  $totalTreat i.stationFE  $weather_int i.lineFE#c.yeartrend  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff





*****saves combined graphs 
graph combine  One Two Three Four Five Six,  name(combined, replace) note( "Dependent: $dependentTitle", size(vsmall) )  title( "$title", size(small) )
graph save "${outputfile2}\Coeff_graph_${fileoutname}.ghp"  , replace    
graph export "${outputfile2}\Coeff_${fileoutname}.png"  , replace    width(1300)  height(800) 
} 

* width(1100)  height(800)

