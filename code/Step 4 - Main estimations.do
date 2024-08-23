/*************************************************************************
**************************************************************************
                 Main estimations
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: September 2022

3) Objective: Estimate main regressions
           
4) Output:    - Grado_programas.dta
              - areas.dta
              - areas_degree.dta

*************************************************************************
*************************************************************************/	
clear all

****************************************************************************
* Globals
****************************************************************************

global main l_salario_ultimo_obs CV
global puntajes punt_global_z 
global school puntaje_colegio

global controls jornada_completa paga_pension female cole_academico calendario_a

global areas area1 area3 area4 area5 area6 area8 area9

****************************************************************************
**#                 1. Estimations
****************************************************************************
use "${data}\Base_final_balanceo_semestral", clear

keep if Periodo_Saber11 <= 20062 & Periodo_Saber11 != 20051

** Drop an outlier 
drop if personabasicaid == 25934008

gen l_salario_ultimo_obs = ln(salario_ultimo_obs)

labvars formalidad dias_ultimo_obs dias_medianos dias_medios        ///
        salario_ultimo_obs l_salario_ultimo_obs salario_mediano     ///
        salario_medio e_graduado_pr grado incompleto SPADIES_prof   ///
        SPADIES_tyt punt_global_z grado_tyt incompleto_tyt          ///
        grado_prof incompleto_prof CV                               ///
        "Formal" "Days contributed (last annual observation)"       ///
        "Median days contributed" "Mean days contributed"           ///
        "Monthly wage (last annual observation)"                    ///
        "Log monthly wage (last annual observation)"                ///
        "Median wage with missing" "Mean wage with missing"         ///
        "Graduation" "Graduation" "Incomplete studies"              ///
        "Access to professional programs"                           ///
        "Access to short-cycle programs" "Global score"             ///
        "Graduation short-cycle" "Incomplete short-cycle studies"   ///
        "Graduation professional" "Incomplete professional studies" ///
        "Coefficient of variation"

gen flexibles_0 = 0
gen laboral_0 = 1
compress

quietly{

****************************************************************************
**#            1.1 Professional and short-cycle graduation
****************************************************************************

local replace replace
local dec 3
local ultimo_mes i.ultimo_mes
foreach years in 0 1 2_5 6_10{
	
    foreach outcome in $main {
        
        local z: variable label `outcome'
        qui sum `outcome' if SPADIES == 0 & laboral_`years' == 1 &      ///
                flexibles_`years' != 1
                
        local mean_`outcome' = r(mean)
		
		*
        reg `outcome' grado_tyt incompleto_tyt grado_prof incompleto_prof    ///
        i.year_sb11 `ultimo_mes' i.year if ((SPADIES == 1 & !mi(nivel))      ///
        | SPADIES == 0) & laboral_`years' == 1 & flexibles_`years' != 1,     ///
        vce(cluster personabasicaid)
            
        outreg2 using "${output}\graduacion_programas.xls", label            ///
        `replace' dec(`dec') nocons keep(grado_tyt incompleto_tyt grado_prof ///
        incompleto_prof) nor2 adds(Control's mean, `mean_`outcome'')         ///
        ctitle("`z'","Years_`years'")                                        ///
        addtext(Scores, NO, Controls, NO, School scores, NO, City of origin FE, NO)
        
        regsave grado_tyt incompleto_tyt grado_prof incompleto_prof using    ///
        "${output}\Grado_programas", `replace'                               ///
        addlabel(outcome, "`outcome'", control, "no",                        ///
        market, "laboral_`years'", media, `mean_`outcome'')

		*
        reg `outcome' grado_tyt incompleto_tyt grado_prof incompleto_prof    ///
        $puntajes i.year_sb11 `ultimo_mes' i.year if                         ///
        ((SPADIES == 1 & !mi(nivel)) | SPADIES == 0) & laboral_`years' == 1  ///
        & flexibles_`years' != 1, vce(cluster personabasicaid)
        
        outreg2 using "${output}\graduacion_programas.xls", label append     ///
        dec(`dec') nocons keep(grado_tyt incompleto_tyt grado_prof           ///
        incompleto_prof) nor2 adds(Control's mean, `mean_`outcome'')         ///
        ctitle("`z'","Years_`years'")                                        ///
        addtext(Scores, YES, Controls, NO, School scores, NO, City of origin FE, NO)
        
        regsave grado_tyt incompleto_tyt grado_prof incompleto_prof using    ///
        "${output}\Grado_programas", append                                  ///
        addlabel(outcome, "`outcome'", control, "scores", market,            ///
        "laboral_`years'", media, `mean_`outcome'')
		
		*
        reg `outcome' grado_tyt incompleto_tyt grado_prof incompleto_prof    ///
        $puntajes $controls i.year_sb11 `ultimo_mes' i.year if               ///
        ((SPADIES == 1 & !mi(nivel)) | SPADIES == 0) & laboral_`years' == 1  ///
        & flexibles_`years' != 1, vce(cluster personabasicaid)
        
        outreg2 using "${output}\graduacion_programas.xls", label append     ///
        dec(`dec') nocons keep(grado_tyt incompleto_tyt grado_prof           ///
        incompleto_prof) nor2 adds(Control's mean, `mean_`outcome'')         ///
        ctitle("`z'","Years_`years'")                                        ///
        addtext(Scores, YES, Controls, YES, School scores, NO, City of origin FE, NO)
        
        regsave grado_tyt incompleto_tyt grado_prof incompleto_prof using    ///
        "${output}\Grado_programas", append                                  ///
        addlabel(outcome, "`outcome'", control, "socioeco", market,          ///
        "laboral_`years'", media, `mean_`outcome'')
		
		*
        reg `outcome' grado_tyt incompleto_tyt grado_prof incompleto_prof    ///
        $puntajes $controls $school i.year_sb11 `ultimo_mes' i.year if       ///
        ((SPADIES == 1 & !mi(nivel)) | SPADIES == 0) & laboral_`years' == 1  ///
        & flexibles_`years' != 1, vce(cluster personabasicaid)
        
        outreg2 using "${output}\graduacion_programas.xls", label append     ///
        dec(`dec') nocons keep(grado_tyt incompleto_tyt grado_prof           ///
        incompleto_prof) nor2 adds(Control's mean, `mean_`outcome'')         ///
        ctitle("`z'","Years_`years'")                                        ///
        addtext(Scores, YES, Controls, YES, School scores, YES, City of origin FE, NO)
        
        regsave grado_tyt incompleto_tyt grado_prof incompleto_prof using    ///
        "${output}\Grado_programas", append                                  ///
        addlabel(outcome, "`outcome'", control, "school", market,            ///
        "laboral_`years'", media, `mean_`outcome'')
		
		*
        reghdfe `outcome' grado_tyt incompleto_tyt grado_prof                ///
        incompleto_prof $puntajes $controls $school if                       ///
        ((SPADIES == 1 & !mi(nivel)) | SPADIES == 0) & laboral_`years' == 1  ///
        & flexibles_`years' != 1, vce(cluster personabasicaid)               ///
        a(year_sb11 ultimo_mes year divipola)
        
        outreg2 using "${output}\graduacion_programas.xls", label append     ///
        dec(`dec') nocons keep(grado_tyt incompleto_tyt grado_prof           ///
        incompleto_prof) nor2 adds(Control's mean, `mean_`outcome'')         ///
        ctitle("`z'","Years_`years'")                                        ///
        addtext(Scores, YES, Controls, YES, School scores, YES, City of origin FE, YES)
        
        regsave grado_tyt incompleto_tyt grado_prof incompleto_prof using    ///
        "${output}\Grado_programas", append                                  ///
        addlabel(outcome, "`outcome'", control, "all", market,               ///
        "laboral_`years'", media, `mean_`outcome'')
		
        local replace append
    }
}


****************************************************************************
**#          1.2 Knowledge areas (excluded is liberal arts)
****************************************************************************

gen ID_areas = (area1 == 1 | area2 == 1 | area3 == 1 | area4 == 1 |     ///
    area5 == 1 | area6 == 1 | area8 == 1 | area9 == 1)
    
local replace replace
local dec 3
local ultimo_mes i.ultimo_mes
foreach years in 0 1 2_5 6_10{

    foreach outcome in $main{
		
        local z: variable label `outcome'
        qui sum `outcome' if area2 == 1 & laboral_`years' == 1 &    ///
                flexibles_`years' != 1
                
        local mean_`outcome' = r(mean)
		
        *
        reg `outcome' $areas i.year_sb11 `ultimo_mes' i.year if             ///
        laboral_`years' == 1 & flexibles_`years' != 1 & ID_areas == 1,      ///
        vce(cluster personabasicaid)
            
        outreg2 using "${output}\areas.xls", label `replace' dec(`dec')     ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        ctitle("`z'","Years_`years'")                                       ///
        addnote(The omitted area is liberal arts.)                          ///
        addtext(Scores, NO, Controls, NO, School scores, NO, City of origin FE, NO) 
        
        regsave $areas using "${output}\areas", `replace'                   ///
        addlabel(outcome, "`outcome'", control, "no", market,               ///
        "laboral_`years'", media, `mean_`outcome'')
		
		*
        reg `outcome' $areas $puntajes i.year_sb11 `ultimo_mes' i.year if   ///
        laboral_`years' == 1 & flexibles_`years' != 1 & ID_areas == 1,      ///
        vce(cluster personabasicaid)
        
        outreg2 using "${output}\areas.xls", label append dec(`dec')        ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        ctitle("`z'","Years_`years'")                                       ///
        addtext(Scores, YES, Controls, NO, School scores, NO, City of origin FE, NO) 
        
        regsave $areas using "${output}\areas", append                      ///
        addlabel(outcome, "`outcome'", control, "scores", market,           ///
        "laboral_`years'", media, `mean_`outcome'')
		
		*
        reg `outcome' $areas $puntajes $controls i.year_sb11 `ultimo_mes'   ///
        i.year if laboral_`years' == 1 & flexibles_`years' != 1 &           ///
        ID_areas == 1, vce(cluster personabasicaid)
        
        outreg2 using "${output}\areas.xls", label append dec(`dec')        ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        ctitle("`z'","Years_`years'")                                       ///
        addtext(Scores, YES, Controls, YES, School scores, NO, City of origin FE, NO) 
        
        regsave $areas using "${output}\areas", append                      ///
        addlabel(outcome, "`outcome'", control, "socioeco", market,         ///
        "laboral_`years'", media, `mean_`outcome'')
		
		*
        reg `outcome' $areas $puntajes $controls $school i.year_sb11        ///
        `ultimo_mes' i.year if laboral_`years' == 1 &                       ///
        flexibles_`years' != 1 & ID_areas == 1, vce(cluster personabasicaid)
        
        outreg2 using "${output}\areas.xls", label append dec(`dec')        ///
        ctitle("`z'","Years_`years'")                                       ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        addtext(Scores, YES, Controls, YES, School scores, YES, City of origin FE, NO) 
        
        regsave $areas using "${output}\areas", append                      ///
        addlabel(outcome, "`outcome'", control, "school", market,           ///
        "laboral_`years'", media, `mean_`outcome'')
		
		*
        reghdfe `outcome' $areas $puntajes $controls $school if             ///
        laboral_`years' == 1 & flexibles_`years' != 1 & ID_areas == 1,      ///
        vce(cluster personabasicaid) a(year_sb11 ultimo_mes year divipola)
        
        outreg2 using "${output}\areas.xls", label append dec(`dec')        ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        ctitle("`z'","Years_`years'")                                       ///
        addtext(Scores, YES, Controls, YES, School scores, YES, City of origin FE, YES)
        
        regsave $areas using "${output}\areas", append                      ///
        addlabel(outcome, "`outcome'", control, "all", market,              ///
        "laboral_`years'", media, `mean_`outcome'')
		
		local replace append
	}
	
}


****************************************************************************
**#      1.3 Knowledge areas by program type (excluded is liberal arts)
****************************************************************************
local replace replace
local dec 3
local ultimo_mes i.ultimo_mes
foreach years in 0 1 2_5 6_10{
	
    foreach program in grado_tyt incompleto_tyt grado_prof incompleto_prof{

    foreach outcome in $main{
			
        local z: variable label `outcome'
        qui sum `outcome' if area2 == 1 & laboral_`years' == 1 &    ///
                flexibles_`years' != 1 & `program' == 1
                
        local mean_`outcome' = r(mean)
        
        *
        reg `outcome' $areas i.year_sb11 `ultimo_mes' i.year if             ///
        laboral_`years' == 1 & flexibles_`years' != 1 & ID_areas == 1 &     ///
        `program' == 1, vce(cluster personabasicaid)
        
        outreg2 using "${output}\areas_degree.xls", label `replace'         ///
        dec(`dec') nocons keep($areas) nor2                                 ///
        adds(Control's mean, `mean_`outcome'')                              ///
        ctitle("`z'","`program'","Years_`years'")                           ///
        addnote(The omitted area is liberal arts.)                          ///
        addtext(Scores, NO, Controls, NO, School scores, NO, City of origin FE, NO)
        
        regsave $areas using "${output}\areas_degree", `replace'            ///
        addlabel(outcome, "`outcome'", control, "no", market,               ///
        "laboral_`years'", degree, "`program'", media, `mean_`outcome'')
        
        *
        reg `outcome' $areas $puntajes i.year_sb11 `ultimo_mes' i.year if   ///
        laboral_`years' == 1 & flexibles_`years' != 1 & ID_areas == 1 &     ///
        `program' == 1, vce(cluster personabasicaid)
        
        outreg2 using "${output}\areas_degree.xls", label append dec(`dec') ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        ctitle("`z'","`program'","Years_`years'")                           ///
        addtext(Scores, YES, Controls, NO, School scores, NO, City of origin FE, NO)
        
        regsave $areas using "${output}\areas_degree", append               ///
        addlabel(outcome, "`outcome'", control, "scores", market,           ///
        "laboral_`years'", degree, "`program'", media, `mean_`outcome'')
        
        *
        reg `outcome' $areas $puntajes $controls i.year_sb11 `ultimo_mes'   ///
        i.year if laboral_`years' == 1 & flexibles_`years' != 1 &           ///
        ID_areas == 1 & `program' == 1, vce(cluster personabasicaid)
        
        outreg2 using "${output}\areas_degree.xls", label append dec(`dec') ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        ctitle("`z'","`program'","Years_`years'")                           ///
        addtext(Scores, YES, Controls, YES, School scores, NO, City of origin FE, NO)
        
        regsave $areas using "${output}\areas_degree", append               ///
        addlabel(outcome, "`outcome'", control, "socioeco", market,         ///
        "laboral_`years'", degree, "`program'", media, `mean_`outcome'')
        
        *
        reg `outcome' $areas $puntajes $controls $school i.year_sb11        ///
        `ultimo_mes' i.year if laboral_`years' == 1 &                       ///
        flexibles_`years' != 1 & ID_areas == 1 & `program' == 1,            ///
        vce(cluster personabasicaid)
        
        outreg2 using "${output}\areas_degree.xls", label append dec(`dec') ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        ctitle("`z'","`program'","Years_`years'")                           ///
        addtext(Scores, YES, Controls, YES, School scores, YES, City of origin FE, NO)
        
        regsave $areas using "${output}\areas_degree", append               ///
        addlabel(outcome, "`outcome'", control, "school", market,           ///
        "laboral_`years'", degree, "`program'", media, `mean_`outcome'')
        
        *
        reghdfe `outcome' $areas $puntajes $controls $school if             ///
        laboral_`years' == 1 & flexibles_`years' != 1 & ID_areas == 1 &     ///
        `program' == 1, vce(cluster personabasicaid)                        ///
        a(year_sb11 ultimo_mes year divipola)
        
        outreg2 using "${output}\areas_degree.xls", label append dec(`dec') ///
        nocons keep($areas) nor2 adds(Control's mean, `mean_`outcome'')     ///
        ctitle("`z'","`program'","Years_`years'")                           ///
        addtext(Scores, YES, Controls, YES, School scores, YES, City of origin FE, YES)
        
        regsave $areas using "${output}\areas_degree", append               ///
        addlabel(outcome, "`outcome'", control, "all", market,              ///
        "laboral_`years'", degree, "`program'", media, `mean_`outcome'')
        
        local replace append
        }
    }
}

}


/*
****** Acceso a TyT y Profesional
local replace replace
foreach i in 0 1 2_5 6_10{
	local ultimo_mes
	
	foreach outcome in $main{
		if "`outcome'" == "salario_ultimo_obs"{
			local dec 0
		}
		else{
			local dec 3
		}
		local z: variable label `outcome'
		qui sum `outcome' if SPADIES == 0 & laboral_`i' == 1 & flexibles_`i' != 1
		local mean_`outcome' = r(mean)
		
		
		reg `outcome' SPADIES_tyt SPADIES_prof if ((SPADIES == 1 & nivel != .) | SPADIES == 0) & laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid)
		outreg2 using "$output\Paper\acceso_programas.xls", label `replace' dec(`dec') keep(SPADIES_tyt SPADIES_prof) nocons nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, NO, HS and College FE, NO) ctitle("`z'","Years_`i'")
		regsave using "$output\Paper\TyT_Prof", `replace' addlabel(outcome, "`outcome'", control,"no",market,"laboral_`i'",media,`mean_`outcome'')
		
		
		reg `outcome' SPADIES_tyt SPADIES_prof $puntajes $controls i.year_sb11 `ultimo_mes' i.year if ((SPADIES == 1 & nivel != .) | SPADIES == 0) & laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid)
		outreg2 using "$output\Paper\acceso_programas.xls", label append dec(`dec') keep(SPADIES_tyt SPADIES_prof) nocons nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, SI, HS and College FE, NO) ctitle("`z'","Years_`i'")
		regsave using "$output\Paper\TyT_Prof", append addlabel(outcome, "`outcome'", control,"all",market,"laboral_`i'",media,`mean_`outcome'')
		
		
		reghdfe `outcome' SPADIES_tyt SPADIES_prof $puntajes $controls `ultimo_mes' if ((SPADIES == 1 & nivel != .) | SPADIES == 0) & laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid) a(year hs_by_cohort college_by_cohort)
		outreg2 using "$output\Paper\acceso_programas.xls", label append dec(`dec') keep(SPADIES_tyt SPADIES_prof) nocons nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, SI, HS and College FE, SI) ctitle("`z'","Years_`i'")
		regsave using "$output\Paper\TyT_Prof", append addlabel(outcome, "`outcome'", control,"FE",market,"laboral_`i'",media,`mean_`outcome'')
		
		local replace append
		local ultimo_mes i.ultimo_mes
	}
}



****** Graduación
local replace replace
foreach i in 0 1 2_5 6_10{
	local ultimo_mes
	
	foreach outcome in $main{
		if "`outcome'" == "salario_ultimo_obs"{
			local dec 0
		}
		else{
			local dec 3
		}		
		local z: variable label `outcome'
		qui sum `outcome' if grado == 0 & incompleto == 0 & laboral_`i' == 1 & flexibles_`i' != 1
		local mean_`outcome' = r(mean)
		
		
		reg `outcome' grado incompleto if laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid)
		outreg2 using "$output\Paper\graduacion.xls", label `replace' dec(`dec') nocons keep(grado incompleto) nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, NO, HS and College FE, NO) ctitle("`z'","Years_`i'") addnote(Acá se incluyen las dos dummies (Graduado y no graduado pero estudió).)
		regsave using "$output\Paper\Grado", `replace' addlabel(outcome, "`outcome'", control,"no",market,"laboral_`i'",media,`mean_`outcome'')
		
		
		reg `outcome' grado incompleto $puntajes $controls i.year_sb11 `ultimo_mes' i.year if laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid)
		outreg2 using "$output\Paper\graduacion.xls", label append dec(`dec') nocons keep(grado incompleto) nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, SI, HS and College FE, NO) ctitle("`z'","Years_`i'")
		regsave using "$output\Paper\Grado", append addlabel(outcome, "`outcome'", control,"all",market,"laboral_`i'",media,`mean_`outcome'')
		
		
		reghdfe `outcome' grado incompleto $puntajes $controls `ultimo_mes' if laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid) a(year hs_by_cohort college_by_cohort)
		outreg2 using "$output\Paper\graduacion.xls", label append dec(`dec') nocons keep(grado incompleto) nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, SI, HS and College FE, SI) ctitle("`z'","Years_`i'")
		regsave using "$output\Paper\Grado", append addlabel(outcome, "`outcome'", control,"FE",market,"laboral_`i'",media,`mean_`outcome'')
		
		local replace append
		local ultimo_mes i.ultimo_mes
	}	
}


****** STEM
local replace replace
foreach i in 0 1 2_5 6_10{
	local ultimo_mes
	
	foreach outcome in $main{
		if "`outcome'" == "salario_ultimo_obs"{
			local dec 0
		}
		else{
			local dec 3
		}		
		local z: variable label `outcome'
		qui sum `outcome' if SPADIES == 0 & laboral_`i' == 1 & flexibles_`i' != 1
		local mean_`outcome' = r(mean)
		
		
		reg `outcome' STEM_prof STEM_tyt no_STEM_prof no_STEM_tyt if ((SPADIES == 1 & prog_nucleo != .) | SPADIES == 0) & laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid)
		outreg2 using "$output\Paper\STEM.xls", label `replace' dec(`dec') nocons keep(STEM_prof STEM_tyt no_STEM_prof no_STEM_tyt) nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, NO, HS and College FE, NO) ctitle("`z'","Years_`i'")
		regsave using "$output\Paper\STEM", `replace' addlabel(outcome, "`outcome'", control,"no",market,"laboral_`i'",media,`mean_`outcome'')
		
		reg `outcome' STEM_prof STEM_tyt no_STEM_prof no_STEM_tyt $puntajes $controls i.year_sb11 `ultimo_mes' i.year if ((SPADIES == 1 & prog_nucleo != .) | SPADIES == 0) & laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid)
		outreg2 using "$output\Paper\STEM.xls", label append dec(`dec') nocons keep(STEM_prof STEM_tyt no_STEM_prof no_STEM_tyt) nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, SI, HS and College FE, NO) ctitle("`z'","Years_`i'")
		regsave using "$output\Paper\STEM", append addlabel(outcome, "`outcome'", control,"all",market,"laboral_`i'",media,`mean_`outcome'')
		
		
		reghdfe `outcome' STEM_prof STEM_tyt no_STEM_prof no_STEM_tyt $puntajes $controls `ultimo_mes' if ((SPADIES == 1 & prog_nucleo != .) | SPADIES == 0) & laboral_`i' == 1 & flexibles_`i' != 1, vce(cluster personabasicaid) a(year hs_by_cohort college_by_cohort)
		outreg2 using "$output\Paper\STEM.xls", label append dec(`dec') nocons keep(STEM_prof STEM_tyt no_STEM_prof no_STEM_tyt) nor2 adds(Control's mean, `mean_`outcome'') addtext(Controles, SI, HS and College FE, SI) ctitle("`z'","Years_`i'")
		regsave using "$output\Paper\STEM", append addlabel(outcome, "`outcome'", control,"FE",market,"laboral_`i'",media,`mean_`outcome'')
			
		local replace append
		local ultimo_mes i.ultimo_mes
		}	
}

*/
