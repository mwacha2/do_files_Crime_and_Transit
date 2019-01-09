
use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"


drop *_count
*imputing values 

egen lineFE = group(line_type)
egen dayFE = group(datem)

set matsize 7000
/*
areg rides_numb  i.stat_id#i.month  i.stat_id#i.day_of_week  i.stat_id  ///
 i.lineFE#i.year        /// 
 , absorb(datem) 
 */
 
 reg rides_numb  i.stat_id#i.month  i.stat_id#i.day_of_week  i.stat_id  ///
 i.lineFE#i.year      
 
 
 
 
 predict imput_val , xb 
 
 gen impute_rides = rides_numb
 
 replace impute_rides==  imput_val if rides_numb <10
