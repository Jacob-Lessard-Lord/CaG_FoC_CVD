/*Tableau 2 */

/* AH traité non traité*/


data person_years;
   set au.final_ah;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table mcp_person_years as
   select shp, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  
   from person_years
   group by shp;
quit;
proc sql;
   select shp,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from mcp_person_years;
quit;

proc freq data=au.final_ah; table shp; run;



/* Modele */
proc phreg data=au.final_ah COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat shp(REF="1") sdp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = shp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat 
                        p_age UPF_grams_s sdp HOUSE_INCOME_YEAR_cat/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_shp; /* Créer un dataset avec les résidus */
ID id ;
run;



/* HBC traité non traité*/

data person_years;
   set au.final_hp;
   person_years = time / 365.25;
run;
proc sql;
   select sum(person_years) as total_person_years
   from person_years;
quit;
proc sql;
   create table mcp_person_years as
   select sdp, 
          sum(person_years) as total_person_years, 
          sum(ecv) as total_cases  
   from person_years
   group by sdp;
quit;
proc sql;
   select sdp,
          total_cases,
          total_person_years,
          (total_cases / total_person_years) as cases_per_person_years
   from mcp_person_years;
quit;

proc freq data=au.final_hp; table sdp; run;


/* Modele 3*/

proc phreg data=au.final_hp COVS(AGGREGATE);
    class sexe SMOKING_STATUS_cat sdp(REF="1") shp HOUSE_INCOME_YEAR_cat;
    model time*ecv(0) = sdp sexe ENERGY_KCAL_CCHS_n BMI_score_n SMOKING_STATUS_cat HOUSE_INCOME_YEAR_cat
                        p_age UPF_grams_s shp/ risklimits ;
    assess ph / resample; /* Obtenir les résidus de Schoenfeld */
    output out=schoenfeld_resid ressch=sch_res resmart=resid_mart dfbeta=dfbeta_sdp; /* Créer un dataset avec les résidus */
ID id ;
run;












