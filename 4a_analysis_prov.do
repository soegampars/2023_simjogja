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

use $clean/target_diy_2020_2, clear

append using $clean/target_diy_2019_2

drop cons_*

save $clean/analysis_diy, replace

** PROVINCE-WIDE ANALYSIS

	** General

		collapse (mean) target_lf target_informal target_underemp target_unemp target_earnings target_workhours [pw=weight], by(year)

		
	** Sectoral -- Share

		use $clean/analysis_diy, clear
		
		collapse (sum) target_working [pw=weight], by(cat_sector year)
		
		bysort year: egen total_working = total(target_working)
		drop if cat_sector == .
		
		gen share = target_working/total_working

	** Sectoral -- Changes

		use $clean/analysis_diy, clear

		collapse (sum) target_working (mean) target_earnings target_workhours target_underemp [pw=weight], by(cat_sector year)

		drop if cat_sector == .

		reshape wide target_working target_earnings target_workhours target_underemp, i(cat_sector) j(year)

		foreach x in target_working target_earnings target_workhours {
			
			gen `x'_diff = `x'2020-`x'2019
			
		}

		foreach x in target_working target_earnings target_workhours {
			
			gen `x'_diffperc = (`x'2020-`x'2019)/`x'2019
			
		}

		gen target_underemp_diff = target_underemp2020-target_underemp2019

		keep cat_sector *_diff *_diffperc