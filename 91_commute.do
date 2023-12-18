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

************************

**********
** 2020 **
**********

/*
use $raw/sak_2020_2, clear

	gen weight = FINAL_WEIG

gen kabkot = (KODE_PROV*100)+KODE_KAB
keep if KODE_PROV == 34

tab R19D [fw=FINAL_WEIG]

replace R19D = . if R19D == 0

tab R19D
*/

use $raw/sak_2019_2, clear

use $raw/sak_2019_2, clear

	gen weight = weightr_sp

gen kabkot = (kode_prov*100)+kode_kab
keep if kode_prov == 34

tab b5_r36c

tab b5_r36c [fw=weightr_sp]

replace R19D = . if R19D == 0

tab R19D