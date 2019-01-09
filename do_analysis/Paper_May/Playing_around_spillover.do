


 run "${main}\do_files\do_analysis\Paper_May\Create_Data_Week.do"
 run "${main}\do_files\do_analysis\Paper_May\Programs_Variables.do"

merge 1:1 stat_id week using "${working}\spillover_treatment.dta" 




*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*
*B F J L  D B F J L 
 foreach i in  B {  

global othercontrol "SD_violent_weekT_after1 SD_violent_weekT_after2 SD_violent_weekT_after3"



global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}"
global title "${title`i'}_Neighbor"
global dependentTitle "${dependentTitle`i'} Neighbor"



reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}.xml" , title("$title")   replace  slow(1000) 
cap log close 
log using "${outputfile2}\Log_${fileoutname}." , replace 


global CRIME_ENT SD_violent_wkOV
global name1 "One" 
global model "Day Time Violent Crime" 
 create_Treat
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 

graph_coeff
******************************
twoway (connected coeff id , lwidth(medthick) lcolor(blue) xline( 0) ) ///
 (line sd_high id , lcolor(red) lpattern(dash)) ///
 (line sd_low id, lcolor(red) lpattern(dash) ) ///
 ,  title("Coefficents on Before_Crime, Crime, and After_Crime",size(medium)) note( "Outcome: Log Entire Week Ridership" )  ytitle("coefficent", size(vsmall)) xtitle("week", size(vsmall)) legend(off)  
 ******************************
graph export "${outputfile2}\Coeff_graphOne_${fileoutname}.png"  , replace    width(1100)  height(800) 


global CRIME_ENT SS_firearm_wkOV
global name1 "Two" 
global model "Firearm Crime" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE  $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff



global CRIME_ENT  SD_firearm_wkOV
global name1 "Three" 
global model "Day Time Firearm Crime" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff 



global CRIME_ENT A_HOMICIDE_week
global name1 "Four" 
global model "Homicides Near Stations" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 
global name1 "Four" 
global model "Homicides Near Stations" 
graph_coeff

graph combine  One Two Three Four,  name(combined, replace) note( "Dependent: $dependentTitle", size(vsmall) )  title( "$title", size(small) )
*ysize(8) xsize(8) ycommon
graph save "${outputfile2}\Coeff_graph_${fileoutname}.ghp"  , replace    

graph export "${outputfile2}\Coeff_${fileoutname}.png"  , replace    width(1300)  height(800) 

log close 
} 
