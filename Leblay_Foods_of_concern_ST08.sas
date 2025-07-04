/* Supplementary Table S8*/
/*********************************Terciles UPF UNIQUEMENT CHEZ LES HYPERTENDUS ******/

data person_years;
   set au.final_ah;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_upf_grams_s_ah, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_upf_grams_s_ah;
quit;
proc sql;
   select tercile_upf_grams_s_ah,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final_ah; by tercile_upf_grams_s_ah; run;
proc means data=au.final_ah mean std min max; var upf_grams_s; by tercile_upf_grams_s_ah; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final_ah; set au.final_ah;
upf_grams_s_ah_continue=(1-upf_grams_s)/10; run;

/* Modele 1*/

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upf_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upf_grams_s_ah p_age shp sdp sexe SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_grams_s_ah_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/
 
proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upf_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upf_grams_s_ah p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_upf_grams_s_ah;
    series x=time y=sch_res / group=tercile_upf_grams_s_ah;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_upf_grams_s_ah;
LOESS Y = resid_mart X = tercile_upf_grams_s_ah / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_upf_grams_s_ah ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_upf_grams_s_ah';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final_ah;
    model ecv=tercile_upf_grams_s_ah  ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_grams_s_ah_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

 
proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upf_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upf_grams_s_ah p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upf_grams_s_ah_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upf_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;










/*********************************Terciles FOPS UNIQUEMENT CHEZ HYPERTENDUS ******/

data person_years;
   set au.final_ah;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_SN_tot_grams_s_ah, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_SN_tot_grams_s_ah;
quit;
proc sql;
   select tercile_SN_tot_grams_s_ah,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final_ah; by tercile_SN_tot_grams_s_ah; run;
proc means data=au.final_ah mean std min max; var SN_tot_grams_s; by tercile_SN_tot_grams_s_ah; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final_ah; set au.final_ah;
sn_grams_s_ah_continue=(1-sn_tot_grams_s)/10; run;

/* Modele 1*/

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams_s_ah shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_s_ah_continue shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

/* Modele 2*/

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams_s_ah shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_SN_tot_grams_s_ah;
    series x=time y=sch_res / group=tercile_SN_tot_grams_s_ah;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_SN_tot_grams_s_ah;
LOESS Y = resid_mart X = tercile_SN_tot_grams_s_ah / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_SN_tot_grams_s_ah ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour tercile_SN_tot_grams_s_ah';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final_ah;
    model ecv=tercile_SN_tot_grams_s_ah shp sdp BMI_score_n SMOKING_STATUS_cat
          p_age / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/



proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_s_ah_continue shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;



/* Modele 3*/

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_SN_tot_grams_s_ah shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_SN_tot_grams_s_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_grams_s_ah_continue shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_grams_s_ah; /* Créer un dataset avec les résidus */
ID id ;
run;




/*********************************Terciles UPF OR SN UNIQUEMENT CHEZ LES HYPERTENDUS ******/

data person_years;
   set au.final_ah;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_upfu_or_snu_grams_ah, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_upfu_or_snu_grams_ah;
quit;
proc sql;
   select tercile_upfu_or_snu_grams_ah,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final_ah; by tercile_upfu_or_snu_grams_ah; run;
proc means data=au.final_ah mean std min max; var upfu_or_snu_grams; by tercile_upfu_or_snu_grams_ah; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final_ah; set au.final_ah;
upfu_or_snu_grams_ah_continue=(1-upfu_or_snu_grams)/10; run;


/* Modele 1*/

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_grams_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_grams_ah p_age shp sdp sexe SMOKING_STATUS_cat 
                       HOUSE_INCOME_YEAR_cat  / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_or_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_grams_ah_continue  shp sdp sexe  SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=upfu_or_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

/* Modele 2*/
 
proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_grams_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_grams_ah p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                       HOUSE_INCOME_YEAR_cat  / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_or_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
needle x=id y=ter_upfu_or_snu_grams_ah ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_upfu_or_snu_grams_ah';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final_ah;
    model ecv=tercile_upfu_or_snu_grams_ah  ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_grams_ah_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=upfu_or_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

 
proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_grams_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_grams_ah p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_or_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_grams_ah_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=upfu_or_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;





/*********************************Terciles UPF and SN UNIQUEMENT CHEZ LES HYPERTENDUS ******/

data person_years;
   set au.final_ah;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table tercile_person_years as
   select tercile_upfu_snu_grams_ah, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_upfu_snu_grams_ah;
quit;
proc sql;
   select tercile_upfu_snu_grams_ah,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final_ah; by tercile_upfu_snu_grams_ah; run;
proc means data=au.final_ah mean std min max; var upfu_snu_grams; by tercile_upfu_snu_grams_ah; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final_ah; set au.final_ah;
upfu_snu_grams_ah_continue=(1-upfu_snu_grams)/10; run;


/* Modele 1*/

proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_snu_grams_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_snu_grams_ah p_age shp sdp sexe SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;



proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_snu_grams_ah_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 2*/
 
proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_snu_grams_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_snu_grams_ah p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=ter_upfu_snu_grams_ah;
    series x=time y=sch_res / group=ter_upfu_snu_grams_ah;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/


proc sgplot data=schoenfeld_resid;
needle x=id y=ter_upfu_snu_grams_ah ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_upfu_snu_grams_ah';
run;
/* les pics doivent etre entre -2 et +2 en y*/


proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_snu_grams_ah_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

 
proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_snu_grams_ah(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_snu_grams_ah p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_snu_grams_ah_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=ter_upfu_snu_grams_ah; /* Créer un dataset avec les résidus */
ID id ;
run;

