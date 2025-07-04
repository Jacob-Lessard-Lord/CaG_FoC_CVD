
/*Supplementary Table S7*/

/*********************************Terciles UPF excluding uncertain GRAMS ******/

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
   select tercile_UPF_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPF_grams;
quit;
proc sql;
   select tercile_UPF_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;

data au.final;
    set au.final;
    ENERGY_KCAL_CCHS_NUM = input(ENERGY_KCAL_CCHS, best32.);
run;

proc sort data=au.final; by tercile_upf_grams; run;
proc means data=au.final mean min max std; var upf_grams ; by tercile_UPF_grams; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
upf_grams_continue=(1-upf_grams)/10; run;

/* Modele 1*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_grams p_age shp sdp sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat
                         / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams; /* Créer un dataset avec les résidus */
ID id ;
run;
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_grams_continue  shp sdp sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat
                        p_age / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams; /* Créer un dataset avec les résidus */
ID id ;
run;




/* Modele 2*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams; /* Créer un dataset avec les résidus */
ID id ;
run;
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams; /* Créer un dataset avec les résidus */
ID id ;
run;
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n  BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_grams; /* Créer un dataset avec les résidus */
ID id ;
run;




/*********************************Terciles FOPS sans uncertains en grams ******/

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
   select tercile_SN_tot_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_SN_tot_grams;
quit;
proc sql;
   select tercile_SN_tot_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_SN_tot_grams; run;
proc means data=au.final mean std min max; var SN_tot_grams; by tercile_SN_tot_grams; run;



/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
sn_grams_continue=(1-sn_tot_grams)/10; run;

/* Modele 1*/


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_continue shp sdp sexe  SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_continue shp sdp sexe ENERGY_KCAL_CCHS_n  SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams; /* Créer un dataset avec les résidus */
ID id ;
run;



/* Modele 3*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams shp sdp sexe ENERGY_KCAL_CCHS_n  BMI_score_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_continue shp sdp sexe ENERGY_KCAL_CCHS_n  BMI_score_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams; /* Créer un dataset avec les résidus */
ID id ;
run;





/*********************************Terciles UPF OR SN sans uncertains******/

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
   select tercile_UPF_OR_SN_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPF_OR_SN_grams;
quit;
proc sql;
   select tercile_UPF_OR_SN_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_UPF_OR_SN_grams; run;
proc means data=au.final mean std median min max; var UPF_OR_SN_grams; by tercile_UPF_OR_SN_grams; run;

/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
UPF_OR_SN_grams_continue=(1-UPF_OR_SN_grams)/10; run;


/* Modele 1*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_OR_SN_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_OR_SN_grams p_age shp sdp sexe SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_OR_SN_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPF_OR_SN_grams_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_OR_SN_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

/* Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_OR_SN_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_OR_SN_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_OR_SN_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPF_OR_SN_grams;
    series x=time y=sch_res / group=tercile_UPF_OR_SN_grams;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPF_OR_SN_grams;
LOESS Y = resid_mart X = tercile_UPF_OR_SN_grams / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPF_OR_SN_grams ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_UPF_OR_SN_grams';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPF_OR_SN_grams  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPF_OR_SN_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_OR_SN_grams; /* Créer un dataset avec les résidus */
ID id ;
run;



/* Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_OR_SN_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_OR_SN_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_OR_SN_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPF_OR_SN_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_OR_SN_grams; /* Créer un dataset avec les résidus */
ID id ;
run;







/***********Terciles UPFU +NSN *********************/



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
   select tercile_UPFU_nsn_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPFU_nsn_grams;
quit;
proc sql;
   select tercile_UPFU_nsn_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_UPFU_nsn_grams; run;
proc means data=au.final mean std median min max; var UPFU_nsn_grams; by tercile_UPFU_nsn_grams; run;


/*continue pour la p-value et UPFU HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
UPFU_nsn_grams_continue=(1-UPFU_nsn_grams)/10; run;


/* Modele 1*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPFU_nsn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPFU_nsn_grams p_age shp sdp sexe SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_nsn_grams_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPFU_nsn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPFU_nsn_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPFU_nsn_grams;
    series x=time y=sch_res / group=tercile_UPFU_nsn_grams;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPFU_nsn_grams;
LOESS Y = resid_mart X = tercile_UPFU_nsn_grams / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPFU_nsn_grams ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_UPFU_nsn_grams';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPFU_nsn_grams  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_nsn_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPFU_nsn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPFU_nsn_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_nsn_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;





/***********Terciles UPF +NSN sans uncertains*********************/



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
   select tercile_UPF_nsn_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPF_nsn_grams;
quit;
proc sql;
   select tercile_UPF_nsn_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_upf_nsn_grams; run;
proc means data=au.final mean std median min max; var upf_nsn_grams; by tercile_UPF_nsn_grams; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
upf_nsn_grams_continue=(1-upf_nsn_grams)/10; run;

/* Modele 1*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_nsn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_nsn_grams p_age shp sdp sexe SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_nsn_grams_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_nsn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_nsn_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPF_nsn_grams;
    series x=time y=sch_res / group=tercile_UPF_nsn_grams;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPF_nsn_grams;
LOESS Y = resid_mart X = tercile_UPF_nsn_grams / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPF_nsn_grams ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_UPF_nsn_grams';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPF_nsn_grams  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_nsn_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_nsn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_nsn_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_nsn_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_nsn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;





/***** Terciles NUPF + SNU*******/


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
   select tercile_nupf_SNU_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_nupf_SNU_grams;
quit;
proc sql;
   select tercile_nupf_SNU_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_nupf_SNU_grams; run;
proc means data=au.final mean std median min max; var nupf_SNU_grams; by tercile_nupf_SNU_grams; run;

/*continue pour la p-value et nupf HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
nupf_SNU_grams_continue=(1-nupf_SNU_grams)/10; run;


/* Modele 1*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_nupf_SNU_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_nupf_SNU_grams p_age shp sdp sexe SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = nupf_SNU_grams_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

/* Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_nupf_SNU_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_nupf_SNU_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_nupf_SNU_grams;
    series x=time y=sch_res / group=tercile_nupf_SNU_grams;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_nupf_SNU_grams;
LOESS Y = resid_mart X = tercile_nupf_SNU_grams / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_nupf_SNU_grams ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_nupf_SNU_grams';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_nupf_SNU_grams  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = nupf_SNU_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_nupf_SNU_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_nupf_SNU_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = nupf_SNU_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_SNU_grams; /* Créer un dataset avec les résidus */
ID id ;
run;






/***** Terciles NUPF + SN*******/


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
   select tercile_nupf_SN_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_nupf_SN_grams;
quit;
proc sql;
   select tercile_nupf_SN_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_nupf_sn_grams; run;
proc means data=au.final mean std median min max; var nupf_sn_grams; by tercile_nupf_sn_grams; run;

/*continue pour la p-value et nupf HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
nupf_sn_grams_continue=(1-nupf_sn_grams)/10; run;

/* Modele 1*/


 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_nupf_sn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_nupf_sn_grams p_age shp sdp sexe SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = nupf_sn_grams_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

/* Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_nupf_sn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_nupf_sn_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_nupf_sn_grams;
    series x=time y=sch_res / group=tercile_nupf_sn_grams;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_nupf_sn_grams;
LOESS Y = resid_mart X = tercile_nupf_sn_grams / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_nupf_sn_grams ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_nupf_sn_grams';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_nupf_sn_grams  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = nupf_sn_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_nupf_sn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_nupf_sn_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = nupf_sn_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_nupf_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;




/*********************************Terciles UPF+SN sans uncertains******/

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
   select tercile_UPF_SN_grams, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPF_SN_grams;
quit;
proc sql;
   select tercile_UPF_SN_grams,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_upf_sn_grams; run;
proc means data=au.final mean std median min max; var upf_sn_grams; by tercile_UPF_sn_grams; run;

/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
upf_sn_grams_continue=(1-upf_sn_grams)/10; run;


/* Modele 1*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_sn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_sn_grams p_age shp sdp sexe SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_sn_grams_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_sn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_sn_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPF_sn_grams;
    series x=time y=sch_res / group=tercile_UPF_sn_grams;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPF_sn_grams;
LOESS Y = resid_mart X = tercile_UPF_sn_grams / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPF_sn_grams ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_UPF_sn_grams';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPF_sn_grams  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_sn_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPF_sn_grams(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPF_sn_grams p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_sn_grams_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_sn_grams; /* Créer un dataset avec les résidus */
ID id ;
run;






