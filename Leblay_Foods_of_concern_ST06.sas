

/*********Tableau supplémentaire 6 *****************/



/*********************************Terciles UPF CALORIES******/

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
   select tercile_UPF_cal_s, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPF_cal_s;
quit;
proc sql;
   select tercile_UPF_cal_s,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_UPF_cal_s; run;
proc means data=au.final mean min max std; var UPF_cal_s; by tercile_UPF_cal_s; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
UPF_cal_s_continue=(1-UPF_cal_s)/10; run;


/* Modele 1*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPF_cal_s(ref="3");
    model time*ecv(0) = tercile_UPF_cal_s p_age shp sdp sexe  SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPF_cal_s_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;

/*Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPF_cal_s(ref="3");
    model time*ecv(0) = tercile_UPF_cal_s p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPF_cal_s;
    series x=time y=sch_res / group=tercile_UPF_cal_s;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPF_cal_s;
LOESS Y = resid_mart X = tercile_UPF_cal_s / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPF_cal_s ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_UPF_cal_s';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPF_cal_s  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPF_cal_s_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;


/*Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_UPF_cal_s(ref="3");
    model time*ecv(0) = tercile_UPF_cal_s p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPF_cal_s_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPF_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;







/*********************************Terciles FOPS CALORIES******/

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
   select tercile_SN_tot_cal_s, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_SN_tot_cal_s;
quit;
proc sql;
   select tercile_SN_tot_cal_s,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_SN_tot_cal_s; run;
proc means data=au.final mean std median min max; var SN_tot_cal_s; by tercile_SN_tot_cal_s; run;



/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
sn_cal_s_continue=(1-sn_tot_cal_s)/10; run;


/*Modele 1*/



proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_SN_tot_cal_s(ref="3");
    model time*ecv(0) = tercile_SN_tot_cal_s shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_cal_s_continue shp sdp sexe SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;

/*Modele 2*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_SN_tot_cal_s(ref="3");
    model time*ecv(0) = tercile_SN_tot_cal_s shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_SN_tot_cal_s;
    series x=time y=sch_res / group=tercile_SN_tot_cal_s;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_SN_tot_cal_s;
LOESS Y = resid_mart X = tercile_SN_tot_cal_s / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_SN_tot_cal_s ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour tercile_SN_tot_cal_s';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_SN_tot_cal_s shp sdp BMI_score_n SMOKING_STATUS_cat
          p_age / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/



proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_cal_s_continue shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;


/*Modele 3*/
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat shp sdp tercile_SN_tot_cal_s(ref="3");
    model time*ecv(0) = tercile_SN_tot_cal_s shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sn_cal_s_continue shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age  HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_SN_tot_cal_s; /* Créer un dataset avec les résidus */
ID id ;
run;







/******************TERCILE UPF OU SN EN CALORIE***********/

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
   select tercile_upfu_or_snu_cal, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_upfu_or_snu_cal;
quit;
proc sql;
   select tercile_upfu_or_snu_cal,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_upfu_or_snu_cal; run;
proc means data=au.final mean std median min max; var upfu_or_snu_cal; by tercile_upfu_or_snu_cal; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
upfu_or_snu_cal_continue=(1-upfu_or_snu_cal)/10; run;


/* Modele 1*/

 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_cal(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_cal p_age shp sdp sexe  SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upfu_or_snu_cal; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_cal_continue  shp sdp sexe  SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upfu_or_snu_cal; /* Créer un dataset avec les résidus */
ID id ;
run;



/* Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_cal(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_cal p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upfu_or_snu_cal; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_upfu_or_snu_cal;
    series x=time y=sch_res / group=tercile_upfu_or_snu_cal;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_upfu_or_snu_cal;
LOESS Y = resid_mart X = tercile_upfu_or_snu_cal / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_upfu_or_snu_cal ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_upfu_or_snu_cal';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_upfu_or_snu_cal  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_cal_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upfu_or_snu_cal; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_upfu_or_snu_cal(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_upfu_or_snu_cal p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upfu_or_snu_cal; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = upfu_or_snu_cal_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_upfu_or_snu_cal; /* Créer un dataset avec les résidus */
ID id ;
run;








/*********************************Terciles UPF AND SN avec uncertain en calorie******/

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
   select tercile_UPFU_SNU_cal, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  /* Assurez-vous que ecv est une variable binaire indiquant la présence d'un cas */
   from person_years
   group by tercile_UPFU_SNU_cal;
quit;
proc sql;
   select tercile_UPFU_SNU_cal,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from tercile_person_years;
quit;


proc sort data=au.final; by tercile_UPFU_SNU_cal; run;
proc means data=au.final mean std median min max; var UPFU_SNU_cal; by tercile_UPFU_SNU_cal; run;


/*continue pour la p-value et UPF HR pour une augmentation de 10% du ratio*/

data au.final; set au.final;
UPFU_SNU_cal_continue=(1-UPFU_SNU_cal)/10; run;

/* Modele 1*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPFU_SNU_cal(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPFU_SNU_cal p_age shp sdp sexe SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_cal; /* Créer un dataset avec les résidus */
ID id ;
run;


proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_SNU_cal_continue  shp sdp sexe SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat / risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_cal; /* Créer un dataset avec les résidus */
ID id ;
run;



/* Modele 2*/
 
proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPFU_SNU_cal(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPFU_SNU_cal p_age shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_cal; /* Créer un dataset avec les résidus */
ID id ;
run;

proc sgplot data=schoenfeld_resid;
    scatter x=time y=sch_res / group=tercile_UPFU_SNU_cal;
    series x=time y=sch_res / group=tercile_UPFU_SNU_cal;
run;
/*pour résidus de scoefiel mais pas besoin ici car cov(aggregate)*/

PROC SGPLOT DATA = schoenfeld_resid;
YAXIS GRID;
REFLINE 0;
SCATTER Y = resid_mart X = tercile_UPFU_SNU_cal;
LOESS Y = resid_mart X = tercile_UPFU_SNU_cal / CLM = "CI";
RUN;
/* Ok graphe à plat donc relation résiduelle ok*/

proc sgplot data=schoenfeld_resid;
needle x=id y=dfbeta_tercile_UPFU_SNU_cal ;
    xaxis label='ID' ;
    yaxis label='DFBETA pour quartile_UPFU_SNU_cal';
run;
/* les pics doivent etre entre -2 et +2 en y*/

proc reg data=au.final;
    model ecv=tercile_UPFU_SNU_cal  BMI_score_n SMOKING_STATUS_cat
          p_age shp sdp / vif collin collinoint;
run;
/* tous vif inf à 5 - OK*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_SNU_cal_continue  shp sdp sexe ENERGY_KCAL_CCHS_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_cal; /* Créer un dataset avec les résidus */
ID id ;
run;


/* Modele 3*/

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp tercile_UPFU_SNU_cal(ref="3") HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = tercile_UPFU_SNU_cal p_age shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                         HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_cal; /* Créer un dataset avec les résidus */
ID id ;
run;

proc phreg data=au.final COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = UPFU_SNU_cal_continue  shp sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_tercile_UPFU_SNU_cal; /* Créer un dataset avec les résidus */
ID id ;
run;
