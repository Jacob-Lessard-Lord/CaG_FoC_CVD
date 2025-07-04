


/*STab 12 : Pression arterielle*/


/*Systole*/
/*Modele 1*/
proc glm data=au.final_ah plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model calc_avg_systolic_bp_n=shp sexe SMOKING_STATUS_cat p_age UPF_grams_s sdp HOUSE_INCOME_YEAR_cat;lsmeans shp/stderr cl ADJUST=TUKEY ; run;

/*Modele 2*/
proc glm data=au.final_ah plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model calc_avg_systolic_bp_n=shp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat p_age UPF_grams_s sdp HOUSE_INCOME_YEAR_cat;lsmeans shp/stderr cl ADJUST=TUKEY ; run;

/*Modele 3*/
proc glm data=au.final_ah plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model calc_avg_systolic_bp_n=shp sexe HOUSE_INCOME_YEAR_cat ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat p_age UPF_grams_s sdp;lsmeans shp/stderr cl ADJUST=TUKEY ; run;


/*Diastole*/
/*Modele 1*/
proc glm data=au.final_ah plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model calc_avg_diastolic_bp_n=shp sexe  HOUSE_INCOME_YEAR_cat SMOKING_STATUS_cat p_age UPF_grams_s sdp;lsmeans shp/stderr cl ADJUST=TUKEY ; run;

/*Modele 2*/
proc glm data=au.final_ah plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model calc_avg_diastolic_bp_n=shp sexe HOUSE_INCOME_YEAR_cat ENERGY_KCAL_CCHS_n  SMOKING_STATUS_cat p_age UPF_grams_s sdp;lsmeans shp/stderr cl ADJUST=TUKEY ; run;

/*Modele 3*/
proc glm data=au.final_ah plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model calc_avg_diastolic_bp_n=shp sexe HOUSE_INCOME_YEAR_cat ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat p_age UPF_grams_s sdp;lsmeans shp/stderr cl ADJUST=TUKEY ; run;



/* STab12 */

/*Modele 1*/
proc glm data=au.final_hp plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model ldl_n=sdp sexe HOUSE_INCOME_YEAR_cat SMOKING_STATUS_cat p_age UPF_grams_s shp;lsmeans sdp/stderr cl ADJUST=TUKEY ; run;

/*Modele 2*/
proc glm data=au.final_hp plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model ldl_n=sdp sexe HOUSE_INCOME_YEAR_cat ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat p_age UPF_grams_s shp;lsmeans sdp/stderr cl ADJUST=TUKEY ; run;

/*Modele 3*/
proc glm data=au.final_hp plots=diagnostics residuals; 
class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
model ldl_n=sdp sexe HOUSE_INCOME_YEAR_cat ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat p_age UPF_grams_s shp;lsmeans sdp/stderr cl ADJUST=TUKEY ; run;

