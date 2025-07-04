/*TABLEAU 1 : Caractéritiques participants*/



data au.final ; set au.final;
if tdp=1 or thp=1 then AtM=1; else atm=0; run;/* au moins un médicaments*/


data au.final; set au.final;
gras_sature=((TOTAL_SATURATED_FATTY_ACIDS_G_C*9)/energy_kcal_cchs_n)*100;
gras_insature=(((TOTAL_POLYUNSATURATED_FAT_ACI_n+TOTAL_MONOUNSATURATED_FATTY_ACI)*9)/energy_kcal_cchs_n)*100;
sucre=((total_sugars_g_cchs*4)/energy_kcal_cchs_n)*100;
fibre = input(dietary_fiber_g_cchs, ?? best12.);
energy_sat=input(Energy_from_TOTAL_SATURATED_F, ?? best12.);
run;

/*UPF*/

proc sort data=au.final; by tercile_upf_grams_s; run;

PROC MEANS data=au.final N NMISS mean std  min max; 
VAR p_age ALCOHOL_G_CCHS_n ENERGY_KCAL_CCHS_n CALC_AVG_WAIST_CM_n BMI_score_n 
CALC_AVG_DIASTOLIC_BP_n CALC_AVG_SYSTOLIC_BP_n TRIG_n HDL_n LDL_n TC_n
FRS_TOTAL_WOMEN FRS_TOTAL_MEN aHEI2010_TOTAL_SCORE  tercile_SN_tot_grams_s SN_tot_grams_s UPF_grams_s
gras_sature Energy_sat gras_insature sodium_mg_cchs_n sucre fibre
; by tercile_UPF_grams_s ; RUN;
proc freq data=au.final ; 
table sexe HOUSE_INCOME_YEAR_cat SMOKING_STATUS_cat ipaq mcp  atm shp*sdp

nb_hp has_statine has_ezetimibe  Combined  has_c02 has_c03 has_c07 has_c08 has_c09 nb_ah;  by tercile_UPF_grams_s ; run;

proc means data=au.final N NMISS mean std  min max; var UPF_grams_s SN_tot_grams_s; run; 


/*SN*/

proc sort data=au.final; by tercile_SN_tot_grams_s ; run;


PROC MEANS data=au.final N NMISS mean std  min max; 
VAR p_age ALCOHOL_G_CCHS_n ENERGY_KCAL_CCHS_n CALC_AVG_WAIST_CM_n BMI_score_n 
CALC_AVG_DIASTOLIC_BP_n CALC_AVG_SYSTOLIC_BP_n TRIG_n HDL_n LDL_n TC_n
FRS_TOTAL_WOMEN FRS_TOTAL_MEN  aHEI2010_TOTAL_SCORE tercile_UPF_grams_s tercile_SN_tot_grams_s SN_tot_grams_s UPF_grams_s 
gras_sature gras_insature sodium_mg_cchs_n sucre fibre
; by tercile_SN_tot_grams_s ; RUN;
proc freq data=au.final ; 
table sexe HOUSE_INCOME_YEAR_cat SMOKING_STATUS_cat ipaq mcp shp*sdp nb_ah nb_hp
has_statine has_ezetimibe  Combined  has_c02 has_c03 has_c07 has_c08 has_c09 ;  by tercile_SN_tot_grams_s ; run;





/*ecrit dans l'article - durée moyenne de suivi*/

PROC MEANS data=au.final N NMISS mean std  min max; var time ;run; 
