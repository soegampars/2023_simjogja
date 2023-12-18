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

use $raw/sak_2020_2, clear

	gen weight = FINAL_WEIG

gen kabkot = (KODE_PROV*100)+KODE_KAB
keep if KODE_PROV == 34

** Other Target Variables

gen target_jobstatus 	= R12A
	replace target_jobstatus = . if R12A == 0
gen target_workhours 	= R16A
	replace target_workhours = . if R16A == 0
gen target_earnings		= R14A1+R14A2

gen cat_sector 		= R13A_KATEG
	replace cat_sector = . if R13A_KATEG == 0

gen target_wfh 			= R18A == 1
	replace target_wfh 	= . if R18A == 0	
gen target_internet 	= R17A == 1
	replace target_internet = . if R17A == 0
gen target_prakerja 	= R27E == 1
	replace target_prakerja = . if R27E == 0
gen target_earnings_decr	= R14B == 2
	replace target_earnings_decr = . if inlist(R14B,0,4)
gen target_workhours_decr	= R16B == 2
	replace target_workhours_decr = . if inlist(R16B,0,4)
gen target_workhours_decr_covid	= R16D == 1
	replace target_workhours_decr_covid = . if R16D == 0

la var target_jobstatus 		"What is your job status?"
la var target_workhours 		"Work hrs during the last week"
la var target_earnings			"Earnings (money+goods)"
la var target_wfh 				"Whether workplace implement WFH"
la var target_internet 		"Whether resp. use internet for work"
la var target_prakerja 			"Whether resp. participated in Prakerja training scheme"
la var target_earnings_decr		"Whether resp. experienced decreased earning compared to Feb 2020"
la var target_workhours_decr	"Whether resp. experienced decreased work hours compared to Feb 2020"
la var target_workhours_decr_covid	"Whether decreased work hours is due to COVID-19 related reasons"

/*
** Not Labour Force

/*
Definition:
1. penduduk usia kerja (15 tahun dan lebih) 
2. masih sekolah ATAU
3. mengurus rumah tangga ATAU
4. melaksanakan kegiatan lainnya selain kegiatan pribadi..
*/

gen target_notlf = R31A == 1 | R31B == 1 | R31C == 1

la var target_notlf "Whether resp. is not included in the labour force"
*/

** Unemployment

/*
Definition:
1. Mereka yang tak punya pekerjaan dan mencari pekerjaan.
2. Mereka yang tak punya pekerjaan dan mempersiapkan usaha.
3. Mereka yang tak punya pekerjaan dan tidak mencari pekerjaan, karena merasa tidak mungkin mendapatkan pekerjaan.
4. Mereka yang sudah punya pekerjaan, tetapi belum mulai bekerja.
*/

gen target_unemp = 0
	replace target_unemp = 1 if R9A == 2 & R22A == 1
	replace target_unemp = 1 if R9A == 2 & R22B == 1
	replace target_unemp = 1 if R9A == 2 & R22A == 1 & R25A == 3
	replace target_unemp = 1 if inlist(R25A,1,2)
// 	replace target_unemp = . if target_notlf == 1

la var target_unemp "Whether resp. is unemployed"


** Working

/*
Definition:
1. paling sedikit 1 jam (tidak terputus) dalam seminggu yang lalu
*/

gen target_working = R9A == 1 & target_workhours >= 1
// 	replace target_working = . if target_notlf == 1
	replace target_working = 0 if inlist(R25A,1,2)

la var target_working "Whether resp. is working"


** Temporarily Absent from Work

/*
Definition:
1. seseorang yang mempunyai pekerjaan tetapi selama seminggu yang lalu sementara tidak bekerja karena berbagai sebab
*/

gen target_tafw = R10A == 1
// 	replace target_tafw = . if target_notlf == 1
	replace target_unemp = 0 if target_tafw == 1

la var target_tafw "Whether resp. is temporarily absent from work"

** Labour Force

/*
Definition:
1. penduduk usia kerja (15 tahun dan lebih) 
2. bekerja ATAU punya pekerjaan namun sementara tidak bekerja
3. pengangguran
*/

gen target_lf = 0
	replace target_lf = 1 if target_unemp	== 1
	replace target_lf = 1 if target_working	== 1
	replace target_lf = 1 if target_tafw	== 1
	replace target_unemp = . if target_lf == 0
	replace target_working = . if target_lf == 0
	replace target_tafw = . if target_lf == 0
	
la var target_lf "Whether resp. is part of the labour force"

** Informal Workers

/*
Status Pekerjaan:
1. berusaha sendiri
2. berusaha dibantu buruh tidak tetap/buruh tak dibayar
3. pekerja bebas
4. pekerja keluarga/tak dibayar.
*/

gen target_informal = target_working == 1 & inlist(target_jobstatus,1,2,5,6,7)
	replace target_informal = . if target_lf == 0 | target_unemp == 1

la var target_informal "Whether resp. is an informal worker"

** Underemployment
/*
Definition:
1. bekerja...
2. ...di bawah jam kerja normal (kurang dari 35 jam seminggu)
3. masih mencari pekerjaan ATAU masih bersedia menerima pekerjaan
*/

gen target_underemp = target_working == 1 & target_workhours < 35 & R26 == 1
	replace target_underemp = 1 if target_working == 1 & target_workhours < 35 & R22A == 1
	replace target_underemp = . if target_working == 0

// sum target_informal target_underemp [fw=weight]

** Target Variables Adjustment

// replace target_earnings		= . if target_unemp == 1
// replace target_earnings		= . if target_lf == 0
replace target_earnings		= 0 if target_earnings == .

gen target_earnings_wi	= R14A1+R14A2
	replace target_earnings_wi = R14A1+R14A2+1000000 if target_working == 0 & R29A == 1 & R30B == 1

replace target_wfh 			= . if target_working == 0
replace target_internet 	= . if target_working == 0

gen target_tafw_cov 		= target_tafw == 1 & R10C == 1
	replace target_tafw_cov = . if target_tafw == 0
	replace target_tafw_cov = . if R10C == 0

la var target_tafw_cov 			"Whether resp. temporarily absent from work due to COVID"

** Constraints: Age

gen cons_age_15_19 	= inrange(K6,15,19)
gen cons_age_20_24 	= inrange(K6,20,24)
gen cons_age_25_29 	= inrange(K6,25,29)
gen cons_age_30_34 	= inrange(K6,30,34)
gen cons_age_35_39 	= inrange(K6,35,39)
gen cons_age_40_44 	= inrange(K6,40,44)
gen cons_age_45_49 	= inrange(K6,45,49)
gen cons_age_50_54 	= inrange(K6,50,54)
gen cons_age_55_59 	= inrange(K6,55,59)
gen cons_age_60_64 	= inrange(K6,60,64)
gen cons_age_65_69 	= inrange(K6,65,69)
gen cons_age_70_74 	= inrange(K6,70,74)
gen cons_age_75_79 	= inrange(K6,75,79)
gen cons_age_80plus 	= inrange(K6,80,.)

** Constraints: Gender

gen cons_gender_male 	= K4 == 1
gen cons_gender_female 	= K4 == 2

** Constraints: Education Level

gen cons_educ_sd 	= R6A == 2
gen cons_educ_smp	= R6A == 3
gen cons_educ_sma	= inrange(R6A,4,5)
gen cons_educ_dipl 	= R6A == 6
gen cons_educ_s1up 	= inrange(R6A,7,8)
gen cons_educ_nonsd 	= R6A == 1

** Constraints: Job Type

gen cons_occ_nonlf 		= target_lf == 0
gen cons_occ_unemployed = target_unemp == 1

gen cons_occ_tnipolri	= target_lf == 1 & target_unemp == 0 & R13B_KBJI2==0
gen cons_occ_public 	= target_lf == 1 & target_unemp == 0 & cat_sector == 14
	replace cons_occ_public = 0 if cons_occ_tnipolri == 1
gen cons_occ_agri		= target_lf == 1 & target_unemp == 0 & cat_sector == 1
gen cons_occ_entre		= target_lf == 1 & target_unemp == 0 & inlist(target_jobstatus,1,2,3)
	replace cons_occ_entre = 0 if cons_occ_agri == 1
gen cons_occ_formal 	= target_lf == 1 & target_unemp == 0 & inlist(target_jobstatus,4,6)
	replace cons_occ_formal = 0 if cons_occ_tnipolri == 1
	replace cons_occ_formal = 0 if cons_occ_public == 1
	replace cons_occ_formal = 0 if cons_occ_agri == 1
gen cons_occ_others = target_lf == 1 & target_unemp == 0 & inlist(target_jobstatus,7)

** Target: Women Working
gen target_womenwork = K4 == 2 & target_working == 1
		replace target_womenwork =  . if target_lf == 0 | target_unemp == 1

** Target: Youth Working (below 30)
gen target_youthwork = K6 < 30 & target_working == 1
		replace target_youthwork =  . if target_lf == 0 | target_unemp == 1

	keep cons_* target_* cat_* weight kabkot

	gen year = 2020
	
	save $clean/target_diy_2020_2, replace
	
	drop year weight kabkot
	
	export delimited $clean/target_diy_2020_2, replace

	drop target_* cat_sector

	export delimited $clean/ind_diy_2020_2, replace

**********
** 2019 **
**********

use $raw/sak_2019_2, clear

	gen weight = weightr_sp

gen kabkot = (kode_prov*100)+kode_kab
keep if kode_prov == 34

** Other Target Variables

gen target_jobstatus 	= b5_r24a
	replace target_jobstatus = . if b5_r24a == 0
gen target_workhours 	= b5_r23a
	replace target_workhours = . if b5_r23a == 0
gen target_earnings		= b5_r28b1+b5_r28b2
	replace target_earnings = b5_r28c1 + b5_r28c2
	
gen target_earnings_wi = b5_r28b1+b5_r28b2

gen cat_sector 		= b5_r20_kat
	replace cat_sector = . if b5_r20_kat == 0

la var target_jobstatus 		"What is your job status?"
la var target_workhours 		"Work hrs during the last week"
la var target_earnings			"Earnings (money+goods)"

/*
** Not Labour Force

/*
Definition:
1. penduduk usia kerja (15 tahun dan lebih) 
2. masih sekolah ATAU
3. mengurus rumah tangga ATAU
4. melaksanakan kegiatan lainnya selain kegiatan pribadi..
*/

gen target_notlf = R31A == 1 | R31B == 1 | R31C == 1

la var target_notlf "Whether resp. is not included in the labour force"
*/

** Unemployment

/*
Definition:
1. Mereka yang tak punya pekerjaan dan mencari pekerjaan.
2. Mereka yang tak punya pekerjaan dan mempersiapkan usaha.
3. Mereka yang tak punya pekerjaan dan tidak mencari pekerjaan, karena merasa tidak mungkin mendapatkan pekerjaan.
4. Mereka yang sudah punya pekerjaan, tetapi belum mulai bekerja.
*/

gen target_unemp = 0
	replace target_unemp = 1 if b5_r5a1 == 2 & b5_r12a == 1
	replace target_unemp = 1 if b5_r5a1 == 2 & b5_r12b == 1
	replace target_unemp = 1 if b5_r5a1 == 2 & b5_r12a == 1 & b5_r17a == 3
	replace target_unemp = 1 if inlist(b5_r17a,1,2)
// 	replace target_unemp = . if target_notlf == 1

la var target_unemp "Whether resp. is unemployed"


** Working

/*
Definition:
1. paling sedikit 1 jam (tidak terputus) dalam seminggu yang lalu
*/

gen target_working = b5_r5a1 == 1 & target_workhours >= 1
// 	replace target_working = . if target_notlf == 1
	replace target_working = 0 if inlist(b5_r17a,1,2)

la var target_working "Whether resp. is working"


** Temporarily Absent from Work

/*
Definition:
1. seseorang yang mempunyai pekerjaan tetapi selama seminggu yang lalu sementara tidak bekerja karena berbagai sebab
*/

gen target_tafw = b5_r6 == 1
// 	replace target_tafw = . if target_notlf == 1
	replace target_unemp = 0 if target_tafw == 1

la var target_tafw "Whether resp. is temporarily absent from work"

** Labour Force

/*
Definition:
1. penduduk usia kerja (15 tahun dan lebih) 
2. bekerja ATAU punya pekerjaan namun sementara tidak bekerja
3. pengangguran
*/

gen target_lf = 0
	replace target_lf = 1 if target_unemp	== 1
	replace target_lf = 1 if target_working	== 1
	replace target_lf = 1 if target_tafw	== 1
	replace target_unemp = . if target_lf == 0
	replace target_working = . if target_lf == 0
	replace target_tafw = . if target_lf == 0
	
la var target_lf "Whether resp. is part of the labour force"

// tab2 target_lf target_unemp target_working target_tafw

** Informal Workers

/*
Status Pekerjaan:
1. berusaha sendiri
2. berusaha dibantu buruh tidak tetap/buruh tak dibayar
3. pekerja bebas
4. pekerja keluarga/tak dibayar.
*/

gen target_informal = target_working == 1 & inlist(target_jobstatus,1,2,5,6,7)
	replace target_informal = . if target_lf == 0 | target_unemp == 1

la var target_informal "Whether resp. is an informal worker"

** Underemployment
/*
Definition:
1. bekerja...
2. ...di bawah jam kerja normal (kurang dari 35 jam seminggu)
3. masih mencari pekerjaan ATAU masih bersedia menerima pekerjaan
*/

gen target_underemp = target_working == 1 & target_workhours < 35 & b5_r18a == 1
	replace target_underemp = 1 if target_working == 1 & target_workhours < 35 & b5_r12a == 1
	replace target_underemp = . if target_working == 0

// sum target_informal target_underemp [fw=weight]

** Target Variables Adjustment

// replace target_earnings		= . if target_unemp == 1
// replace target_earnings		= . if target_lf == 0
replace target_earnings		= 0 if target_earnings == .

** Constraints: Age

gen cons_age_15_19 	= inrange(b4_k8,15,19)
gen cons_age_20_24 	= inrange(b4_k8,20,24)
gen cons_age_25_29 	= inrange(b4_k8,25,29)
gen cons_age_30_34 	= inrange(b4_k8,30,34)
gen cons_age_35_39 	= inrange(b4_k8,35,39)
gen cons_age_40_44 	= inrange(b4_k8,40,44)
gen cons_age_45_49 	= inrange(b4_k8,45,49)
gen cons_age_50_54 	= inrange(b4_k8,50,54)
gen cons_age_55_59 	= inrange(b4_k8,55,59)
gen cons_age_60_64 	= inrange(b4_k8,60,64)
gen cons_age_65_69 	= inrange(b4_k8,65,69)
gen cons_age_70_74 	= inrange(b4_k8,70,74)
gen cons_age_75_79 	= inrange(b4_k8,75,79)
gen cons_age_80plus 	= inrange(b4_k8,80,.)

** Constraints: Gender

gen cons_gender_male 	= b4_k6 == 1
gen cons_gender_female 	= b4_k6 == 2

** Constraints: Education Level

gen cons_educ_sd 	= inrange(b5_r1a,2,4)
gen cons_educ_smp	= inrange(b5_r1a,5,7)
gen cons_educ_sma	= inrange(b5_r1a,8,11)
gen cons_educ_dipl 	= inrange(b5_r1a,12,13)
gen cons_educ_s1up 	= inrange(b5_r1a,14,16)
gen cons_educ_nonsd 	= b5_r1a == 1

** Constraints: Job Type

gen cons_occ_nonlf 		= target_lf == 0
gen cons_occ_unemployed = target_unemp == 1

gen cons_occ_tnipolri	= target_lf == 1 & target_unemp == 0 & b5_r21_kbj==0
gen cons_occ_public 	= target_lf == 1 & target_unemp == 0 & cat_sector == 14
	replace cons_occ_public = 0 if cons_occ_tnipolri == 1
gen cons_occ_agri		= target_lf == 1 & target_unemp == 0 & cat_sector == 1
gen cons_occ_entre		= target_lf == 1 & target_unemp == 0 & inlist(target_jobstatus,1,2,3)
	replace cons_occ_entre = 0 if cons_occ_agri == 1
gen cons_occ_formal 	= target_lf == 1 & target_unemp == 0 & inlist(target_jobstatus,4,6)
	replace cons_occ_formal = 0 if cons_occ_tnipolri == 1
	replace cons_occ_formal = 0 if cons_occ_public == 1
	replace cons_occ_formal = 0 if cons_occ_agri == 1
gen cons_occ_others = target_lf == 1 & target_unemp == 0 & inlist(target_jobstatus,7)

/*
gen check = 0

foreach x of varlist cons_occ*{
    
	replace check = 1 if `x' == 1
	
}

tab check
*/

** Target: Women Working
gen target_womenwork = b4_k6 == 2 & target_working == 1
		replace target_womenwork =  . if target_lf == 0 | target_unemp == 1

** Target: Youth Working (below 30)
gen target_youthwork = b4_k8 < 30 & target_working == 1
		replace target_youthwork =  . if target_lf == 0 | target_unemp == 1

	keep cons_* target_* cat_* weight kabkot

	gen year = 2019
	
	save $clean/target_diy_2019_2, replace
	
	drop year weight kabkot
	
	export delimited $clean/target_diy_2019_2, replace

	drop target_* cat_sector

	export delimited $clean/ind_diy_2019_2, replace