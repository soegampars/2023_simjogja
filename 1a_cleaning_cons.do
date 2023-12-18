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


foreach kab in kotajogja sleman bantul kulonprogo gunungkidul{
	forval year = 2019/2020{
		
		*******************
		** JENIS KELAMIN **
		*******************

		/*
		import delimited "$raw/jk_`kab'_`year'_2.csv", clear

		renvars l p lp \ cons_gender_male cons_gender_female population

		tempfile jk_`kab'
		save `jk_`kab''
		*/

		import delimited "$raw/usia_`kab'_`year'_2.csv", varn(1) clear

		replace jk = subinstr(jk, " ", "", .)
		replace kelurahan = subinstr(kelurahan, " ", "", .)
		replace kelurahan = subinstr(kelurahan, "-", "", .)

		replace jk = "male" if jk == "L"
		replace jk = "female" if jk == "P"
		replace jk = "total" if jk == "L+P"

		renvars v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 keatas \ 		///
				cons_age_0_4 cons_age_5_9 cons_age_10_14 cons_age_15_19 cons_age_20_24 		///
				cons_age_25_29 cons_age_30_34 cons_age_35_39 cons_age_40_44 cons_age_45_49 	///
				cons_age_50_54 cons_age_55_59 cons_age_60_64 cons_age_65_69 cons_age_70_74 	///
				cons_age_75_79 cons_age_80plus

		drop if jk == "total"
		egen cons_gender_ = rowtotal(cons_age_15_19-cons_age_80plus)
		drop cons_age_*

		reshape wide cons_gender_, i(kecamatan kelurahan) j(jk) string

		tempfile jk_`kab'
		save `jk_`kab''

		export delimited "$clean/jk_`kab'_`year'_2.csv", replace

		*******************
		** KELOMPOK USIA **
		*******************
		import delimited "$raw/usia_`kab'_`year'_2.csv", varn(1) clear

		replace jk = subinstr(jk, " ", "", .)
		replace kelurahan = subinstr(kelurahan, " ", "", .)
		replace kelurahan = subinstr(kelurahan, "-", "", .)

		replace jk = "male" if jk == "L"
		replace jk = "female" if jk == "P"
		replace jk = "total" if jk == "L+P"

		renvars v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 keatas \ 		///
				cons_age_0_4 cons_age_5_9 cons_age_10_14 cons_age_15_19 cons_age_20_24 		///
				cons_age_25_29 cons_age_30_34 cons_age_35_39 cons_age_40_44 cons_age_45_49 	///
				cons_age_50_54 cons_age_55_59 cons_age_60_64 cons_age_65_69 cons_age_70_74 	///
				cons_age_75_79 cons_age_80plus

		keep if jk == "total"
		drop jk

		drop cons_age_0_4 cons_age_5_9 cons_age_10_14 

		tempfile usia_`kab'
		save `usia_`kab''

		export delimited "$clean/usia_`kab'_`year'_2.csv", replace

		*********************
		** JENIS PEKERJAAN **
		*********************
		import delimited "$raw/occ_`kab'_`year'_2.csv", clear

		keep kecamatan kelurahan v31 *_lp

		replace kelurahan = subinstr(kelurahan, " ", "", .)
		replace kelurahan = subinstr(kelurahan, "-", "", .)

		egen cons_occ_nonlf = rowtotal(mengurusrumahtangga_lp pelajarmahasiswa_lp pensiunan_lp)
		gen cons_occ_unemployed = belumbekerja_lp
		gen cons_occ_entre = wiraswasata_lp
		egen cons_occ_public = rowtotal(asn_lp pejabatnegara_lp)
		egen cons_occ_tnipolri = rowtotal(tni_lp polri_lp)
		egen cons_occ_formal = rowtotal(buruhtukangberkeahliankhusus_lp karyawanbumnbumd_lp karyawanswasta_lp tenagamedis_lp)
		gen cons_occ_agri = v31
		gen cons_occ_others = pekerjaanlainnya_lp

		keep kecamatan kelurahan cons_occ_*

		tempfile cons_occ_`kab'
		save `cons_occ_`kab''

		export delimited "$clean/occ_`kab'_`year'_2.csv", replace

		************************
		** TINGKAT PENDIDIKAN **
		************************
		import delimited "$raw/educ_`kab'_`year'_2.csv", clear

		keep kecamatan kelurahan *_lp

		replace kelurahan = subinstr(kelurahan, " ", "", .)
		replace kelurahan = subinstr(kelurahan, "-", "", .)

		egen cons_educ_nonsd = rowtotal(tidaksekolah_lp belumtamatsdmi_lp)

		renvars 	tamatsdmi_lp smpmts_lp smasmkma_lp diplomaiii_lp 		///
					akademidplmiiismud_lp diplomaivstratai_lp strataii_lp 	///
					strataiii_lp \ cons_educ_sd cons_educ_smp cons_educ_sma cons_educ_d2		///
					cons_educ_d3 cons_educ_s1 cons_educ_s2 cons_educ_s3

		egen cons_educ_dipl 	= rowtotal(cons_educ_d2 cons_educ_d3)
		egen cons_educ_s1up 	= rowtotal(cons_educ_s1 cons_educ_s2 cons_educ_s3)

		drop cons_educ_d2 cons_educ_d3 cons_educ_s1 cons_educ_s2 cons_educ_s3

		keep kecamatan kelurahan cons_educ_*

		export delimited "$clean/educ_`kab'_`year'_2.csv", replace

		foreach x in jk usia cons_occ{
			
			merge 1:1 kecamatan kelurahan using ``x'_`kab'', nogen
			
		}

		// drop population
		
		generate kab = "`kab'"
		
		tempfile 	cons_`kab'_`year'
		save 		`cons_`kab'_`year''
		export delimited $clean/cons_`kab'_`year'_2, replace
		
	}
}

forval year = 2019/2020{
	
import delimited "$clean/cons_gunungkidul_`year'_2.csv", clear
	
	foreach kab in kotajogja sleman bantul kulonprogo{
	
	append using `cons_`kab'_`year''

}

		replace kecamatan = strltrim(kecamatan)
		egen id = group(kelurahan kecamatan)
		gen weightsid = "weights"+string(id)
		
		order weightsid id kelurahan kecamatan kab
		export delimited $clean/cons_diy_`year'_2, replace
}

		keep weightsid id kelurahan kecamatan kab
		save $clean/identifier_kelurahan, replace
