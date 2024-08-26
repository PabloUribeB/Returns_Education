/*************************************************************************
**************************************************************************
                 Main estimation plots
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: September 2022

3) Objective: Plot main regression results

*************************************************************************
*************************************************************************/	
clear all

****************************************************************************
* Globals
****************************************************************************

cap mkdir "${graphs}\Degree type"
cap mkdir "${graphs}\area_degree"
cap mkdir "${graphs}\area_degree\temp"
cap mkdir "${graphs}\area"

set scheme white_tableau

local plot_note "{it:Note:} A red outline indicates that the coefficient " ///
"is not statistically significant. The numbers displayed represent the "   ///
"point estimate of the full-controls specification."

local plot_note2 "{it:Note:} A red outline indicates that the "         ///
"coefficient is not statistically significant. These estimations are "  ///
"ran with full controls."

****************************************************************************
**#             1. Professional and short-cycle graduation
****************************************************************************

use "${output}\Grado_programas", clear

replace var = "Complete short-cycle"    if var == "grado_tyt"
replace var = "Incomplete short-cycle"  if var == "incompleto_tyt"
replace var = "Complete professional"   if var == "grado_prof"
replace var = "Incomplete professional" if var == "incompleto_prof"

label define orden 1 "Incomplete short-cycle"  2 "Complete short-cycle"  ///
                   3 "Incomplete professional" 4 "Complete professional"

gen tstat = abs(coef) / stderr
*list var outcome control market tstat if tstat < 1.645

gen non_sig = (tstat < 1.645)

encode var, gen(en_var) label(orden)

levelsof outcome, local(outcome)
foreach var in `outcome' {

    sum coef if outcome == "`var'" & market == "laboral_0"
    local min: dis %7.2fc r(min)
    local max: dis %7.2fc r(max)

    sum coef if outcome == "`var'" & control == "all"
    local min2: dis %7.2fc r(min)
    local max2: dis %7.2fc r(max) + (r(max) / 4)

    if "`var'" == "l_salario_ultimo_obs" {
        local dec = 3
        local formato format(%7.2fc)
        local scale xscale(range(0 `max'))
        local scale2 xscale(range(0 `max2'))
        local name Log wages
    }

    else{
        local dec = 3
        local formato format(%7.2fc)
        local scale xscale(range(0 `max'))
        local scale2 xscale(range(0 `max2'))
        local name Coefficient of variation
    }

    format %13.`dec'fc coef

    twoway (sc en_var coef if control == "no" & market == "laboral_0" &     ///
    outcome == "`var'", m(triangle) mlc(black) mfc(none))                   ///
    (sc en_var coef if control == "scores" & market == "laboral_0" &        ///
    outcome == "`var'", m(square) mlc(black) mfc(none))                     ///
    (sc en_var coef if control == "socioeco" & market == "laboral_0" &      ///
    outcome == "`var'", m(diamond) mlc(black) mfc(none))                    ///
    (sc en_var coef if control == "school" & market == "laboral_0" &        ///
    outcome == "`var'", m(plus) mlc(black) mfc(none))                       ///
    (sc en_var coef if control == "all" & market == "laboral_0" &           ///
    outcome == "`var'", m(circle) mlc(black) mlabel(coef) mlabposition(12)  ///
    mfc(none))                                                              ///
    (sc en_var coef if control == "no" & market == "laboral_0" &            ///
    outcome == "`var'" & non_sig == 1, m(triangle) mlc(red) mfc(none))      ///
    (sc en_var coef if control == "scores" & market == "laboral_0" &        ///
    outcome == "`var'" & non_sig == 1, m(square) mlc(red) mfc(none))        ///
    (sc en_var coef if control == "socioeco" & market == "laboral_0" &      ///
    outcome == "`var'" & non_sig == 1, m(diamond) mlc(red) mfc(none))       ///
    (sc en_var coef if control == "school" & market == "laboral_0" &        ///
    outcome == "`var'" & non_sig == 1, m(plus) mlc(red) mfc(none))          ///
    (sc en_var coef if control == "all" & market == "laboral_0" &           ///
    outcome == "`var'" & non_sig == 1, m(circle) mlc(red) mlabel(coef)      ///
    mlabposition(12) mfc(none)),                                            ///
    xline(0, lcolor(black)) legend(order(1 "No controls" 2 "Scores" 3       ///
    "+ Socioeconomic controls" 4 "+ School controls" 5 "+ City FE")         ///
    region(color(white)) rows(5) size(vsmall)) graphregion(fcolor(white))   ///
    yscale(range(0 5)) ylabel(1(1)4, val angle(horizontal) labs(vsmall))    ///
    ytitle("") xlabel(#10, angle(45) `formato') xtitle(Point estimate,      ///
    margin(medsmall)) `scale' subtitle(`name')                              ///
    note("{it:Note:} A red outline indicates that the coefficient is not statistically significant. The" "numbers displayed represent the point estimate of the full-controls specification.", size(vsmall))

    graph export "${graphs}\Degree type\degree_type_controls_`var'.png", replace


    twoway (sc en_var coef if control == "all" & market == "laboral_1" &    ///
    outcome == "`var'", m(triangle) mlc(black) mfc(none)) 	                ///
    (sc en_var coef if control == "all" & market == "laboral_2_5" &         ///
    outcome == "`var'", m(square) mlc(black) mfc(none)) 		            ///
    (sc en_var coef if control == "all" & market == "laboral_6_10" &        ///
    outcome == "`var'", m(circle) mlc(black) mfc(none)) 		            ///
    (sc en_var coef if control == "all" & market == "laboral_1" &           ///
    outcome == "`var'" & non_sig == 1, m(triangle) mlc(red) mfc(none)) 	    ///
    (sc en_var coef if control == "all" & market == "laboral_2_5" &         ///
    outcome == "`var'" & non_sig == 1, m(square) mlc(red) mfc(none)) 		///
    (sc en_var coef if control == "all" & market == "laboral_6_10" &        ///
    outcome == "`var'" & non_sig == 1, m(circle) mlc(red) mfc(none)),       ///
    xline(0, lcolor(black)) legend(order(1 "First year" 2 "2-5 years" 3     ///
    "6-10 years") region(color(white)) rows(3) size(vsmall)                 ///
    title({bf:Labor market}, size(small))) graphregion(fcolor(white))       ///
    yscale(range(0 5)) ylabel(1(1)4, val angle(horizontal) labs(vsmall))    ///
    ytitle("") xlabel(#14, angle(45) `formato') xtitle(Point estimate,      ///
    margin(medsmall)) `scale2' subtitle(`name')                             ///
    note("{it:Note:} A red outline indicates that the coefficient is not statistically significant. These estimations are" "ran with full controls.", size(vsmall))

    graph export "${graphs}\Degree type\degree_type_years_`var'.png", replace

}



****************************************************************************
**#             2. Knowledge areas (excluded is liberal arts)
****************************************************************************

use "${output}\areas", clear

replace var = "Agronomy, veterinary"                if var == "area1"
replace var = "Education sciences"                  if var == "area3"
replace var = "Health sciences"                     if var == "area4"
replace var = "Social and human sciences"           if var == "area5"
replace var = "Economics, BA, accounting"           if var == "area6"
replace var = "Engineering, architecture, urbanism" if var == "area8"
replace var = "Mathematics and natural sciences"    if var == "area9"

label define orden 1 "Agronomy, veterinary" 2 "Education sciences" 3    ///
"Health sciences" 4 "Social and human sciences" 5                       ///
"Economics, BA, accounting" 6 "Engineering, architecture, urbanism" 7   ///
"Mathematics and natural sciences"

gen tstat = abs(coef) / stderr
*list var outcome control market tstat if tstat < 1.645

gen non_sig = (tstat < 1.645)

encode var, gen(en_var) label(orden)

levelsof outcome, local(outcome)
foreach var in `outcome' {

    sum coef if outcome == "`var'"
    local min: dis %7.2fc r(min)
    local max: dis %7.2fc r(max)

    sum coef if outcome == "`var'" & control == "all"
    local min2: dis %7.2fc r(min)
    local max2: dis %7.2fc r(max)

    if "`var'" == "l_salario_ultimo_obs" {
        local dec = 3
        local formato format(%7.2fc)
        local scale xscale(range(0 `max'))
        local scale2 xscale(range(0 `max2'))
    }

    else{
        local dec = 3
        local formato format(%7.2fc)
        local scale xscale(range(`min' `max'))
        local scale2 xscale(range(`min2' `max2'))
    }

    format %13.`dec'fc coef

    twoway (sc en_var coef if control == "no" & market == "laboral_0" &     ///
    outcome == "`var'", m(triangle) mlc(black) mfc(none))                   ///
    (sc en_var coef if control == "scores" & market == "laboral_0" &        ///
    outcome == "`var'", m(square) mlc(black) mfc(none))                     ///
    (sc en_var coef if control == "socioeco" & market == "laboral_0" &      ///
    outcome == "`var'", m(diamond) mlc(black) mfc(none))                    ///
    (sc en_var coef if control == "school" & market == "laboral_0" &        ///
    outcome == "`var'", m(plus) mlc(black) mfc(none))                       ///
    (sc en_var coef if control == "all" & market == "laboral_0" &           ///
    outcome == "`var'", m(circle) mlc(black) mlabel(coef) mlabposition(12)  ///
    mfc(none))                                                              ///
    (sc en_var coef if control == "no" & market == "laboral_0" &            ///
    outcome == "`var'" & non_sig == 1, m(triangle) mlc(red) mfc(none))      ///
    (sc en_var coef if control == "scores" & market == "laboral_0" &        ///
    outcome == "`var'" & non_sig == 1, m(square) mlc(red) mfc(none))        ///
    (sc en_var coef if control == "socioeco" & market == "laboral_0" &      ///
    outcome == "`var'" & non_sig == 1, m(diamond) mlc(red) mfc(none))       ///
    (sc en_var coef if control == "school" & market == "laboral_0" &        ///
    outcome == "`var'" & non_sig == 1, m(plus) mlc(red) mfc(none))          ///
    (sc en_var coef if control == "all" & market == "laboral_0" &           ///
    outcome == "`var'" & non_sig == 1, m(circle) mlc(red) mlabel(coef)      ///
    mlabposition(12) mfc(none)),                                            ///
    xline(0, lcolor(black)) legend(order(1 "No controls" 2 "Scores" 3       ///
    "+ Socioeconomic controls" 4 "+ School controls" 5 "+ City FE")         ///
    region(color(white)) rows(5) size(vsmall)) graphregion(fcolor(white))   ///
    yscale(range(0 8)) ylabel(1(1)7, val angle(horizontal) labs(vsmall))    ///
    ytitle("") xlabel(#10, angle(45) `formato') xtitle(Point estimate,      ///
    margin(medsmall)) `scale'                                               ///
    note("{it:Note:} Outcome variable: `var'. A red outline indicates that the coefficient is not" "statistically significant.", size(vsmall))

    graph export "${graphs}\area\area_controls_`var'.png", replace


    twoway (sc en_var coef if control == "all" & market == "laboral_1" &    ///
    outcome == "`var'", m(triangle) mlc(black) mfc(none)) 	                ///
    (sc en_var coef if control == "all" & market == "laboral_2_5" &         ///
    outcome == "`var'", m(square) mlc(black) mfc(none)) 		            ///
    (sc en_var coef if control == "all" & market == "laboral_6_10" &        ///
    outcome == "`var'", m(circle) mlc(black) mfc(none)) 		            ///
    (sc en_var coef if control == "all" & market == "laboral_1" &           ///
    outcome == "`var'" & non_sig == 1, m(triangle) mlc(red) mfc(none)) 		///
    (sc en_var coef if control == "all" & market == "laboral_2_5" &         ///
    outcome == "`var'" & non_sig == 1, m(square) mlc(red) mfc(none)) 		///
    (sc en_var coef if control == "all" & market == "laboral_6_10" &        ///
    outcome == "`var'" & non_sig == 1, m(circle) mlc(red) mfc(none)),       ///
    xline(0, lcolor(black)) legend(order(1 "First year" 2 "2-5 years" 3     ///
    "6-10 years") region(color(white)) rows(3) size(vsmall)                 ///
    title({bf:Labor market}, size(small))) graphregion(fcolor(white))       ///
    yscale(range(0 8)) ylabel(1(1)7, val angle(horizontal) labs(vsmall))    ///
    ytitle("") xlabel(#10, angle(45) `formato') xtitle(Point estimate,      ///
    margin(medsmall)) `scale2'                                              ///
    note("{it:Note:} Outcome variable: `var'. A red outline indicates that the coefficient is not" "statistically significant.", size(vsmall))

    graph export "${graphs}\area\area_years_`var'.png", replace

}



****************************************************************************
**#             3. Knowledge areas by program type
****************************************************************************

use "${output}\areas_degree", clear

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

cd "${graphs}\area_degree\temp"

foreach degrees in grado_prof incompleto_prof grado_tyt incompleto_tyt {

    preserve

    keep if degree == "`degrees'"

    levelsof outcome, local(outcome)
    local variable "CV"
    foreach var in `outcome'{
        
        sum coef if outcome == "`var'" & market == "laboral_0"
        local min: dis %7.2fc r(min)
        local max: dis %7.2fc r(max)
        
        sum coef if outcome == "`var'" & control == "all"
        local min2: dis %7.2fc r(min)
        local max2: dis %7.2fc r(max)
        
        if "`var'" == "l_salario_ultimo_obs"{
            local dec = 3
            local formato format(%7.2fc)
            local scale xscale(range(`min' `max'))
            local scale2 xscale(range(`min2' `max2'))
        }
        
        else{
            local dec = 3
            local formato format(%7.2fc)
            local scale xscale(range(`min' `max'))
            local scale2 xscale(range(`min2' `max2'))
        }
        
        format %13.`dec'fc coef
        
        twoway (sc en_var coef if control == "no" & market == "laboral_0"   ///
        & outcome == "`var'", m(triangle) mlc(black) mfc(none)) 	        ///
        (sc en_var coef if control == "scores" & market == "laboral_0" &    ///
        outcome == "`var'", m(square) mlc(black) mfc(none)) 		        ///
        (sc en_var coef if control == "socioeco" & market == "laboral_0" &  ///
        outcome == "`var'", m(diamond) mlc(black) mfc(none)) 	            ///
        (sc en_var coef if control == "school" & market == "laboral_0" &    ///
        outcome == "`var'", m(plus) mlc(black) mfc(none)) 			        ///
        (sc en_var coef if control == "all" & market == "laboral_0" &       ///
        outcome == "`var'", m(circle) mlc(black) mlabel(coef)               ///
        mlabposition(12) mfc(none))                                         ///
        (sc en_var coef if control == "no" & market == "laboral_0" &        ///
        outcome == "`var'" & non_sig == 1, m(triangle) mlc(red) mfc(none)) 	///
        (sc en_var coef if control == "scores" & market == "laboral_0" &    ///
        outcome == "`var'" & non_sig == 1, m(square) mlc(red) mfc(none)) 	///
        (sc en_var coef if control == "socioeco" & market == "laboral_0" &  ///
        outcome == "`var'" & non_sig == 1, m(diamond) mlc(red) mfc(none)) 	///
        (sc en_var coef if control == "school" & market == "laboral_0" &    ///
        outcome == "`var'" & non_sig == 1, m(plus) mlc(red) mfc(none)) 		///
        (sc en_var coef if control == "all" & market == "laboral_0" &       ///
        outcome == "`var'" & non_sig == 1, m(circle) mlc(red) mlabel(coef)  ///
        mlabposition(12) mfc(none)),                                        ///
        xline(0, lcolor(black)) legend(order(1 "No controls" 2 "Scores" 3   ///
        "+ Socioeconomic controls" 4 "+ School controls" 5 "+ City FE")     ///
        region(color(white)) rows(1) size(vsmall))                          ///
        graphregion(fcolor(white)) yscale(range(0 8)) ylabel(1(1)7, val     ///
        angle(horizontal) labs(vsmall)) ytitle("")                          ///
        xlabel(#10, angle(45) `formato')                                    ///
        xtitle(Point estimate, margin(medsmall)) `scale'                    ///
        saving(`variable'_`degrees'_control, replace)


        twoway (sc en_var coef if control == "all" & market == "laboral_1"  ///
        & outcome == "`var'", m(triangle) mlc(black) mfc(none)) 	        ///
        (sc en_var coef if control == "all" & market == "laboral_2_5" &     ///
        outcome == "`var'", m(square) mlc(black) mfc(none)) 		        ///
        (sc en_var coef if control == "all" & market == "laboral_6_10" &    ///
        outcome == "`var'", m(circle) mlc(black) mfc(none))		            ///
        (sc en_var coef if control == "all" & market == "laboral_1" &       ///
        outcome == "`var'" & non_sig == 1, m(triangle) mlc(red) mfc(none)) 	///
        (sc en_var coef if control == "all" & market == "laboral_2_5" &     ///
        outcome == "`var'" & non_sig == 1, m(square) mlc(red) mfc(none)) 	///
        (sc en_var coef if control == "all" & market == "laboral_6_10" &    ///
        outcome == "`var'" & non_sig == 1, m(circle) mlc(red) mfc(none)),   ///
        xline(0, lcolor(black)) legend(order(1 "First year" 2 "2-5 years" 3 ///
        "6-10 years") region(color(white)) rows(1) size(vsmall)             ///
        title({bf:Labor market}, size(small))) graphregion(fcolor(white))   ///
        yscale(range(0 8)) ylabel(1(1)7, val angle(horizontal)              ///
        labs(vsmall)) ytitle("") xlabel(#10, angle(45) `formato')           ///
        xtitle(Point estimate, margin(medsmall)) `scale2'                   ///
        saving(`variable'_`degrees'_years, replace)

        local variable "Salario"
        
    }

    restore
}


****************************************************************************
**#             3.1 Combined plots from section 3
****************************************************************************
local i = 1
local suffix ""
local option ""
foreach types in off common{

    ** Wages
    grc1leg Salario_grado_prof_control.gph Salario_incompleto_prof_control.gph  ///
    Salario_grado_tyt_control.gph Salario_incompleto_tyt_control.gph,           ///
    legendfrom(Salario_grado_prof_control.gph) rows(2) imargin(medium)          ///
    subtitle(Log wages) `option' note(`plot_note', size(vsmall))

    graph play "${graphs}\areas_degree.grec"

    graph export "$graphs\area_degree\Salario_controls`suffix'.png", replace


    grc1leg Salario_grado_prof_years.gph Salario_incompleto_prof_years.gph      ///
    Salario_grado_tyt_years.gph Salario_incompleto_tyt_years.gph,               ///
    legendfrom(Salario_grado_prof_years.gph) rows(2) imargin(medium)            ///
    subtitle(Log wages) `option' note(`plot_note2', size(vsmall))

    graph play "${graphs}\areas_degree.grec"

    graph export "${graphs}\area_degree\Salario_years`suffix'.png", replace



    ** CV
    grc1leg CV_grado_prof_control.gph CV_incompleto_prof_control.gph            ///
    CV_grado_tyt_control.gph CV_incompleto_tyt_control.gph,                     ///
    legendfrom(CV_grado_prof_control.gph) rows(2) imargin(medium)               ///
    subtitle(Coefficient of variation) `option' note(`plot_note', size(vsmall)) 

    graph play "${graphs}\areas_degree.grec"

    graph export "${graphs}\area_degree\CV_controls`suffix'.png", replace


    grc1leg CV_grado_prof_years.gph CV_incompleto_prof_years.gph                ///
    CV_grado_tyt_years.gph CV_incompleto_tyt_years.gph,                         ///
    legendfrom(CV_grado_prof_years.gph) rows(2) imargin(medium)                 ///
    subtitle(Coefficient of variation) `option' note(`plot_note2', size(vsmall))

    graph play "${graphs}\areas_degree.grec"

    graph export "${graphs}\area_degree\CV_years`suffix'.png", replace

    local suffix "_common"
    local option "xcommon"
}


****
*!rmdir "${graphs}\area_degree\temp"  /s /q // Erase all temp graphs

/*
***** STEM
use "$output\STEM", clear

keep if inlist(var,"STEM_tyt","no_STEM_tyt","STEM_prof","no_STEM_prof")

replace var = "Short-cycle STEM" if var == "STEM_tyt"
replace var = "Short-cycle not STEM" if var == "no_STEM_tyt"
replace var = "Professional STEM" if var == "STEM_prof"
replace var = "Professional not STEM" if var == "no_STEM_prof"

label define orden 1 "Short-cycle not STEM" 2 "Short-cycle STEM" 3 "Professional not STEM" 4 "Professional STEM"

gen tstat = abs(coef)/stderr
list var outcome control market tstat if tstat < 1.645

encode var, gen(en_var) label(orden)

levelsof outcome, local(outcome)
foreach var in `outcome'{
	
	sum coef if outcome == "`var'" & market == "laboral_0"
	local min: dis %7.2fc r(min)
	local max: dis %7.2fc r(max)
	
	sum coef if outcome == "`var'" & control == "FE"
	local min2: dis %7.2fc r(min)
	local max2: dis %7.2fc r(max)
	
	if "`var'" == "salario_ultimo_obs"{
		local dec = 0
		local formato format(%13.0fc)
		local scale xscale(range(0 `max'))
		local scale2 xscale(range(-50000 `max2'))
		local adicional (sc en_var coef if control == "FE" & market == "laboral_0" & outcome == "salario_ultimo_obs" & var == "Short-cycle STEM", m(circle) mlc(red) mfc(none))
		local adicional2
	}
	
	else if "`var'" == "l_salario_ultimo_obs"{
		local dec = 3
		local formato format(%7.2fc)
		local scale xscale(range(0 `max'))
		local scale2 xscale(range(0 `max2'))
		local adicional
		local adicional2
	}
	
	else if "`var'" == "CV"{
		local dec = 3
		local formato format(%7.2fc)
		local scale xscale(range(`min' `max'))
		local scale2 xscale(range(`min2' `max2'))
		local adicional (sc en_var coef if control == "FE" & market == "laboral_0" & outcome == "CV" & var == "Short-cycle STEM", m(circle) mlc(red) mfc(none)) (sc en_var coef if control == "FE" & market == "laboral_0" & outcome == "CV" & var == "Professional not STEM", m(circle) mlc(red) mfc(none))
		local adicional2 (sc en_var coef if control == "all" & market == "laboral_1" & outcome == "CV" & var == "Short-cycle STEM", m(triangle) mlc(red) mfc(none))
	}
	
	else{
		local dec = 3
		local formato format(%7.2fc)
		local scale xscale(range(`min' `max'))
		local scale2 xscale(range(0 `max2'))
		local adicional
		local adicional2
	}
	
	format %13.`dec'fc coef
	
	twoway (sc en_var coef if control == "no" & market == "laboral_0" & outcome == "`var'", m(triangle) mlc(black) mfc(none)) (sc en_var coef if control == "all" & market == "laboral_0" & outcome == "`var'", m(square) mlc(black) mfc(none)) (sc en_var coef if control == "FE" & market == "laboral_0" & outcome == "`var'", m(circle) mlc(black) mlabel(coef) mlabposition(12) mfc(none)) `adicional', xline(0, lcolor(black)) legend(order(1 "No controls" 2 "Scores + Socioeco" 3 "Controls + HS and college FE") region(color(white)) rows(3) size(vsmall)) graphregion(fcolor(white)) yscale(range(0 5)) ylabel(1(1)4, val angle(horizontal) labs(vsmall)) ytitle("") xlabel(#10, angle(45) `formato') xtitle(Point estimate, margin(medsmall)) `scale' note("{it:Note:} Outcome variable: `var'. The red outline indicates the coefficient" "is not statistically significant.")

	graph export "$graphs\STEM\STEM_controls_`var'.png", replace


	twoway (sc en_var coef if control == "all" & market == "laboral_1" & outcome == "`var'", m(triangle) mlc(black) mfc(none)) (sc en_var coef if control == "all" & market == "laboral_2_5" & outcome == "`var'", m(square) mlc(black) mfc(none)) (sc en_var coef if control == "all" & market == "laboral_6_10" & outcome == "`var'", m(circle) mlc(black) mfc(none)) `adicional2', xline(0, lcolor(black)) legend(order(1 "1 Year Post-HS" 2 "2-5 Years Post-HS" 3 "6-10 Years Post-HS") region(color(white)) rows(3) size(vsmall)) graphregion(fcolor(white)) yscale(range(0 5)) ylabel(1(1)4, val angle(horizontal) labs(vsmall)) ytitle("") xlabel(#12, angle(45) `formato') xtitle(Point estimate, margin(medsmall)) `scale2' note("{it:Note:} Outcome variable: `var'. The red outline indicates the coefficient" "is not statistically significant.")

	graph export "$graphs\STEM\STEM_years_`var'.png", replace

}

*/
