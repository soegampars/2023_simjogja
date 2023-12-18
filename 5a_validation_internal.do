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
global report	"report"

**************

**********
** 2019 **
**********

import delimited $clean/reshaped_diy_2019_2.csv, clear

keep cons_* weights

collapse (sum) cons_* [pw=weights]

gen data = "simulated"

tempfile sim19
save `sim19'

import delimited $clean/reshaped_diy_2020_2.csv, clear

keep cons_* weights

collapse (sum) cons_* [pw=weights]

gen data = "simulated"

tempfile sim20
save `sim20'

use $clean/target_diy_2019_2, clear

keep cons_* weight

collapse (sum) cons_* [pw=weight]

gen data = "sakernas"

tempfile sak19
save `sak19'

use $clean/target_diy_2020_2, clear

keep cons_* weight

collapse (sum) cons_* [pw=weight]

gen data = "sakernas"

foreach x in sim19 sim20 sak19{

append using ``x''	
	
}

export delimited $report/internalvalidation_unedited.csv, replace

****************

import delimited $clean/cons_diy_2019_2.csv, clear

collapse (sum) cons_*

****************

import delimited $report/internalvalidation.csv, clear

scatter sakernas simulated || line sakernas sakernas, sort