
*keep treatment constant 
*arbitrarly choose station daytime violent 

*models 
*set of models - main, line-type, hhincome, station-month  
* control no/control , weekend and weekday 
********************************************



 
 
*imports data 
 run "${main}\do_files\do_analysis\Paper_May\Create_Data_Week.do"
 run "${main}\do_files\do_analysis\Paper_May\Programs_Variables.do"
merge 1:1  stat_id week_unscaled using "${working}\Crime_Probabilities.dta"

*****MAY 2018*
 
 sort stat_id week
foreach var in  prob_of_crime prop_of_prime prob_of_crime_city prop_of_prime_city{
replace `var' = 0 if `var' ==. 
*gen `var'_wkOV = `var'
gen `var'_wkOV = `var'
replace `var'_wkOV = `var' +1 if `var'>0 // updated version to give less linear.  

forvalues i=1(1)4{
gen `var'_wkOV_before`i' = f`i'.`var'_wkOV
gen `var'_wkOV_after`i' = l`i'.`var'_wkOV
}
}  
 

 
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


*global control1 "S_violent_wkOV S_violent_wkOV_after1 S_violent_wkOV_after2 S_violent_wkOV_after3 S_violent_wkOV_after4 S_violent_wkOV_before1 S_violent_wkOV_before2 S_violent_wkOV_before3 S_violent_wkOV_before4"
global control1 " " 



*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*
*B F J L 
 foreach i in  B  D    {  

   

global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "Prob_${fileoutname`i'}"
global title "${title`i'}"
global dependentTitle "${dependentTitle`i'}"



reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}.xml" , title("$title")   replace  slow(1000) 
cap log close 
log using "${outputfile2}\Log_${fileoutname}." , replace 


global CRIME_ENT prob_of_crime_wkOV
global name1 "One" 
global model "prob_of_crime" 
 create_Treat
areg $dependent  $totalTreat i.stationFE $control1 $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 

graph_coeff
******************************

global CRIME_ENT prob_of_crime_city_wkOV
global name1 "Two" 
global model "prob_of_crime_city" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $control1  $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff



global CRIME_ENT  prop_of_prime_wkOV
global name1 "Three" 
global model "prop_of_prime" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $control1 $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff 

graph_coeff 



global CRIME_ENT prop_of_prime_city_wkOV
global name1 "Four" 
global model "prop_of_prime_city" 
 create_Treat
areg $dependent  $totalTreat  i.stationFE $control1 $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff 

graph_coeff

graph combine  One Two Three Four,  name(combined, replace) note( "Dependent: $dependentTitle", size(vsmall) )  title( "$title", size(small) )
*ysize(8) xsize(8) ycommon
graph save "${outputfile2}\Coeff_graph_${fileoutname}.ghp"  , replace    

graph export "${outputfile2}\Coeff_${fileoutname}.png"  , replace    width(1300)  height(800) 

log close 
} 

* width(1100)  height(800)

