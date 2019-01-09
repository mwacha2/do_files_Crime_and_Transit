
**Creates demographic info
import delimited "${raw_data}\Census_CTA_Tract.csv", clear 
keep tractce10 station_id longname

gen tractce10aa = string( tractce10, "%06.0f")
save "${working}\CTA_Census_tract.dta", replace 
 

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

expand 17 , gen(year)
sort tractce10aa 
gen id = mod(_n-1,17) 
replace year =2001+id 



*see if I can strip string 
ds *00,
foreach var in `r(varlist)' {
local string_var = subinstr("`var'", "00", "",.)
local labelthis : variable label `var'
gen `string_var' = . 
label var `string_var' "`labelthis'" 
 replace `string_var' = `string_var'00 if year <2005
 cap replace `string_var' = `string_var'0a if year <2011 & year>=2005
 cap replace `string_var' = `string_var'12 if year >=2011
}


merge m:m tractce10aa using "${working}\CTA_Census_tract.dta"
drop if _merge !=3
drop _merge

gen pov_rate = npov/ dpov 

 gen stat_id = station_id +40000
 
 keep  year stat_id hinc  pov_rate



save "${working}\demographic_info.dta", replace 
*see if I can strip string 

