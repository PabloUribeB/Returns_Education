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

set scheme white_tableau

cap mkdir "${graphs}\RIF"
cap mkdir "${graphs}\RIF\temps"

local plot_note "{it:Note:} Results come from RIF regressions using full controls."

****************************************************************************
**#             1. Professional and short-cycle graduation
****************************************************************************
** RIF Degree

use "${output}\RIF_degree", clear

cd "${graphs}\RIF\temps"

keep if inlist(perc,10,50,90)

replace perc = 1 if perc == 10
replace perc = 2 if perc == 50
replace perc = 3 if perc == 90

label define value 1 "10" 2 "50" 3 "90"
label val perc value

foreach outcome in grado_prof incompleto_prof grado_tyt incompleto_tyt {

	twoway  (rcap ci_lower ci_upper perc if var == "`outcome'",         ///
    fcolor(none) lcolor(red))                                           ///
    (bar coef perc if var == "`outcome'", fcolor(none) lcolor(black)    ///
    barw(0.5)),                                                         ///
    legend(order(2 "Point estimate" 1 "95% CI") region(lwidth(none))    ///
    position(bottom) rows(1)) xlabel(1(1)3,val) xscale(range(0, 4))     ///
    yscale(range(-0.05 1)) ylabel(-0.05(0.1)1)                          ///
    graphregion(color(white)) ytitle({&beta}, orientation(horizontal))  ///
    xtitle(Percentile, m(medsmall)) yline(0) saving(`outcome', replace)

}

grc1leg grado_prof.gph incompleto_prof.gph grado_tyt.gph incompleto_tyt.gph, ///
    legendfrom(grado_prof.gph) note(`plot_note', size(vsmall))

graph play "${graphs}\degrees.grec"

graph export "${graphs}\RIF\RIF_degrees.png", replace



****************************************************************************
**#             2. Knowledge areas (excluded is liberal arts)
****************************************************************************

use "${output}\RIF_areas", clear

cd "${graphs}\RIF\temps"

keep if inlist(perc,10,50,90)

replace perc = 1 if perc == 10
replace perc = 2 if perc == 50
replace perc = 3 if perc == 90

label define value 1 "10" 2 "50" 3 "90"
label val perc value

foreach outcome in area1 area3 area4 area5 area6 area8 area9 {

	twoway  (rcap ci_lower ci_upper perc if var == "`outcome'",         ///
    fcolor(none) lcolor(red))                                           ///
    (bar coef perc if var == "`outcome'", fcolor(none) lcolor(black)    ///
    barw(0.5)),                                                         ///
    legend(order(2 "Point estimate" 1 "95% CI") region(lwidth(none))    ///
    position(bottom) rows(1)) xlabel(1(1)3,val) xscale(range(0, 4))     ///
    yscale(range(-.1 .6)) ylabel(-.1(.1).6) graphregion(color(white))   ///
    ytitle({&beta}, orientation(horizontal)) xtitle(Percentile,         ///
    m(medsmall)) yline(0) saving(`outcome', replace)

}

grc1leg area1.gph area3.gph area4.gph area5.gph area6.gph area8.gph     ///
    area9.gph, legendfrom(area1.gph) rows(3) holes(7) imargin(medium)   ///
    note(`plot_note', size(vsmall))

graph play "${graphs}\areas.grec"

graph export "${graphs}\RIF\RIF_areas.png", replace



****************************************************************************
**#             3. Knowledge areas by program type
****************************************************************************

use "${output}\RIF_areas_degree", clear

cd "${graphs}\RIF\temps"

keep if inlist(perc,10,50,90)

replace perc = 1 if perc == 10
replace perc = 2 if perc == 50
replace perc = 3 if perc == 90

label define value 1 "10" 2 "50" 3 "90"
label val perc value

foreach degree in grado_prof incompleto_prof grado_tyt incompleto_tyt {

	if "`degree'" == "grado_prof"{
		local ranges yscale(range(-.2 .6)) ylabel(-.2(.2).6)
	}
	
	else if "`degree'" == "incompleto_prof"{
		local ranges yscale(range(-.2 .6)) ylabel(-.2(.2).6)
	}
	
	else if "`degree'" == "grado_tyt"{
		local ranges yscale(range(-.2 .6)) ylabel(-.2(.2).6)
	}
	
	else if "`degree'" == "incompleto_tyt"{
		local ranges yscale(range(-.2 .6)) ylabel(-.2(.2).6)
	}

	foreach outcome in area1 area3 area4 area5 area6 area8 area9 {

		twoway  (rcap ci_lower ci_upper perc if var == "`outcome'" &    ///
        degree == "`degree'", fcolor(none) lcolor(red))                 ///
        (bar coef perc if var == "`outcome'" & degree == "`degree'",    ///
        fcolor(none) lcolor(black) barw(0.5)),                          ///
        legend(order(2 "Point estimate" 1 "95% CI")                     ///
        region(lwidth(none)) position(bottom) rows(1))                  ///
        xlabel(1(1)3,val) xscale(range(0, 4)) `ranges'                  ///
        graphregion(color(white)) ytitle({&beta},                       ///
        orientation(horizontal)) xtitle(Percentile, m(medsmall))        ///
        yline(0) saving(`outcome'_`degree', replace)

	}

	grc1leg area1_`degree'.gph area3_`degree'.gph area4_`degree'.gph    ///
    area5_`degree'.gph area6_`degree'.gph area8_`degree'.gph            ///
    area9_`degree'.gph, legendfrom(area1_`degree'.gph) rows(3) holes(7) ///
    imargin(medium) note(`plot_note', size(vsmall))

	graph play "${graphs}\areas.grec"

	graph export "${graphs}\RIF\RIF_areas_`degree'.png", replace

}

*!rmdir "${graphs}\RIF\temps"  /s /q // Erase all temp graphs
