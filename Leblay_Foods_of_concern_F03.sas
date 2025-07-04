
/**Figure 3 **/



/*AH ET UPF */
data au.final_ah; 
    set au.final_ah;
   upf_grams_continue_s = (UPF_grams_s / 10) * -1;
run;


proc phreg data=au.final_ah ;
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp(ref='1') sdp / param=ref;

    model time*ecv(0) = shp upf_grams_continue_s shp*upf_grams_continue_s
                        sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat sdp
                        p_age HOUSE_INCOME_YEAR_cat
                        / risklimits; 

    estimate "HR01: 10% ↓ UPF, shp=0" 
        upf_grams_continue_s 1 shp 0 shp*upf_grams_continue_s 0 / exp cl;

    estimate "HR11: 10% ↓ UPF, shp=1" 
        upf_grams_continue_s 1 shp 1 shp*upf_grams_continue_s 1 / exp cl;
        
    estimate "HR10: Max UPF + shp=1"
        upf_grams_continue_s 0 shp 1 shp*upf_grams_continue_s 0 / exp cl;

    ods output Estimates=est_noncentered;
run;

data reri_prep;
    set est_noncentered;
    if Label in (
        'HR11: 10% ↓ UPF, shp=1', 
        'HR01: 10% ↓ UPF, shp=0', 
        'HR10: Max UPF + shp=1'
    );

    logHR = log(ExpEstimate);
    se_logHR = (log(UpperExp) - log(LowerExp)) / (2*1.96);

    if Label = 'HR11: 10% ↓ UPF, shp=1' then short_label = 'HR11';
    else if Label = 'HR01: 10% ↓ UPF, shp=0' then short_label = 'HR01';
    else if Label = 'HR10: Max UPF + shp=1' then short_label = 'HR10';
run;

proc transpose data=reri_prep out=logHR_t prefix=logHR_;
    id short_label;
    var logHR;
run;

proc transpose data=reri_prep out=se_t prefix=se_logHR_;
    id short_label;
    var se_logHR;
run;

data reri_api;
    merge logHR_t se_t;

    logHR11 = logHR_HR11;
    logHR01 = logHR_HR01;
    logHR10 = logHR_HR10;

    se11 = se_logHR_HR11;
    se01 = se_logHR_HR01;
    se10 = se_logHR_HR10;

    HR11 = exp(logHR11);
    HR01 = exp(logHR01);
    HR10 = exp(logHR10);

    RERI = HR11 - HR10 - HR01 + 1;
    API = RERI / HR11;

    varHR11 = (HR11 * se11)**2;
    varHR10 = (HR10 * se10)**2;
    varHR01 = (HR01 * se01)**2;

    varRERI = varHR11 + varHR10 + varHR01;
    seRERI = sqrt(varRERI);

    lowerRERI = RERI - 1.96*seRERI;
    upperRERI = RERI + 1.96*seRERI;

    format RERI API lowerRERI upperRERI 8.3;
run;

proc print data=reri_api noobs label;
    var RERI API lowerRERI upperRERI;
    label 
        RERI = "RERI (interaction additive)"
        API = "Attributable Proportion due to Interaction (API)"
        lowerRERI = "Lower 95% CI RERI"
        upperRERI = "Upper 95% CI RERI";
run;









/*AH ET FOPS */

data au.final_ah; 
    set au.final_ah;
   sn_grams_s_continue = (sn_tot_grams_s / 10) * -1;
run;

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp(ref='1') sdp / param=ref;

    model time*ecv(0) = shp sn_grams_s_continue shp*sn_grams_s_continue
                        sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat sdp
                        p_age HOUSE_INCOME_YEAR_cat
                        / risklimits;

    estimate "HR01: 10% ↓ UPF, shp=0" 
       sn_grams_s_continue 1 shp 0 shp*sn_grams_s_continue 0 / exp cl;

    estimate "HR11: 10% ↓ UPF, shp=1" 
        sn_grams_s_continue 1 shp 1 shp*sn_grams_s_continue 1 / exp cl;
    estimate "HR10: Max UPF + shp=1"
        sn_grams_s_continue 0 shp 1 shp*sn_grams_s_continue 0 / exp cl;
    
    ods output Estimates=est_noncentered;
run;


data reri_prep;
    set est_noncentered;
    if Label in (
        'HR11: 10% ↓ UPF, shp=1', 
        'HR01: 10% ↓ UPF, shp=0', 
        'HR10: Max UPF + shp=1'
    );

    logHR = log(ExpEstimate);
    se_logHR = (log(UpperExp) - log(LowerExp)) / (2*1.96);

    if Label = 'HR11: 10% ↓ UPF, shp=1' then short_label = 'HR11';
    else if Label = 'HR01: 10% ↓ UPF, shp=0' then short_label = 'HR01';
    else if Label = 'HR10: Max UPF + shp=1' then short_label = 'HR10';
run;

proc transpose data=reri_prep out=logHR_t prefix=logHR_;
    id short_label;
    var logHR;
run;

proc transpose data=reri_prep out=se_t prefix=se_logHR_;
    id short_label;
    var se_logHR;
run;

data reri_api;
    merge logHR_t se_t;

    logHR11 = logHR_HR11;
    logHR01 = logHR_HR01;
    logHR10 = logHR_HR10;

    se11 = se_logHR_HR11;
    se01 = se_logHR_HR01;
    se10 = se_logHR_HR10;

    HR11 = exp(logHR11);
    HR01 = exp(logHR01);
    HR10 = exp(logHR10);

    RERI = HR11 - HR10 - HR01 + 1;
    API = RERI / HR11;

    varHR11 = (HR11 * se11)**2;
    varHR10 = (HR10 * se10)**2;
    varHR01 = (HR01 * se01)**2;

    varRERI = varHR11 + varHR10 + varHR01;
    seRERI = sqrt(varRERI);

    lowerRERI = RERI - 1.96*seRERI;
    upperRERI = RERI + 1.96*seRERI;

    format RERI API lowerRERI upperRERI 8.3;
run;

proc print data=reri_api noobs label;
    var RERI API lowerRERI upperRERI;
    label 
        RERI = "RERI (interaction additive)"
        API = "Attributable Proportion due to Interaction (API)"
        lowerRERI = "Lower 95% CI RERI"
        upperRERI = "Upper 95% CI RERI";
run;









/*AH ET UPF OR FOPS */

data au.final_ah; 
    set au.final_ah;
   UPFU_or_SNU_grams_continue = (UPFU_or_SNU_grams  / 10) * -1;
run;


proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp(ref='1') sdp / param=ref;

    model time*ecv(0) = shp UPFU_or_SNU_grams_continue shp*UPFU_or_SNU_grams_continue
                        sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat sdp
                        p_age HOUSE_INCOME_YEAR_cat
                        / risklimits;

    estimate "HR01: 10% ↓ UPF, shp=0" 
       UPFU_or_SNU_grams_continue 1 shp 0 shp*UPFU_or_SNU_grams_continue 0 / exp cl;

    estimate "HR11: 10% ↓ UPF, shp=1" 
        UPFU_or_SNU_grams_continue 1 shp 1 shp*UPFU_or_SNU_grams_continue 1 / exp cl;
    estimate "HR10: Max UPF + shp=1"
        UPFU_or_SNU_grams_continue 0 shp 1 shp*UPFU_or_SNU_grams_continue 0 / exp cl;
    ods output Estimates=est_noncentered;
run;


data reri_prep;
    set est_noncentered;
    if Label in (
        'HR11: 10% ↓ UPF, shp=1', 
        'HR01: 10% ↓ UPF, shp=0', 
        'HR10: Max UPF + shp=1'
    );

    logHR = log(ExpEstimate);
    se_logHR = (log(UpperExp) - log(LowerExp)) / (2*1.96);

    if Label = 'HR11: 10% ↓ UPF, shp=1' then short_label = 'HR11';
    else if Label = 'HR01: 10% ↓ UPF, shp=0' then short_label = 'HR01';
    else if Label = 'HR10: Max UPF + shp=1' then short_label = 'HR10';
run;

proc transpose data=reri_prep out=logHR_t prefix=logHR_;
    id short_label;
    var logHR;
run;

proc transpose data=reri_prep out=se_t prefix=se_logHR_;
    id short_label;
    var se_logHR;
run;

data reri_api;
    merge logHR_t se_t;

    logHR11 = logHR_HR11;
    logHR01 = logHR_HR01;
    logHR10 = logHR_HR10;

    se11 = se_logHR_HR11;
    se01 = se_logHR_HR01;
    se10 = se_logHR_HR10;

    HR11 = exp(logHR11);
    HR01 = exp(logHR01);
    HR10 = exp(logHR10);

    RERI = HR11 - HR10 - HR01 + 1;
    API = RERI / HR11;

    varHR11 = (HR11 * se11)**2;
    varHR10 = (HR10 * se10)**2;
    varHR01 = (HR01 * se01)**2;

    varRERI = varHR11 + varHR10 + varHR01;
    seRERI = sqrt(varRERI);

    lowerRERI = RERI - 1.96*seRERI;
    upperRERI = RERI + 1.96*seRERI;

    format RERI API lowerRERI upperRERI 8.3;
run;

proc print data=reri_api noobs label;
    var RERI API lowerRERI upperRERI;
    label 
        RERI = "RERI (interaction additive)"
        API = "Attributable Proportion due to Interaction (API)"
        lowerRERI = "Lower 95% CI RERI"
        upperRERI = "Upper 95% CI RERI";
run;






/*AH ET UPF AND FOPS */

data au.final_ah; 
    set au.final_ah;
   UPFU_SNU_grams_continue = (UPFU_SNU_grams  / 10) * -1;
run;

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp(ref='1') sdp / param=ref;

    model time*ecv(0) = shp UPFU_SNU_grams_continue shp*UPFU_SNU_grams_continue
                        sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat sdp
                        p_age HOUSE_INCOME_YEAR_cat
                        / risklimits;

    estimate "HR01: 10% ↓ UPF, shp=0" 
       UPFU_SNU_grams_continue 1 shp 0 shp*UPFU_SNU_grams_continue 0 / exp cl;

    estimate "HR11: 10% ↓ UPF, shp=1" 
        UPFU_SNU_grams_continue 1 shp 1 shp*UPFU_SNU_grams_continue 1 / exp cl;

    estimate "HR10: Max UPF + shp=1"        
        UPFU_SNU_grams_continue 0 shp 1 shp*UPFU_SNU_grams_continue 0 / exp cl;

    ods output Estimates=est_noncentered;
run;

data reri_prep;
    set est_noncentered;
    if Label in (
        'HR11: 10% ↓ UPF, shp=1', 
        'HR01: 10% ↓ UPF, shp=0', 
        'HR10: Max UPF + shp=1'
    );

    logHR = log(ExpEstimate);
    se_logHR = (log(UpperExp) - log(LowerExp)) / (2*1.96);

    if Label = 'HR11: 10% ↓ UPF, shp=1' then short_label = 'HR11';
    else if Label = 'HR01: 10% ↓ UPF, shp=0' then short_label = 'HR01';
    else if Label = 'HR10: Max UPF + shp=1' then short_label = 'HR10';
run;

proc transpose data=reri_prep out=logHR_t prefix=logHR_;
    id short_label;
    var logHR;
run;

proc transpose data=reri_prep out=se_t prefix=se_logHR_;
    id short_label;
    var se_logHR;
run;

data reri_api;
    merge logHR_t se_t;

    logHR11 = logHR_HR11;
    logHR01 = logHR_HR01;
    logHR10 = logHR_HR10;

    se11 = se_logHR_HR11;
    se01 = se_logHR_HR01;
    se10 = se_logHR_HR10;

    HR11 = exp(logHR11);
    HR01 = exp(logHR01);
    HR10 = exp(logHR10);

    RERI = HR11 - HR10 - HR01 + 1;
    API = RERI / HR11;

    varHR11 = (HR11 * se11)**2;
    varHR10 = (HR10 * se10)**2;
    varHR01 = (HR01 * se01)**2;

    varRERI = varHR11 + varHR10 + varHR01;
    seRERI = sqrt(varRERI);

    lowerRERI = RERI - 1.96*seRERI;
    upperRERI = RERI + 1.96*seRERI;

    format RERI API lowerRERI upperRERI 8.3;
run;

proc print data=reri_api noobs label;
    var RERI API lowerRERI upperRERI;
    label 
        RERI = "RERI (interaction additive)"
        API = "Attributable Proportion due to Interaction (API)"
        lowerRERI = "Lower 95% CI RERI"
        upperRERI = "Upper 95% CI RERI";
run;







/* HP et UPF */

data au.final_hp; 
    set au.final_hp;
  upf_grams_continue_s = (UPF_grams_s / 10) * -1;
run;


proc phreg data=au.final_hp covs(aggregate);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat sdp(ref='1') shp / param=ref;

    model time*ecv(0) = sdp upf_grams_continue_s sdp*upf_grams_continue_s
                        sexe ENERGY_KCAL_CCHS_n BMI_score_n 
                        SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat
                        p_age shp / risklimits;

    estimate "HR01: 10% ↓ UPF, sdp=0" 
        upf_grams_continue_s 1 sdp 0 sdp*upf_grams_continue_s 0 / exp cl;

    estimate "HR11: 10% ↓ UPF, sdp=1" 
        upf_grams_continue_s 1 sdp 1 sdp*upf_grams_continue_s 1 / exp cl;
        
    estimate "HR10: Max UPF + sdp=1"
         upf_grams_continue_s 0 sdp 1 sdp*upf_grams_continue_s 0 / exp cl;

    ods output Estimates=est_noncentered;
run;



data reri_prep;
    set est_noncentered;
    if Label in (
        'HR11: 10% ↓ UPF, sdp=1', 
        'HR01: 10% ↓ UPF, sdp=0', 
        'HR10: Max UPF + sdp=1'
    );

    logHR = log(ExpEstimate);
    se_logHR = (log(UpperExp) - log(LowerExp)) / (2*1.96);

    if Label = 'HR11: 10% ↓ UPF, sdp=1' then short_label = 'HR11';
    else if Label = 'HR01: 10% ↓ UPF, sdp=0' then short_label = 'HR01';
    else if Label = 'HR10: Max UPF + sdp=1' then short_label = 'HR10';
run;

proc transpose data=reri_prep out=logHR_t prefix=logHR_;
    id short_label;
    var logHR;
run;

proc transpose data=reri_prep out=se_t prefix=se_logHR_;
    id short_label;
    var se_logHR;
run;

data reri_api;
    merge logHR_t se_t;

    logHR11 = logHR_HR11;
    logHR01 = logHR_HR01;
    logHR10 = logHR_HR10;

    se11 = se_logHR_HR11;
    se01 = se_logHR_HR01;
    se10 = se_logHR_HR10;

    HR11 = exp(logHR11);
    HR01 = exp(logHR01);
    HR10 = exp(logHR10);

    RERI = HR11 - HR10 - HR01 + 1;
    API = RERI / HR11;

    varHR11 = (HR11 * se11)**2;
    varHR10 = (HR10 * se10)**2;
    varHR01 = (HR01 * se01)**2;

    varRERI = varHR11 + varHR10 + varHR01;
    seRERI = sqrt(varRERI);

    lowerRERI = RERI - 1.96 * seRERI;
    upperRERI = RERI + 1.96 * seRERI;

    format RERI API lowerRERI upperRERI 8.3;
run;

proc print data=reri_api noobs label;
    var RERI API lowerRERI upperRERI;
    label 
        RERI = "RERI (interaction additive)"
        API = "Attributable Proportion due to Interaction (API)"
        lowerRERI = "Lower 95% CI RERI"
        upperRERI = "Upper 95% CI RERI";
run;





/* HP et FOPS */


data au.final_hp; 
    set au.final_hp;
   sn_grams_s_continue = (sn_tot_grams_s / 10) * -1;
run;


proc phreg data=au.final_hp covs(aggregate);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat sdp(ref='1') shp / param=ref;

    model time*ecv(0) = sdp sn_grams_s_continue sdp*sn_grams_s_continue
                        sexe ENERGY_KCAL_CCHS_n BMI_score_n 
                        SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat
                        p_age shp / risklimits;

    estimate "HR01: 10% ↓ UPF, sdp=0" 
        sn_grams_s_continue 1 sdp 0 sdp*sn_grams_s_continue 0 / exp cl;

    estimate "HR11: 10% ↓ UPF, sdp=1" 
        sn_grams_s_continue 1 sdp 1 sdp*sn_grams_s_continue 1 / exp cl;
    
    estimate "HR10: Max UPF + sdp=1"
        sn_grams_s_continue 0 sdp 1 sdp*sn_grams_s_continue 0 / exp cl;
    ods output Estimates=est_noncentered;
run;

data reri_prep;
    set est_noncentered;
    if Label in (
        'HR11: 10% ↓ UPF, sdp=1', 
        'HR01: 10% ↓ UPF, sdp=0', 
        'HR10: Max UPF + sdp=1'
    );

    logHR = log(ExpEstimate);
    se_logHR = (log(UpperExp) - log(LowerExp)) / (2*1.96);

    if Label = 'HR11: 10% ↓ UPF, sdp=1' then short_label = 'HR11';
    else if Label = 'HR01: 10% ↓ UPF, sdp=0' then short_label = 'HR01';
    else if Label = 'HR10: Max UPF + sdp=1' then short_label = 'HR10';
run;

proc transpose data=reri_prep out=logHR_t prefix=logHR_;
    id short_label;
    var logHR;
run;

proc transpose data=reri_prep out=se_t prefix=se_logHR_;
    id short_label;
    var se_logHR;
run;

data reri_api;
    merge logHR_t se_t;

    logHR11 = logHR_HR11;
    logHR01 = logHR_HR01;
    logHR10 = logHR_HR10;

    se11 = se_logHR_HR11;
    se01 = se_logHR_HR01;
    se10 = se_logHR_HR10;

    HR11 = exp(logHR11);
    HR01 = exp(logHR01);
    HR10 = exp(logHR10);

    RERI = HR11 - HR10 - HR01 + 1;
    API = RERI / HR11;

    varHR11 = (HR11 * se11)**2;
    varHR10 = (HR10 * se10)**2;
    varHR01 = (HR01 * se01)**2;

    varRERI = varHR11 + varHR10 + varHR01;
    seRERI = sqrt(varRERI);

    lowerRERI = RERI - 1.96 * seRERI;
    upperRERI = RERI + 1.96 * seRERI;

    format RERI API lowerRERI upperRERI 8.3;
run;

proc print data=reri_api noobs label;
    var RERI API lowerRERI upperRERI;
    label 
        RERI = "RERI (interaction additive)"
        API = "Attributable Proportion due to Interaction (API)"
        lowerRERI = "Lower 95% CI RERI"
        upperRERI = "Upper 95% CI RERI";
run;




/* HP ET UPF OR FOPS*/


data au.final_hp; 
    set au.final_hp;
   UPFU_or_SNU_grams_continue = (UPFU_or_SNU_grams  / 10) * -1;
run;


proc phreg data=au.final_hp covs(aggregate);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat sdp(ref='1') shp / param=ref;

    model time*ecv(0) = sdp UPFU_or_SNU_grams_continue sdp*UPFU_or_SNU_grams_continue
                        sexe ENERGY_KCAL_CCHS_n BMI_score_n 
                        SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat
                        p_age shp / risklimits;

    estimate "HR01: 10% ↓ UPF, sdp=0" 
        UPFU_or_SNU_grams_continue 1 sdp 0 sdp*UPFU_or_SNU_grams_continue 0 / exp cl;

    estimate "HR11: 10% ↓ UPF, sdp=1" 
        UPFU_or_SNU_grams_continue 1 sdp 1 sdp*UPFU_or_SNU_grams_continue 1 / exp cl;
        
    estimate "HR10: Max UPF + sdp=1"   
        UPFU_or_SNU_grams_continue 0 sdp 1 sdp*UPFU_or_SNU_grams_continue 0 / exp cl;
        
    ods output Estimates=est_noncentered;
run;

data reri_prep;
    set est_noncentered;
    if Label in (
        'HR11: 10% ↓ UPF, sdp=1', 
        'HR01: 10% ↓ UPF, sdp=0', 
        'HR10: Max UPF + sdp=1'
    );

    logHR = log(ExpEstimate);
    se_logHR = (log(UpperExp) - log(LowerExp)) / (2*1.96);

    if Label = 'HR11: 10% ↓ UPF, sdp=1' then short_label = 'HR11';
    else if Label = 'HR01: 10% ↓ UPF, sdp=0' then short_label = 'HR01';
    else if Label = 'HR10: Max UPF + sdp=1' then short_label = 'HR10';
run;

proc transpose data=reri_prep out=logHR_t prefix=logHR_;
    id short_label;
    var logHR;
run;

proc transpose data=reri_prep out=se_t prefix=se_logHR_;
    id short_label;
    var se_logHR;
run;

data reri_api;
    merge logHR_t se_t;

    logHR11 = logHR_HR11;
    logHR01 = logHR_HR01;
    logHR10 = logHR_HR10;

    se11 = se_logHR_HR11;
    se01 = se_logHR_HR01;
    se10 = se_logHR_HR10;

    HR11 = exp(logHR11);
    HR01 = exp(logHR01);
    HR10 = exp(logHR10);

    RERI = HR11 - HR10 - HR01 + 1;
    API = RERI / HR11;

    varHR11 = (HR11 * se11)**2;
    varHR10 = (HR10 * se10)**2;
    varHR01 = (HR01 * se01)**2;

    varRERI = varHR11 + varHR10 + varHR01;
    seRERI = sqrt(varRERI);

    lowerRERI = RERI - 1.96 * seRERI;
    upperRERI = RERI + 1.96 * seRERI;

    format RERI API lowerRERI upperRERI 8.3;
run;

proc print data=reri_api noobs label;
    var RERI API lowerRERI upperRERI;
    label 
        RERI = "RERI (interaction additive)"
        API = "Attributable Proportion due to Interaction (API)"
        lowerRERI = "Lower 95% CI RERI"
        upperRERI = "Upper 95% CI RERI";
run;


/* HP ET UPF AND FOPS*/


data au.final_hp; 
    set au.final_hp;
   UPFU_SNU_grams_continue = (UPFU_SNU_grams  / 10) * -1;
run;

proc phreg data=au.final_hp covs(aggregate);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat sdp(ref='1') shp / param=ref;

    model time*ecv(0) = sdp UPFU_SNU_grams_continue sdp*UPFU_SNU_grams_continue
                        sexe ENERGY_KCAL_CCHS_n BMI_score_n 
                        SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat
                        p_age shp / risklimits;

    estimate "HR01: 10% ↓ UPF, sdp=0" 
        UPFU_SNU_grams_continue 1 sdp 0 sdp*UPFU_SNU_grams_continue 0 / exp cl;

    estimate "HR11: 10% ↓ UPF, sdp=1" 
        UPFU_SNU_grams_continue 1 sdp 1 sdp*UPFU_SNU_grams_continue 1 / exp cl;
    estimate "HR10: Max UPF + sdp=1"
        UPFU_SNU_grams_continue 0 sdp 1 sdp*UPFU_SNU_grams_continue 0 / exp cl;
    ods output Estimates=est_noncentered;
run;


data reri_prep;
    set est_noncentered;
    if Label in (
        'HR11: 10% ↓ UPF, sdp=1', 
        'HR01: 10% ↓ UPF, sdp=0', 
        'HR10: Max UPF + sdp=1'
    );

    logHR = log(ExpEstimate);
    se_logHR = (log(UpperExp) - log(LowerExp)) / (2*1.96);

    if Label = 'HR11: 10% ↓ UPF, sdp=1' then short_label = 'HR11';
    else if Label = 'HR01: 10% ↓ UPF, sdp=0' then short_label = 'HR01';
    else if Label = 'HR10: Max UPF + sdp=1' then short_label = 'HR10';
run;

proc transpose data=reri_prep out=logHR_t prefix=logHR_;
    id short_label;
    var logHR;
run;

proc transpose data=reri_prep out=se_t prefix=se_logHR_;
    id short_label;
    var se_logHR;
run;

data reri_api;
    merge logHR_t se_t;

    logHR11 = logHR_HR11;
    logHR01 = logHR_HR01;
    logHR10 = logHR_HR10;

    se11 = se_logHR_HR11;
    se01 = se_logHR_HR01;
    se10 = se_logHR_HR10;

    HR11 = exp(logHR11);
    HR01 = exp(logHR01);
    HR10 = exp(logHR10);

    RERI = HR11 - HR10 - HR01 + 1;
    API = RERI / HR11;

    varHR11 = (HR11 * se11)**2;
    varHR10 = (HR10 * se10)**2;
    varHR01 = (HR01 * se01)**2;

    varRERI = varHR11 + varHR10 + varHR01;
    seRERI = sqrt(varRERI);

    lowerRERI = RERI - 1.96 * seRERI;
    upperRERI = RERI + 1.96 * seRERI;

    format RERI API lowerRERI upperRERI 8.3;
run;

proc print data=reri_api noobs label;
    var RERI API lowerRERI upperRERI;
    label 
        RERI = "RERI (interaction additive)"
        API = "Attributable Proportion due to Interaction (API)"
        lowerRERI = "Lower 95% CI RERI"
        upperRERI = "Upper 95% CI RERI";
run;










