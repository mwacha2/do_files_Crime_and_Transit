

************
*Import Ridership
************
*import excel using "${main}\CTA_-_Ridership_-__L__Station_Entries_-_Daily_Totals.xlsx" ,clear 
import delimited "${raw_data}\CTA_-_Ridership_-__L__Station_Entries_-_Daily_Totals.csv" ,clear //ridership data from CTA website 
cap rename ïstation_id station_id
rename date date1
replace rides =subinstr(rides, "," , "", .)
destring rides, gen(rides_numb) force 
*some sort of input error too many on July August 2011
duplicates drop station_id date1, force 
gen stat_id = station_id

gen datem = date(date1, "MDY",2000)
format %td datem
gen year= year(datem)
gen month = month(datem)
gen day_of_week = dow(datem)

save "${working}\CTA_Ridership.dta", replace 



 *************
 *prep for mergin  stations 
 ***************
 import delimited "${raw_data}\CTA_StationXY.csv", clear
 rename point_x cta_x 
 rename point_y cta_y 
 gen stat_id = station_id +40000
 
**creates branches for each line. I could use official CTA one later 
 foreach color in "Red" "Green" "Blue" "Yellow" "Orange" "Brown" "Pink" "Purple" {
 gen `color'_line_ind = strpos(lines, "`color'")
 replace `color'_line_ind =1 if `color'_line_ind>0
 }

 gen line_type = ""
 replace line_type ="Blue North" if cta_y >41.88575 &    Blue_line_ind==1 
 replace line_type = "Blue West" if cta_x <-87.63089 & cta_y <41.87819   & Blue_line_ind==1
 replace line_type = "Red North" if cta_y >41.88482  &   Red_line_ind==1
 replace line_type = "Red South" if cta_y <41.87816  & Red_line_ind==1
 replace line_type = "Green West" if cta_x <-87.63089 & Green_line_ind==1
 replace line_type = "Green South" if cta_y <41.87952 & Green_line_ind==1 & Orange_line_ind==0  

 replace line_type = "Pink" if Pink_line_ind==1 & Green_line_ind==0
 replace line_type = "Brown" if  Brown_line_ind==1 & Red_line_ind==0
 replace line_type = "Orange" if  Orange_line_ind==1 & Green_line_ind==0
 *Mix stations 
 replace line_type ="Mix" if (Pink_line_ind==1 & Green_line_ind==1) | ///
 (Brown_line_ind==1 & Red_line_ind==1) | (Orange_line_ind==1 & Green_line_ind==1)


 replace line_type = "Center" if inlist(longname, "Washington/Wabash", "State/Lake", "Adams/Wabash")
 replace line_type = "Center" if inlist(longname,"Library" , "Washington/Wells" , "LaSalle/Van Buren" , "Quincy/Wells" )
  replace line_type = "Center" if inlist(longname,"Clark/Lake", "Jackson/Dearborn" , "Lake/State", "Jackson/State" ) 
 replace line_type = "Center" if inlist(longname, "Monroe/Dearborn", "Washington/Dearborn" ,"Monroe/State")
replace line_type = "Purple" if Purple_line_ind==1 & line_type== ""
replace line_type = "Yellow" if Yellow_line_ind==1 & line_type== ""

merge m:1  stat_id  using "${working}\Branch.dta"
drop if _merge!=3
drop _merge 

 save  "${working}\CTA_StationXY.dta" ,replace 


 