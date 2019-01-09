
use "${clean}\CTA_Crime_Final_w_CrimeWEEK.dta", clear
run "${main}\do_files\Restrict_Station.do"

*checking for errors in early year of data

sort year stat_id 
by year stat_id : egen stat_var = sd(rides_numb_sum)

gen station_var2005= stat_var if year==2005
gen station_var2002 = stat_var if year==2002

sort stat_id
by stat_id : egen stat_var_m2005= max(station_var2005)
by stat_id : egen stat_var_m2002= max(station_var2002)

sum station_var2005 station_var2002

keep if line_type=="Brown"


collapse (first) stationname line_type ///
stat_var stat_var_m2005 stat_var_m2002  ,by(year stat_id)








