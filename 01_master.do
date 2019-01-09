
*******************
*master do file for crime_CTA project 
*******************


/*
*don't run unless you need to 
run "${main}\do_files\crime_data_prep.do" 
*/
*lots of work was done in gis 





run "${main}\do_files\A01_Station_Raw_Cleaning.do"
run "${main}\do_files\A02_Crime_Stat_Intersection.do"

run "${main}\do_files\A03_merge_station_crime.do"

run "${main}\do_files\A04_Weather.do"
run "${main}\do_files\A05_Week_Crime_Treatment.do"
run "${main}\do_files\A05_5_Crime_Treatment.do"
run "${main}\do_files\A06_demographic_info_buffer.do"
run "${main}\do_files\A07_Regression_data.do"

*Secondary Analysis
run "${main}\do_files\B01_Nearest_Station.do"
run "${main}\do_files\B02_Spillover_Data_Create.do"
run "${main}\do_files\B03_hourly cleaning.do"
run "${main}\do_files\B04_Taxi_Cab_Data_Clean.do"
run "${main}\do_files\B05_Station_Regressions_Clean.do"




run "${main}\do_files\do_analysis\summary_stats.do"
