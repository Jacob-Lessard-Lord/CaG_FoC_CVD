
/*Figure 1C*/

PROC MEANS N NMISS MIN MAX MEDIAN Q1 Q3 mean std stderr data=au.final maxdec=2; var  
 UPF_grams_s UPF_cal_s  
 SN_tot_grams_s SN_tot_cal_s
  UPFU_or_SNU_grams UPFU_or_SNU_cal 
  UPFU_SNU_grams UPFU_SNU_cal
UPFU_NSN_grams  UPFU_NSN_cal 
 NUPF_SNU_grams  NUPF_SNU_cal  ;run;