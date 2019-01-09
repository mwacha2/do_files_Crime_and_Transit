
 
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
global outputfile2 "${main}\analysis\Paper_May\Crime_Specific\"
global fileoutname "Main_Stat_ViolTreatents.xml"
global title "Main Model"


/*
A_firearm_week
global fileoutname "OutsideFirearm"
global title "Firearm Crime within 0.3m of Station"
*/


*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*
*B F J L 
  
  *A_CRIM_SEX_ASLT_wkOV  S_CRIM_SEX_ASLT_wkOV
foreach ctimetype in    A_violent_week    {

global  CRIME_ENT `ctimetype'
global control "  ${controls}"
global dependent " ${dependent`i'} " 
global fileoutname "OutsideViolent"
global title "Violent Crime within 0.3m of Station"
global dependentTitle "${dependentTitle`i'}"

   

reg   ln_rides_numb_sum
outreg2 using "${outputfile2}\${fileoutname}.xml" , title("$title")   replace  slow(1000) 
cap log close 
log using "${outputfile2}\Log_${fileoutname}." , replace 


global name1 "One" 
global model "Log Ridership" 
 create_Treat
areg ln_rides_numb_sum  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 

graph_coeff
******************************



global name1 "Two" 
global model "Log Weekend Ridership" 
 create_Treat
areg ln_rides_numb_wkend  $totalTreat  i.stationFE  $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff



global name1 "Three" 
global model "Log Weekend Revenue " 
 create_Treat
areg ln_weekend_revenue  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff 



global name1 "Four" 
global model "Log Student Revenue " 
 create_Treat
areg ln_student_revenue  $totalTreat  i.stationFE $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 
graph_coeff

graph combine  One Two Three Four,  name(combined, replace) note( "Dependent: $dependentTitle", size(vsmall) )  title( "$title", size(small) )
*ysize(8) xsize(8) ycommon
graph save "${outputfile2}\Coeff_graph_${fileoutname}.ghp"  , replace    

graph export "${outputfile2}\Coeff_${fileoutname}.png"  , replace    width(1300)  height(800) 

}

* width(1100)  height(800)

