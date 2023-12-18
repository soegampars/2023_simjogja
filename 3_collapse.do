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

******************************************


import delimited $clean/reshaped_diy_2020_2.csv, clear

replace target_earnings = . if target_working != 1

la de status 1 "Berusaha sendiri" 2 "Berusaha dibantu pekerja tidak tetap/pekerja keluarga/tidak dibayar" 3 "Berusaha dibantu pekerja tetap dan dibayar" 4 "Buruh/karyawan/pegawai" 5 "Pekerja bebas di pertanian" 6 "Pekerja bebas di nonpertanian" 7 "Pekerja keluarga/tidak dibayar"

la val target_jobstatus status

la de sector 1  "Agriculture, Forestry and Fishing" 2  "Mining and Quarrying" 3  "Manufacturing" 4  "Electricity and Gas" 5  "Water, Sewerage, Waste" 6  "Construction" 7  "Wholesale and Retail Trade; Repair of Motor" 8  "Transportation and Storage" 9  "Accommodation and Food Service Activities" 10 "Information and Communication" 11 "Financial and Insurance Activities" 12 "Real Estate Activities" 13 "Business Activities" 14 "Public Administration and Defence; Compulsory" 15 "Education" 16 "Human Health and Social Work Activities" 17 "Other Services Activities"

la val cat_sector sector

merge m:1 id using $clean/identifier_kelurahan, nogen

forval x = 1/17{
	
	gen cat_sector_`x' = cat_sector == `x'
		replace cat_sector_`x' = . if target_working !=1
}

forval x = 1/7{
	
	gen target_jobstatus_`x' = target_jobstatus == `x'
		replace target_jobstatus_`x' = . if target_working !=1
		
}

collapse (mean) cat_sector_* target_jobstatus_* target_workhours target_earnings target_wfh target_internet target_prakerja target_earnings_decr target_workhours_decr target_workhours_decr_covid target_unemp target_working target_tafw target_lf target_informal target_underemp target_tafw_cov target_womenwork target_youthwork (first) kelurahan [pw=weights], by(id)


/*
foreach x of varlist target_tempunemp target_whchange target_quit {
	
	gen `x'_prop = `x'_covid/`x'
	
	drop `x' `x'_covid
}
*/

sort id
merge m:1 id using $clean/identifier_kelurahan, nogen

drop weightsid

replace kelurahan = "BANGUNJIWO" if kelurahan == "BANGUJIWO"
replace kelurahan = "BOTODAYAKAN" if kelurahan == "BOTODAYAAN"
replace kelurahan = "CATURHARJO" if kelurahan == "CATUHARJO"
replace kelurahan = "GLAGAHHARJO" if kelurahan == "GLAGAHARJO"
replace kelurahan = "JAMBIDAN" if kelurahan == "JAMBITAN"
replace kelurahan = "JEPITU" if kelurahan == "JEPUTI"
replace kelurahan = "KARANGWARU" if kelurahan == "KARANGAWARU"
replace kelurahan = "KEPUHHARJO" if kelurahan == "KEPUHARJO"
replace kelurahan = "NGLORA" if kelurahan == "NGLORO"
replace kelurahan = "SAMBIREJO" if kelurahan == "SEMIBIREJO"
replace kelurahan = "SIDOKARTO" if kelurahan == "SIDOKERTO"
replace kelurahan = "SUMBERRAHAYU" if kelurahan == "SUMBERAHAYU"
replace kelurahan = "TIRTARAHAYU" if kelurahan == "TIRTORAHAYU"
replace kelurahan = "TIRTOHARGO" if kelurahan == "TIRTOHARJO"

renvars cat_sector_* target_jobstatus_* target_workhours target_earnings target_wfh target_internet target_prakerja target_earnings_decr target_workhours_decr target_workhours_decr_covid target_unemp target_working target_tafw target_lf target_informal target_underemp target_tafw_cov target_womenwork target_youthwork, postfix(_2020)

gen join = kelurahan+"_"+kecamatan

export delimited $clean/collapsed_diy_2020_2.csv, replace

tempfile data2020
save `data2020'

****************************

import delimited $clean/reshaped_diy_2019_2.csv, clear

replace target_earnings = . if target_working != 1

la de status 1 "Berusaha sendiri" 2 "Berusaha dibantu pekerja tidak tetap/pekerja keluarga/tidak dibayar" 3 "Berusaha dibantu pekerja tetap dan dibayar" 4 "Buruh/karyawan/pegawai" 5 "Pekerja bebas di pertanian" 6 "Pekerja bebas di nonpertanian" 7 "Pekerja keluarga/tidak dibayar"

la val target_jobstatus status

la de sector 1  "Agriculture, Forestry and Fishing" 2  "Mining and Quarrying" 3  "Manufacturing" 4  "Electricity and Gas" 5  "Water, Sewerage, Waste" 6  "Construction" 7  "Wholesale and Retail Trade; Repair of Motor" 8  "Transportation and Storage" 9  "Accommodation and Food Service Activities" 10 "Information and Communication" 11 "Financial and Insurance Activities" 12 "Real Estate Activities" 13 "Business Activities" 14 "Public Administration and Defence; Compulsory" 15 "Education" 16 "Human Health and Social Work Activities" 17 "Other Services Activities"

la val cat_sector sector

merge m:1 id using $clean/identifier_kelurahan, nogen

forval x = 1/17{
	
	gen cat_sector_`x' = cat_sector == `x'
		replace cat_sector_`x' = . if target_working !=1
}

forval x = 1/7{
	
	gen target_jobstatus_`x' = target_jobstatus == `x'
		replace target_jobstatus_`x' = . if target_working !=1
		
}

collapse (mean) target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp cat_sector_* target_jobstatus_* target_womenwork target_youthwork (first) kelurahan [pw=weights], by(id)

/*
foreach x of varlist target_tempunemp target_whchange target_quit {
	
	gen `x'_prop = `x'_covid/`x'
	
	drop `x' `x'_covid
}
*/

sort id
merge m:1 id using $clean/identifier_kelurahan, nogen

drop weightsid

replace kelurahan = "BANGUNJIWO" if kelurahan == "BANGUJIWO"
replace kelurahan = "BOTODAYAKAN" if kelurahan == "BOTODAYAAN"
replace kelurahan = "CATURHARJO" if kelurahan == "CATUHARJO"
replace kelurahan = "GLAGAHHARJO" if kelurahan == "GLAGAHARJO"
replace kelurahan = "JAMBIDAN" if kelurahan == "JAMBITAN"
replace kelurahan = "JEPITU" if kelurahan == "JEPUTI"
replace kelurahan = "KARANGWARU" if kelurahan == "KARANGAWARU"
replace kelurahan = "KEPUHHARJO" if kelurahan == "KEPUHARJO"
replace kelurahan = "NGLORA" if kelurahan == "NGLORO"
replace kelurahan = "SAMBIREJO" if kelurahan == "SEMIBIREJO"
replace kelurahan = "SIDOKARTO" if kelurahan == "SIDOKERTO"
replace kelurahan = "SUMBERRAHAYU" if kelurahan == "SUMBERAHAYU"
replace kelurahan = "TIRTARAHAYU" if kelurahan == "TIRTORAHAYU"
replace kelurahan = "TIRTOHARGO" if kelurahan == "TIRTOHARJO"

renvars target_workhours target_earnings target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork cat_sector_* target_jobstatus_*, postfix(_2019)

gen join = kelurahan+"_"+kecamatan

export delimited $clean/collapsed_diy_2019_2.csv, replace

*******

import delimited $clean/reshaped_diy_2019_2.csv, clear

replace target_earnings = . if target_working != 1

la de status 1 "Berusaha sendiri" 2 "Berusaha dibantu pekerja tidak tetap/pekerja keluarga/tidak dibayar" 3 "Berusaha dibantu pekerja tetap dan dibayar" 4 "Buruh/karyawan/pegawai" 5 "Pekerja bebas di pertanian" 6 "Pekerja bebas di nonpertanian" 7 "Pekerja keluarga/tidak dibayar"

la val target_jobstatus status

la de sector 1  "Agriculture, Forestry and Fishing" 2  "Mining and Quarrying" 3  "Manufacturing" 4  "Electricity and Gas" 5  "Water, Sewerage, Waste" 6  "Construction" 7  "Wholesale and Retail Trade; Repair of Motor" 8  "Transportation and Storage" 9  "Accommodation and Food Service Activities" 10 "Information and Communication" 11 "Financial and Insurance Activities" 12 "Real Estate Activities" 13 "Business Activities" 14 "Public Administration and Defence; Compulsory" 15 "Education" 16 "Human Health and Social Work Activities" 17 "Other Services Activities"

la val cat_sector sector

merge m:1 id using $clean/identifier_kelurahan, nogen

forval x = 1/17{
	
	gen cat_sector_`x' = cat_sector == `x'
		replace cat_sector_`x' = . if target_working !=1
}

forval x = 1/7{
	
	gen target_jobstatus_`x' = target_jobstatus == `x'
		replace target_jobstatus_`x' = . if target_working !=1
		
}

/*
Scenario 1: Bottom 50% workers in Accommodation and Food Service sector by earnings lose all their income
Scenario 2: All workers above 50 y.o. lose all their income

SCRAPPED
Scenario 3: All informal workers by earnings have their income halved
Reason: All informal workers has their income zeroed by BPS
*/


// Scenario 1
xtile sect9_earnings_quantile = target_earnings if cat_sector == 9 & target_earnings>0

gen earnings_wi1 = target_earnings 
	replace earnings_wi1 = 0 if sect9_earnings_quantile == 1

// Scenario 2
gen above50 = cons_age_50_54 == 1 | cons_age_55_59 == 1 | cons_age_60_64 == 1 | cons_age_65_69 == 1 | cons_age_70_74 == 1 | cons_age_75_79 == 1
gen earnings_wi2 = target_earnings
	replace earnings_wi2 = 0 if above50 == 1

sum target_earnings earnings_wi*
	
collapse (mean) target_earnings earnings_* (first) kelurahan [pw=weights], by(id)

sum target_earnings earnings_wi*

/*
foreach x of varlist target_tempunemp target_whchange target_quit {
	
	gen `x'_prop = `x'_covid/`x'
	
	drop `x' `x'_covid
}
*/

sort id
merge m:1 id using $clean/identifier_kelurahan, nogen

drop weightsid

replace kelurahan = "BANGUNJIWO" if kelurahan == "BANGUJIWO"
replace kelurahan = "BOTODAYAKAN" if kelurahan == "BOTODAYAAN"
replace kelurahan = "CATURHARJO" if kelurahan == "CATUHARJO"
replace kelurahan = "GLAGAHHARJO" if kelurahan == "GLAGAHARJO"
replace kelurahan = "JAMBIDAN" if kelurahan == "JAMBITAN"
replace kelurahan = "JEPITU" if kelurahan == "JEPUTI"
replace kelurahan = "KARANGWARU" if kelurahan == "KARANGAWARU"
replace kelurahan = "KEPUHHARJO" if kelurahan == "KEPUHARJO"
replace kelurahan = "NGLORA" if kelurahan == "NGLORO"
replace kelurahan = "SAMBIREJO" if kelurahan == "SEMIBIREJO"
replace kelurahan = "SIDOKARTO" if kelurahan == "SIDOKERTO"
replace kelurahan = "SUMBERRAHAYU" if kelurahan == "SUMBERAHAYU"
replace kelurahan = "TIRTARAHAYU" if kelurahan == "TIRTORAHAYU"
replace kelurahan = "TIRTOHARGO" if kelurahan == "TIRTOHARJO"

gen join = kelurahan+"_"+kecamatan

// export delimited $clean/collapsed_diy_2019_2.csv, replace
export delimited $clean/whatif.csv, replace

*****
import delimited $clean/whatif.csv, clear

tempfile data_whatif
save `data_whatif'

import delimited $clean/collapsed_diy_2020_2.csv, clear

tempfile data2020
save `data2020'

import delimited $clean/collapsed_diy_2019_2.csv, clear

merge 1:1 join using `data2020', nogen
merge 1:1 join using `data_whatif', nogen

foreach x in target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork{
	
	replace `x'_2019 = `x'_2019*100
	replace `x'_2020 = `x'_2020*100

}

foreach x of varlist cat_sector_* target_jobstatus_* {
	
	replace `x' = `x'*100
	
}

foreach x in target_workhours target_unemp target_working target_tafw target_lf target_informal target_underemp target_womenwork target_youthwork{
	
	gen `x'_diff = `x'_2020 - `x'_2019
	
}

forval x = 1/7 {
	
	gen target_jobstatus_`x'_diff = target_jobstatus_`x'_2020 - target_jobstatus_`x'_2019
	
}

	gen target_earndiffpc = ((target_earnings_2020 - target_earnings_2019)/target_earnings_2019)*100

forval x = 1/2{
	
	gen target_earndiffwi`x' = ((earnings_wi`x' - target_earnings_2019)/target_earnings_2019)*100	
	
}

export delimited $clean/collapsed_diy.csv, replace

