


gen S_Jviolent1_week = SS_violent_wkOV - SD_violent_wkOV - SS_firearm_wkOV- D_HOMICIDE_week
gen S_Jviolent2_week =  SD_violent_wkOV - SS_firearm_wkOV- D_HOMICIDE_week
gen S_Jviolent3_week =  SS_firearm_wkOV- SD_firearm_wkOV-  D_HOMICIDE_week
gen S_Jviolent4_week =  SS_firearm_wkOV- SD_firearm_wkOV -D_HOMICIDE_week
gen S_Jviolent5_week =   SD_firearm_wkOV -D_HOMICIDE_week
gen S_Jviolent6_week =   D_HOMICIDE_week


sort stat_id week
forvalues i=1(1)6{
replace S_Jviolent`i'_week=0 if S_Jviolent`i'_week<=0
gen S_Jviolent`i'_week_after1= l1.S_Jviolent`i'_week
gen S_Jviolent`i'_week_after2= l2.S_Jviolent`i'_week
}



global totalTreata " S_Jviolent1_week S_Jviolent2_week S_Jviolent3_week S_Jviolent4_week S_Jviolent5_week S_Jviolent6_week S_Jviolent1_week_after1 S_Jviolent2_week_after1 S_Jviolent3_week_after1 S_Jviolent4_week_after1 S_Jviolent5_week_after1 S_Jviolent6_week_after1   S_Jviolent1_week_after2 S_Jviolent2_week_after2 S_Jviolent3_week_after2 S_Jviolent4_week_after2 S_Jviolent5_week_after2 S_Jviolent6_week_after2 "

