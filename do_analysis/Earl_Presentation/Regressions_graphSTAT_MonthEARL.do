

global outputfile2 "${main}\EARL\EARL_OUTPUT\Stationi_Month\"

*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*
 foreach i in  B D E    {  



global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}"
global title "${title`i'}"




reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}_Stat.xml" , title("$title")   replace  slow(1000) 


global CRIME_ENT SD_violent_wkOV
global name1 "One" 
global model "Station Month FE: Day Time Violent Crime" 
 create_Treat
areg $dependent  $totalTreat i.stationBYmonthFE $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_Stat.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 

graph_coeff



global CRIME_ENT SS_firearm_wkOV
global name1 "Two" 
global model "Station Month FE: Firearm Crime" 
 create_Treat
areg $dependent  $totalTreat  i.stationBYmonthFE  $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_Stat.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff



global CRIME_ENT  SD_firearm_wkOV
global name1 "Three" 
global model "Station Month FE:Day Time Firearm Crime" 
 create_Treat
areg $dependent  $totalTreat  i.stationBYmonthFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_Stat.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff 



global CRIME_ENT D_HOMICIDE_week
global name1 "Four" 
global model "Station Month FE:Homicides Near Stations" 
 create_Treat
areg $dependent  $totalTreat  i.stationBYmonthFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_Stat.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 
global name1 "Four" 
global model "Homicides Near Stations" 
graph_coeff

graph combine  One Two Three Four,  name(combined, replace) note( " ", size(vsmall) )  title( "$title", size(small) )

*ysize(8) xsize(8) ycommon
graph save "${outputfile2}\Coeff_graphStatMonth_${fileoutname}.gph"  , replace   
graph export "${outputfile2}\Coeff_graphStatMonth_${fileoutname}.png"  , replace    width(1100)  height(800) 
} 



