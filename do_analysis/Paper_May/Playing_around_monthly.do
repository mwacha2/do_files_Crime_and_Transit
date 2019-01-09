

use "${clean}\CTA_Crime_Final_w_CrimeMONTH.dta", clear
merge 1:1 stat_id year month using "${working}\Rail_Hourly_w_Ridership_merge.dta"
*_merge no 2001 and 2017 in the crime data 
drop if _merge !=3
drop if line_type =="Center"

egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
gen yeartrend = year-2000
egen yearmonthFE = group(year month)
*Fixed effects used 


global outputfile2 "${main}\analysis\Paper_May\Main_results\"
global fileoutname "Main_Stat_ViolTreatents.xml"
global title "Main Model"



reg   $dependent 
outreg2 using "${outputfile2}\${fileoutname}.xml" , title("$title")   replace  slow(1000) 


gen ln_week_entries_late = ln(week_entries_late)
gen ln_weekend_entries_late = ln( weekend_entries_late)
gen  ln_weekend_entries_super_late = ln(weekend_entries_super_late)




reg ln_week_entries_late SD_property_month_before1 SD_violent_month SD_violent_month_after1 ///
O_SimpleCrime_month O_SimpleCrime_month_after1 O_SimpleCrime_month_before1 ///
 A_property_month A_property_month_after1 A_property_month_before1 ///
i.stat_id  i.linetypeFE#c.year  i.modate




reg ln_week_entries_late SD_firearm_month_before1 SD_firearm_month SD_firearm_month_after1 ///
A_SimpleCrime_month A_SimpleCrime_month_after1 A_SimpleCrime_month_before1 ///
 A_property_month A_property_month_after1 A_property_month_before1 ///
i.stat_id  i.linetypeFE#c.year  i.modate


reg ln_week_entries_late A_HOMICIDE_month_before1 A_HOMICIDE_month A_HOMICIDE_month_after1 ///
A_SimpleCrime_month A_SimpleCrime_month_after1 A_SimpleCrime_month_before1 ///
 A_property_month A_property_month_after1 A_property_month_before1 ///
i.stat_id  i.linetypeFE#c.year  i.modate

