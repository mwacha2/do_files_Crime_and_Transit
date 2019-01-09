


use "${clean_data}\CTA_Crime_Final_w_Crime.dta", clear 



***********************
*Residual Graphs*
***********************
egen dayFE = group(datem)
egen stationFE = group(stat_id)
egen linetypeFE = group(line_type)
egen stationBYYearFE = group(stat_id year)
egen monthbyYearFE = group(month year)
egen dowFE = group( dayofweek)

areg rides_numb   i.stationFE , absorb(dayFE) 
predict resid_1, residuals



*levelsof primarytyp , local(crimelist)
local crimelist "ASSAULT CRIM_SEXUAL_ASSAULT ASSAULTsimp BATTERYsimp SEX_OFFENSE ROBBERY LIQUOR_LAW_VIOLATION"
foreach var in `crimelist'{
global treatvar = "`var'"
sort stat_id datem
gen ${treatvar}_asslt_day = . 

/*
*one way of creating it.
forvalues i= -5(1)10{
replace  ${treatvar}_asslt_day = `i'  if ${treatvar}_count[_n-`i']==1 & stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i'  & ///
${treatvar}_asslt_day != 0  & ((${treatvar}_asslt_day<`i' & `i'>=0) | (${treatvar}_asslt_day>`i')) 
*if a crime happened on that day but a crime happened 10 days ago then it is coded as being a 10, 
*I want it to be coded as a zero. 
}
*/

*another way of doing it 
forvalues i= -5(1)-1{
local j = -`i'
replace  ${treatvar}_asslt_day = `i'  if ${treatvar}_c_daymN`j'>=1 
}
replace  ${treatvar}_asslt_day = 0  if ${treatvar}_count>=1  
forvalues i= 1(1)10{
replace  ${treatvar}_asslt_day = `i'  if ${treatvar}_c_daym`i'>=1 & ( ${treatvar}_asslt_day == . | (${treatvar}_asslt_day < `i' & ${treatvar}_asslt_day>0))  
}

sort ${treatvar}_asslt_day
by   ${treatvar}_asslt_day: egen m_${treatvar}_riders = mean( resid_1)
twoway (line  m_${treatvar}_riders ${treatvar}_asslt_day)
graph export "${analysis}\graphs\${treatvar}graph.png", replace 

}





preserve 

collapse (mean) resid_1 , by( ${treatvar}_asslt_day)
twoway (line  resid_1 ${treatvar}_asslt_day)

restore 


*******************************************
*******************************************
/*

*effect of treatment for criminal sexual assult. rescale to be zero then following days after 
sort stat_id datem
gen sex_asslt_day = . 

forvalues i= -5(1)10{
replace  sex_asslt_day = `i'  if CRIM_SEXUAL_ASSAULT_count[_n-`i']==1 & stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
*need counterfactual other stations
}

sort stat_id
by stat_id :egen sex_asslt_Flag = max( CRIM_SEXUAL_ASSAULT_count) 

sort datem
by datem: egen  sex_asslt_day_A = max(sex_asslt_day) 


preserve 
collapse (mean) rides_numb , by(sex_asslt_Flag sex_asslt_day_A)
twoway (line  rides_numb sex_asslt_day_A if sex_asslt_Flag==1) (line  rides_numb sex_asslt_day_A if sex_asslt_Flag==0) , ///
legend(order(1 "Treated" 2 "Unttreated" ))
restore 



*******************
*
sort stat_id datem
gen violent_asslt_day = . 
*if overapping I rather keep the positive smallest term. 
forvalues i= -5(1)10{
replace  violent_asslt_day = `i'  if violent_count[_n-`i']==1 & stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
*need counterfactual other stations
}

forvalues i= 10(-1)1{
replace  violent_asslt_day = `i'  if violent_count[_n-`i']==1 & stat_id[_n] == stat_id[_n-`i'] & datem[_n] ==datem[_n-`i'] +`i' 
*need counterfactual other stations
}

sort stat_id
by stat_id :egen violent_asslt_Flag = max( violent_count) 

sort datem
by datem: egen  violent_asslt_day_A = max(violent_asslt_day) 


preserve 
collapse (mean) rides_numb , by(violent_asslt_Flag violent_asslt_day_A)
twoway (line  rides_numb violent_asslt_day_A if violent_asslt_Flag==1) (line  rides_numb violent_asslt_day_A if violent_asslt_Flag==0) , ///
legend(order(1 "Treated" 2 "Unttreated" ))
restore 

*/
