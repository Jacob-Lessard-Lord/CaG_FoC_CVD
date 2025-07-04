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

/*courbe de survie */
/* 1. Moyenne des variables continues par tercile */
proc means data=au.final noprint;
    class tercile_upf_grams_s;
    var ENERGY_KCAL_CCHS_n BMI_score_n p_age shp sdp;
    output out=stats_mean mean=ENERGY_MEAN BMI_MEAN AGE_MEAN SHP_MEAN SDP_MEAN;
run;

/* 2. Mode des variables catégorielles par tercile */

/* Sexe */
proc freq data=au.final noprint;
    tables tercile_upf_grams_s*sexe / out=freq_sexe(rename=(count=Count));
run;

proc sql;
    create table mode_sexe as
    select tercile_upf_grams_s, sexe
    from freq_sexe
    group by tercile_upf_grams_s
    having Count = max(Count);
quit;

/* SMOKING_STATUS_cat */
proc freq data=au.final noprint;
    tables tercile_upf_grams_s*SMOKING_STATUS_cat / out=freq_smoking(rename=(count=Count));
run;

proc sql;
    create table mode_smoking as
    select tercile_upf_grams_s, SMOKING_STATUS_cat
    from freq_smoking
    group by tercile_upf_grams_s
    having Count = max(Count);
quit;

/* HOUSE_INCOME_YEAR_cat */
proc freq data=au.final noprint;
    tables tercile_upf_grams_s*HOUSE_INCOME_YEAR_cat / out=freq_house_income(rename=(count=Count));
run;

proc sql;
    create table mode_house_income as
    select tercile_upf_grams_s, HOUSE_INCOME_YEAR_cat
    from freq_house_income
    group by tercile_upf_grams_s
    having Count = max(Count);
quit;

proc freq data=au.final noprint;
    tables tercile_upf_grams_s*shp / out=freq_shp(rename=(count=Count));
run;

proc sql;
    create table mode_shp as
    select tercile_upf_grams_s, shp
    from freq_shp
    group by tercile_upf_grams_s
    having Count = max(Count);
quit;

proc freq data=au.final noprint;
    tables tercile_upf_grams_s*sdp / out=freq_sdp(rename=(count=Count));
run;

proc sql;
    create table mode_sdp as
    select tercile_upf_grams_s, sdp
    from freq_sdp
    group by tercile_upf_grams_s
    having Count = max(Count);
quit;


/* 3. Combinaison des modalités modales */
proc sql;
    create table modes_cat as
    select a.tercile_upf_grams_s, a.sexe, b.SMOKING_STATUS_cat, c.HOUSE_INCOME_YEAR_cat, d.shp, e.sdp
    from mode_sexe a
    inner join mode_smoking b on a.tercile_upf_grams_s = b.tercile_upf_grams_s
    inner join mode_house_income c on a.tercile_upf_grams_s = c.tercile_upf_grams_s
    inner join mode_shp d on a.tercile_upf_grams_s = d.tercile_upf_grams_s
    inner join mode_sdp e on a.tercile_upf_grams_s = e.tercile_upf_grams_s
    order by tercile_upf_grams_s;
quit;


/* 4. Nettoyage du dataset stats_mean (supprimer _TYPE_, _FREQ_) */
data stats_mean_clean;
    set stats_mean;
    if _TYPE_ = 1; /* _TYPE_=1 correspond aux moyennes par classe */
    keep tercile_upf_grams_s ENERGY_MEAN BMI_MEAN AGE_MEAN SHP_MEAN SDP_MEAN;
run;

/* 5. Combinaison finale profils = moyennes + modalités modales */
proc sql;
    create table profils as
    select a.tercile_upf_grams_s,
           a.sexe,
           a.SMOKING_STATUS_cat,
           a.HOUSE_INCOME_YEAR_cat,
           a.shp,
           a.sdp,
           b.ENERGY_MEAN as ENERGY_KCAL_CCHS_n,
           b.BMI_MEAN as BMI_score_n,
           b.AGE_MEAN as p_age
    from modes_cat a
    inner join stats_mean_clean b
    on a.tercile_upf_grams_s = b.tercile_upf_grams_s
    order by tercile_upf_grams_s;
quit;

/* 6. Modèle Cox et estimation des courbes de survie pour ces profils */

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_upf_grams_s(ref="3");
    model time*ecv(0) = tercile_upf_grams_s shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat  
                        HOUSE_INCOME_YEAR_cat p_age / risklimits;

    baseline out=surv_pred survival=survival_prob covariates=profils / method=PL;
run;


data surv_pred;
    set surv_pred;
    length UPF $30.;
    
    /* Conversion en années (en supposant 365.25 jours/an pour précision) */
    time_years = time / 365.25;
    if tercile_upf_grams_s = 1 then UPF = "Tertile 1";
    else if tercile_upf_grams_s = 2 then UPF = "Tertile 2";
    else if tercile_upf_grams_s = 3 then UPF = "Tertile 3";
run;

/* 7. Tracé des courbes de survie par tercile */
ods pdf file="/project/166600266/CAG_912595/LILEB/Medication CP/CODE/courbes_UPF.pdf" style=journal; 

proc sgplot data=surv_pred;
    series x=time_years y=survival_prob / group=UPF markers;
    xaxis label="Time (years)";
    yaxis label="Survival probability" values=(0.85 to 1 by 0.05);  /* échelle de 0 à 1 par pas de 0.05 */
    title "";
run;

ods pdf close;






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




/* 1. Moyennes des variables continues par tercile_SN_tot_grams_s */
proc means data=au.final noprint;
    class tercile_SN_tot_grams_s;
    var ENERGY_KCAL_CCHS_n BMI_score_n p_age;
    output out=stats_mean_sn mean=ENERGY_MEAN BMI_MEAN AGE_MEAN;
run;

/* 2. Récupérer les modalités modales (modes) des variables catégorielles par tercile_SN_tot_grams_s */

/* sexe */
proc freq data=au.final noprint;
    tables tercile_SN_tot_grams_s*sexe / out=freq_sexe_sn(rename=(count=Count));
run;

proc sql;
    create table mode_sexe_sn as
    select tercile_SN_tot_grams_s, sexe
    from freq_sexe_sn
    group by tercile_SN_tot_grams_s
    having Count = max(Count);
quit;

/* SMOKING_STATUS_cat */
proc freq data=au.final noprint;
    tables tercile_SN_tot_grams_s*SMOKING_STATUS_cat / out=freq_smoking_sn(rename=(count=Count));
run;

proc sql;
    create table mode_smoking_sn as
    select tercile_SN_tot_grams_s, SMOKING_STATUS_cat
    from freq_smoking_sn
    group by tercile_SN_tot_grams_s
    having Count = max(Count);
quit;

/* HOUSE_INCOME_YEAR_cat */
proc freq data=au.final noprint;
    tables tercile_SN_tot_grams_s*HOUSE_INCOME_YEAR_cat / out=freq_house_income_sn(rename=(count=Count));
run;

proc sql;
    create table mode_house_income_sn as
    select tercile_SN_tot_grams_s, HOUSE_INCOME_YEAR_cat
    from freq_house_income_sn
    group by tercile_SN_tot_grams_s
    having Count = max(Count);
quit;

/* shp */
proc freq data=au.final noprint;
    tables tercile_SN_tot_grams_s*shp / out=freq_shp_sn(rename=(count=Count));
run;

proc sql;
    create table mode_shp_sn as
    select tercile_SN_tot_grams_s, shp
    from freq_shp_sn
    group by tercile_SN_tot_grams_s
    having Count = max(Count);
quit;

/* sdp */
proc freq data=au.final noprint;
    tables tercile_SN_tot_grams_s*sdp / out=freq_sdp_sn(rename=(count=Count));
run;

proc sql;
    create table mode_sdp_sn as
    select tercile_SN_tot_grams_s, sdp
    from freq_sdp_sn
    group by tercile_SN_tot_grams_s
    having Count = max(Count);
quit;

/* 3. Combiner les modalités modales */
proc sql;
    create table modes_cat_sn as
    select a.tercile_SN_tot_grams_s, a.sexe, b.SMOKING_STATUS_cat, c.HOUSE_INCOME_YEAR_cat, d.shp, e.sdp
    from mode_sexe_sn a
    inner join mode_smoking_sn b on a.tercile_SN_tot_grams_s = b.tercile_SN_tot_grams_s
    inner join mode_house_income_sn c on a.tercile_SN_tot_grams_s = c.tercile_SN_tot_grams_s
    inner join mode_shp_sn d on a.tercile_SN_tot_grams_s = d.tercile_SN_tot_grams_s
    inner join mode_sdp_sn e on a.tercile_SN_tot_grams_s = e.tercile_SN_tot_grams_s
    order by tercile_SN_tot_grams_s;
quit;

/* 4. Nettoyer stats_mean_sn */
data stats_mean_sn_clean;
    set stats_mean_sn;
    if _TYPE_ = 1;
    keep tercile_SN_tot_grams_s ENERGY_MEAN BMI_MEAN AGE_MEAN;
run;

/* 5. Combiner profils pour baseline */
proc sql;
    create table profils_sn as
    select a.tercile_SN_tot_grams_s,
           a.sexe,
           a.SMOKING_STATUS_cat,
           a.HOUSE_INCOME_YEAR_cat,
           a.shp,
           a.sdp,
           b.ENERGY_MEAN as ENERGY_KCAL_CCHS_n,
           b.BMI_MEAN as BMI_score_n,
           b.AGE_MEAN as p_age
    from modes_cat_sn a
    inner join stats_mean_sn_clean b
    on a.tercile_SN_tot_grams_s = b.tercile_SN_tot_grams_s
    order by tercile_SN_tot_grams_s;
quit;

/* 6. Modèle Cox et baseline */

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat tercile_SN_tot_grams_s(ref="3");
    model time*ecv(0) = tercile_SN_tot_grams_s shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat  
                        p_age HOUSE_INCOME_YEAR_cat / risklimits;
    assess ph / resample;
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s;
    ID id;
    baseline out=surv_pred_sn survival=survival_prob covariates=profils_sn / method=PL;
run;

data surv_pred_sn;
    set surv_pred_sn;
    length FOPS $30.;
    
    /* Conversion en années (en supposant 365.25 jours/an pour précision) */
    time_years = time / 365.25;
    if tercile_SN_tot_grams_s = 1 then FOPS = "Tertile 1";
    else if tercile_SN_tot_grams_s = 2 then FOPS = "Tertile 2";
    else if tercile_SN_tot_grams_s = 3 then FOPS = "Tertile 3";
run;
/* 7. Sortie graphique PDF */

ods pdf file="C:\chemin\vers\ton\dossier\courbes_survie_SN_par_tercile.pdf" style=journal;

proc sgplot data=surv_pred_sn;
    series x=time_years y=survival_prob / group=FOPS markers;
    xaxis label="Time (years)";
    yaxis label="Survival probability" values=(0.85 to 1 by 0.05);
    title "";
run;

ods pdf close;




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


/* 1. Moyennes variables continues par tercile_UPFU_OR_SNU_grams */
proc means data=au.final noprint;
    class tercile_UPFU_OR_SNU_grams;
    var ENERGY_KCAL_CCHS_n BMI_score_n p_age;
    output out=stats_mean_upfu mean=ENERGY_MEAN BMI_MEAN AGE_MEAN;
run;

/* 2. Modes variables catégorielles par tercile_UPFU_OR_SNU_grams */

/* sexe */
proc freq data=au.final noprint;
    tables tercile_UPFU_OR_SNU_grams*sexe / out=freq_sexe_upfu(rename=(count=Count));
run;

proc sql;
    create table mode_sexe_upfu as
    select tercile_UPFU_OR_SNU_grams, sexe
    from freq_sexe_upfu
    group by tercile_UPFU_OR_SNU_grams
    having Count = max(Count);
quit;

/* SMOKING_STATUS_cat */
proc freq data=au.final noprint;
    tables tercile_UPFU_OR_SNU_grams*SMOKING_STATUS_cat / out=freq_smoking_upfu(rename=(count=Count));
run;

proc sql;
    create table mode_smoking_upfu as
    select tercile_UPFU_OR_SNU_grams, SMOKING_STATUS_cat
    from freq_smoking_upfu
    group by tercile_UPFU_OR_SNU_grams
    having Count = max(Count);
quit;

/* HOUSE_INCOME_YEAR_cat */
proc freq data=au.final noprint;
    tables tercile_UPFU_OR_SNU_grams*HOUSE_INCOME_YEAR_cat / out=freq_house_income_upfu(rename=(count=Count));
run;

proc sql;
    create table mode_house_income_upfu as
    select tercile_UPFU_OR_SNU_grams, HOUSE_INCOME_YEAR_cat
    from freq_house_income_upfu
    group by tercile_UPFU_OR_SNU_grams
    having Count = max(Count);
quit;

/* shp */
proc freq data=au.final noprint;
    tables tercile_UPFU_OR_SNU_grams*shp / out=freq_shp_upfu(rename=(count=Count));
run;

proc sql;
    create table mode_shp_upfu as
    select tercile_UPFU_OR_SNU_grams, shp
    from freq_shp_upfu
    group by tercile_UPFU_OR_SNU_grams
    having Count = max(Count);
quit;

/* sdp */
proc freq data=au.final noprint;
    tables tercile_UPFU_OR_SNU_grams*sdp / out=freq_sdp_upfu(rename=(count=Count));
run;

proc sql;
    create table mode_sdp_upfu as
    select tercile_UPFU_OR_SNU_grams, sdp
    from freq_sdp_upfu
    group by tercile_UPFU_OR_SNU_grams
    having Count = max(Count);
quit;

/* 3. Combinaison des modalités */
proc sql;
    create table modes_cat_upfu as
    select a.tercile_UPFU_OR_SNU_grams, a.sexe, b.SMOKING_STATUS_cat, c.HOUSE_INCOME_YEAR_cat, d.shp, e.sdp
    from mode_sexe_upfu a
    inner join mode_smoking_upfu b on a.tercile_UPFU_OR_SNU_grams = b.tercile_UPFU_OR_SNU_grams
    inner join mode_house_income_upfu c on a.tercile_UPFU_OR_SNU_grams = c.tercile_UPFU_OR_SNU_grams
    inner join mode_shp_upfu d on a.tercile_UPFU_OR_SNU_grams = d.tercile_UPFU_OR_SNU_grams
    inner join mode_sdp_upfu e on a.tercile_UPFU_OR_SNU_grams = e.tercile_UPFU_OR_SNU_grams
    order by tercile_UPFU_OR_SNU_grams;
quit;

/* 4. Nettoyage stats_mean */
data stats_mean_upfu_clean;
    set stats_mean_upfu;
    if _TYPE_ = 1;
    keep tercile_UPFU_OR_SNU_grams ENERGY_MEAN BMI_MEAN AGE_MEAN;
run;

/* 5. Création du dataset profils */
proc sql;
    create table profils_upfu as
    select a.tercile_UPFU_OR_SNU_grams,
           a.sexe,
           a.SMOKING_STATUS_cat,
           a.HOUSE_INCOME_YEAR_cat,
           a.shp,
           a.sdp,
           b.ENERGY_MEAN as ENERGY_KCAL_CCHS_n,
           b.BMI_MEAN as BMI_score_n,
           b.AGE_MEAN as p_age
    from modes_cat_upfu a
    inner join stats_mean_upfu_clean b
    on a.tercile_UPFU_OR_SNU_grams = b.tercile_UPFU_OR_SNU_grams
    order by tercile_UPFU_OR_SNU_grams;
quit;

/* 6. Exécution modèle avec baseline */

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPFU_OR_SNU_grams shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat  
                        p_age HOUSE_INCOME_YEAR_cat / risklimits;
    assess ph / resample;
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_OR_SNU_grams;
    ID id;
    baseline out=surv_pred_upfu survival=survival_prob covariates=profils_upfu / method=PL;
run;

data surv_pred_upfu;
    set surv_pred_upfu;
    length UPF_or_FOPS $30.;
    
    /* Conversion en années (en supposant 365.25 jours/an pour précision) */
    time_years = time / 365.25;
    if tercile_UPFU_OR_SNU_grams = 1 then UPF_or_FOPS = "Tertile 1";
    else if tercile_UPFU_OR_SNU_grams = 2 then UPF_or_FOPS = "Tertile 2";
    else if tercile_UPFU_OR_SNU_grams = 3 then UPF_or_FOPS = "Tertile 3";
run;
/* 7. Export graphique en PDF */

ods pdf file="C:\chemin\vers\ton\dossier\courbes_survie_UPFU_OR_SNU_par_tercile.pdf" style=journal;

proc sgplot data=surv_pred_upfu;
    series x=time_years y=survival_prob / group=UPF_or_FOPS markers;
    xaxis label="Time (years)";
    yaxis label="Survival probability" values=(0.85 to 1 by 0.05);
    title "";
run;

ods pdf close;





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



/* 1. Moyennes des variables continues par tercile_UPFU_SNU_grams */
proc means data=au.final noprint;
    class tercile_UPFU_SNU_grams;
    var ENERGY_KCAL_CCHS_n BMI_score_n p_age;
    output out=stats_mean_upfu_snu mean=ENERGY_MEAN BMI_MEAN AGE_MEAN;
run;

/* 2. Modes variables catégorielles par tercile_UPFU_SNU_grams */

/* sexe */
proc freq data=au.final noprint;
    tables tercile_UPFU_SNU_grams*sexe / out=freq_sexe_upfu_snu(rename=(count=Count));
run;

proc sql;
    create table mode_sexe_upfu_snu as
    select tercile_UPFU_SNU_grams, sexe
    from freq_sexe_upfu_snu
    group by tercile_UPFU_SNU_grams
    having Count = max(Count);
quit;

/* SMOKING_STATUS_cat */
proc freq data=au.final noprint;
    tables tercile_UPFU_SNU_grams*SMOKING_STATUS_cat / out=freq_smoking_upfu_snu(rename=(count=Count));
run;

proc sql;
    create table mode_smoking_upfu_snu as
    select tercile_UPFU_SNU_grams, SMOKING_STATUS_cat
    from freq_smoking_upfu_snu
    group by tercile_UPFU_SNU_grams
    having Count = max(Count);
quit;

/* HOUSE_INCOME_YEAR_cat */
proc freq data=au.final noprint;
    tables tercile_UPFU_SNU_grams*HOUSE_INCOME_YEAR_cat / out=freq_house_income_upfu_snu(rename=(count=Count));
run;

proc sql;
    create table mode_house_income_upfu_snu as
    select tercile_UPFU_SNU_grams, HOUSE_INCOME_YEAR_cat
    from freq_house_income_upfu_snu
    group by tercile_UPFU_SNU_grams
    having Count = max(Count);
quit;

/* shp */
proc freq data=au.final noprint;
    tables tercile_UPFU_SNU_grams*shp / out=freq_shp_upfu_snu(rename=(count=Count));
run;

proc sql;
    create table mode_shp_upfu_snu as
    select tercile_UPFU_SNU_grams, shp
    from freq_shp_upfu_snu
    group by tercile_UPFU_SNU_grams
    having Count = max(Count);
quit;

/* sdp */
proc freq data=au.final noprint;
    tables tercile_UPFU_SNU_grams*sdp / out=freq_sdp_upfu_snu(rename=(count=Count));
run;

proc sql;
    create table mode_sdp_upfu_snu as
    select tercile_UPFU_SNU_grams, sdp
    from freq_sdp_upfu_snu
    group by tercile_UPFU_SNU_grams
    having Count = max(Count);
quit;

/* 3. Combinaison des modalités modales */
proc sql;
    create table modes_cat_upfu_snu as
    select a.tercile_UPFU_SNU_grams, a.sexe, b.SMOKING_STATUS_cat, c.HOUSE_INCOME_YEAR_cat, d.shp, e.sdp
    from mode_sexe_upfu_snu a
    inner join mode_smoking_upfu_snu b on a.tercile_UPFU_SNU_grams = b.tercile_UPFU_SNU_grams
    inner join mode_house_income_upfu_snu c on a.tercile_UPFU_SNU_grams = c.tercile_UPFU_SNU_grams
    inner join mode_shp_upfu_snu d on a.tercile_UPFU_SNU_grams = d.tercile_UPFU_SNU_grams
    inner join mode_sdp_upfu_snu e on a.tercile_UPFU_SNU_grams = e.tercile_UPFU_SNU_grams
    order by tercile_UPFU_SNU_grams;
quit;

/* 4. Nettoyer stats_mean */
data stats_mean_upfu_snu_clean;
    set stats_mean_upfu_snu;
    if _TYPE_ = 1;
    keep tercile_UPFU_SNU_grams ENERGY_MEAN BMI_MEAN AGE_MEAN;
run;

/* 5. Création du dataset profils */
proc sql;
    create table profils_upfu_snu as
    select a.tercile_UPFU_SNU_grams,
           a.sexe,
           a.SMOKING_STATUS_cat,
           a.HOUSE_INCOME_YEAR_cat,
           a.shp,
           a.sdp,
           b.ENERGY_MEAN as ENERGY_KCAL_CCHS_n,
           b.BMI_MEAN as BMI_score_n,
           b.AGE_MEAN as p_age
    from modes_cat_upfu_snu a
    inner join stats_mean_upfu_snu_clean b
    on a.tercile_UPFU_SNU_grams = b.tercile_UPFU_SNU_grams
    order by tercile_UPFU_SNU_grams;
quit;

/* 6. Lancer le modèle avec baseline */

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat tercile_UPFU_SNU_grams(ref="3");
    model time*ecv(0) = tercile_UPFU_SNU_grams shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat  
                        p_age HOUSE_INCOME_YEAR_cat / risklimits;
    assess ph / resample;
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_grams;
    ID id;
    baseline out=surv_pred_upfu_snu survival=survival_prob covariates=profils_upfu_snu / method=PL;
run;

/* 7. Export graphique en PDF */


data surv_pred_upfu_snu;
    set surv_pred_upfu_snu;
    length UPF_and_FOPS $30.;
    
    /* Conversion en années (en supposant 365.25 jours/an pour précision) */
    time_years = time / 365.25;
    if tercile_UPFU_SNU_grams = 1 then UPF_and_FOPS = "Tertile 1";
    else if tercile_UPFU_SNU_grams = 2 then UPF_and_FOPS = "Tertile 2";
    else if tercile_UPFU_SNU_grams = 3 then UPF_and_FOPS = "Tertile 3";
run;

ods pdf file="C:\chemin\vers\ton\dossier\courbes_survie_UPFU_SNU_par_tercile.pdf" style=journal;

proc sgplot data=surv_pred_upfu_snu;
    series x=time_years y=survival_prob / group=UPF_and_FOPS markers;
    xaxis label="Time (years)";
    yaxis label="Survival probability" values=(0.85 to 1 by 0.05);
    title "";
run;

ods pdf close;

    









/*exemple pour vérifier la linéarité : tout est ok*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;

    /* Création de l’effet spline */
    effect spl_sn = spline( UPFU_SNU_grams_continue / naturalcubic);

    /* Modèle avec spline au lieu d'une forme linéaire */
    model time*ecv(0) = spl_sn
                        shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n 
                        SMOKING_STATUS_cat p_age
                        HOUSE_INCOME_YEAR_cat / risklimits;

    /* Résidus pour diagnostic */
    assess var=(spl_sn) / resample;
    output out=spline_resid ressch=sch_res resmart=mart_res;
    id id;
run;

ods output FitStatistics=fit_spline;
proc phreg data=au.final;
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;
    effect spl_sn = spline( UPFU_SNU_grams_continue  / naturalcubic);
    model time*ecv(0) = spl_sn shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n
                        SMOKING_STATUS_cat p_age HOUSE_INCOME_YEAR_cat;
run;

ods output FitStatistics=fit_linear;
proc phreg data=au.final;
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;
    model time*ecv(0) =  UPFU_SNU_grams_continue shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n
                        SMOKING_STATUS_cat p_age HOUSE_INCOME_YEAR_cat;
run;



