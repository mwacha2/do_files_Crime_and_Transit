
*Create a random treatement 



use "${clean}\CTA_Crime_Final_w_Crime.dta", clear
run "${main}\do_files\Restrict_Station.do"

keep $keep_vars $interesting_vars //defined in library 

*range 3,000 ,600 , 200

merge m:1 datem using "${working}\weather.dta" 
drop if _merge ==2
drop _merge 

set seed 98034
generate u1 = runiform()

gen u21 = 0.6+(1.4-0.6)*runiform()
gen u3 = u21*((imput_avg_temp+10)/100)*0.01+ 0.99*u1



gsort- u1
gen S_randomA_count = 1 if _n<=6000 // similar to station violent crime 
replace S_randomA_count =0 if S_randomA_count==. 
gen S_randomB_count = 1 if _n<=600 // similar to just station violent 
replace S_randomB_count =0 if S_randomB_count==. 
gen S_randomC_count = 1 if _n<=200 //similar to firearm at station
replace S_randomC_count =0 if S_randomC_count==. 



gsort- u3
gen S_randtempA_count = 1 if  _n<=6000
replace S_randtempA_count =0 if S_randtempA_count==. 
gen S_randtempB_count = 1 if _n<=600
replace S_randtempB_count =0 if S_randtempB_count==. 
gen S_randtempC_count = 1 if _n<=200
replace S_randtempC_count =0 if S_randtempC_count==. 


*create another variable no difference

keep datem stat_id  *_rand*
save "${working}\random_crime.dta", replace  



foreach var in S_randomA_count S_randomB_count S_randomC_count  ///
S_randtempA_count S_randtempB_count S_randtempC_count {

quietly sum `var' 
local mean = round(`r(mean)',0.001)
di "`var' `r(sum)' and  `mean'"
}



/*

gen S_randomA_count = 1 if u1>=0.99 // similar to station violent crime 
replace S_randomA_count =0 if S_randomA_count==. 
gen S_randomB_count = 1 if u1>=0.995 // similar to just station violent 
replace S_randomB_count =0 if S_randomB_count==. 
gen S_randomC_count = 1 if u1>=0.999 //similar to firearm at station
replace S_randomC_count =0 if S_randomC_count==. 

gen u2 = (.2*((imput_avg_temp+10)/100) + .8*u1)   
sum u2 , d


gen S_randtempA_count = 1 if u2>=0.99
replace S_randtempA_count =0 if S_randtempA_count==. 
gen S_randtempB_count = 1 if u2>=0.995
replace S_randtempB_count =0 if S_randtempB_count==. 
gen S_randtempC_count = 1 if u2>=0.999
replace S_randtempC_count =0 if S_randtempC_count==. 


*create another variable no difference
gen u21 = 0.8+(1.2-0.8)*runiform()
gen u3 = u21*((imput_avg_temp+10)/100)*0.5+ 0.5*u1

pctile ptile_u3= u3

*/
