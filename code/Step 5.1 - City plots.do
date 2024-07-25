/*************************************************************************
**************************************************************************
                 City estimation plots
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: September 2022

3) Objective: Plot city regression results

*************************************************************************
*************************************************************************/	
clear all

****************************************************************************
* Globals
****************************************************************************

set scheme white_tableau

cap mkdir "${graphs}\City"
cap mkdir "${graphs}\City\temp"

local plot_note "{it:Note:} Each circle represents one of the 62 cities "   ///
"with large labor markets as in O'Clery et al. (2019). Regressions are "    ///
"ran with full controls."

****************************************************************************
**#             1. Professional and short-cycle graduation
****************************************************************************

use "${output}\Grado_programas_city", clear

replace var = "Complete short-cycle"    if var == "grado_tyt"
replace var = "Incomplete short-cycle"  if var == "incompleto_tyt"
replace var = "Complete professional"   if var == "grado_prof"
replace var = "Incomplete professional" if var == "incompleto_prof"

label define orden 1 "Incomplete short-cycle"  2 "Complete short-cycle"  ///
                   3 "Incomplete professional" 4 "Complete professional"

gen tstat = abs(coef) / stderr

gen non_sig = (tstat < 1.645)

encode var, gen(en_var) label(orden)

cd "${graphs}\City\temp"

foreach markets in laboral_0 laboral_1 laboral_2_5 laboral_6_10{

	levelsof outcome, local(outcome)
	foreach var in `outcome'{

		if "`var'" == "l_salario_ultimo_obs"{
			local dec = 3
			local formato format(%7.2fc)
			local scale2 xscale(range(-.1 .8))
		}
		
		else{
			local dec = 3
			local formato format(%7.2fc)
			local scale2 xscale(range(-.7 1.4))
		}
		
		format %13.`dec'fc coef
		

		twoway (sc en_var coef if market == "`markets'" &                   ///
        outcome == "`var'", m(circle) mlc(black) mfc(none)),                ///
        xline(0, lcolor(black)) legend(order(1 "City estimate")             ///
        region(color(white)) size(vsmall)) graphregion(fcolor(white))       ///
        yscale(range(0 5)) ylabel(1(1)4, val angle(horizontal)              ///
        labs(vsmall)) ytitle("") xlabel(#14, angle(45) `formato')           ///
        xtitle(Point estimate, margin(medsmall)) `scale2'                   ///
        saving(`var'_`markets', replace)

	}
}

** Wages
* Entire time
grc1leg l_salario_ultimo_obs_laboral_0.gph, subtitle(Log wages) imargin(medium) ///
note(`plot_note', size(vsmall))

graph play "${graphs}\degree.grec"

graph export "${graphs}\City\Degree_wages_entire_market.png", replace


* By years
grc1leg l_salario_ultimo_obs_laboral_1.gph l_salario_ultimo_obs_laboral_2_5.gph ///
l_salario_ultimo_obs_laboral_6_10.gph,                                          ///
legendfrom(l_salario_ultimo_obs_laboral_1.gph) rows(2) imargin(medium)          ///
subtitle(Log wages) note(`plot_note', size(vsmall)) 

graph play "${graphs}\degree2.grec"

graph export "${graphs}\City\Degree_wages.png", replace


** CV
* Entire time
grc1leg CV_laboral_0.gph, imargin(medium) subtitle(Coefficient of variation)    ///
note(`plot_note', size(vsmall)) 

graph play "${graphs}\degree.grec"

graph export "${graphs}\City\Degree_CV_entire_market.png", replace


* By years
grc1leg CV_laboral_1.gph CV_laboral_2_5.gph CV_laboral_6_10.gph,                ///
legendfrom(CV_laboral_1.gph) rows(2) imargin(medium)                            ///
subtitle(Coefficient of variation) note(`plot_note', size(vsmall)) 

graph play "${graphs}\degree2.grec"

graph export "${graphs}\City\Degree_CV.png", replace


/* Too many dimensions (code needs to change if want to plot this)
****************************************************************************
**#             2. Knowledge areas by program type
****************************************************************************

use "$output\areas_degree_city", clear

replace var = "Agronomy, veterinary"                if var == "area1"
replace var = "Education sciences"                  if var == "area3"
replace var = "Health sciences"                     if var == "area4"
replace var = "Social and human sciences"           if var == "area5"
replace var = "Economics, BA, accounting"           if var == "area6"
replace var = "Engineering, architecture, urbanism" if var == "area8"
replace var = "Mathematics and natural sciences"    if var == "area9"

label define orden 1 "Education sciences" 2 "Agronomy, veterinary" 3    ///
"Economics, BA, accounting" 4 "Mathematics and natural sciences" 5      ///
"Social and human sciences" 6 "Engineering, architecture, urbanism" 7   ///
"Health sciences"

encode var, gen(en_var) label(orden)

gen tstat = abs(coef) / stderr
gen non_sig = (tstat < 1.645)

cd "$graphs\City\temp"

foreach degrees in grado_prof incompleto_prof grado_tyt incompleto_tyt {

	preserve

	keep if degree == "`degrees'"

	foreach markets in laboral_0 laboral_1 laboral_2_5 laboral_6_10{

	levelsof outcome, local(outcome)
		foreach var in `outcome'{

			if "`var'" == "l_salario_ultimo_obs"{
				local dec = 3
				local formato format(%7.2fc)
				local scale2 xscale(range(-.1 .8))
			}
			
			else{
				local dec = 3
				local formato format(%7.2fc)
				local scale2 xscale(range(-.7 1.4))
			}
			
			format %13.`dec'fc coef
			

			twoway (sc en_var coef if market == "`markets'" &               ///
            outcome == "`var'" & degree == "`degrees'", m(circle)           ///
            mlc(black) mfc(none)),                                          ///
            xline(0, lcolor(black)) legend(order(1 "City estimate")         ///
            region(color(white)) size(vsmall)) graphregion(fcolor(white))   ///
            yscale(range(0 8)) ylabel(1(1)7, val angle(horizontal)          ///
            labs(vsmall)) ytitle("") xlabel(#14, angle(45) `formato')       ///
            xtitle(Point estimate, margin(medsmall)) `scale2'               ///
            saving(`var'_`markets'_`degrees', replace)

		}
	}	

	restore
}

** Wages
grc1leg Salario_grado_prof_control.gph Salario_incompleto_prof_control.gph  ///
Salario_grado_tyt_control.gph Salario_incompleto_tyt_control.gph,           ///
legendfrom(Salario_grado_prof_control.gph) rows(2) imargin(medium) note("Outcome: Wages. A red outline indicates that the coefficient is not statistically significant.")

graph play "${graphs}\areas_degree.grec"

graph export "$graphs\City\Salario_controls.png", replace


grc1leg Salario_grado_prof_years.gph Salario_incompleto_prof_years.gph Salario_grado_tyt_years.gph Salario_incompleto_tyt_years.gph, legendfrom(Salario_grado_prof_years.gph) rows(2) imargin(medium) note("Outcome: Wages. A red outline indicates that the coefficient is not statistically significant.")

graph play "${graphs}\areas_degree.grec"

graph export "$graphs\City\Salario_years.png", replace


** CV
grc1leg CV_grado_prof_control.gph CV_incompleto_prof_control.gph CV_grado_tyt_control.gph CV_incompleto_tyt_control.gph, legendfrom(CV_grado_prof_control.gph) rows(2) imargin(medium) note("Outcome: CV. A red outline indicates that the coefficient is not statistically significant.")

graph play "${graphs}\areas_degree.grec"

graph export "$graphs\City\CV_controls.png", replace

grc1leg CV_grado_prof_years.gph CV_incompleto_prof_years.gph CV_grado_tyt_years.gph CV_incompleto_tyt_years.gph, legendfrom(CV_grado_prof_years.gph) rows(2) imargin(medium) note("Outcome: Wages. A red outline indicates that the coefficient is not statistically significant.")

graph play "${graphs}\areas_degree.grec"

graph export "$graphs\City\CV_years.png", replace
*/


****
*!rmdir "${graphs}\City\temp"  /s /q // Erase all temp graphs
