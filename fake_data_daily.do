clear
set obs 50 

gen datem = _n
gen stat_id = 1 
gen D_HOMICIDE_d_count = 0 

replace D_HOMICIDE_d_count = 1 if datem== 10

replace D_HOMICIDE_d_count = 1 if datem== 14

replace D_HOMICIDE_d_count = 1 if datem== 22


sort stat_id datem
tset stat_id datem 



local c ="D_HOMICIDE"
di "`c'"
global crime `c'_d


forvalues v= 1(1)5 {
gen `c'_d_after`v' =  0
gen `c'_d_before`v' =  0
}

forvalues v=1(1)5 {
replace `c'_d_after`v' =  l`v'.`c'_d_count 
replace `c'_d_before`v' =  f`v'.`c'_d_count 
}

ds *_d_* 
foreach var in `r(varlist)'{
replace `var'=0 if `var'==. 
}

global sumafter " " // create sum to tell me if another crime event happened there 
global sumbefore " "
 
forvalues v=1(1)5 {
global sumafter " $sumafter  ${crime}_after`v' "
global sumbefore " $sumbefore  ${crime}_before`v' "
}
di "right before sum $sumafter"



egen ${crime}_aftersum = rowtotal(  $sumafter )
egen ${crime}_beforesum = rowtotal(  $sumbefore )
egen ${crime}_ever_c = rowtotal(  $sumafter $sumbefore ${crime}_count   )


gen ${crime}_olap = 0 
replace  ${crime}_olap= 1 if ${crime}_ever_c >1 & ${crime}_count>0
label var ${crime}_olap "indicator in overlappign crimes"

gen ${crime}_tdrop = ${crime}_olap
forvalues v=1(1)5 {
replace ${crime}_tdrop = l`v'.${crime}_olap if l`v'.${crime}_olap>0 
replace ${crime}_tdrop = f`v'.${crime}_olap if f`v'.${crime}_olap>0
}
replace ${crime}_tdrop ==0 if ${crime}_tdrop==. 
label var ${crime}_tdrop "indicator in overlapping crimes periods "



**************************************

*drop if ${crime}_aftersum>1 | ${crime}_beforesum>1

replace datem=.  if ${crime}_ever_c>=1


gen time_ref = .   
forvalues i=1(1)5{
replace time_ref = `i' if ${crime}_after`i' >0 & datem!=. 
replace time_ref = -`i' if ${crime}_before`i' >0 & datem!=. 
}
replace time_ref =0 if ${crime}_count>0

*keep if time_ref!= . 




tab ${crime}_ever_c
	
tab  ${crime}_aftersum   ${crime}_beforesum
