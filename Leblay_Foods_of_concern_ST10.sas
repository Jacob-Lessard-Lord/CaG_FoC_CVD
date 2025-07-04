
/*Tableau supplémentaire 10*/


/*traité non traité HP et HBC*/
data au.final_ah; set au.final;
if SHP=0 then delete; run;


data au.final_hp; set au.final;
if SDP=0 then delete; run;

proc freq data=au.final_ah;
    tables  sdp shp;
run;
proc freq data=au.final_hp;
    tables sdp shp;
run;



/*UPF*/


/* Calcul des percentiles 33 et 66 */

proc univariate data=au.final_ah noprint;
    var UPF_grams_s ;
    output out=terciles pctlpts=33 66 pctlpre=UPF_grams_s_ ;
run;

PROC TRANSPOSE DATA = terciles OUT =terciles2 name=cutpoint prefix=P; RUN;


data _null_; set terciles2;
 call symputx(cutpoint,p1);
run;
%put &UPF_grams_s_33 &UPF_grams_s_66  ;
  


data au.final_ah;
    set au.final_ah;

    if UPF_grams_s <= &UPF_grams_s_33 then tercile_UPF_grams_s_ah = 1;
    if &UPF_grams_s_33 < UPF_grams_s <= &UPF_grams_s_66 then tercile_UPF_grams_s_ah = 2;
    if UPF_grams_s > &UPF_grams_s_66 then tercile_UPF_grams_s_ah = 3;
run;

proc sort data=au.final_ah; by shp;run;
proc freq data=au.final_ah;
    tables tercile_UPF_grams_s_ah ; by shp;
run;




/* Calcul des percentiles 33 et 66 */
proc univariate data=au.final_ah noprint;
    var SN_tot_grams_s UPFU_or_SNU_grams UPFU_SNU_grams;
    output out=terciles pctlpts=33 66 pctlpre=SN_tot_grams_s_ UPFU_or_SNU_grams_ UPFU_SNU_grams_ ;
run;

PROC TRANSPOSE DATA = terciles OUT =terciles2 name=cutpoint prefix=P; RUN;


data _null_; set terciles2;
 call symputx(cutpoint,p1);
run;
%put &SN_tot_grams_s_33 &SN_tot_grams_s_66  
 &UPFU_or_SNU_grams_33  &UPFU_or_SNU_grams_66 &UPFU_SNU_grams_33 &UPFU_SNU_grams_66;
 


data au.final_ah;
    set au.final_ah;

    if SN_tot_grams_s <= &SN_tot_grams_s_33 then tercile_SN_tot_grams_s_ah = 1;
    if &SN_tot_grams_s_33 < SN_tot_grams_s <= &SN_tot_grams_s_66 then tercile_SN_tot_grams_s_ah = 2;
    if SN_tot_grams_s > &SN_tot_grams_s_66 then tercile_SN_tot_grams_s_ah = 3;
    
     if UPFU_or_SNU_grams <= &UPFU_or_SNU_grams_33 then tercile_UPFU_or_SNU_grams_ah = 1;
    if &UPFU_or_SNU_grams_33 < UPFU_or_SNU_grams <= &UPFU_or_SNU_grams_66 then tercile_UPFU_or_SNU_grams_ah= 2;
    if UPFU_or_SNU_grams> &UPFU_or_SNU_grams_66 then tercile_UPFU_or_SNU_grams_ah = 3;
    
     if UPFU_SNU_grams <= &UPFU_SNU_grams_33 then tercile_UPFU_SNU_grams_ah = 1;
    if &UPFU_SNU_grams_33 < UPFU_SNU_grams <= &UPFU_SNU_grams_66 then tercile_UPFU_SNU_grams_ah= 2;
    if UPFU_SNU_grams> &UPFU_SNU_grams_66 then tercile_UPFU_SNU_grams_ah = 3;
run; 



data au.final_ah ; set au.final_ah;
if tdp=1 or thp=1 then AtM=1; else atm=0; run;

data au.final_ah; set au.final_ah;
gras_sature=((TOTAL_SATURATED_FATTY_ACIDS_G_C*9)/energy_kcal_cchs_n)*100;
gras_insature=(((TOTAL_POLYUNSATURATED_FAT_ACI_n+TOTAL_MONOUNSATURATED_FATTY_ACI)*9)/energy_kcal_cchs_n)*100;
sucre=((total_sugars_g_cchs*4)/energy_kcal_cchs_n)*100;
fibre = input(dietary_fiber_g_cchs, ?? best12.);
run;


proc sort data=au.final_ah; by shp ; run;


PROC MEANS data=au.final_ah N NMISS mean std  min max; 
VAR p_age ALCOHOL_G_CCHS_n ENERGY_KCAL_CCHS_n CALC_AVG_WAIST_CM_n BMI_score_n 
CALC_AVG_DIASTOLIC_BP_n CALC_AVG_SYSTOLIC_BP_n TRIG_n HDL_n LDL_n TC_n
FRS_TOTAL_WOMEN FRS_TOTAL_MEN  aHEI2010_TOTAL_SCORE  SN_tot_grams_s UPF_grams_s
gras_sature gras_insature sodium_mg_cchs_n sucre fibre; by shp ; RUN;


proc freq data=au.final_ah ; 
table sexe HOUSE_INCOME_YEAR_cat SMOKING_STATUS_cat ipaq mcp atm shp*sdp nb_ah nb_hp
has_statine has_ezetimibe  Combined  has_c02 has_c03 has_c07 has_c08 has_c09;  by shp ; run;


