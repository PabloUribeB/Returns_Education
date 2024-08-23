/*************************************************************************
 *************************************************************************			       	
	        Returns to education replication do file
			 
1) Created by: Pablo Uribe
			   Yale University
			   p.uribe@yale.edu
				
2) Date: July 2024

3) Objective: Replicate all the paper's exhibits. Exact replicability is
              ensured by using constant packages versions
              
*************************************************************************
*************************************************************************/	

version 17
set graphics off

cap which repkit  
if _rc == 111{
    ssc install repkit
}

****************************************************************************
* Globals
****************************************************************************
* Set path for original datasets in BanRep
if "`c(hostname)'" == "SM201439" global pc "C:"
else global pc "\\sm093119"


global data      "${pc}\Proyectos\Banrep research\f_ReturnsToEducation\Data"
global pila_og   "\\sm134796\D\Originales\PILA\1.Pila mensualizada\PILA mes cotizado"
global ipc       "\\sm037577\D\Proyectos\Banrep research\c_2018_SSO Servicio Social Obligatorio\Project SSO Training\Data"
global crosswalk "\\sm037577\F\personabasicaid_all_projects\Bases insumos"


* Set path to reproducibility package (where ado and code are located)
if inlist("`c(username)'", "Pablo Uribe", "pu42") {
    
    global root	    "~\Documents\GitHub\Returns_Education"
    
}
else {
    
    global root	 "Z:\Christian Posso\_banrep_research\proyectos\Returns_Education"
    
}

cap mkdir "${root}\Logs"
cap mkdir "${root}\Tables"
cap mkdir "${root}\Graphs"
cap mkdir "${root}\Output"
cap mkdir "${root}\ado"

* Point adopath to the ado folder in the reproducibility package
repado, adopath("${root}\ado") mode(strict)

* Folders within rep package
global do_files "${root}\code"
global tables   "${root}\Tables"
global graphs   "${root}\Graphs"
global logs     "${root}\Logs"
global output   "${root}\Output"

****************************************************************************
* Run all do files
****************************************************************************

*do "${do_files}\Step 1.1 - Clean master.do"
*do "${do_files}\Step 1.2 - Clean SPADIES.do"
*do "${do_files}\Step 1.3 Clean PILA.do"
*do "${do_files}\Step 2 - Match master-SPADIES-PILA.do"
do "${do_files}\Step 4 - Main estimations.do"
do "${do_files}\Step 4.1 - City estimations.do"
do "${do_files}\Step 4.2 - RIF regressions.do"
do "${do_files}\Step 5 - Main plots.do"
do "${do_files}\Step 5.1 - City plots.do"
do "${do_files}\Step 5.2 - RIF plots.do"