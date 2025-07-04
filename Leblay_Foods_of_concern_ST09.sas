

/* Supplementary Table S9*/



data person_years;
   set au.final_hp;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_upf_grams_s_hp, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_upf_grams_s_hp;
quit;
proc sql;
   select tercile_upf_grams_s_hp,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final_hp; by tercile_upf_grams_s_hp; run;
proc means data=au.final_hp mean std min max; var upf_grams_s; by tercile_upf_grams_s_hp; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final_hp; set au.final_hp;
upf_grams_s_hp_continue=(1-upf_grams_s)/10; run;


/* Modele 1*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upf_grams_s_hp(ref="3") HOUSE_INCOME_YEAR_cat ;
    model time*ecv(0) = tercile_upf_grams_s_hp p_age shp sdp sexe SMOKING_STATUS_cat 
                       HOUSE_INCOME_YEAR_cat   / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat ;
    model time*ecv(0) = upf_grams_s_hp_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/
 
proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upf_grams_s_hp(ref="3") HOUSE_INCOME_YEAR_cat ;
    model time*ecv(0) = tercile_upf_grams_s_hp p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat  / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_upf_grams_s_hp;
    series x=time y=sch_res / group=tercile_upf_grams_s_hp;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_upf_grams_s_hp;
LOESS Y = resid_mart X = tercile_upf_grams_s_hp / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_upf_grams_s_hp ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_upf_grams_s_hp';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final_hp;
    model ecv=tercile_upf_grams_s_hp  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat ;
    model time*ecv(0) = upf_grams_s_hp_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upf_grams_s_hp(ref="3") HOUSE_INCOME_YEAR_cat ;
    model time*ecv(0) = tercile_upf_grams_s_hp p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat ;
    model time*ecv(0) = upf_grams_s_hp_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;







/*********************************Terciles FOPS UNIQUEMENT CHEZ HIGH BLOOD CHOLESTEROL******/

data person_years;
   set au.final_hp;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_SN_tot_grams_s_hp, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_SN_tot_grams_s_hp;
quit;
proc sql;
   select tercile_SN_tot_grams_s_hp,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final_hp; by tercile_SN_tot_grams_s_hp; run;
proc means data=au.final_hp mean std min max; var SN_tot_grams_s; by tercile_SN_tot_grams_s_hp; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final_hp; set au.final_hp;
sn_grams_continue=(1-sn_tot_grams_s)/10; run;

/* Modele 1*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams_s_hp shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_continue shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams_s_hp shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_SN_tot_grams_s_hp;
    series x=time y=sch_res / group=tercile_SN_tot_grams_s_hp;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_SN_tot_grams_s_hp;
LOESS Y = resid_mart X = tercile_SN_tot_grams_s_hp / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_SN_tot_grams_s_hp ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour tercile_SN_tot_grams_s_hp';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final_hp;
    model ecv=tercile_SN_tot_grams_s_hp shp sdp ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat
          p_age / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/



proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_continue shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/


proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams_s_hp shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_continue shp sdp sexe BMI_score_n ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_hp; /* Créer un dataset avec les résidus */
ID id ;
run;




/*********************************Terciles UPF OR SN UNIQUEMENT CHEZ HIGH BLOOD CHOLESTEROL******/

data person_years;
   set au.final_hp;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_upfu_or_snu_grams_hp, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_upfu_or_snu_grams_hp;
quit;
proc sql;
   select tercile_upfu_or_snu_grams_hp,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final_hp; by tercile_upfu_or_snu_grams_hp; run;
proc means data=au.final_hp mean std min max; var upfu_or_snu_grams; by tercile_upfu_or_snu_grams_hp; run;

/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final_hp; set au.final_hp;
upfu_or_snu_grams_hp_continue=(1-upfu_or_snu_grams)/10; run;


/* Modele 1*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_grams_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_grams_hp p_age shp sdp sexe SMOKING_STATUS_cat 
                       HOUSE_INCOME_YEAR_cat  / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_or_snu_grams_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_grams_hp_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=upfu_or_snu_grams_hp_con; /* Créer un dataset avec les résidus */
ID id ;
run;

/* Modele 2*/
 
proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_grams_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_grams_hp p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_or_snu_grams_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


proc sgplot data=schoenfeld_resid;
needle x=id y=ter_upfu_or_snu_grams_hp ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_upfu_or_snu_grams_hp';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final_hp;
    model ecv=tercile_upfu_or_snu_grams_hp  BMI_score_n SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_grams_hp_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=upfu_or_snu_grams_hp_con; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_grams_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_grams_hp p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                       HOUSE_INCOME_YEAR_cat  / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_or_snu_grams_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_grams_hp_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=upfu_or_snu_grams_hp_cont; /* Créer un dataset avec les résidus */
ID id ;
run;




/*********************************Terciles UPF and SN UNIQUEMENT CHEZ HIGH BLOOD CHOLESTEROL******/

data person_years;
   set au.final_hp;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_upfu_snu_grams_hp, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_upfu_snu_grams_hp;
quit;
proc sql;
   select tercile_upfu_snu_grams_hp,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final_hp; by tercile_upfu_snu_grams_hp; run;
proc means data=au.final_hp mean std min max; var upfu_snu_grams; by tercile_upfu_snu_grams_hp; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final_hp; set au.final_hp;
upfu_snu_grams_hp_continue=(1-upfu_snu_grams)/10; run;

/* Modele 1*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_snu_grams_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_snu_grams_hp p_age shp sdp sexe SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_hp; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_snu_grams_hp_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/
 
proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_snu_grams_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_snu_grams_hp p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_hp; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_upfu_snu_grams_hp;
    series x=time y=sch_res / group=tercile_upfu_snu_grams_hp;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_upfu_snu_grams_hp;
LOESS Y = resid_mart X = tercile_upfu_snu_grams_hp / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=ter_upfu_snu_grams_hp ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_upfu_snu_grams_hp';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final_hp;
    model ecv=tercile_upfu_snu_grams_hp  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_snu_grams_hp_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_snu_grams_hp(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_snu_grams_hp p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_hp; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_snu_grams_hp_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=upfu_snu_grams_hp_cont; /* Créer un dataset avec les résidus */
ID id ;
run;




