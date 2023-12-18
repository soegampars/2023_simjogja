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

import delimited $clean/target_diy_2020_2, clear

** Checking the correlation between the constraint and target variables

foreach x of varlist target_incomedecrease target_sector target_income target_informal target_workhours target_useinternet target_wfh{
	
	reg `x' 	cons_educ_nonsd cons_educ_sd cons_educ_smp cons_educ_sma cons_educ_dipl cons_educ_s1up 	///
				cons_gender_male cons_gender_female 							///
				cons_age_0_4 cons_age_5_9 cons_age_10_14 cons_age_15_19 		///
				cons_age_20_24 cons_age_25_29 cons_age_30_34 cons_age_35_39 	///
				cons_age_40_44 cons_age_45_49 cons_age_50_54 cons_age_55_59 	///
				cons_age_60_64 cons_age_65_69 cons_age_70_74 cons_age_75_79 	///
				cons_age_80plus cons_occ_agri cons_occ_entre cons_occ_public 	///
				cons_occ_formal cons_occ_tnipolri cons_occ_nonlf 				///
				cons_occ_unemployed, robust											

}

foreach x of cons_occ_agri cons_occ_entre cons_occ_public cons_occ_formal cons_occ_tnipolri cons_occ_nonlf cons_occ_unemployed{
	
	
	
	
}

** Statistically checking the correlation between target variables

import delimited $clean/collapsed_kotajogja_2020_2.csv, clear

forval sect = 1/17{
	
	reg target_sector_`sect' target_income target_incomedecrease target_informal target_prakerjatraining target_quit_prop target_tempunemp_prop target_unemployed target_useinternet target_wfh target_whchange_prop target_workhours, robust
	
}
