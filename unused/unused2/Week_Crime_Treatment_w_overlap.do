************************************************
/*
*Treatment effects with overlap, except for decay 


*/
************************************************



foreach crime in $list1 {
local c =subinstr("`crime'","_week","",.)


gen `c'_week_after1 =  0
gen `c'_week_after2 =  0
gen `c'_week_after3 =  0
gen `c'_week_after4 =  0
gen `c'_week_after5=  0
gen `c'_week_after6 =  0


gen `c'_week_before1 =  0
gen `c'_week_before2 =  0
gen `c'_week_before3=  0
gen `c'_week_before4 =  0
gen `c'_week_before5 =  0
gen `c'_week_before6 =  0




gen `c'_week_a7decay= 0 
gen  `c'_week_a7decay2 = 0

*order matters here
****After 
replace `c'_week_after1 =  l1.`c'_week 
replace `c'_week_after2 =  l2.`c'_week 
replace `c'_week_after3 =  l3.`c'_week 
replace `c'_week_after4 =   l4.`c'_week 
replace `c'_week_after5 =  l5.`c'_week  
replace `c'_week_after6 =  l6.`c'_week  

****Before

replace `c'_week_before1 =  f1.`c'_week  
replace `c'_week_before2 =  f2.`c'_week  
replace `c'_week_before3 =  f3.`c'_week  
replace `c'_week_before4 =  f4.`c'_week  
replace `c'_week_before5 =  f5.`c'_week  
replace `c'_week_before6 =  f6.`c'_week  


****Decay
gen temp_var = l1.`c'_week + l2.`c'_week + l3.`c'_week + l4.`c'_week + l5.`c'_week + l6.`c'_week //still on if crime this week

forvalues i= 27(-1)7{
local j= 27-`i'
replace `c'_week_a7decay =  l`i'.`c'_week*(`j'/(27- 7))  if l`i'.`c'_week>=1 & temp_var==0

}
*decay rate can overlap with before variables.  
drop temp_var
replace  `c'_week_a7decay2 = `c'_week_a7decay*`c'_week_a7decay
**************


replace `c'_week_after1 =  0 if `c'_week_after1 ==.  
replace `c'_week_after2 =  0  if `c'_week_after2 ==. 
replace `c'_week_after3 =  0  if `c'_week_after3 ==. 
replace `c'_week_after4 =  0  if `c'_week_after4 ==. 
replace `c'_week_after5=  0  if `c'_week_after5 ==. 
replace `c'_week_after6 =  0  if `c'_week_after6 ==. 
replace `c'_week_before1 =  0 if  `c'_week_before1 ==. 
replace `c'_week_before2 =  0 if  `c'_week_before2 ==.
replace `c'_week_before3=  0  if  `c'_week_before3 ==.
replace `c'_week_before4 =  0  if  `c'_week_before4 ==.
replace `c'_week_before5 =  0  if  `c'_week_before5 ==.
replace `c'_week_before6 =  0  if  `c'_week_before6 ==.

replace `c'_week_a7decay= 0  if `c'_week_a7decay ==. 
replace  `c'_week_a7decay2 = 0 if  `c'_week_a7decay2 ==.

}



