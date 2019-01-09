
*ssc install geodist
use  "${working}\CTA_StationXY.dta", clear 

gen Center_x= -87.63089
gen Center_y = 	41.88575


geodist cta_y cta_x Center_y  Center_x ,  generate(dist_to_center)

 xtile center_ref = dist_to_center , n(4)
 
 *also cluster analysis
keep stat_id center_ref
save  "${working}\CTA_StationXY_Quartile.dta",  replace 

 
 
****************
*Cluster locations 
* population density 2001 
* age 
* home structure 
* Ridership numbers in 2010
* Weekend ridership 
* S_property Crime   


*Test on income
*Violent crime 
clear 
use "${clean}\CTA_Crime_Final_w_CrimeWEEK_reg.dta", clear 

keep if  year ==2013
drop if line_type=="Center"

replace rides_numb_wkend =. if rides_numb_wkend<10
replace rides_numb_sum =. if rides_numb_sum<10

bysort stat_id : egen sd_rides = sd(rides_numb_sum)
bysort stat_id: egen  A_violent_week_mean = mean( A_violent_week)
bysort stat_id: egen  rides_numb_wkend_mean = mean(rides_numb_wkend)
*demographics to use   multi white_hh pov_rate
gen  mult_per_pop = multi/ pop

global varlist  "sd_rides A_violent_week_mean rides_numb_wkend_mean pov_rate white_hh"
global std_varlist " " 

foreach var in $varlist {
sum `var'

gen `var'_std = (`var' - `r(mean)')/ `r(sd)'
global std_varlist "$std_varlist   `var'_std  " 
} 

*keep stat_id $std_varlist

collapse (first) stationname line_type longname $std_varlist , by(stat_id year)
cluster kmeans $std_varlist, name(Cluster_id)  k(6)

cluster  kmedians  $std_varlist, name(Cluster_id2)  k(6)

keep stat_id Cluster_id Cluster_id2

save  "${working}\CTA_StationXY_Cluster.dta", replace 




 

