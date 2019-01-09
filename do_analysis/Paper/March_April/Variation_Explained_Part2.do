
run "${main}\do_files\do_analysis\Paper\March_April\Create_Data_Week.do"

global outputfile1 "${analysis}\Event_Graph\"
global fileoutname "HowMuchExplained.xml"

global controls " A_property_week  A_property_week_after1   A_qual_life_week   A_qual_life_week_after1 "
global othercrimes "O_SimpleCrime_week O_SimpleCrime_week_after1 S_SimpleCrime_week S_SimpleCrime_week_after1 " 
global weather_int " c.imput_avg_temp#i.xm_inc_tile c.imput_avg_temp#c.imput_avg_temp#i.xm_inc_tile c.prcp#i.xm_inc_tile"
global demograph "  hinc   pov_rate mrent mhmval multi crime_age white_hh hispanic_hh   fem_lab_force unemploy_rate population poverty_int_flabor"


reg ln_rides_numb_sum
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 



reg ln_rides_numb_sum  i.stationFE  
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE)   ctitle("Week outcome")    addtext(  note , "StationFE")
areg ln_rides_numb_sum  i.stationFE   , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)  ctitle("Week outcome")    addtext(  note , "StationFE weekFE")
areg ln_rides_numb_sum    i.stationFE $demograph  , absorb(weekFE) 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("Week outcome")    addtext(  note , "StationFE WeekFE demograph")  
areg ln_rides_numb_sum    i.stationFE $weather_int $demograph  , absorb(weekFE) 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("Week outcome")    addtext(  note , "StationFE WeekFE demograph weather")  
areg ln_rides_numb_sum  $controls   $weather_int i.stationFE $demograph  , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("Week outcome")    addtext(  note , "StationFE WeekFE demograph weather crimecontrol")
areg ln_rides_numb_sum  $othercrimes $controls  $weather_int  i.stationFE $demograph  , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("Week outcome")    addtext(  note , "StationFE WeekFE demograph weather crimecontrol other crime controls")




reg ln_rides_numb_wkend  i.stationFE  
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE)   ctitle("WeekEND outcome")    addtext(  note , "StationFE")
areg ln_rides_numb_wkend  i.stationFE   , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)  ctitle("Week outcome")    addtext(  note , "StationFE weekFE")
areg ln_rides_numb_wkend    i.stationFE $demograph  , absorb(weekFE) 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("WeekEND outcome")    addtext(  note , "StationFE WeekFE demograph")  
areg ln_rides_numb_wkend    i.stationFE $weather_int $demograph  , absorb(weekFE) 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("WeekEND outcome")    addtext(  note , "StationFE WeekFE demograph weather")  
areg ln_rides_numb_wkend  $controls   $weather_int i.stationFE $demograph  , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("WeekEND outcome")    addtext(  note , "StationFE WeekFE demograph weather crimecontrol")
areg ln_rides_numb_wkend  $othercrimes $controls  $weather_int  i.stationFE $demograph  , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("WeekEND outcome")    addtext(  note , "StationFE WeekFE demograph weather crimecontrol other crime controls")






