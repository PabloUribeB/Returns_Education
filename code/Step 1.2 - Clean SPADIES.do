/*************************************************************************
 *************************************************************************			       	
	        SPADIES cleaning
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: September 2022

3) Objective: Clean higher education data
           
4) Output:    - SPADIES_limpia_01_08.dta

*************************************************************************
*************************************************************************/	
clear all



****************************************************************************
**#         1. Loop through SPADIES years
****************************************************************************

forval year = 2001/2015 {
	
	dis as err "SPADIES `year'"
	use "${data}\SPADIES\SPADIES_Completa_`year'", clear
	
	bys id_persona: gen n = _N
	egen primiparo  = rowmin(prim_sem_p prim_sem_i)
	egen fecha_grad = rowmin(grado_per_p grado_per_i)
	bys id_persona: egen minima_carrera = min(primiparo)
	
	drop if minima_carrera < 20011
	
	collapse (min) primiparo fecha_grad (first) ies programa_nombre     ///
        prog_nivel prog_nucleo e_graduado_pr area*, by(id_persona)
	
	tempfile spadies_`year'
	
	save `spadies_`year'', replace
	
}

clear all
forval year = 2001/2015 {
	
	append using  `spadies_`year''
	
}

replace programa_nombre = stritrim(programa_nombre)
replace programa_nombre = strtrim(programa_nombre)


** Keep the program that the student started first (if multiple degrees)
tempvar x raro
bys id_persona: egen `x' = min(primiparo)
gsort id_persona primiparo
gen `raro' = (primiparo == `x')
keep if `raro' == 1


** Keep the degree from which student graduated first. If graduation date is the
** same, keep the highest level degree (professional). If same type of degree in
** several institutions, keep the one he graduated from
bys id_persona: egen x = min(fecha_grad)
gen raro = (fecha_grad == x)

gen nivel = 1 if substr(programa_nombre, 1, 3) == "TEC" |   ///
                 substr(programa_nombre, 1, 2) == "TP"
    
replace nivel = 2 if substr(programa_nombre, 1, 3) == "LIC"
replace nivel = 3 if mi(nivel) & !mi(programa_nombre)

bys id_persona: egen max_nivel = max(nivel)
bys id_persona: egen mean_raro = mean(raro)

drop if raro == 0

keep if nivel == max_nivel

bys id_persona programa_nombre: gen n = _N
bys id_persona: egen maxi = max(n)

drop if n != maxi

bys id_persona: egen max_grad = max(e_graduado_pr)

keep if e_graduado_pr == max_grad


** Keep unique student observations with the date they started college, date of
** graduation, type of degree and whether they graduated or not

collapse (mean) primiparo fecha_grad e_graduado_pr (firstnm) ies nivel      ///
    prog_nucleo programa_nombre area*, by(id_persona)
    

labvars area1 area2 area3 area4 area5 area6 area7 area8 area9               ///
"Agronomia, veterinaria y afines" "Bellas artes" "Ciencias de la educacion" ///
"Ciencias de la salud" "Ciencias sociales y humanas"                        ///
"Economia, administracion, contaduria y afines"                             ///
"Humanidades y ciencias religiosas"                                         ///
"Ingenieria, arquitectura, urbanismo y afines"                              ///
"Matematicas y ciencias naturales"

compress

save "${data}\SPADIES_limpia_01_08.dta", replace

