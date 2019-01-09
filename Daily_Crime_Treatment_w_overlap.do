************************************************
/*
*Treatment effects with overlap, except for decay 


*/
************************************************

foreach crime in  $list1  {

local c =subinstr("`crime'","_week","",.)
di "`c'"

forvalues v= 1(1)30 {
gen `c'_d_after`v' =  0
gen `c'_d_before`v' =  0
}

forvalues v=1(1)30 {
replace `c'_d_after`v' =  l`v'.`c'_count 
replace `c'_d_before`v' =  f`v'.`c'_count 
}

gen `c'_d_aftersum = 0
gen `c'_d_beforesum = 0 


forvalues v=1(1)30 {
replace `c'_d_aftersum =  l`v'.`c'_count + `c'_d_aftersum  
replace `c'_d_beforesum =  f`v'.`c'_count + `c'_d_beforesum 
}
}
global sum1 


/*
sort stat_id datem
drop *aftersum
drop *beforesum
foreach crime in  $list1  {

local c =subinstr("`crime'","_week","",.)
di "`c'"

gen `c'_d_aftersum = 0
gen `c'_d_beforesum = 0 


forvalues v=1(1)30 {
replace `c'_d_aftersum =  l`v'.`c'_d_count + `c'_d_aftersum  
replace `c'_d_beforesum =  f`v'.`c'_d_count + `c'_d_beforesum 
}
}



*/
