
/*Uniquement les 2123 */

PROC MEANS data=au.final N NMISS mean std  min max; 
VAR p_age CALC_AVG_WAIST_CM_n BMI_score_n 
CALC_AVG_DIASTOLIC_BP_n CALC_AVG_SYSTOLIC_BP_n TRIG_n HDL_n LDL_n TC_n
FRS_TOTAL_WOMEN FRS_TOTAL_MEN ; RUN;
proc freq data=au.final ; 
table sexe HOUSE_INCOME_YEAR_cat SMOKING_STATUS_cat ipaq mcp  shp*sdp nb_ah nb_hp
has_statine has_ezetimibe  Combined  has_c02 has_c03 has_c07 has_c08 has_c09; run;

/* Pour les personnes sans crieres FFQ*/

PROC MEANS data=premiere_ligne N NMISS mean std  min max; 
VAR p_age CALC_AVG_WAIST_CM_n BMI_score_n 
CALC_AVG_DIASTOLIC_BP_n CALC_AVG_SYSTOLIC_BP_n TRIG_n HDL_n LDL_n TC_n
FRS_TOTAL_WOMEN FRS_TOTAL_MEN ; RUN;
proc freq data=premiere_ligne ; 
table sexe HOUSE_INCOME_YEAR_cat SMOKING_STATUS_cat ipaq mcp  shp*sdp
nb_ah nb_hp
has_statine has_ezetimibe  Combined  has_c02 has_c03 has_c07 has_c08 has_c09; run;


/* Pour les personnes sans criteres FFQ et sans les 2123 */


PROC MEANS data=premiere_ligne N NMISS mean std  min max; 
VAR p_age CALC_AVG_WAIST_CM_n BMI_score_n 
CALC_AVG_DIASTOLIC_BP_n CALC_AVG_SYSTOLIC_BP_n TRIG_n HDL_n LDL_n TC_n
FRS_TOTAL_WOMEN FRS_TOTAL_MEN ; RUN;
proc freq data=premiere_ligne ; 
table sexe HOUSE_INCOME_YEAR_cat SMOKING_STATUS_cat ipaq mcp  shp*sdp
nb_ah nb_hp
has_statine has_ezetimibe  Combined  has_c02 has_c03 has_c07 has_c08 has_c09
; run;
