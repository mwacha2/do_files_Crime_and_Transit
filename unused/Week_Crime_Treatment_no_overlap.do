
************************************************************
/*
Ok I tried loops but it is too difficult to follow. 
Create the treatment effects so that they do not overlap with each other. 
Create before variable when no other after variable is on
create after variable only  for the most recent crime. 
*/
*************************************************************


foreach crime in $list1 {
local c =subinstr("`crime'","_week","",.)


gen `c'_week_after1_2 =  0
gen `c'_week_after3_4 =  0
gen `c'_week_after5_6 =  0

gen `c'_week_before1_2 =  0
gen `c'_week_before3_4 =  0
gen `c'_week_before5_6 =  0

gen `c'_week_a7decay= 0 
gen  `c'_week_a7decay2 = 0

*order matters here
****After 
replace `c'_week_after1_2 =  l1.`c'_week + l2.`c'_week if `c'_week ==0
replace `c'_week_after3_4 =  l3.`c'_week + l4.`c'_week if `c'_week ==0 & `c'_week_after1_2==0
replace `c'_week_after5_6 =  l5.`c'_week + l6.`c'_week if `c'_week ==0 & `c'_week_after1_2==0 & `c'_week_after3_4==0


****Before
replace `c'_week_before1_2 =  f1.`c'_week + f2.`c'_week ///
 if `c'_week ==0 &  `c'_week_after1_2==0 & `c'_week_after3_4 ==0 & `c'_week_after5_6 ==0
 replace `c'_week_before3_4 =  f3.`c'_week + f4.`c'_week  ///
if `c'_week ==0 &  `c'_week_after1_2==0 & `c'_week_after3_4==0 & `c'_week_after5_6 ==0 & `c'_week_before1_2==0
replace `c'_week_before5_6 =  f5.`c'_week + f6.`c'_week  ///
if `c'_week ==0 &  `c'_week_after1_2==0 & `c'_week_after3_4==0 & `c'_week_after5_6 ==0 & `c'_week_before1_2==0  & `c'_week_before3_4==0 



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

replace `c'_week_after1_2 =  0 if `c'_week_after1_2 ==.
replace `c'_week_after3_4 =  0 if `c'_week_after3_4 ==.
replace `c'_week_after5_6 =  0 if `c'_week_after5_6 ==.
replace `c'_week_before1_2 =  0 if `c'_week_before1_2==.
replace `c'_week_before3_4 =  0 if `c'_week_before3_4 ==.
replace `c'_week_before5_6 =  0 if `c'_week_before5_6 ==.
replace `c'_week_a7decay= 0  if `c'_week_a7decay ==. 
replace  `c'_week_a7decay2 = 0 if  `c'_week_a7decay2 ==.


}


