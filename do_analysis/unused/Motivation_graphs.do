
*three blue line stations 
*Stations: Western, Harlmem , UIC 
*Crimes: Sexual, Violent, Property. 
*Actual and Residual 
*3x3x2 
*No criminal sexual assualt at this time 


use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"
global outputfile1 "${analysis}\motivation_graph\"
global fileoutname "Prelim_Reg_BlueNorth.xml"

keep if inlist(stationname, "Harlem-O'Hare",  "Western/Milwaukee", "UIC-Halsted")
*
keep $keep_vars S_violentNSEX_count  S_property_count O_CRIM_SEXUAL_ASSAULT_count

*Possible Month Restrictions


ds *_count,
sort stat_id datem 
foreach var in `r(varlist)'{
forvalues i=1(1)15{
local var= subinstr("`var'", "_count", "",.) 
gen `var'_c_daym`i' = `var'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
}
}

ds *_count,
sort stat_id datem 
foreach var in `r(varlist)'{
forvalues i=-15(1)-1{
local var= subinstr("`var'", "_count", "",.) 
local j= -`i'
gen `var'_c_daymN`j' = `var'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
}
}

global station1 "Harlem-O'Hare"
global station2 "Western/Milwaukee"
global station3 "UIC-Halsted"

global stat1 "Harlem"
global stat2 "Western"
global stat3 "UIC"



foreach k in  1 2 3 {

preserve 
drop if stationname!= "${station`k'}"
*levelsof primarytyp , local(crimelist)
local crimelist "S_violentNSEX  S_property O_CRIM_SEXUAL_ASSAULT"
foreach var in `crimelist'{
global treatvar = "`var'"
sort stat_id datem
gen ${treatvar}_asslt_day = . 

forvalues i= -15(1)-1{
local j = -`i'
replace  ${treatvar}_asslt_day = `i'  if ${treatvar}_c_daymN`j'>=1 
}
replace  ${treatvar}_asslt_day = 0  if ${treatvar}_count>=1  
forvalues i= 1(1)15{
replace  ${treatvar}_asslt_day = `i'  if ${treatvar}_c_daym`i'>=1 & ( ${treatvar}_asslt_day == . | (${treatvar}_asslt_day < `i' & ${treatvar}_asslt_day>0))  
}

sort ${treatvar}_asslt_day
by   ${treatvar}_asslt_day: egen m_${treatvar}_riders = mean( rides_numb)
twoway (line  m_${treatvar}_riders ${treatvar}_asslt_day)
graph export "${outputfile1}\${treatvar}graph_${stat`k'}.png", replace 

}
restore 
} 





