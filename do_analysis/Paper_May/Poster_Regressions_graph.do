
*keep treatment constant 
*arbitrarly choose station daytime violent 

*models 
*set of models - main, line-type, hhincome, station-month  
* control no/control , weekend and weekday 
********************************************



 
 
*imports data 
 run "${main}\do_files\do_analysis\Paper_May\Create_Data_Week.do"
 run "${main}\do_files\do_analysis\Paper_May\Programs_Variables.do"

 ******
 *for this drop if 
 /*
keep if line_type=="Center"
global outputfile2 "${main}\analysis\Paper_May\Main_Loop\"
global title "Main Model:Loop"
*/

drop if line_type=="Center"
global outputfile2 "${main}\Poster\Poster_Presentation_Results\"


global dependentB "ln_rides_numb_sum"
global dependentTitleB "Log Entire Week Ridership"
global controlsB " ${controls} "
global fileoutnameB "Reg_Week"
global titleB "Effect of Crime on CTA Train Ridership"
global subtitleB "Coefficents of Diff-in-Diff Model"


global dependentD "ln_rides_numb_wkend"
global dependentTitleD "Log Weekend Ridership"
global controlsD "  ${controls}"
global fileoutnameD "Reg_WeekEND"
global titleD "Effect of Crime on CTA Train Weekend Ridership"
global subtitleD "Coefficents of Diff-in-Diff Model"

*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*
*B F J L 
 foreach i in D  {  


global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}"
global title "${title`i'}"
global subtitle "${subtitle`i'}"
global dependentTitle "${dependentTitle`i'}"



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



global CRIME_ENT D_HOMICIDE_week
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

graph combine  One Two Three Four,  name(combined, replace)  title( "$title", size(medium) ) subtitle( "$subtitle", size(vsmall) )   
*ysize(8) xsize(8) ycommon
graph save "${outputfile2}\Coeff_graph_${fileoutname}.ghp"  , replace    

graph export "${outputfile2}\Coeff_${fileoutname}.png"  , replace    width(1950)  height(1200) 

log close 
} 

* width(1100)  height(800)

