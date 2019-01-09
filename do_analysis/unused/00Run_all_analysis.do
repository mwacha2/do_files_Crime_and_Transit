
***Main Models 
clear
run "${main}\do_files\do_analysis\Paper\RegressionsAutoJanuary.do"


***Main spillovers 
clear
run "${main}\do_files\do_analysis\Paper\RegressionsAutoJanuary_Spillover.do"


***Taxi Data 
clear
run "${main}\do_files\do_analysis\Paper\RegressionsAutoJanuaryTaxi.do"

***Hourly Data 
clear
run "${main}\do_files\do_analysis\Paper\RegressionsHourly.do"


****Crime Random
clear
run "${main}\do_files\do_analysis\Paper\RegressionsCrimeRandom.do"
