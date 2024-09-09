/*************************************************************************
**************************************************************************
                 RIF estimations
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: September 2022

3) Objective: Estimate RIF regressions
           
4) Output:    - RIF_degree.dta
              - RIF_areas.dta
              - RIF_areas_degree.dta

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
forval i = 10(40)90 {

    dis as err "Percentil `i'"
    bsrifhdreg l_salario_ultimo_obs grado_tyt incompleto_tyt grado_prof     ///
    incompleto_prof $puntajes $controls $school if                          ///
    ((SPADIES == 1 & !mi(nivel)) | SPADIES == 0), abs(year_sb11 ultimo_mes  ///
    year divipola) vce(cluster personabasicaid) rif(q(`i')) reps(500)   ///
    seed(64)


    regsave grado_tyt incompleto_tyt grado_prof incompleto_prof using       ///
    "${output}\RIF_degree", `replace' ci level(95) addlabel(perc, `i')

    local replace append
}



****************************************************************************
**#         1.2 Knowledge areas (excluded is liberal arts)
****************************************************************************

gen ID_areas = (area1 == 1 | area2 == 1 | area3 == 1 | area4 == 1 |         ///
    area5 == 1 | area6 == 1 | area8 == 1 | area9 == 1)

local replace replace
forval i = 10(40)90 {

    dis as err "Percentil `i'"
    bsrifhdreg l_salario_ultimo_obs $areas $puntajes $controls $school if   ///
    ID_areas == 1, abs(year_sb11 ultimo_mes year divipola)                  ///
    vce(cluster personabasicaid) rif(q(`i')) reps(500) seed(64)

    regsave $areas using "${output}\RIF_areas", `replace' ci level(95)      ///
    addlabel(perc, `i')

    local replace append
}


****************************************************************************
**#     1.3 Knowledge areas by program type (excluded is liberal arts)
****************************************************************************

local replace replace
foreach program in grado_tyt incompleto_tyt grado_prof incompleto_prof {

    forval i = 10(40)90 {
        
        dis as err "Percentil `i'"
        bsrifhdreg l_salario_ultimo_obs $areas $puntajes $controls $school if ///
        ID_areas == 1 & `program' == 1, abs(year_sb11 ultimo_mes year         ///
        divipola) vce(cluster personabasicaid) rif(q(`i')) reps(500) seed(64)

        regsave $areas using "${output}\RIF_areas_degree", `replace' ci       ///
        level(95) addlabel(perc, `i', degree,"`program'")

        local replace append
    }
}

}
