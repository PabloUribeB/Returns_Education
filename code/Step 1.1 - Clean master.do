/*************************************************************************
 *************************************************************************			       	
	        Master data processing
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: September 2022

3) Objective: Process original dataset
           
4) Output:    - Maestra_2001_2008_limpia.dta

*************************************************************************
*************************************************************************/	
clear all


****************************************************************************
**#         1. Open and clean data
****************************************************************************

use "${data}\Maestra_Completa_2001_2008.dta", clear

keep if inlist(estu_estudiante, "1", "ESTUDIANTE") | mi(estu_estudiante)

drop cod_idioma cod_interdisciplinar cole_cod_dane_establecimiento          ///
cole_cod_dane_sede cole_cod_depto_ubicacion cole_codigo_icfes               ///
cole_direccion cole_email cole_nombre_establecimiento cole_sede_principal   ///
cole_telefono desemp_ingles desemp_profundiza_biologia                      ///
desemp_profundiza_csociales desemp_profundiza_lenguaje                      ///
desemp_profundiza_matematica estu_alumnosgrupo estu_ano_matricula_primero   ///
estu_ano_matricula_sexto estu_ano_termino_quinto estu_anoprimero            ///
estu_anoquinto estu_anos_colegio_actual estu_anos_preescolar                ///
estu_anoscolegio estu_anosexto estu_anospreescolar estu_anoterminobachiller ///
estu_areareside estu_celular estu_cod_depto_presentacion                    ///
estu_cod_iesdeseada estu_cod_mcpio_presentacion estu_cod_programadeseado    ///
estu_cod_reside_depto estu_cod_sitio_presentacion                           ///
estu_como_capacitoparaexamsb11 estu_correoelectronico                       ///
estu_cuanto_falto_colegio estu_cuantos_cole_estudio estu_depto_reside       ///
estu_direccion estu_direccion_sitio estu_disc_bajavision                    ///
estu_disc_cognitiva estu_disc_invidente estu_disc_motriz                    ///
estu_disc_sordoceguera estu_disc_sordointerprete                            ///
estu_disc_sordonointerprete estu_estadoinvestigacion estu_fecha_nacimiento  ///
estu_fechaactagrado estu_fechanacimiento estu_horassemanatrabaja            ///
estu_iesdeseada estu_limita_bajavision estu_limita_cognitiva                ///
estu_limita_sordoceguera estu_limita_sordoconinterprete                     ///
estu_limita_sordosininterprete estu_mcpio_reside                            ///
estu_motivo_presentavalidacion estu_nacionalidad estu_numeroactagrado       ///
estu_numerocolegios estu_perdiocuarto estu_perdiodecimo estu_perdionoveno   ///
estu_perdiooctavo estu_perdioprimero estu_perdioquinto estu_perdiosegundo   ///
estu_perdioseptimo estu_perdiosexto estu_perdiotercero estu_perdioundecimo  ///
estu_por_amigosestudiando estu_por_influenciaalguien                        ///
estu_por_orientacionvocacional estu_por_otrarazon                           ///
estu_por_tradicionfamiliar estu_por_ubicacion estu_por_unicaqueofrece       ///
estu_prestigioinstitucion estu_programadeseado estu_razon_inst_deseada      ///
estu_razon_prog_deseado estu_razon_retiro estu_razonretirocolegio           ///
estu_reprobo_cuarto estu_reprobo_decimo estu_reprobo_noveno                 ///
estu_reprobo_octavo estu_reprobo_once_mas estu_reprobo_primero              ///
estu_reprobo_quinto estu_reprobo_segundo estu_reprobo_septimo               ///
estu_reprobo_sexto estu_reprobo_tercero estu_retirocolegio                  ///
estu_sitio_presentacion estu_snp estu_telefono estu_tipocarreradeseada      ///
estu_total_alumnos_curso estu_trabajaactualmente estu_valorpensioncolegio   ///
estu_vecespresentoexamen estu_vecespresentoexamenestado                     ///
estu_zona_presentacion fami_cuartoshogar fami_educacion_hermanomayor        ///
fami_educacionmadre fami_educacionpadre fami_estratovivienda                ///
fami_ingresofmiliarmensual fami_nivelsisben fami_ocupacionmadre             ///
fami_ocupacionpadre fami_personashogar fami_pisoshogar fami_telefono        ///
fami_telefono_fijo fami_tiene_acueducto fami_tiene_alcantarillado           ///
fami_tiene_celular fami_tiene_conexionsanitario fami_tiene_energiaelectrica ///
fami_tiene_estufa fami_tiene_nevera fami_tiene_recoleccionbasura            ///
fami_tiene_sanitario fami_tiene_serviciotv fami_tieneautomovil              ///
fami_tienecomputador fami_tienedvd fami_tienehorno fami_tieneinternet       ///
fami_tienelavadora fami_tienemicroondas fami_tienetelevisor                 ///
inad_ingresaprograma inad_ingresobto inad_ingresoprofesional                ///
inad_ingresotecnitecno inad_puntajeingles inad_puntajelenguaje              ///
inad_puntajematematicas inad_razoncarreraeconomica inad_razoncarreraguia    ///
inad_razoncarrerainteres inad_razoncarrerataller inad_razonunivcosto        ///
inad_razonunivempleo inpe_autorizaenvioemail inpe_autorizaenviosms          ///
inpe_celular inpe_direccion inpe_email inpe_telefono inst_cantidadsedes     ///
inst_celular1 inst_celular2 inst_direccion inst_direccioncorrespondencia    ///
inst_email inst_fax inst_fax2 inst_nombredirector inst_paginaweb            ///
inst_telefono1 inst_telefono2 plan_codigodaneinstitucion                    ///
punt_ciencias_sociales punt_ingles punt_interdisc_medioambiente             ///
punt_interdisc_violenciaysoc punt_profundiza_biologia                       ///
punt_profundiza_csociales punt_profundiza_lenguaje punt_profundiza_matematica snp


*** Homogenize variables that change across years
replace fami_ing_fmiliar_mensual        = fami_ingreso_fmiliar_mensual  if mi(fami_ing_fmiliar_mensual)
replace estu_exam_cod_mpio_presentacio  = estu_exam_cod_mpiopresentacio if mi(estu_exam_cod_mpio_presentacio)
replace ind_anno_termino_bachillerato   = inac_anoterminobachiller      if mi(ind_anno_termino_bachillerato)
replace cole_cod_dane_institucion       = codigo_dane                   if mi(cole_cod_dane_institucion)
replace estu_depto_presentacion         = estu_exam_dept_presentacion   if mi(estu_depto_presentacion)
replace estu_reside_depto               = estu_reside_dept_presentacion if mi(estu_reside_depto)
replace estu_reside_mcpio               = estu_reside_mpio_presentacion if mi(estu_reside_mcpio)
replace estu_depto_presentacion         = estu_dept_presentacion        if mi(estu_depto_presentacion)
replace estu_cod_reside_mcpio           = estu_codigo_reside_mcpio      if mi(estu_cod_reside_mcpio)
replace cole_calendario                 = cole_calendario_colegio       if mi(cole_calendario)
replace nombre_interdisciplinar         = interdisciplinar_nombre       if mi(nombre_interdisciplinar)

replace punt_biologia          = biologia_punt          if mi(punt_biologia)
replace fami_ocupa_madre       = fami_ocup_madre        if mi(fami_ocupa_madre)
replace fami_ocupa_padre       = fami_ocup_padre        if mi(fami_ocupa_padre)
replace cole_caracter          = cole_caracter_colegio  if mi(cole_caracter)
replace cole_cod_icfes         = cole_codigo_colegio    if mi(cole_cod_icfes)
replace cole_bilingue          = cole_es_bilingue       if mi(cole_bilingue)
replace cole_genero            = cole_genero_poblacion  if mi(cole_genero)
replace cole_jornada           = cole_inst_jornada      if mi(cole_jornada)
replace cole_nombre_sede       = cole_inst_nombre       if mi(cole_nombre_sede)
replace cole_valor_pension     = cole_inst_vlr_pension  if mi(cole_valor_pension)
replace cole_zona_ubicacion    = cole_zonalocalizacion  if mi(cole_zona_ubicacion)
replace punt_filosofia         = filosofia_punt         if mi(punt_filosofia)
replace punt_fisica            = fisica_punt            if mi(punt_fisica)
replace punt_geografia         = geografia_punt         if mi(punt_geografia)
replace punt_historia          = historia_punt          if mi(punt_historia)
replace desemp_idioma          = idioma_desem           if mi(desemp_idioma)
replace nombre_idioma          = idioma_nombre          if mi(nombre_idioma)
replace punt_idioma            = idioma_punt            if mi(punt_idioma)
replace punt_interdisciplinar  = interdisciplinar_punt  if mi(punt_interdisciplinar)
replace punt_lenguaje          = lenguaje_punt          if mi(punt_lenguaje)
replace punt_matematicas       = matematicas_punt       if mi(punt_matematicas)
replace desemp_comp_flexible   = profundizacion_desem   if mi(desemp_comp_flexible)
replace nombre_profundizacion  = profundizacion_nombre  if mi(nombre_profundizacion)
replace punt_profundizacion    = profundizacion_punt    if mi(punt_profundizacion)
replace punt_quimica           = quimica_punt           if mi(punt_quimica)
replace fami_computador        = econ_sn_computador     if mi(fami_computador)
replace estu_estudiante        = tipo_evaluado          if mi(estu_estudiante)
replace infa_madreleeescribe   = fami_lee_escribe_madre if mi(infa_madreleeescribe)
replace infa_padreleeescribe   = fami_lee_escribe_padre if mi(infa_padreleeescribe)
replace infa_hermanos          = fami_num_hermanos      if mi(infa_hermanos)
replace infa_hermanosestudian  = fami_hermanos_estudian if mi(infa_hermanosestudian)
replace fami_estrato_vivienda  = estu_estrato           if mi(fami_estrato_vivienda)
replace fami_cuartos_hogar     = econ_cuartos           if mi(fami_cuartos_hogar)
replace fami_pisos_hogar       = econ_material_pisos    if mi(fami_pisos_hogar)
replace fami_dormitorios_hogar = econ_dormintorios      if mi(fami_dormitorios_hogar)
replace fami_personas_hogar    = econ_personas_hogar    if mi(fami_personas_hogar)




drop estu_exam_cod_mpiopresentacion biologia_punt codigo_dane               ///
cole_calendario_colegio cole_caracter_colegio cole_codigo_colegio           ///
cole_es_bilingue cole_genero_poblacion cole_inst_jornada                    ///
cole_inst_nombre cole_inst_vlr_pension cole_zonalocalizacion                ///
estu_codigo_reside_mcpio estu_exam_dept_presentacion                        ///
estu_reside_dept_presentacion estu_reside_mpio_presentacion                 ///
filosofia_punt fisica_punt geografia_punt historia_punt idioma_desem        ///
idioma_nombre idioma_punt interdisciplinar_nombre interdisciplinar_punt     ///
lenguaje_punt matematicas_punt profundizacion_desem                         ///
profundizacion_nombre profundizacion_punt quimica_punt econ_sn_computador   ///
tipo_evaluado fami_lee_escribe_madre fami_lee_escribe_padre                 ///
fami_num_hermanos fami_hermanos_estudian estu_estrato econ_cuartos          ///
econ_material_pisos econ_dormintorios econ_personas_hogar                   ///
estu_dept_presentacion fami_ingreso_fmiliar_mensual fami_ocup_madre         ///
fami_ocup_padre estu_limita* fami_cod_educa_madre fami_cod_educa_padre      ///
fami_cod_ocup_madre fami_cod_ocup_padre inac_cursodocentesies               ///
inac_cursoiesexterno inac_cursopregicfes inac_egresadoemestudia             ///
inac_egresadoestudia inac_egresadoestudiacurso inac_egresadoestudiaotro     ///
inac_egresadoestudiaposgrado inac_estudiauniversidad                        ///
inac_fechaactagradobachiller inac_fechatituloprofesional                    ///
inac_gradonormalista inac_idiomahabla inac_idiomalee                        ///
inac_institutopreparacion inac_instterminobto inac_matriculabeca            ///
inac_matriculacredito inac_matriculapadres inac_matriculapropio inac_nis    ///
inac_nivelpostgrado inac_porcentajecreditos inac_refuerzoareas              ///
inac_refuerzogsa inac_semestrecursa inac_semestreexamenestado               ///
inac_terminobachillerato inac_titulo inac_titulobachillerato inac_tomocurso ///
inac_ultimogradoaprobo inac_universidad inac_valormatriculaanterior         ///
infa_hogaractual infa_nivelhermano infa_personasacargo inpe_actividadpano   ///
inpe_comocapacito inpe_estadocivil inpe_motivoexamen                        ///
inpe_municipionacimiento inpe_ocupacion inpe_tipodocsb11 inst_apartadoaereo ///
estu_carrdeseada_tipo estu_carrdeseada_nucleo inac_actadegradobachiller     ///
inac_anoegreso punt_comp_flexible punt_sociales_ciudadanas punt_c_naturales ///
punt_lectura_critica nombre_comp_flexible estu_otra_inst_deseada            ///
estu_por_buscandocarrera estu_por_colombiaaprende estu_por_costomatricula   ///
estu_por_interespersonal estu_por_mejorarposicionsocial                     ///
estu_por_oportunidades estu_privado_libertad estu_programa_academicodeseado ///
estu_recibe_salario estu_retirarse_colegio estu_tipo_carrera_deseada        ///
fami_sost_personal estu_es_validante inac_actividadnocurso                  ///
inac_annoultimogrado inac_anoexamenestado


foreach x of varlist punt* {
    
	replace `x' = "" if `x' == "-1"
	replace `x' = "" if `x' == "-"
	replace `x' = "" if `x' == "---"
	replace `x' = subinstr(`x',".",",",.)
	destring `x', replace dpcomma
    
}


gen     vivienda_propia = 0 if inlist(fami_vivienda_propia, "*", "-", "N")
replace vivienda_propia = 1 if inlist(fami_vivienda_propia, "S", "5")

gen     deuda_vivienda = 0 if inlist(fami_deuda_vivienda, "*", "-", "N")
replace deuda_vivienda = 1 if fami_deuda_vivienda == "S"

** At least one contributor
gen     min_1aportante = 0 if inlist(fami_aportantes, "*", "-", "@", "0")
replace min_1aportante = 1 if inlist(fami_aportantes, "1", "2", "3", "4", "5") ///
        | inlist(fami_aportantes, "6", "7", "8", "9", "+")

** Full schedule
gen     jornada_completa = 0 if inlist(cole_jornada, "2003", "M", "MAANA",  ///
        "MAÑANA", "N", "NOCHE", "S", "SABATINA - DOMINICAL")                ///
        | inlist(cole_jornada, "SABATINA-DOMINICAL", "T", "TARDE")
replace jornada_completa = 1 if inlist(cole_jornada, "C", "COMPLETA U ORDINARIA", "UNICA")

** Pays for school
gen     paga_pension = 0 if (cole_valor_pension == "1" & periodo <= "20042") ///
        | (cole_valor_pension == "0" & periodo >= "20051")
        
replace paga_pension = 1 if (cole_valor_pension != "1" &                    ///
        cole_valor_pension != "" & periodo <= "20042") |                    ///
        (cole_valor_pension != "0" & cole_valor_pension != "" & periodo >= "20051")

** Gender (female = 1)
gen     female = 0 if inlist(estu_genero, "M", "m", "3")
replace female = 1 if estu_genero == "F"

** Reason for IES (Costs, prestige, employment outlooks == 1)
gen     razon_iesdeseada = 0 if estu_razoninstituto != "2" &        ///
        estu_razoninstituto != "3" & estu_razoninstituto != "4" &   ///
        estu_razoninstituto != ""
replace razon_iesdeseada = 1 if inlist(estu_razoninstituto, "2", "3", "4")

** People in HH (5 or more)
gen     mas5_personas = 0 if inlist(fami_personas_hogar, "*", "0", "1", "2", ///
        "3", "4", "@")
replace mas5_personas = 1 if inlist(fami_personas_hogar, "5", "6", "7", "8", ///
        "9", "10", "11", "12")

** Father and mother education (complete or incomplete tertiary)
gen     educa_padre = 0 if inlist(fami_educa_padre, "9", "10", "11", "12",  ///
        "99", "0", "1", "2") | inlist(fami_educa_padre, "3", "4", "5", "S", "@", "*")
replace educa_padre = 1 if inlist(fami_educa_padre, "6", "7", "8", "13",    ///
        "14", "15", "16", "17")

gen     educa_madre = 0 if inlist(fami_educa_madre, "9", "10", "11", "12",  ///
        "99", "0", "1") | inlist(fami_educa_madre, "2", "3", "4", "5", "S", "@", "*")

replace educa_madre = 1 if inlist(fami_educa_madre, "6", "7", "8", "13",    ///
        "14", "15", "16", "17")

** Student works
gen     trabaja = 0 if inlist(estu_trabaja, "N", "0", "@", "*", "+")
replace trabaja = 1 if inlist(estu_trabaja, "S", "1", "2", "3", "4", "5",   ///
        | inlist(estu_trabaja, "6", "7", "8", "9")

** Will study next year
replace estu_act_prox_anno = "" if estu_act_prox_anno == "-"
gen     estudia_proxano = 0 if inlist(estu_act_prox_anno, "*", "1", "N", "P")
replace estudia_proxano = 1 if inlist(estu_act_prox_anno, "1", "T")

** Bilingual school
replace cole_bilingue = "1" if inlist(cole_bilingue, "2", "B")

** Academic school
gen     cole_academico = 0 if inlist(cole_caracter, "DESCONOCIDO",      ///
        "NORMALISTA", "TECNICO")
replace cole_academico = 1 if inlist(cole_caracter, "ACADEMICO",        ///
        "ACADEMICO Y TECNICO")

** A calendar
gen     calendario_a = 0 if inlist(cole_calendario, "B", "F", "3")
replace calendario_a = 1 if cole_calendario == "A"

** High stratum (>3)
gen     estrato = 0 if inlist(cole_calendario, "1", "2", "3", "8")
replace estrato = 1 if inlist(cole_calendario, "4", "5", "6")

** Private school
gen     privado = 0 if cole_naturaleza == "O"
replace privado = 1 if cole_naturaleza == "N"

** Father (mother) reads and writes
gen     padre_lee = 0 if inlist(infa_padreleeescribe, "0", "3", "@", "N", "*")
replace padre_lee = 1 if infa_padreleeescribe == "S"

gen     madre_lee = 0 if inlist(infa_madreleeescribe, "0", "@", "N", "*")
replace madre_lee = 1 if infa_madreleeescribe == "S"

** >=3 siblings
gen     mas3_hermanos = 0 if inlist(infa_hermanos, "0", "1", "2", "*", "@", "+")
replace mas3_hermanos = 1 if inlist(infa_hermanos, "3", "4", "5", "6", "06") ///
        | inlist(infa_hermanos, "7", "8", "9", "10")

** All siblings study
gen     hermanosestudian = 0 if inlist(infa_hermanosestudian, "2", "88")
replace hermanosestudian = 1 if infa_hermanosestudian == "1"

** SISBEN (>=3)
gen     sisben_mas3 = 0 if inlist(fami_nivel_sisben, "1", "2")
replace sisben_mas3 = 1 if inlist(fami_nivel_sisben, "3", "4", "5")

** Monthly HH income
gen     ingreso_mas3 = 1 if (inlist(fami_ing_fmiliar_mensual, "3", "4",     ///
        "5", "6", "7", "8", "9") & periodo <= "20052") |                    ///
        (inlist(fami_ing_fmiliar_mensual, "4", "5", "6", "7") & periodo > "20052")

replace ingreso_mas3 = 0 if (inlist(fami_ing_fmiliar_mensual, "0", "1", "2", ///
        "@", "*", "+") & periodo <= "20052") |                               ///
        (inlist(fami_ing_fmiliar_mensual, "1", "2", "3", "@", "*", "+")      ///
        & periodo > "20052")

** HH floors
gen     piso_madera = "0" if inlist(fami_pisos_hogar, "1", "2", "3")
replace piso_madera = "1" if inlist(fami_pisos_hogar, "4", "5")

** Mobile phone
gen     celular = 0 if fami_celular == "0"
replace celular = 1 if inlist(fami_celular, "2", "1")

** PC
gen     computador = 0 if fami_computador == "0"
replace computador = 1 if inlist(fami_computador, "2", "3", "4", "1")

** DVD
gen     dvd = 0 if fami_dvd == "0"
replace dvd = 1 if inlist(fami_dvd, "2", "1")

** Car
gen     carro = 0 if fami_automovil == "0"
replace carro = 1 if inlist(fami_automovil, "2", "1")

** TV
gen     tv = 0 if fami_televisor == "0"
replace tv = 1 if inlist(fami_televisor, "2", "1")

** Motorcycle
gen     motocicleta = 0 if fami_motocicleta == "0"
replace motocicleta = 1 if inlist(fami_motocicleta, "2", "1")

** Exclusive toilet
gen     sanitario_exclusivo = 0 if fami_sanitario == "0"
replace sanitario_exclusivo = 0 if inlist(fami_sanitario, "1", "2", "3", "4")

** School gender (mixed = 1)
gen     cole_mixto = "0" if inlist(cole_genero, "F", "M")
replace cole_mixto = "1" if cole_genero == "X"


destring fami_internet fami_servicio_television fami_lavadora fami_nevera   ///
fami_horno fami_microondas fami_electricidad fami_acueducto                 ///
fami_alcantarillado fami_aseo fami_estufa cole_bilingue, replace

compress

save "${data}\Maestra_2001_2008_limpia", replace



****************************************************************************
**#         2. Municipalities
****************************************************************************

** Fix state names
use estu_consecutivo estu_reside_mcpio estu_depto_presentacion using    ///
    "${data}\Maestra_2001_2008_limpia", clear

replace estu_depto_presentacion = "ATLANTICO"       if      /// 
        estu_depto_presentacion == "ATLNTICO"
        
replace estu_depto_presentacion = "BOGOTA"          if      /// 
        estu_depto_presentacion == "BOGOT"
        
replace estu_depto_presentacion = "BOLIVAR"         if      /// 
        estu_depto_presentacion == "BOLVAR"
        
replace estu_depto_presentacion = "BOYACA"          if      /// 
        estu_depto_presentacion == "BOYAC"
        
replace estu_depto_presentacion = "CAQUETA"         if      /// 
        estu_depto_presentacion == "CAQUET"
        
replace estu_depto_presentacion = "CORDOBA"         if      /// 
        estu_depto_presentacion == "CRDOBA"
        
replace estu_depto_presentacion = "CHOCO"           if      /// 
        estu_depto_presentacion == "CHOC"
        
replace estu_depto_presentacion = "GUAINIA"         if      /// 
        estu_depto_presentacion == "GUAINA"
        
replace estu_depto_presentacion = "NARIÑO"          if      /// 
        estu_depto_presentacion == "NARIO"
        
replace estu_depto_presentacion = "QUINDIO"         if      /// 
        inlist(estu_depto_presentacion, "QUINDO", "QUINDaaIO")
        
replace estu_depto_presentacion = "SAN ANDRES"      if      /// 
        estu_depto_presentacion == "SAN ANDRS"
        
replace estu_depto_presentacion = "VAUPES"          if      /// 
        estu_depto_presentacion == "VAUPS"
        
replace estu_depto_presentacion = "VALLEDELCAUCA"   if      ///
        estu_depto_presentacion == "VALLE"

foreach x in estu_reside_mcpio estu_depto_presentacion {
    
	replace `x' = subinstr(`x',"Á","A",.)
	replace `x' = subinstr(`x',"É","E",.)
	replace `x' = subinstr(`x',"Í","I",.)
	replace `x' = subinstr(`x',"Ó","O",.)
	replace `x' = subinstr(`x',"Ú","U",.)
	replace `x' = subinstr(`x'," ","",.)
	replace `x' = strupper(`x')
	replace `x' = stritrim(`x')
	replace `x' = strtrim(`x')
    
}

** Fix municipality names
replace estu_reside_mcpio = "VILLADESANDIEGODEUBATE" if ///
        estu_reside_mcpio == "UBATE"
        
replace estu_reside_mcpio = "SANANTONIODELTEQUENDAMA" if ///
        estu_reside_mcpio == "SANANTONIODETEQUENDAMA"
        
replace estu_reside_mcpio = "BOGOTA"                if /// 
        estu_reside_mcpio == "BOGOTAD.C."
        
replace estu_reside_mcpio = "BOGOTA"                if /// 
        estu_reside_mcpio == "BOGOTD.C."
        
replace estu_reside_mcpio = "CHACHAGSI"             if /// 
        estu_reside_mcpio == "CHACHAGUI"
        
replace estu_reside_mcpio = "CIUDADBOLIVAR"         if ///
        inlist(estu_reside_mcpio, "BOLIVAR", "ANTIOQUIA")
        
replace estu_reside_mcpio = "ELCANTONDELSANPABLO"   if /// 
        estu_reside_mcpio == "CANTONDELSANPABLO"
        
replace estu_reside_mcpio = "ELCARMENDEATRATO"      if /// 
        inlist(estu_reside_mcpio, "ELCARMEN", "CHOCO")
        
replace estu_reside_mcpio = "GUACHENE"              if /// 
        estu_reside_mcpio == "GUACHEN"
        
replace estu_reside_mcpio = "GUADALAJARADEBUGA"     if /// 
        estu_reside_mcpio == "BUGA"
        
replace estu_reside_mcpio = "LEGUIZAMO"             if /// 
        estu_reside_mcpio == "PUERTOLEGUIZAMO"
        
replace estu_reside_mcpio = "ELCARMENDEVIBORAL"     if /// 
        estu_reside_mcpio == "CARMENDEVIBORAL"
        
replace estu_reside_mcpio = "ELSANTUARIO"           if /// 
        inlist(estu_reside_mcpio, "SANTUARIO", "ANTIOQUIA")
        
replace estu_reside_mcpio = "MANAURE"               if /// 
        estu_reside_mcpio == "MANAUREBALCONDELCESAR"
        
replace estu_reside_mcpio = "NARIÑO"                if /// 
        estu_reside_mcpio == "NARIO"
        
replace estu_reside_mcpio = "PIJIÑODELCARMEN"       if /// 
        estu_reside_mcpio == "PIJIODELCARMEN"
        
replace estu_reside_mcpio = "PISBA"                 if /// 
        estu_reside_mcpio == "PISVA"
        
replace estu_reside_mcpio = "SANANDRESDETUMACO"     if /// 
        estu_reside_mcpio == "TUMACO"
        
replace estu_reside_mcpio = "SANTAFEDEANTIOQUIA"    if /// 
        estu_reside_mcpio == "SANTAFDEANTIOQUIA"
        
replace estu_reside_mcpio = "SANTIAGODETOLU"        if /// 
        estu_reside_mcpio == "TOLU"
        
replace estu_reside_mcpio = "TUTAZA"                if /// 
        estu_reside_mcpio == "TUTASA"



gen nom_mpio = estu_reside_mcpio + estu_depto_presentacion

replace nom_mpio = ustrregexra(nom_mpio,"\(.+?\)","")

drop if (estu_depto_presentacion == estu_reside_mcpio) &        ///
estu_reside_mcpio != "BOGOTA" & estu_reside_mcpio != "ARAUCA" & ///
estu_reside_mcpio != "BOYACA" & estu_reside_mcpio != "NARIÑO" & ///
estu_reside_mcpio != "SANANDRES" & estu_reside_mcpio != "SUCRE"

*duplicates drop nom_mpio, force

merge m:1 nom_mpio using "${data}\Codigos_dpto_mpio.dta", keep(1 3)     ///
      keepusing(cod_dpto cod_mpio) nogen

keep estu_consecutivo cod_dpto cod_mpio

merge 1:1 estu_consecutivo using "${data}\Maestra_2001_2008_limpia.dta", nogen

gen divipola = string(cod_dpto) + cod_mpio

destring divipola, replace

drop cod_dpto cod_mpio

recode divipola (11001 25286 25200 25473 25377 25099 25486 25793              ///
       25175 25295 25785 25326 25736 25754 25899 25269 25126 25758            ///
       25781 25817 25214 25740 25430 = 1 "Bogotá Met")                        ///
       (5001 5129 5380 5088 5079 5266 5212 5308 5360 5631 = 2 "Medellín Met") ///
       (76001 19845 76364 76275 19573 19513 76892 76563 76869                 ///
            76130 = 3 "Cali met")                                             ///
       (8001 8634 8520 8558 47745 8560 8685 8078 8638 8832 8849 13620 8758    ///
            8573 8433 8296 = 4 "Barranquilla Met")                            ///
       (13001 13683 13052 13222 13838 13836 13873 = 5 "Cartagena Met")        ///
       (68001 68307 68276 68547 = 6 "Bucaramanga Met")                        ///
       (54001 54673 54405 54874 = 7 "Cúcuta Met")                             ///
       (66001 66170 66682 = 8 "Pereira Met")                                  ///
       (15759 15491 15806 15466 15114 15362 15272 15820                       ///
            15215 = 9 "Sogamoso Met")                                         ///
       (5615 5376 5318 5440 5148 = 10 "Rionegro Met")                         ///
       (15001 15204 15187 15500 15476 = 11 "Tunja Met")                       ///
       (63001 63401 63190 63130 = 12 "Armenia Met")                           ///
       (25307 73275 25612 = 13 "Girardot Met")                                ///
       (50001 50606 = 14 "Villavicencio Met")                                 ///
       (17001 17873 = 15 "Manizales Met")                                     ///
       (52001 52480 = 16 "Pasto Met")                                         ///
       (76834 76036 = 17 "Tuluá Met")                                         ///
       (52356 52022 = 18 "Ipiales Met")                                       ///
       (15238 15162 = 19 "Duitama Met")                                       ///
       (73001 = 20 "Ibagué")                                                  ///
       (47001 = 21 "Santa Marta")                                             ///
       (23001 = 22 "Montería")                                                ///
       (20001 = 23 "Valledupar")                                              ///
       (76109 = 24 "Buenaventura")                                            ///
       (41001 = 25 "Neiva")                                                   ///
       (76520 = 26 "Palmira")                                                 ///
       (19001 = 27 "Popayán")                                                 ///
       (70001 = 28 "Sincelejo")                                               ///
       (44001 = 29 "Riohacha")                                                ///
       (68081 = 30 "Barrancabermeja")                                         ///
       (52835 = 31 "San Andres de Tumaco")                                    ///
       (18001 = 32 "Florencia")                                               ///
       (5045 = 33 "Apartadó")                                                 ///
       (44430 = 34 "Maicao")                                                  ///
       (5837 = 35 "Turbo")                                                    ///
       (76147 = 36 "Cartago")                                                 ///
       (85001 = 37 "Yopal")                                                   ///
       (13430 = 38 "Magangué")                                                ///
       (25290 = 39 "Fusagasugá")                                              ///
       (76111 = 40 "Guadalajara de Buga")                                     ///
       (27001 = 41 "Quibdó")                                                  ///
       (23417 = 42 "Lorica")                                                  ///
       (41551 = 43 "Pitalito")                                                ///
       (47189 = 44 "Ciénaga")                                                 ///
       (5154 = 45 "Caucasia")                                                 ///
       (54498 = 46 "Ocaña")                                                   ///
       (20011 = 47 "Aguachica")                                               ///
       (23162 = 48 "Cereté")                                                  ///
       (19698 = 49 "Santander de Quilichao")                                  ///
       (81001 = 50 "Arauca")                                                  ///
       (73268 = 51 "Espinal")                                                 ///
       (17380 = 52 "La Dorada")                                               ///
       (23466 = 53 "Montelíbano")                                             ///
       (13244 = 54 "El Carmen de Bolívar")                                    ///
       (88001 = 55 "San Andrés")                                              ///
       (5172 = 56 "Chigorodó")                                                ///
       (50006 = 57 "Acacías")                                                 ///
       (15176 = 58 "Chiquinquirá")                                            ///
       (70215 = 59 "Corozal")                                                 ///
       (47288 = 60 "Fundación")                                               ///
       (50313 = 61 "Granada")                                                 ///
       (54518 = 62 "Pamplona"), gen(areas_lora)

merge m:1 divipola using "${data}\municipal", keep(1 3)

compress

save "${data}\Maestra_2001_2008_limpia", replace