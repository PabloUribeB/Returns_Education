/*************************************************************************
**************************************************************************
                 Cities estimations
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: September 2022

3) Objective: Estimate regressions for cities
           
4) Output:    - Grado_programas_city.dta
              - areas_degree_city.dta

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

gen ID_areas = (area1 == 1 | area2 == 1 | area3 == 1 | area4 == 1 |     ///
    area5 == 1 | area6 == 1 | area8 == 1 | area9 == 1)

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
    forval city = 1/62{
	
        foreach outcome in $main{
			
            dis as err "Regression for outcome: `outcome' in labor market: " ///
            "`years' for city `city'"

            local z: variable label `outcome'
            qui sum `outcome' if SPADIES == 0 & laboral_`years' == 1 &      ///
                    flexibles_`years' != 1 & areas_lora == `city'
                    
            local mean_`outcome' = r(mean)

            reg `outcome' grado_tyt incompleto_tyt grado_prof               ///
            incompleto_prof $puntajes $controls $school i.year_sb11         ///
            `ultimo_mes' i.year if ((SPADIES == 1 & !mi(nivel) |            ///
            SPADIES == 0) & laboral_`years' == 1 & flexibles_`years' != 1   ///
            & areas_lora == `city', vce(cluster personabasicaid)

            regsave grado_tyt incompleto_tyt grado_prof incompleto_prof     ///
            using "${output}\Grado_programas_city", `replace'                 ///
            addlabel(outcome, "`outcome'", city, "`city'", market,          ///
            "laboral_`years'", media, `mean_`outcome'')

            local replace append
        }
    }
}

/*
****** Áreas conocimiento
* Excluyendo bellas artes

local replace replace
local dec 3
local ultimo_mes i.ultimo_mes

foreach i in 0 1 2_5 6_10{

	forval city = 1/62{

		foreach outcome in $main{
			
			dis as err "Regression for outcome: `outcome' in labor market: `i' for city `city'"
			
			local z: variable label `outcome'
			qui sum `outcome' if area2 == 1 & laboral_`i' == 1 & flexibles_`i' != 1
			local mean_`outcome' = r(mean)
			
			reg `outcome' $areas $puntajes $controls $school i.year_sb11 `ultimo_mes' i.year if laboral_`i' == 1 & flexibles_`i' != 1 & ID_areas == 1, vce(cluster personabasicaid)
			regsave $areas using "${output}\areas_city", `replace' addlabel(outcome, "`outcome'", city,"`city'",market,"laboral_`i'",media,`mean_`outcome'')
			
			local replace append
		}
	}
}
*/


****************************************************************************
**#     1.2 Knowledge areas by program type (excluded is liberal arts)
****************************************************************************

local replace replace
local dec 3
local ultimo_mes i.ultimo_mes
foreach years in 0 1 2_5 6_10{
	
	foreach program in grado_tyt incompleto_tyt grado_prof incompleto_prof{

		forval city = 1/62{
			
			foreach outcome in $main{
				
				dis as err "Regression for outcome: `outcome' in labor "    ///
                "market: `years' for city `city'"
				
				local z: variable label `outcome'
				qui sum `outcome' if area2 == 1 & laboral_`years' == 1 &    ///
                        flexibles_`years' != 1 & `program' == 1 &           ///
                        areas_lora == `city'
                        
				local mean_`outcome' = r(mean)
				
				
				reg `outcome' $areas $puntajes $controls $school            ///
                i.year_sb11 `ultimo_mes' i.year if laboral_`years' == 1 &   ///
                flexibles_`years' != 1 & ID_areas == 1 & `program' == 1 &   ///
                areas_lora == `city', vce(cluster personabasicaid)
                
				regsave $areas using "${output}\areas_degree_city", `replace' ///
                addlabel(outcome, "`outcome'", city, "`city'", market,      ///
                "laboral_`years'", degree, "`program'", media, `mean_`outcome'')
				
				local replace append
			}
		}
	}
}

}