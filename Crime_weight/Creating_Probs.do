
cap program drop rename_primary 
program rename_primary
replace primarytype ="ASSAULTsimp"  if primarytype =="ASSAULT" & description == "SIMPLE"
replace primarytype ="BATTERYsimp"  if primarytype =="BATTERY" & description == "SIMPLE"
replace primarytype ="SEX_OFFENSEdec"  if primarytype =="SEX_OFFENSE" & description == "PUBLIC INDECENCY" 
*rename shorter names 
replace primarytype = "OFF_INV_CHILD"  if primarytype =="OFFENSE_INVOLVING_CHILDREN"  
replace primarytype =" OTHER_NARCOTIC" if primarytype =="OTHER_NARCOTIC_VIOLATION" 
replace primarytype =" PUBLIC_PEACE_V" if primarytype =="PUBLIC_PEACE_VIOLATION" 
replace primarytype ="WEAPONS_V" if primarytype =="WEAPONS_VIOLATION" 
replace primarytype ="CC__LICENSE_V" if primarytype =="CC__LICENSE_VIOLATION" 
replace primarytype ="LIQUOR_LAW_V"   if primarytype =="LIQUOR_LAW_VIOLATION" 
*cop related assaults 
replace primarytype= "BATTERYsimp"  if inlist(description, "PRO EMP HANDS NO/MIN INJURY", "AGG PO HANDS NO/MIN INJURY", "STALKING AGGRAVATED", "STALKING CYBERSTALKING" )
replace primarytype= "ASSAULTsimp"   if inlist(description, "AGG: HANDS/FIST/FEET NO/MINOR INJURY" , "AGG PO HANDS NO/MIN INJURY", "PRO EMP HANDS NO/MIN INJURY" ,"AGGRAVATED OF A UNBORN CHILD")
replace primarytype="SimpleCrime" if primarytype=="ASSAULTsimp" | primarytype== "BATTERYsimp"

replace  primarytype= "CRIM_SEX_ASLT" if primarytype =="CRIM_SEXUAL_ASSAULT"
replace  primarytype = "CRIM_TRESPASS" if primarytype =="CRIMINAL_TRESPASS"
replace primarytype= "MOTOR_V_THEFT" if primarytype =="MOTOR_VEHICLE_THEFT"

drop if domestic =="true"
gen domestic_word = strpos(description,"DOMESTIC")
drop if domestic_word>0
end



clear 

forvalue year=2001(1)2010{

append using  "${working}\CTACrimedataVIS_`year'.dta" , force

}
rename_primary



gen violent_ind = 1 if inlist(primarytype, "ROBBERY", "BATTERY", "HOMICIDE", "ASSAULT", "CRIM_SEX_ASLT") // broken


egen crime_type = group(primarytype description) //similar to iucr


gen count =1 

save "${working}\CTACrime_RAW.dta" 
**************************************
*one set 
collapse (sum) count (first) primarytype description violent_ind ,by(crime_type)

keep if violent_ind==1

sum count, d 
global total = `r(sum)'

gen prob_of_crime = count/ $total 

bysort primarytype: egen primary_count = sum(count)

gen prop_of_prime = primary_count/ $total

keep primarytype description   prob_of_crime prop_of_prime
save "${working}\CTACrime_Prob.dta" , replace  
*****************************************


******************************************************
*Matching to Stations 

******************************************************

*use iucr  or group primary and descript



















