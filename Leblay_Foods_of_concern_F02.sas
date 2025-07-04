/*Figure 2*/


/**************** UPF AVEC UNCERTAIN************************/

data au.final; set au.final;
upf_grams_continue_s=(upf_grams_s/10)*-1; run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp ;
    model time*ecv(0) = upf_grams_continue_s  shp sdp sexe  ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                       HOUSE_INCOME_YEAR_cat p_age  / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbetaupf_grams_continue_s ; /* Créer un dataset avec les résidus */
ID id ;
run;





/********************************* FOPS UNCERTAIN******/


data au.final; set au.final;
sn_grams_s_continue=(sn_tot_grams_s/10)*-1; run;; run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_s_continue shp sdp sexe ENERGY_KCAL_CCHS_n  BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;



/*********************************UPF OR SN avec uncertain******/

data au.final; set au.final;
UPFU_OR_SNU_grams_continue=(UPFU_OR_SNU_grams/10)*-1; run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_OR_SNU_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_OR_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;






/*********************************UPF AND SN avec uncertain******/



data au.final; set au.final;
UPFU_SNU_grams_continue=(UPFU_SNU_grams/10)*-1; run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_SNU_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


    















