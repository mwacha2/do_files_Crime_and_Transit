






use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear

drop if inlist(year, 2006, 2007 ,2008) & line_type=="Brown"
drop if year<2005 & line_type=="Pink"
drop if line_type=="Center"

xtile xm_inc_tile= hinc,  n(4)
egen IncByweekFE = group(weekFE xm_inc_tile)
egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen stationBYmonthFE = group(stat_id month)
egen lineByWeekFE = group( line_type weekFE) 
gen yeartrend = year-2000
egen yearmonthFE = group(year month)
egen clusterWeekFE = group(Cluster_id weekFE)
egen clusterWeek2FE = group(Cluster_id2 weekFE) 
egen distanceWeekFE = group(center_ref weekFE)


global outputfile1 "${analysis}\Paper\Regressions\Just_Station\"
set matsize 2000

global fileoutname "Main_Stat_ViolTreatents.xml"

global dependent "ln_rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global title "Station Crime and Ridership, Main Robust"
*global weather "imput_avg_temp prcp " 

*Station violent
*Station Staion Daytime 
*Station Station Firearm
*Homicide 
global totalTreatb1 " S_violent_week_  S_violent_week_before5 S_violent_week_before4  S_violent_week_before3  S_violent_week_before2  S_violent_week_before1  S_violent_week"
global totalTreata1 "S_violent_week_after1 S_violent_week_after2  S_violent_week_after3 S_violent_week_after4  S_violent_week_after5 S_violent_week_after6 S_violent_week_a7decay S_violent_week_a7decay2 "

global totalTreatb2 " SD_violent_week_  SD_violent_week_before5 SD_violent_week_before4  SD_violent_week_before3  SD_violent_week_before2  SD_violent_week_before1  SD_violent_week"
global totalTreata2 "SD_violent_week_after1 SD_violent_week_after2  SD_violent_week_after3 SD_violent_week_after4   SD_violent_week_after5 SD_violent_week_after6 SD_violent_week_a7decay SD_violent_week_a7decay2 "

global totalTreatb3 " SD_firearm_week_  SD_firearm_week_before5 SD_firearm_week_before4  SD_firearm_week_before3  SD_firearm_week_before2  SD_firearm_week_before1  SD_firearm_week"
global totalTreata3 "SD_firearm_week_after1 SD_firearm_week_after2   SD_firearm_week_after3 SD_firearm_week_after4   SD_firearm_week_after5 SD_firearm_week_after6  SD_firearm_week_a7decay SD_firearm_week_a7decay2 "

global totalTreatb4 " D_HOMICIDE_week_  D_HOMICIDE_week_before5 D_HOMICIDE_week_before4  D_HOMICIDE_week_before3  D_HOMICIDE_week_before2  D_HOMICIDE_week_before1  D_HOMICIDE_week"
global totalTreata4 "D_HOMICIDE_week_after1 D_HOMICIDE_week_after2   D_HOMICIDE_week_after3  D_HOMICIDE_week_after4  D_HOMICIDE_week_after5 D_HOMICIDE_week_after6 D_HOMICIDE_week_a7decay D_HOMICIDE_week_a7decay2 "

global totalTreatb5 " S_violent_wkOV_  S_violent_wkOV_before5 S_violent_wkOV_before4  S_violent_wkOV_before3  S_violent_wkOV_before2  S_violent_wkOV_before1  S_violent_wkOV"
global totalTreata5 "S_violent_wkOV_after1 S_violent_wkOV_after2  S_violent_wkOV_after3 S_violent_wkOV_after4  S_violent_wkOV_after5 S_violent_wkOV_after6 S_violent_wkOV_a7decay S_violent_wkOV_a7decay2 "

global totalTreatb6 " SD_violent_wkOV_  SD_violent_wkOV_before5 SD_violent_wkOV_before4  SD_violent_wkOV_before3  SD_violent_wkOV_before2  SD_violent_wkOV_before1  SD_violent_wkOV"
global totalTreata6 "SD_violent_wkOV_after1 SD_violent_wkOV_after2  SD_violent_wkOV_after3 SD_violent_wkOV_after4   SD_violent_wkOV_after5 SD_violent_wkOV_after6 SD_violent_wkOV_a7decay SD_violent_wkOV_a7decay2 "

global totalTreatb7 " SD_firearm_wkOV_  SD_firearm_wkOV_before5 SD_firearm_wkOV_before4  SD_firearm_wkOV_before3  SD_firearm_wkOV_before2  SD_firearm_wkOV_before1  SD_firearm_wkOV"
global totalTreata7 "SD_firearm_wkOV_after1 SD_firearm_wkOV_after2   SD_firearm_wkOV_after3 SD_firearm_wkOV_after4   SD_firearm_wkOV_after5 SD_firearm_wkOV_after6  SD_firearm_wkOV_a7decay SD_firearm_wkOV_a7decay2 "

global totalTreatb8 " D_HOMICIDE_wkOV_  D_HOMICIDE_wkOV_before5 D_HOMICIDE_wkOV_before4  D_HOMICIDE_wkOV_before3  D_HOMICIDE_wkOV_before2  D_HOMICIDE_wkOV_before1  D_HOMICIDE_wkOV"
global totalTreata8 "D_HOMICIDE_wkOV_after1 D_HOMICIDE_wkOV_after2   D_HOMICIDE_wkOV_after3  D_HOMICIDE_wkOV_after4  D_HOMICIDE_wkOV_after5 D_HOMICIDE_wkOV_after6 D_HOMICIDE_wkOV_a7decay D_HOMICIDE_wkOV_a7decay2 "



global totalTreatb9 "  S_randomA_wkOV_before4  S_randomA_wkOV_before3  S_randomA_wkOV_before2  S_randomA_wkOV_before1  S_randomA_wkOV"
global totalTreata9 "S_randomA_wkOV_after1 S_randomA_wkOV_after2   S_randomA_wkOV_after3  S_randomA_wkOV_after4   S_randomA_wkOV_a7decay S_randomA_wkOV_a7decay2 "

global totalTreatb10 "  S_randomB_wkOV_before4  S_randomB_wkOV_before3  S_randomB_wkOV_before2  S_randomB_wkOV_before1  S_randomB_wkOV"
global totalTreata10 "S_randomB_wkOV_after1 S_randomB_wkOV_after2   S_randomB_wkOV_after3  S_randomB_wkOV_after4   S_randomB_wkOV_a7decay S_randomB_wkOV_a7decay2 "

global totalTreatb11 "  S_randomC_wkOV_before4  S_randomC_wkOV_before3  S_randomC_wkOV_before2  S_randomC_wkOV_before1  S_randomC_wkOV"
global totalTreata11 "S_randomC_wkOV_after1 S_randomC_wkOV_after2   S_randomC_wkOV_after3  S_randomC_wkOV_after4   S_randomC_wkOV_a7decay S_randomC_wkOV_a7decay2 "


global totalTreatb12 "  S_randtempA_wkOV_before4  S_randtempA_wkOV_before3  S_randtempA_wkOV_before2  S_randtempA_wkOV_before1  S_randtempA_wkOV"
global totalTreata12 "S_randtempA_wkOV_after1 S_randtempA_wkOV_after2   S_randtempA_wkOV_after3  S_randtempA_wkOV_after4  S_randtempA_wkOV_a7decay S_randtempA_wkOV_a7decay2 "

global totalTreatb13 " S_randtempB_wkOV_before4  S_randtempB_wkOV_before3  S_randtempB_wkOV_before2  S_randtempB_wkOV_before1  S_randtempB_wkOV"
global totalTreata13 "S_randtempB_wkOV_after1 S_randtempB_wkOV_after2   S_randtempB_wkOV_after3  S_randtempB_wkOV_after4  S_randtempB_wkOV_a7decay S_randtempB_wkOV_a7decay2 "

global totalTreatb14 "  S_randtempC_wkOV_before4  S_randtempC_wkOV_before3  S_randtempC_wkOV_before2  S_randtempC_wkOV_before1  S_randtempC_wkOV"
global totalTreata14 "S_randtempC_wkOV_after1 S_randtempC_wkOV_after2   S_randtempC_wkOV_after3  S_randtempC_wkOV_after4  S_randtempC_wkOV_a7decay S_randtempC_wkOV_a7decay2 "


***
global totalTreatb15 "  S_randomA_week_before4  S_randomA_week_before3  S_randomA_week_before2  S_randomA_week_before1  S_randomA_week"
global totalTreata15 "S_randomA_week_after1 S_randomA_week_after2   S_randomA_week_after3  S_randomA_week_after4    S_randomA_week_a7decay S_randomA_week_a7decay2 "

global totalTreatb16 " S_randomB_week_before4  S_randomB_week_before3  S_randomB_week_before2  S_randomB_week_before1  S_randomB_week"
global totalTreata16 "S_randomB_week_after1 S_randomB_week_after2   S_randomB_week_after3  S_randomB_week_after4    S_randomB_week_a7decay S_randomB_week_a7decay2 "

global totalTreatb17 "    S_randomC_week_before4  S_randomC_week_before3  S_randomC_week_before2  S_randomC_week_before1  S_randomC_week"
global totalTreata17 "S_randomC_week_after1 S_randomC_week_after2   S_randomC_week_after3  S_randomC_week_after4    S_randomC_week_a7decay S_randomC_week_a7decay2 "


global totalTreatb18 "    S_randtempA_week_before4  S_randtempA_week_before3  S_randtempA_week_before2  S_randtempA_week_before1  S_randtempA_week"
global totalTreata18 "S_randtempA_week_after1 S_randtempA_week_after2   S_randtempA_week_after3  S_randtempA_week_after4    S_randtempA_week_a7decay S_randtempA_week_a7decay2 "

global totalTreatb19 "    S_randtempB_week_before4  S_randtempB_week_before3  S_randtempB_week_before2  S_randtempB_week_before1  S_randtempB_week"
global totalTreata19 "S_randtempB_week_after1 S_randtempB_week_after2   S_randtempB_week_after3  S_randtempB_week_after4    S_randtempB_week_a7decay S_randtempB_week_a7decay2 "

global totalTreatb20 "    S_randtempC_week_before4  S_randtempC_week_before3  S_randtempC_week_before2  S_randtempC_week_before1  S_randtempC_week"
global totalTreata20 "S_randtempC_week_after1 S_randtempC_week_after2   S_randtempC_week_after3  S_randtempC_week_after4    S_randtempC_week_a7decay S_randtempC_week_a7decay2 "


global fileoutname "Main_Stat_ViolTreatents2.xml"


reg   $dependent 
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 

*9 10 11 12 13 14
 foreach i in   15 16 17 18 19 20   {  
 
   
global totalTreat "${totalTreatb`i'} ${totalTreata`i'}  "
 * O_property_week O_property_week_after1 O_property_week_before1 S_violent_week O_violent_week O_violent_week_after1 O_violent_week_before1 
 
areg $dependent  $totalTreat $weather i.stationFE $demograph  , absorb(weekFE)   $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("MAIN `i' ") addtext( WeekFE, "X", StationFE, "X")
sleep 2000


areg $dependent  $totalTreat $weather i.stationFE  $demograph , absorb(lineByWeekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("LINE_BY_Week `i'") addtext( lineByWeekFE, "X", StationFE, "X") 
sleep 2000  

areg $dependent  $totalTreat $weather i.stationFE  $demograph , absorb(IncByweekFE) $clusterlevel
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("IncByweekFE `i'") addtext( lineByWeekFE, "X", StationFE, "X") 
sleep 2000  
 
 
areg $dependent  $totalTreat $weather  i.yearmonthFE  $demograph , absorb( stationBYmonthFE)
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) keep($totalTreat) ctitle("STAT_MONTH `i'") addtext( yearmonthFE, "X", StationbyMonth FE , "X")
sleep 2000
}
