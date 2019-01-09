
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
global outputfile2 "${main}\analysis\Paper_May\Main_Hetero\"
global fileoutname "Main_Stat_ViolTreatents.xml"
global title "Main Model"



gen INCOME_split = 1 if  xm_inc_tile==4
replace INCOME_split = 0 if  xm_inc_tile==3 | xm_inc_tile==2
replace INCOME_split = -1 if  xm_inc_tile==1


gen crime_split = 1 if  xm_basic_crime==4
replace crime_split = 0 if  xm_basic_crime==3 | xm_basic_crime==2
replace crime_split = -1 if  xm_basic_crime==1

gen dist_split = 1 if  center_ref==4
replace dist_split = 0 if  center_ref==3 | center_ref==2
replace dist_split = -1 if  center_ref==1



*****************************************************
cap program drop save_coeff_het
program save_coeff_het

cap drop  id coeff_Hi sd_Hi sd_high_Hi sd_low_Hi coeff_Lo sd_Lo sd_high_Lo sd_low_Lo

gen id = _n - 5 in 1/9
gen coeff_Hi = . 
gen sd_Hi = .
gen sd_high_Hi = .
gen sd_low_Hi = . 

gen coeff_Lo = . 
gen sd_Lo = .
gen sd_high_Lo = .
gen sd_low_Lo = . 



forvalues i=1(1)4 {
replace coeff_Hi = _b[ ${crime_l}_after`i'_Hi ] if  id >0 & id==`i'
replace coeff_Hi = _b[ ${crime_l}_before`i'_Hi ] if  id <0 & id==-`i'
replace sd_Hi = _se[ ${crime_l}_after`i'_Hi ] if  id >0 & id==`i'
replace sd_Hi = _se[ ${crime_l}_before`i'_Hi ] if  id <0 & id==-`i'

replace coeff_Lo = _b[ ${crime_l}_after`i'_Lo ] if  id >0 & id==`i'
replace coeff_Lo = _b[ ${crime_l}_before`i'_Lo ] if  id <0 & id==-`i'
replace sd_Lo = _se[ ${crime_l}_after`i'_Lo ] if  id >0 & id==`i'
replace sd_Lo = _se[ ${crime_l}_before`i'_Lo ] if  id <0 & id==-`i'

}

replace coeff_Hi = _b[ ${crime_l}_Hi] if  id ==0
replace sd_Hi = _se[ ${crime_l}_Hi] if  id ==0
replace coeff_Lo = _b[ ${crime_l}_Lo] if  id ==0
replace sd_Lo = _se[ ${crime_l}_Lo] if  id ==0


replace sd_high_Lo = coeff_Lo+1.96*sd_Lo 
replace sd_low_Lo = coeff_Lo-1.96*sd_Lo


replace sd_high_Hi = coeff_Hi+1.96*sd_Hi 
replace sd_low_Hi = coeff_Hi-1.96*sd_Hi

end 

*****************************************************
cap prog drop graph_coeff_het
prog graph_coeff_het
*rely on name1 model
twoway (connected coeff_Hi id , lwidth(medthick) lcolor(blue) xline( 0) ) ///
 (line sd_high_Hi id , lcolor(red) lpattern(dash)) ///
 (line sd_low_Hi id, lcolor(red) lpattern(dash) ) ///
 , name("${name1}_Hi", replace)  title(" $model HIGH",size(small))  ytitle(" ", size(vsmall)) xtitle("week", size(vsmall)) legend(off) 

 twoway (connected coeff_Lo id , lwidth(medthick) lcolor(blue) xline( 0) ) ///
 (line sd_high_Lo id , lcolor(red) lpattern(dash)) ///
 (line sd_low_Lo id, lcolor(red) lpattern(dash) ) ///
 , name("${name1}_Lo", replace)  title(" $model LOW",size(small))  ytitle("", size(vsmall)) xtitle("week", size(vsmall)) legend(off) 
 
 
 end 

cap program drop create_Treat_het 
program create_Treat_het
 
global totalTreatb " ${CRIME_ENT}_before4  ${CRIME_ENT}_before3  ${CRIME_ENT}_before2  ${CRIME_ENT}_before1  ${CRIME_ENT}"
global totalTreata "${CRIME_ENT}_after1 ${CRIME_ENT}_after2  ${CRIME_ENT}_after3 ${CRIME_ENT}_after4  ${CRIME_ENT}_a7decay ${CRIME_ENT}_a7decay2 "

 global totalTreat "${totalTreatb} ${totalTreata}  "

 global add_var " " 
 foreach var in $totalTreat{
 cap  gen `var'_Hi = . 
 cap   gen `var'_Lo = . 
 cap gen `var'_Mi = .
 replace  `var'_Hi = . 
 replace   `var'_Lo = . 

 replace `var'_Hi = `var' if ${HET}==1
 replace  `var'_Hi = 0 if ${HET}==0 | ${HET}==-1
 
 
 replace `var'_Lo = `var' if ${HET}==-1
 replace  `var'_Lo = 0 if ${HET}==1 | ${HET}==0

 
 replace `var'_Mi = `var' if ${HET}==0
 replace  `var'_Mi = 0 if ${HET}==1 | ${HET}==-1

 
 
 global add_var " $add_var `var'_Lo   `var'_Hi  `var'_Mi" 
 
 }
 global totalTreat "$add_var"
 
 local spot: word 1 of $totalTreat
di "`spot'"

*global crime= subinstr("`spot'" , "_week_before4" ,"", .)
*global crime= subinstr("`spot'" , "_wkOV_before4" ,"", .)
global crime= subinstr("${CRIME_ENT}" , "_wkOV_" ,"", .)

di "$crime"
*global crime_l =subinstr("`spot'" , "_before4" ,"", .)
global crime_l = "${CRIME_ENT}"

di "$crime_l"
 
end 
 
*****************



************************************************




*SS_violent_wkOV SD_violent_wkOV SD_firearm_wkOV    D_HOMICIDE_week
*FEMALE_LABOR_FORCE_split dist_split   INCOME_split 
foreach type in  crime_split   {
global HET "`type'" 
 foreach i in D     {  



global control " ${controls`i'} "
global dependent " ${dependent`i'} " 
global fileoutname "${fileoutname`i'}"
global title "${title`i'}"




reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}_${HET}_t.xml" , title("$title")   replace  slow(1000) 
cap log close 
log using "${outputfile2}\Log_${fileoutname}." , replace 


global CRIME_ENT SD_violent_wkOV
global name1 "One" 
global model "Day Time Violent Crime" 
 create_Treat_het
areg $dependent  $totalTreat i.stationFE $othercontrol $control $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}_t.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000
save_coeff_het 

graph_coeff_het



global CRIME_ENT SS_firearm_wkOV
global name1 "Two" 
global model "Firearm Crime" 
 create_Treat_het
areg $dependent  $totalTreat  i.stationFE  $othercontrol $control  $demograph , absorb(weekFE) $clusterlevel
outreg2 using "${outputfile2}\${fileoutname}_${HET}_t.xml" , append slow(1000) keep($totalTreat) dec(4) ctitle("$model ") addtext( WeekFE, "X", StationFE, "X", Crime Control, "X")
sleep 2000  
save_coeff_het 

graph_coeff_het



graph combine  One_Hi One_Lo  Two_Hi Two_Lo ,  name(combined, replace) note( "Heterogenaity by ${HET} ", size(small) )  title( "$title", size(small) )
*ysize(8) xsize(8) ycommon
graph save "${outputfile2}\Coeff_graph_${fileoutname}_${HET}_t.gph"  , replace     

graph export "${outputfile2}\Coeff_graph_${fileoutname}_${HET}_t.png"  , replace    width(1100)  height(800) 
cap log close 
} 
}




