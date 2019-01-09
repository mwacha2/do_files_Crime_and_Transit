
**Creates demographic info
*TractBuffer_01.csv
*import delimited "${raw_data}\CTA_Tract_Buffered.csv", clear //buffer of 0.3
import delimited "${raw_data}\TractBuffer_01.csv", clear //buffer of 0.1


collapse (first) longname ,by(tractce10 station_id) // arcgis tool gives multiples sometimes need to collapse 
keep tractce10 station_id longname

gen tractce10aa = string( tractce10, "%06.0f")
merge m:1 station_id using "${working}\CTA_StationXY.dta"
drop _merge 
save "${working}\CTA_Census_tract.dta", replace 
 

 

 *longitudinal data import
import delimited "${raw_data}\demographic\LTDB_Std_2010_SampleNEW.csv", clear

gen stateS = string(statea,"%02.0f") 
gen countyS = string( countya ,"%03.0f")
gen tractS = string( tracta, "%06.0f")
gen state_county = stateS +countyS
gen trtid10s = stateS + countyS + tractS
gen gisjoin = trtid10s
drop if state_county != "17031"

rename tractS tractce10aa 

save "${working}\sample2010data.dta", replace 


*************
use "${raw_data}\demographic\ltdb_std_2010_2000_sample.dta" , clear

merge 1:1 tractce10aa using "${working}\sample2010data.dta"
drop if _merge !=3 
drop _merge

merge 1:m tractce10aa using "${working}\CTA_Census_tract.dta"
drop if _merge !=3
drop _merge

sort stat_id  
gen year = 0 
expand 17 
sort stat_id 
gen id = mod(_n-1,17) 
replace year =2001+id 


ds *00,
foreach var in `r(varlist)' {
local string_var = subinstr("`var'", "00", "",.)
local labelthis : variable label `var'
gen `string_var' = . 
label var `string_var' "`labelthis'" 
 replace `string_var' = `string_var'00 if year <=2005
 cap replace `string_var' = `string_var'0a if year <2011 & year>2005
 cap replace `string_var' = `string_var'12 if year >=2011
}

gen pov_rate = npov/ dpov 
gen white_hh = hhw/hh
gen hispanic_hh = hhh/hh
gen black_hh = hhb/hh 
gen crime_age = ag15up - ag25up 
gen fem_lab_force = flabf/ dflabf
gen unemploy_rate = unemp/ clf
gen population = ag5up00 
 

duplicates drop tractce10aa year  stat_id, force
collapse (first) longname (mean) hinc  pov_rate mrent mhmval multi crime_age white_hh hispanic_hh black_hh  fem_lab_force unemploy_rate population , by(stat_id year )

gen poverty_int_flabor = fem_lab_force*pov_rate

xtile xm_inc_tile_a= hinc if year ==2002,  n(4) 
bysort stat_id : egen  xm_inc_tile =max(xm_inc_tile_a)


xtile xm_pov_rate_a= pov_rate if year ==2002,  n(4) 
bysort stat_id : egen  xm_pov_rate =max(xm_pov_rate_a)



xtile xm_white_hh_a= white_hh if year ==2002,  n(4) 
bysort stat_id : egen  xm_white_hh =max(xm_white_hh_a)

xtile xm_fem_lab_force_a= fem_lab_force if year ==2002,  n(4) 
bysort stat_id : egen  xm_fem_lab_force =max(xm_fem_lab_force_a)



save "${working}\demographic_info.dta", replace 

