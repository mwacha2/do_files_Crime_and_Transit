
/*

Use this data to create a heatmap of crime near Stations 
and station Crime 

*/
*use  "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear


use "${working}\Week_Level_Crime.dta", clear 

keep if inrange(year, 2001,2005)

collapse (sum) A_violent_week SS_violent_week (first) longname stationname , by(stat_id)

rename *_week *_week_01_05

export excel using  ///
 "C:\Users\MAC\Dropbox\Fall2017research\CTA_Crime\CTA_GIS\Crime_Data_Station_01_05.xls", firstrow(variables) replace



 
 

use "${working}\Week_Level_Crime.dta", clear 

keep if inrange(year, 2012,2017)

collapse (sum) A_violent_week SS_violent_week (first) longname stationname , by(stat_id)

rename *_week *_week_12_17


export excel using  ///
 "C:\Users\MAC\Dropbox\Fall2017research\CTA_Crime\CTA_GIS\Crime_Data_Station_12_17.xls", firstrow(variables) replace


