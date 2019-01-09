
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear
drop if line_type =="Center"

collapse  (mean)  rides_numb_sum S_violent_week  O_violent_week  O_property_week S_property_week A_violent_week   ,by(year stat_id)
*replace  rides_numb_sum= rides_numb_sum/1000000


xtile crime_tile = S_violent_week if year ==2005 , n(4)
bysort stat_id : egen crime_tile4 = max(crime_tile)

collapse  (mean)  rides_numb_sum S_violent_week  O_violent_week  O_property_week S_property_week A_violent_week   ,by(year crime_tile4)

reg  rides_numb_sum i.crime_tile4 i.crime_tile4#c.year


sort year crime_tile4
twoway (line rides_numb year if crime_tile4==1 , yaxis(1))  ///
 (line rides_numb year if crime_tile4==2 , yaxis(1)) /// 
  (line rides_numb year if crime_tile4==3 , yaxis(1)) /// 
   (line rides_numb year if crime_tile4==4 , yaxis(1)) , ///
   legend(label(1 "Lowest") label(2 "Second Lowest") label(3 "Second Highest") label(4 "Highest") )
   