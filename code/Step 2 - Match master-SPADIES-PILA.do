/*************************************************************************
 *************************************************************************			       	
	        Match SPADIES - PILA
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: September 2022

3) Objective: Match higher education data with master sample and labor market
           
4) Output:    - Base_final_balanceo_semestral.dta

*************************************************************************
*************************************************************************/	
clear all

****************************************************************************
* Globals
****************************************************************************

global master_vars calendario_a cole_academico cole_cod_icfes               ///
    estu_carrdeseada_cod estu_depto_presentacion estu_reside_mcpio female   ///
    jornada_completa paga_pension punt_biologia punt_filosofia punt_fisica  ///
    punt_idioma punt_interdisciplinar punt_lenguaje punt_matematicas        ///
    punt_quimica divipola areas_lora nbi_2005 incidenciah prop_nevera       ///
    prop_lavadora prop_ducha prop_licuadora prop_horno prop_pc              ///
    prop_hayactivecon prop_energia prop_alcantarillado prop_acueducto       ///
    prop_gas prop_telefono

****************************************************************************
**#         1. Import ID crosswalk dataset
****************************************************************************

use estu_consecutivo Periodo_Saber11 ID_SPADIES documento using ///
    "${data}\Final_Llaves.dta", clear

destring Periodo_Saber11, replace

keep if Periodo_Saber11 <= 20082

gen d_docu = (!mi(documento))

tab d_docu


/*
     d_docu |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  1,223,861       29.89       29.89
          1 |  2,871,203       70.11      100.00
------------+-----------------------------------
      Total |  4,095,064      100.00
	  
*/


** Drop SPADIES duplicates with duplicates IDs. Keep the earliest Saber 11 test

gduplicates tag ID_SPADIES, gen(dup)

bys ID_SPADIES: gegen dist = nvals(documento), missing

gsort ID_SPADIES -documento

bys ID_SPADIES: replace documento = documento[_n - 1] if mi(documento) &    ///
    !mi(ID_SPADIES)

** count if mi(documento) should be = 1187267
bys ID_SPADIES: gegen min_s11 = min(Periodo_Saber11) if !mi(documento) &    ///
    !mi(ID_SPADIES)

gen inconsistencia = (dist >= 2 & !mi(dist))

drop if Periodo_Saber11 != min_s11 & !mi(min_s11)

drop dup* min_s11

** For those in SPADIES without documento, drop duplicates of ID_SPADIES using
** the first Saber 11

bys ID_SPADIES: gegen min_s11 = min(Periodo_Saber11) if mi(documento) &     ///
    !mi(ID_SPADIES)

drop if Periodo_Saber11 != min_s11 & !mi(min_s11)

** count if mi(ID_SPADIES) should be = 2052484
gduplicates tag ID_SPADIES Periodo_Saber11 if !mi(ID_SPADIES), gen(dup2)

drop if dup2 != 0 & !mi(dup2)

bys documento: gegen max_sp = max(ID_SPADIES) if !mi(documento)

drop if mi(ID_SPADIES) & !mi(max_sp)

drop dist inconsistencia min_s11 dup*

bys documento: gegen min_s11 = min(Periodo_Saber11) if !mi(documento)

drop if Periodo_Saber11 != min_s11 & !mi(min_s11)

compress

rename ID_SPADIES id_persona

drop max_sp min_s11

****************************************************************************
**#                 2. Merge to SPADIES and master
****************************************************************************

merge m:1 id_persona using "${data}\SPADIES_limpia_01_08", keep(1 3)    ///
    gen(SPADIES)

replace SPADIES = 0 if SPADIES == 1
replace SPADIES = 1 if SPADIES == 3

label def SPADIES 0 "No SPADIES" 1 "Si SPADIES"
label val SPADIES SPADIES

replace e_graduado_pr = 1 if e_graduado_pr == 0 & !mi(fecha_grad)
replace e_graduado_pr = 0 if SPADIES == 0

merge 1:1 estu_consecutivo using "${data}\Maestra_2001_2008_limpia",    ///
    keepusing(${master_vars}) keep(3) nogen

keep if !mi(documento)

rename documento identif

** Randomly drop cedula duplicates to match 1:m to PILA
set seed 1

gen u = runiform()

sort u

duplicates drop identif, force

replace punt_idioma = "" if punt_idioma == "*"
destring punt_idioma, replace dpcomma

egen punt_global = rowtotal(punt_biologia punt_matematicas punt_filosofia  ///
    punt_fisica punt_quimica punt_lenguaje punt_interdisciplinar           ///
    punt_idioma), missing

merge 1:m identif using "${crosswalk}\personabasicaid_all", keep(1 3)   ///
    gen(m_personabasica) nolabel

** Generate negative personabasicaid for unmatched. This guarantees they won't
** match to PILA but will be balanced separately
bys personabasicaid: gen n = - _n if mi(personabasicaid)

replace personabasicaid = n if mi(personabasicaid)

drop n u


****************************************************************************
**#                 3. Merge to PILA
****************************************************************************

merge 1:m personabasicaid using "${data}\PILA_master_semester", keep(1 3)   ///
    gen(m_pila) nolabel

rename m_pila formal

replace m_personabasica = 0 if m_personabasica == 1
replace m_personabasica = 1 if m_personabasica == 3

replace formal = 0 if formal == 1
replace formal = 1 if formal == 3

replace half_pila = yh(2008, 1) if mi(half_pila)

compress

save "${data}\Base_final_semestral.dta", replace


****************************************************************************
**#                 4. Balance panel
****************************************************************************

drop half_pila salario_ultimo_obs salario_mediano ultimo_mes salario_medio  ///
    dias_ultimo_obs dias_medianos dias_medios

gduplicates drop personabasicaid, force

/* bys personabasicaid: gen n = _n
keep if n == 1
drop n */

* 24 semesters between 2008-1 and 2019-2
expand 24

bys personabasicaid: gen half_pila = (_n - 1) + yh(2008, 1)

format half_pila %th

drop m_personabasica

merge 1:1 personabasicaid half_pila using "${data}\Base_final_semestral.dta"

drop nivel m_personabasica

label drop _merge


****************************************************************************
**#                 5. Create relevant variables
****************************************************************************

gen     nivel = 1 if substr(programa_nombre, 1, 3) == "TEC" |   ///
        substr(programa_nombre, 1, 2) == "TP"
        
replace nivel = 2 if substr(programa_nombre, 1, 3) == "LIC"
replace nivel = 3 if mi(nivel) & !mi(programa_nombre)

gen SPADIES_tyt  = (nivel == 1)
gen SPADIES_prof = (nivel == 2 | nivel == 3)

labvars nivel id_persona SPADIES formal                             ///
    "1: TyT; 2: Licenciatura; 3: Profesional" "ID SPADIES"          ///
    "Pegó (1) o no con SPADIES (0)" "Pegó (1) o no con PILA (0)"

drop _merge

** Formality
bys personabasicaid half_pila: gegen formalidad = max(formal)
replace formalidad = 0 if formalidad == .

replace dias_ultimo_obs = 0 if dias_ultimo_obs == .

replace ultimo_mes = 1 if ultimo_mes == .

** Replace salario = ., formality and days = 0 for those with wage = 0 
** (tipo cotizante 40 - Beneficiario UPC Adicional)
replace formalidad         = 0 if salario_ultimo_obs == 0
replace dias_ultimo_obs    = 0 if salario_ultimo_obs == 0
replace salario_ultimo_obs = . if salario_ultimo_obs == 0

** Create indicator for first labor market year
tostring fecha_grad, replace

gen grado_year = substr(fecha_grad, 1, 4)
gen grado_half = substr(fecha_grad, 5, 1)

destring grado_half grado_year fecha_grad, replace

gen fecha_grado_semestre = yh(grado_year, grado_half)

format fecha_grado_semestre %th

drop grado_year grado_half

** Get the difference between half PILA and grado half. Only for those who 
** graduated >= 2008-1 for whom we see the immediate labor semesters
gen delta = half_pila - fecha_grado_semestre if             ///
    fecha_grado_semestre >= yh(2008, 1) & !mi(fecha_grado_semestre)

local i = 1
forvalues x = 97(1)116 {
    
    replace delta = `i' if half_pila == `x' & (SPADIES == 0 |   ///
        mi(fecha_grado_semestre))
    local ++i
    
}

gen     laboral_1     = 1 if inrange(delta, 1, 2)
replace laboral_1     = 1 if inrange(half_pila, 97, 98) &       ///
        fecha_grado_semestre < 96 & !mi(fecha_grado_semestre)

gen     flexibles_1   = 1 if inrange(half_pila, 97, 98) &       ///
        (fecha_grado_semestre < 96 & !mi(fecha_grado_semestre)

gen     laboral_2_5   = 1 if inrange(delta, 3, 10)
replace laboral_2_5   = 1 if inrange(half_pila, 99, 106) &      ///
        (fecha_grado_semestre < 96 & !mi(fecha_grado_semestre)

gen     flexibles_2_5 = 1 if inrange(half_pila, 99, 106) &      ///
        (fecha_grado_semestre < 96 & !mi(fecha_grado_semestre)

gen     laboral_6_10 = 1 if inrange(delta, 11, 20)
replace laboral_6_10 = 1 if inrange(half_pila, 107, 116) &      ///
        (fecha_grado_semestre < 96 & !mi(fecha_grado_semestre)

gen     flexibles_6_10 = 1 if inrange(half_pila, 107, 116) &    ///
        (fecha_grado_semestre < 96 & !mi(fecha_grado_semestre)

** Variables for regressions

tostring Periodo_Saber11, replace

gen year_sb11 = substr(Periodo_Saber11, 1, 4)

destring Periodo_Saber11 year_sb11, replace

** Standardize overall score
local gen gen
foreach t in 20011 20012 20021 20022 20031 20032 20041 20042 20051  ///
20052 20061 20062{
    
    qui sum punt_global if Periodo_Saber11 == `t'
    `gen' punt_global_z = (punt_global - r(mean)) / r(sd) if    ///
          Periodo_Saber11 == `t'
    
    local gen replace
}

drop punt_global

gen grado      = (e_graduado_pr == 1 & SPADIES == 1)
gen incompleto = (e_graduado_pr == 0 & SPADIES == 1)


foreach area in area1 area2 area3 area4 area5 area6 area7 area8 area9 {
    
    replace `area' = 0 if mi(`area')
    
}


** Clean the program names and the program codes
replace programa_nombre = subinstr(programa_nombre, "Á", "A", .)
replace programa_nombre = subinstr(programa_nombre, "É", "E", .)
replace programa_nombre = subinstr(programa_nombre, "Í", "I", .)
replace programa_nombre = subinstr(programa_nombre, "Ó", "O", .)
replace programa_nombre = subinstr(programa_nombre, "Ú", "U", .)

** Make prog_nucleo consistent with what the dictionary has
replace prog_nucleo = mod(prog_nucleo, 10)  if strlen(string(prog_nucleo)) == 2
replace prog_nucleo = mod(prog_nucleo, 100) if strlen(string(prog_nucleo)) == 3

replace prog_nucleo = . if programa_nombre != "ENFERMERIA" &    ///
        prog_nucleo == 41
        
replace prog_nucleo = 66 if prog_nucleo == 59 &                 ///
        programa_nombre == "PSICOLOGIA"
        
replace prog_nucleo = 9 if prog_nucleo == 11 &                  ///
        programa_nombre == "ADMINISTRACION DE EMPRESAS"

** Impute code to the ones with missing values based on those with exact same
** name but assigned code
bys programa_nombre: ereplace prog_nucleo = max(prog_nucleo)

replace prog_nucleo = 12 if programa_nombre == "CONTADURIA PUBLICA"
replace prog_nucleo = 7  if programa_nombre == "DISEÑO INDUSTRIAL"
replace prog_nucleo = 42 if programa_nombre == "TERAPIA FISICA"
replace prog_nucleo = 58 if programa_nombre == "TECNOLOGIA EN DEPORTE"

*** STEM variables
gen STEM = (inrange(prog_nucleo,19,50) | inrange(prog_nucleo,1,3))

gen STEM_prof = (STEM == 1 & SPADIES_prof == 1)
gen STEM_tyt  = (STEM == 1 & SPADIES_tyt  == 1)

gen no_STEM = ((inrange(prog_nucleo, 4, 18) | prog_nucleo > 50) &   ///
    !mi(prog_nucleo))

gen no_STEM_prof = (no_STEM == 1 & SPADIES_prof == 1)
gen no_STEM_tyt  = (no_STEM == 1 & SPADIES_tyt  == 1)

gen grado_tyt       = (grado == 1 & SPADIES_tyt  == 1)
gen incompleto_tyt  = (grado == 0 & SPADIES_tyt  == 1)
gen grado_prof      = (grado == 1 & SPADIES_prof == 1)
gen incompleto_prof = (grado == 0 & SPADIES_prof == 1)

** Generate average school's score
destring cole_cod_icfes, replace

drop if mi(cole_cod_icfes)

** No year before 2001, so average excluding the respective observation
gegen total = total(punt_global_z) if year_sb11 == 2001, by(cole_cod_icfes)
gegen n = count(punt_global_z) if year_sb11 == 2001, by(cole_cod_icfes)

gen totalMINUSi = total - cond(mi(punt_global_z), 0, punt_global_z) if  ///
    year_sb11 == 2001
    
gen meanMINUSi = totalMINUSi / (n - !mi(punt_global_z)) if year_sb11 == 2001

drop total n totalMINUSi

rename meanMINUSi puntajes_2001

bys cole_cod_icfes: gegen puntajes_2002 = mean(punt_global_z *  ///
    inrange(Periodo_Saber11, 20011, 20012))
    
bys cole_cod_icfes: gegen puntajes_2003 = mean(punt_global_z *  ///
    inrange(Periodo_Saber11, 20021, 20022))
    
bys cole_cod_icfes: gegen puntajes_2004 = mean(punt_global_z *  ///
    inrange(Periodo_Saber11, 20031, 20032))
    
bys cole_cod_icfes: gegen puntajes_2005 = mean(punt_global_z *  ///
    inrange(Periodo_Saber11, 20041, 20042))
    
bys cole_cod_icfes: gegen puntajes_2006 = mean(punt_global_z *  ///
    inrange(Periodo_Saber11, 20051, 20052))

gen puntaje_colegio = .

foreach year in 2001 2002 2003 2004 2005 2006 {
    
	replace puntajes_`year' = . if puntajes_`year' == 0
	replace puntaje_colegio = puntajes_`year' if year_sb11 == `year'
    
}

drop puntajes_*

** For those with gaps, use the last available score
bys cole_cod_icfes (Periodo_Saber11): replace puntaje_colegio =     ///
    puntaje_colegio[_n - 1] if mi(puntaje_colegio)

replace estu_depto_presentacion = "ATLANTICO"   if      ///
        estu_depto_presentacion == "ATLNTICO"
        
replace estu_depto_presentacion = "BOGOTA"      if      ///
        estu_depto_presentacion == "BOGOT"
        
replace estu_depto_presentacion = "BOLIVAR"     if      ///
        estu_depto_presentacion == "BOLVAR"
        
replace estu_depto_presentacion = "BOYACA"      if      ///
        estu_depto_presentacion == "BOYAC"
        
replace estu_depto_presentacion = "CHOCO"       if      ///
        estu_depto_presentacion == "CHOC"
        
replace estu_depto_presentacion = "CORDOBA"     if      ///
        estu_depto_presentacion == "CRDOBA"
        
replace estu_depto_presentacion = "GUAINA"      if      ///
        estu_depto_presentacion == "GUAINIA"
        
replace estu_depto_presentacion = "NARIO"       if      ///
        estu_depto_presentacion == "NARIÑO"
        
replace estu_depto_presentacion = "QUINDIO"     if      ///
        inlist(estu_depto_presentacion, "QUINDO", "QUINDaaIO")
        
replace estu_depto_presentacion = "SAN ANDRES"  if      ///
        estu_depto_presentacion == "SAN ANDRS"
        
replace estu_depto_presentacion = "VAUPES"      if      ///
        estu_depto_presentacion == "VAUPS"


** Generate coefficient of variation

reg salario_ultimo_obs half_pila

predict yhat, xb

gen CV = abs((salario_ultimo_obs - yhat)) / yhat

compress

save "${data}\Base_final_balanceo_semestral.dta", replace


** Erase massive files that are no longer necessary
erase "${data}\Base_final_semestral.dta"
erase "${data}\PILA_master_semester.dta"

