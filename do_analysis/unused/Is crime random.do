/*
Is crime random
Run these regressions. 
*/


areg S_violent_week S_property_week S_qual_life_week i.stationFE, absorb(weekFE) robust 



areg S_violent_week  O_violent_week S_property_week S_qual_life_week O_property_week O_qual_life_week i.stationFE, absorb(weekFE) robust 
