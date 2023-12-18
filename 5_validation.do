clear
set more off

local datestamp : di %tdCYND daily("$S_DATE", "DMY")

global suser = c(username)

if (inlist("${suser}","satya")) {
	cd "C:\Users\satya\OneDrive\WORKBENCH\Personal Study\1B - Thesis\proposals\spatialmicrosim"
}

global output	"output"
global dofile	"dofile"
global raw		"raw"
global clean	"clean"

**************

**********
** 2019 **
**********

import delimited $clean/reshaped_diy_2019_2.csv, clear

destring target_* cat_sector, replace force

keep target_jobstatus cat_sector target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork weights

forval x = 1/7{
	
	gen target_jobstatus`x' = target_jobstatus == `x'
		replace target_jobstatus`x' = . if target_jobstatus == .
}

forval x = 1/17{
	
	gen cat_sector`x' = cat_sector == `x'
		replace cat_sector`x' = . if cat_sector == .
}


collapse (mean) target_jobstatus* cat_sector* target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork [pw=weights]

****

use $clean/target_diy_2019_2, clear

keep target_jobstatus cat_sector target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork weight

forval x = 1/7{
	
	gen target_jobstatus`x' = target_jobstatus == `x'
		replace target_jobstatus`x' = . if target_jobstatus == .
}

forval x = 1/17{
	
	gen cat_sector`x' = cat_sector == `x'
		replace cat_sector`x' = . if cat_sector == .
}

collapse (mean) target_jobstatus* cat_sector* target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork [fw=weight]

**********
** 2020 **
**********

import delimited $clean/reshaped_diy_2020_2.csv, clear

destring target_* cat_sector, replace force

keep target_jobstatus cat_sector target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork weights

forval x = 1/7{
	
	gen target_jobstatus`x' = target_jobstatus == `x'
		replace target_jobstatus`x' = . if target_jobstatus == .
}

forval x = 1/17{
	
	gen cat_sector`x' = cat_sector == `x'
		replace cat_sector`x' = . if cat_sector == .
}


collapse (mean) target_jobstatus* cat_sector* target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork [pw=weights]

****

use $clean/target_diy_2020_2, clear

keep target_jobstatus cat_sector target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork weight

forval x = 1/7{
	
	gen target_jobstatus`x' = target_jobstatus == `x'
		replace target_jobstatus`x' = . if target_jobstatus == .
}

forval x = 1/17{
	
	gen cat_sector`x' = cat_sector == `x'
		replace cat_sector`x' = . if cat_sector == .
}

collapse (mean) target_jobstatus* cat_sector* target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork [fw=weight]
