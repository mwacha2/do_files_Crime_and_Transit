
*unused combinations 

/*
else if "`block'"=="C" {
di "Block `block' running " 
*
global fileoutname "MainResults_timeHet.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global totalTreat  " i.time_dum#c.S_violent_week_L2B"
global title "Station Crime and Ridership, Main with Time Heterogenaity"
*global weather "imput_avg_temp prcp " 
**
}

else if "`block'"=="D" {
di "Block `block' running " 
global fileoutname "Main_Outside_timeHet.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_L2B  i.time_dum#c.O_violent_week_L2B "
global title "Station and Outside Crime and Ridership"
}

else if "`block'"=="E" {
di "Block `block' running " 
***Week entire data set 
global fileoutname "MainResultsALL.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global totalTreat  "S_violent_week_L2B O_violent_week_L2B S_property_week_L2B O_property_week_L2B S_qual_life_week_L2B O_qual_life_week_L2B"
global title "Station Crime and Ridership, Main All Interactions"
*global weather "imput_avg_temp prcp " 
**


}

else if "`block'"=="F" {
di "Block `block' running " 
***Week entire data set 
global fileoutname "MainResultsALL_timeHet.xml"
global dependent "rides_numb_sum"
*global clusterlevel "vce( cluster stat_id )"
global clusterlevel "robust"
global totalTreat  "i.time_dum#c.S_violent_week_L2B i.time_dum#c.O_violent_week_L2B i.time_dum#c.S_property_week_L2B i.time_dum#c.O_property_week_L2B i.time_dum#c.S_qual_life_week_L2B i.time_dum#c.O_qual_life_week_L2B"
global title "Station Crime and Ridership, Main All Interactions with Time"
*global weather "imput_avg_temp prcp " 
**
}
*/
**************************************************
*OST CHANGES
***************************************************
***Change model*****************
***Week entire data set 
global fileoutname "MainResultsOst.xml"
global dependent "rides_numb_sum"
*global clusterlevel "vce( cluster stat_id )"
global clusterlevel "robust"
global totalTreat  "S_violent_week_L2B"
global title "Station Crime and Ridership, Main"
*global weather "imput_avg_temp prcp " 
**



global fileoutname "Mainfirearmost.xml"
global dependent "rides_numb_sum"
*global clusterlevel "vce( cluster stat_id )" 
global clusterlevel "vce( robust )"
global totalTreat  "S_firearm_week_L2B"
global title "Station Crime and Ridership, Main Firearm crime"
*global weather "imput_avg_temp prcp " 
**

global fileoutname "FULLMODEL_OST.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )" 
*global clusterlevel "vce( robust )"
global totalTreat  "S_violent_week_L2B O_violent_week_L2B S_property_week_L2B O_property_week_L2B S_qual_life_week_L2B O_qual_life_week_L2B"
global title "Station Crime and Ridership, Main ALL crime"
*global weather "imput_avg_temp prcp " 
**






*DONE WITH OST CHANGES 
**************************************************


***Change model*****************
***Week entire data set 
global fileoutname "MainResults.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global totalTreat  " i.time_dum#c.S_violent_week_L2B i.time_dum#c.S_violent_week_L2 "
global title "Station Crime and Ridership, Main"
*global weather "imput_avg_temp prcp " 
**


global fileoutname "MainNoTime.xml"
global dependent "rides_numb_sum"
global clusterlevel "robust"
*global clusterlevel "robust"
global totalTreat  "S_violent_week_L2B S_violent_week_L2 "
global title "Station Crime and Ridership, Main Effect does not vary over time"
*global weather "imput_avg_temp prcp " 
**


***Week entire data set 

global fileoutname "Mainfirearm.xml"
global dependent "rides_numb_sum"
*global clusterlevel "vce( cluster stat_id )" 
global clusterlevel "vce( robust )"
global totalTreat  " i.time_dum#c.S_firearm_week_L2B i.time_dum#c.S_firearm_week_L2"
global title "Station Crime and Ridership, Main Firearm crime"
*global weather "imput_avg_temp prcp " 
**


***SEX entire data set 

global fileoutname "MainSEXxml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )" 
global totalTreat  " i.time_dum#c.A_CRIM_SEXUAL_ASSAULT_week_L2B i.time_dum#c.A_CRIM_SEXUAL_ASSAULT_week_L2 i.time_dum#c.A_violentNSEX_week_L2B i.time_dum#c.A_violentNSEX_week_L2"
global title "Station Crime and Ridership, Main Sex  crime"
*global weather "imput_avg_temp prcp " 
**






***Change model*****************
***Week entire data set 
global fileoutname "Main_Outside.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_L2B i.time_dum#c.S_violent_week_L2 i.time_dum#c.O_violent_week_L2B i.time_dum#c.O_violent_week_L2"
global title "Station and Outside Crime and Ridership"
*global weather "imput_avg_temp prcp " 

**Weekend split
global fileoutname "Main_Weekend.xml"
global dependent "rides_numb_wkend"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_L2B i.time_dum#c.S_violent_week_L2 i.time_dum#c.O_violent_week_L2B i.time_dum#c.O_violent_week_L2"
global title "Station and Outside Crime and Ridership, Weekend"
*global weather "imput_avg_temp prcp " 

****Placebo
global fileoutname "PlaceboYear_Outside.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_P1 i.time_dum#c.S_violent_week_P2 i.time_dum#c.O_violent_week_P1 i.time_dum#c.O_violent_week_P2"
global title "Placebo Test 1 year ahead"
*global weather "imput_avg_temp prcp "  

****Placebo
global fileoutname "PlaceboLag_Outside.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_F1 i.time_dum#c.S_violent_week_F2 i.time_dum#c.O_violent_week_F1 i.time_dum#c.O_violent_week_F2"
global title "Placebo Test future week ahead"
*global weather "imput_avg_temp prcp " 


***Get ride of center
global fileoutname "Main_OutsideNoCenter.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
global totalTreat  " i.time_dum#c.S_violent_week_L2B i.time_dum#c.S_violent_week_L2 i.time_dum#c.O_violent_week_L2B i.time_dum#c.O_violent_week_L2"
global title "Station and Outside Crime and Ridership No Center"
*global weather "imput_avg_temp prcp " 
*drop if line_type =="Center"


********Validation
global totalTreat " O_violent_week O_property_week S_property_week S_qual_life_week O_qual_life_week"
global fileoutname "Validation.xml"
global dependent "S_violent_week"
global clusterlevel "vce( cluster stat_id )"
global title "Station_Crime predicted using other crime"
*global weather "imput_avg_temp prcp " 
**

********Validation
global totalTreat " i.time_dum#c.O_violent_week i.time_dum#c.O_property_week i.time_dum#c.S_property_week i.time_dum#c.S_qual_life_week i.time_dum#c.O_qual_life_week"
global fileoutname "Validation1.xml"
global dependent "S_violent_week"
global clusterlevel "vce( cluster stat_id )"
global title "Station_Crime predicted using other crime"
*global weather "imput_avg_temp prcp " 
**

********Validation2
global totalTreat " O_property_week S_property_week S_qual_life_week O_qual_life_week "
global fileoutname "Validation2.xml"
global dependent "A_violent_week"
global clusterlevel "vce( cluster stat_id )"
global title "All_Violent_Crime predicted using other crime"
*global weather "imput_avg_temp prcp " 
**

************validation3 
global totalTreat " O_property_week S_property_week S_qual_life_week O_qual_life_week "
global fileoutname "Validation3.xml"
global dependent "A_violent_week_L2B"
global clusterlevel "vce( cluster stat_id )"
global title "Station_Crime predicted using other crime"
*global weather "imput_avg_temp prcp " 
**


global fileoutname "MainResults_AllTreat.xml"
global dependent "rides_numb_sum"
global clusterlevel "vce( cluster stat_id )"
*global clusterlevel "robust"
global treat1 "i.time_dum#c.S_ASSAULT_week_L2B i.time_dum#c.S_BATTERY_week_L2B i.time_dum#c.S_ROBBERY_week_L2B i.time_dum#c.S_SEX_OFFENSE_week_L2B "
global treat2 "i.time_dum#c.S_ASSAULT_week_L2 i.time_dum#c.S_BATTERY_week_L2 i.time_dum#c.S_ROBBERY_week_L2 i.time_dum#c.S_SEX_OFFENSE_week_L2 "

global treat3 "i.time_dum#c.O_ASSAULT_week_L2B i.time_dum#c.O_BATTERY_week_L2B i.time_dum#c.O_ROBBERY_week_L2B i.time_dum#c.O_SEX_OFFENSE_week_L2B "
global treat4 "i.time_dum#c.O_ASSAULT_week_L2 i.time_dum#c.O_BATTERY_week_L2 i.time_dum#c.O_ROBBERY_week_L2 i.time_dum#c.O_SEX_OFFENSE_week_L2 "
global treat5 "i.time_dum#c.S_property_week_L2B i.time_dum#c.S_qual_life_week_L2B"
global treat6 "i.time_dum#c.S_property_week_L2 i.time_dum#c.S_qual_life_week_L2"

global treat7 "i.time_dum#c.O_property_week_L2B i.time_dum#c.O_qual_life_week_L2B"
global treat8 "i.time_dum#c.O_property_week_L2 i.time_dum#c.O_qual_life_week_L2"

global totalTreat  "$treat1 $treat2 $treat3 $treat4 $treat5 $treat6 $treat7 $treat8"
global title "Station Crime and Ridership, Several Treatments"
*global weather "imput_avg_temp prcp " 
**



****
*Checking which observations are driving the positive coefficents in the nonclusterd



