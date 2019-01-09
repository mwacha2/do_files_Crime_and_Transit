/*
How much variation is there left to explain

*/ 



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

global outputfile1 "${analysis}\Event_Graph\"
global fileoutname "HowMuchExplained.xml"

global controls " A_property_week  A_property_week_after1   A_qual_life_week   A_qual_life_week_after1"
*


reg ln_rides_numb_sum
outreg2 using "${outputfile1}\${fileoutname}" , title("$title")   replace  slow(1000) 


reg ln_rides_numb_sum  i.stationFE  
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE)   ctitle("Week outcome")    addtext(  note , "StationFE")
areg ln_rides_numb_sum  i.stationFE   , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)  ctitle("Week outcome")    addtext(  note , "StationFE weekFE")
areg ln_rides_numb_sum    i.stationFE $demograph  , absorb(weekFE) 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("Week outcome")    addtext(  note , "StationFE WeekFE demograph")  
areg ln_rides_numb_sum  $controls  i.stationFE $demograph  , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("Week outcome")    addtext(  note , "StationFE WeekFE demograph crimecontrol")



reg ln_rides_numb_wkend  i.stationFE  
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE)   ctitle("WeekEND outcome")    addtext(  note , "StationFE")
areg ln_rides_numb_wkend  i.stationFE   , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)  ctitle("WeekEND outcome")    addtext(  note , "StationFE weekFE")
areg ln_rides_numb_wkend    i.stationFE $demograph  , absorb(weekFE) 
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("WeekEND outcome")    addtext(  note , "StationFE WeekFE demograph")  
areg ln_rides_numb_wkend  $controls  i.stationFE $demograph  , absorb(weekFE)   
outreg2 using "${outputfile1}\${fileoutname}" , append slow(1000) drop(i.stationFE weekFE)   ctitle("WeekEND outcome")    addtext(  note , "StationFE WeekFE demograph crimecontrol")



