/*Tableau supplémentaire 5*/

/****************TERCILES UPF AVEC UNCERTAIN************************/


data person_years;
   set au.final;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_UPF_grams_s, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPF_grams_s;
quit;
proc sql;
   select tercile_UPF_grams_s,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;

proc sort data=au.final; by tercile_upf_grams_s; run;
proc means data=au.final mean std median min max; var upf_grams_s; by tercile_UPF_grams_s; run;

/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
upf_grams_continue_s=(1-upf_grams_s)/10; run;



/* Modele 1 */

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPF_grams_s(ref="3");
    model time*ecv(0) = tercile_UPF_grams_s shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;; 
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
     output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;


/*continue*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp ;
    model time*ecv(0) = upf_grams_continue_s  shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbetaupf_grams_continue_s ; /* Créer un dataset avec les résidus */
ID id ;
run;


/*Modele 2*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPF_grams_s(ref="3");
    model time*ecv(0) = tercile_UPF_grams_s shp sdp sexe SMOKING_STATUS_cat ENERGY_KCAL_CCHS_n
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;; 
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
     output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;


proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPF_grams_s;
    series x=time y=sch_res / group=tercile_UPF_grams_s;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate) */

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPF_grams_s;
LOESS Y = resid_mart X = tercile_UPF_grams_s / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPF_grams_s ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour tercile_UPF_grams_s';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPF_grams_s shp sdp BMI_score_n SMOKING_STATUS_cat
          p_age / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/


/*continue*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp ;
    model time*ecv(0) = upf_grams_continue_s  shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat ENERGY_KCAL_CCHS_n/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbetaupf_grams_continue_s ; /* Créer un dataset avec les résidus */
ID id ;
run;


/*Modele 3*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPF_grams_s(ref="3");
    model time*ecv(0) = tercile_UPF_grams_s shp sdp sexe SMOKING_STATUS_cat ENERGY_KCAL_CCHS_n
                        p_age HOUSE_INCOME_YEAR_cat BMI_score_n / risklimits ;; 
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
     output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;


/*continue*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp ;
    model time*ecv(0) = upf_grams_continue_s  shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat ENERGY_KCAL_CCHS_n BMI_score_n / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbetaupf_grams_continue_s ; /* Créer un dataset avec les résidus */
ID id ;
run;








/*********************************Terciles FOPS UNCERTAIN******/

data person_years;
   set au.final;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_SN_tot_grams_s, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_SN_tot_grams_s;
quit;
proc sql;
   select tercile_SN_tot_grams_s,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_SN_tot_grams_s; run;
proc means data=au.final mean std min max; var SN_tot_grams_s; by tercile_SN_tot_grams_s; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
sn_grams_s_continue=(1-sn_tot_grams_s)/10; run;

/* Modele 1*/


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_SN_tot_grams_s(ref="3");
    model time*ecv(0) = tercile_SN_tot_grams_s shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;
    model time*ecv(0) = sn_grams_s_continue shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;

/* Modele 2*/


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_SN_tot_grams_s(ref="3");
    model time*ecv(0) = tercile_SN_tot_grams_s shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;
    model time*ecv(0) = sn_grams_s_continue shp sdp sexe ENERGY_KCAL_CCHS_n  SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;



/* Modele 3*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_SN_tot_grams_s(ref="3");
    model time*ecv(0) = tercile_SN_tot_grams_s shp sdp sexe ENERGY_KCAL_CCHS_n  BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;
    model time*ecv(0) = sn_grams_s_continue shp sdp sexe ENERGY_KCAL_CCHS_n  BMI_score_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s; /* Créer un dataset avec les résidus */
ID id ;
run;




/*********************************Terciles UPF OR SN avec uncertain******/

data person_years;
   set au.final;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_UPFU_OR_SNU_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPFU_OR_SNU_grams;
quit;
proc sql;
   select tercile_UPFU_OR_SNU_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_UPFU_OR_SNU_grams; run;
proc means data=au.final mean std median min max; var UPFU_OR_SNU_grams; by tercile_UPFU_OR_SNU_grams; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
UPFU_OR_SNU_grams_continue=(1-UPFU_OR_SNU_grams)/10; run;


/* Modele 1*/


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPFU_OR_SNU_grams(ref="3");
    model time*ecv(0) = tercile_UPFU_OR_SNU_grams p_age shp sdp sexe SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_OR_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;
    model time*ecv(0) = UPFU_OR_SNU_grams_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_OR_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/*Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPFU_OR_SNU_grams(ref="3");
    model time*ecv(0) = tercile_UPFU_OR_SNU_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_OR_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPFU_OR_SNU_grams;
    series x=time y=sch_res / group=tercile_UPFU_OR_SNU_grams;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPFU_OR_SNU_grams;
LOESS Y = resid_mart X = tercile_UPFU_OR_SNU_grams / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPFU_OR_SNU_grams ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_UPFU_OR_SNU_grams';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPFU_OR_SNU_grams  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;
    model time*ecv(0) = UPFU_OR_SNU_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_OR_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/*Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPFU_OR_SNU_grams(ref="3");
    model time*ecv(0) = tercile_UPFU_OR_SNU_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_OR_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp;
    model time*ecv(0) = UPFU_OR_SNU_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_OR_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;




/*********************************Terciles UPF AND SN avec uncertain******/

data person_years;
   set au.final;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_UPFU_SNU_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPFU_SNU_grams;
quit;
proc sql;
   select tercile_UPFU_SNU_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_UPFU_SNU_grams; run;
proc means data=au.final mean std median min max; var UPFU_SNU_grams; by tercile_UPFU_SNU_grams; run;

/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
UPFU_SNU_grams_continue=(1-UPFU_SNU_grams)/10; run;


/* Modele 1*/


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPFU_SNU_grams(ref="3");
    model time*ecv(0) = tercile_UPFU_SNU_grams p_age shp sdp sexe  SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_SNU_grams_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/*Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPFU_SNU_grams(ref="3");
    model time*ecv(0) = tercile_UPFU_SNU_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPFU_SNU_grams;
    series x=time y=sch_res / group=tercile_UPFU_SNU_grams;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPFU_SNU_grams;
LOESS Y = resid_mart X = tercile_UPFU_SNU_grams / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPFU_SNU_grams ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_UPFU_SNU_grams';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPFU_SNU_grams  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_SNU_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/*Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPFU_SNU_grams(ref="3");
    model time*ecv(0) = tercile_UPFU_SNU_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_SNU_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;
