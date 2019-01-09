
*keep treatment constant 
*arbitrarly choose station daytime violent 

*models 
*set of models - main, line-type, hhincome, station-month  
* control no/control , weekend and weekday 
********************************************


global outputfile2   "${analysis}\RegressionsGraph\"

 
 
*imports data 
 run "${main}\do_files\do_analysis\Paper_May\Create_Data_Week.do"
 run "${main}\do_files\do_analysis\Paper_May\Programs_Variables.do"

 ******
 *for this drop if 
 
*keep if line_type=="Center"
*global outputfile2 "${main}\analysis\Paper_May\Main_Loop\"

drop if line_type=="Center"
global outputfile2 "${main}\analysis\Paper_May\Robustness\TimeFE\"
global fileoutname "Main_Stat_ViolTreatents.xml"
global title "Robustness: Different Short Run Trends"




*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*

 foreach i in B  {  



global CRIME_ENT SS_firearm_wkOV
global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}_Rob_TimeFE"
global title "${title`i'}"
global dependentTitle "${dependentTitle`i'}"



reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}.xml" , title("$title")   replace  slow(1000) 


global name1 "One" 
global model "Time FE" 
 create_Treat
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext(Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff


global name1 "Two" 
global model "Distance FE" 
 create_Treat
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(distanceWeekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff



global name1 "Three" 
global model "Baseline Crime FE" 
 create_Treat
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(crimeWeekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff


global name1 "Four" 
global model "WeekendRatio FE" 
 create_Treat
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(ratioWeekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext(  Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff






graph combine  One Two Three Four,  name(combined, replace) note( "Dependent: $dependentTitle", size(vsmall) )  title( "$title", size(small) )
graph save "${outputfile2}\Coeff_graph_${fileoutname}.ghp"  , replace    
graph export "${outputfile2}\Coeff_${fileoutname}.png"  , replace    width(1300)  height(800) 
} 

* width(1100)  height(800)

