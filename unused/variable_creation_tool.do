


*don't include count here 
global newvar_name "`a'"
*include count here 
global newvar_sum_list "`b' " 



egen ${newvar_name}_count= rowtotal("$newvar_sum_list")
sort stat_id datem 
ds *_count
foreach crime in "${newvar_name}_count"{
forvalues i=1(1)30{
local crimename =subinstr("`crime'","_count","",.)  
gen `crimename'_c_daym`i' = `crimename'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
replace `crimename'_c_daym`i' =0 if  `crimename'_c_daym`i' ==. 
}
}
*copy and pasted what is above
sort stat_id datem 
ds *_count
foreach crime in "${newvar_name}_count"{
forvalues i=-10(1)0{
local j = -`i'
local crimename =subinstr("`crime'","_count","",.)  
gen `crimename'_c_daymN`j' = `crimename'_count[_n-`i']   if stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
replace `crimename'_c_daymN`j' =0 if  `crimename'_c_daymN`j' ==. 
}
}

foreach crime in "${newvar_name}_count"{
foreach j in  7 9 14 21{
local crimename =subinstr("`crime'","_count","",.)
global sumlist ""
forvalues i=1(1)`j'{
global sumlist " $sumlist `crimename'_c_daym`i'"
}
egen `crimename'trt`j' = rowtotal($sumlist)

}

gen `crimename'_sep7_14 = `crimename'trt14 - `crimename'trt7
gen `crimename'_sep14_21 = `crimename'trt21 - `crimename'trt14
}

