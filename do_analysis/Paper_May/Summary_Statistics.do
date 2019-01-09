*summary statistics for Data Portion of the paper 


/*
1.	Turnstile entries in 2007 compared to 2017
a.	Use all stations collapse by year
*/

use "${working}\CTA_Ridership.dta", clear //All stations 

collapse (sum) rides_numb , by(year)

gen rides_in100K = rides_numb/(100000)
gen rides_inMil = rides_numb/(1000000)

di (188.66- 157.9)/ 157.9 




/*
2.	Number of stations that experience increased in turnstile ntries from 2007 to 2017
a.	Use all stations collapse by year and station, c
b.	Calculate the difference between 2007 and 2017. 
*/

use "${working}\CTA_Ridership.dta", clear //All stations 

collapse (sum) rides_numb , by( stationname year)
keep if inlist(year,2007,2017)

gen rides_in10K = rides_numb/(10000)

gen m_rides2007 =rides_in10K if year==2007
gen m_rides2017 =rides_in10K if year==2017

bysort stationname: egen rides2007 = max(m_rides2007)
bysort stationname: egen rides2017 = max(m_rides2017)

gen diff2017_2007 = rides2017- rides2007
gen grow = 1 if diff2017_2007>=0
replace grow=0 if diff2017_2007<0
duplicates drop stationname , force
drop if diff2017_2007==.
sum grow


/*
3.	Change in crime incidences over time 
a.	I think I have this table but put it in 
b.	Table of crime rates binned by years. 
*/


local list1   SS_violent_week SD_violent_week 
local list2   SS_property_week SD_property_week 
local list3   SS_firearm_week   SD_firearm_week 
local list4   D_HOMICIDE_week

global list_all " `list1' `list2' `list3' `list4' count "


 
use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type=="Center"
drop if line_type==""

gen count =1 

collapse (mean) rides_numb_sum (sum) $list_all ,by(year)

foreach var in $list_all {
gen `var'_per = round(`var'/ count, 0.001)
}



keep year SS_violent_week

export excel using "${main}\EARL\EARL_OUTPUT\Descriptive\Crime_Counts_Line.xls", firstrow(varlabels) replace








*********************************************************************
/*
4.	Number of treated periods. (
a.	I think I have this table but put it in 
b.	Same Table 

*/
*********************************************************************

 
use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type=="Center"
drop if line_type==""

gen count =1 

collapse (mean) rides_numb_sum (sum) $list_all ,by(time_dum)

gen time_dum_name= "              " 
replace  time_dum_name = "2001-2005" if time_dum==1
replace  time_dum_name = "2006-2010" if time_dum==2
replace  time_dum_name = "2011-2015" if time_dum==3

foreach var in $list_all {
gen `var'_per = round(`var'/ count, 0.001)
}


export excel using "${main}\EARL\EARL_OUTPUT\Descriptive\Crime_Counts_time.xls", firstrow(varlabels) replace



**********************************
*9.	Percent of turnstile entries in the loop compared with all stations 
*********
use "${working}\CTA_Ridership.dta" , clear 

merge m:1 stat_id using "${working}\CTA_StationXY.dta"
drop if _merge !=3
gen if_center  = 1 if line_type=="Center"
replace if_center= 0 if if_center==. & line_type!="" 

collapse (sum) rides_numb, by(year if_center)

gen rides_inMil = rides_numb/(1000000)

di 40/(150+40)


*********************************************
*count the number of unique stations 
 run "${main}\do_files\do_analysis\Paper_May\Create_Data_Week.do"
 run "${main}\do_files\do_analysis\Paper_May\Programs_Variables.do"

tab stat_id, nofreq
di `r(r)'
  
 collapse (mean) hinc, by(line_type year) 
 
 
 keep if year ==2011
 sort hinc

 
 
 **************************************************
 *Revenue type
 
 use "${clean}\Revenue_FOIA_daily.dta", clear
 
 collapse (sum) daily_revenue student_revenue senior_revenue, by(YEAR)
 
 gen percent_of_total = (student_revenue+ senior_revenue)/ daily_revenue
 
 
 
 
 ************************************************
 **************************************************Relationship between ridership and violent crime. 
  run "${main}\do_files\do_analysis\Paper_May\Create_Data_Week.do"
 run "${main}\do_files\do_analysis\Paper_May\Programs_Variables.do"

 
  collapse (first) year stationname (sum ) rides_numb_sum SS_violent_week SD_violent_week SS_property_week, by(yearmonthFE stat_id)
 corr rides_numb_sum SS_violent_week
  corr rides_numb_sum  SS_property_week
 
 collapse (first) stationname (sum ) rides_numb_sum SS_violent_week SD_violent_week SS_property_week, by(year stat_id)
 corr rides_numb_sum SS_violent_week
   corr rides_numb_sum  SS_property_week
 
 
 ****************** NOT USED 
 clear
 use "${working}\CTACrime_RAW.dta" 
 
keep if violent_ind==1 
 
gen assualt_battery_ind = 1 if primarytype="ASSAULT"
 
 
 
 
 *****************************************
 *Collapse and export 
 ******************************************
 
 use "${working}\CTA_Ridership.dta" , clear 
 
merge m:1 stat_id using "${working}\CTA_StationXY.dta"
drop if _merge !=3

 
 gen year_2001_2005 =1 if inlist(year, 2001, 2002, 2003, 2004, 2005) 
 
 collapse (first) station_id longname (sum) rides_numb , by(year_2001_2005 stat_id)
 keep if year_2001_2005==1 
 gen ridership_sum =  rides_numb/ 100000
 gen longname_upper=  upper(longname)
 
 
 export excel using "C:\Users\MAC\Dropbox\Fall2017research\CTA_Crime\CTA_GIS\Ridership_Counts_time.xls", firstrow(varlabels) sheet(Ridership) replace

export delimited using "C:\Users\MAC\Dropbox\Fall2017research\CTA_Crime\CTA_GIS\Ridership_Counts_timeCSV.csv",  replace


 
 