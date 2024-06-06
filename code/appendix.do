**********************************

/* Outline

1. General 
2. Table A2 - News - Imputation
3. Lee Bounds Calculations
4. Table A3 - Lee Bounds: Test vs. Control
5. Table A4 - Lee Bounds: Video vs. Control
6. Table A5 - Lee Bounds: Both vs. Control

*/


*******************
** 1. GENERAL    **
*******************


** import the data 
import delimited "./data/raw/Round_3(1).csv", clear
save "./data/cleaned/Round_3(1).dta", replace

import delimited "./data/raw/Round_3(2).csv", clear
save "./data/cleaned/Round_3(2).dta", replace

use "./data/cleaned/Round_3(1).dta", clear
append using "./data/cleaned/Round_3(2).dta", force

save "./data/cleaned/dip_third_round", replace


** define treatment variables
global D1 any_form
global D2 any_video
global D3 any_video_form 

** define controls 
global controls age female high_school postgraduate technical_educ undergraduate bog_dept post


** set seed 
set seed 10000


************************************************
** 2. NEWS - IMPUTATION                       **
************************************************


** Access round three of the experiment & clean the relevant variables 


use "./data/cleaned/dip_third_round", clear

* age 
gen age = 2022 - year_of_birth 
label variable age "Age of the participants"

* gender 
replace gender = "male" if gender == "Hombre"
replace gender = "female" if gender == "Mujer"

gen female = . 
replace female = 1 if gender == "female"
replace female = 0 if gender == "male"


* education 
replace education_level = "high_school" if education_level == "Bachillerato"
replace education_level = "postgraduate" if education_level == "Posgrado"
replace education_level = "primary_school" if education_level == "Primaria"
replace education_level = "technical_educ" if education_level == "Técnico / Tecnológico"
replace education_level = "undergraduate" if education_level == "Título universitario"

gen high_school = 0 
replace high_school = 1 if education_level == "high_school"
label variable high_school "Dummy variable for High School education"

gen postgraduate = 0
replace postgraduate = 1 if education_level == "postgraduate"
label variable postgraduate "Dummy variable for postgraduate eduction"

gen technical_educ = 0 
replace technical_educ = 1 if education_level == "technical_educ"
label variable technical_educ "Dummy variable for technical education"

gen undergraduate = 0 
replace undergraduate = 1 if education_level == "undergraduate"
label variable undergraduate "Dummy variable for undergraduate education"


* department
gen bog_dept = 0 
replace bog_dept = 1 if department == "Bogotá D.C."
label variable bog_dept "Dummy variable for Bogotá department"


* variable complete 
replace complete = "1" if complete == "true"
replace complete = "0" if complete == ""
destring complete, replace 


* ID variables ** 
// Note: the variable id_last_four should have 4 digits; however, there are 274 observations that have less than 4 digits; drop these

drop if id_last_four < 999


*****************************
*****************************



** Add the data needed for the imputation


* add additional observations
insobs 1063
gen new_obs = 1 if response_date == ""


*save the mean of the control variables
foreach var in age female high_school postgraduate technical_educ undergraduate bog_dept{
	
	sum `var' if complete == 0
	gen mean_attrition_`var' = r(mean)
	
}


*only leave the newly created observations in the dataset 
keep if new_obs == 1 
keep mean* new_obs


*generate a count variable
gen count = _n 

*rename variables 
rename mean_attrition_age age 
rename mean_attrition_female female 
rename mean_attrition_high_school high_school
rename mean_attrition_postgraduate postgraduate
rename mean_attrition_technical_educ technical_educ
rename mean_attrition_undergraduate undergraduate
rename mean_attrition_bog_dept bog_dept

save "./data/cleaned/dip_third_round_imputation", replace




*****************************
*****************************

** Perform the actual permutation exercise

use "./data/cleaned/dip_first_round.dta", clear

append using "./data/cleaned/dip_third_round_imputation"


* new observations
replace new_obs = 0 if new_obs == .

* post dummy 
replace post = 1 if post == .


* add individuals to each treatment and control group 
replace any_form = 1 if new_obs == 1 & count < 129
replace any_video = 1 if new_obs == 1 & count > 128 & count < 601
replace any_video_form = 1 if new_obs == 1 & count > 600 & count < 1049

replace any_form = 0 if any_form == .
replace any_video = 0 if any_video == . 
replace any_video_form = 0 if any_video_form == . 



*predict the missing values 
foreach var in d_all_fake_reliable ///  
			d_fake_center_reliable ///  
			d_fake_right_reliable /// 
			d_fake_left_reliable ///  
			d_all_true_reliable ///
			d_true_center_reliable /// 
			d_true_right_reliable /// 
			d_true_left_reliable {
    reg `var' $D1 $D2 $D3 $controls if new_obs == 0, vce(robust)
    
    predict `var'_hat
	gen residual_`var' = rnormal(0, e(rmse))
    replace `var' = `var'_hat + residual_`var' if new_obs == 1
   
    drop `var'_hat residual_`var'
}

		
		
*Table 1 News - Imputation
estimates clear 


*regressions
foreach var in d_all_fake_reliable ///  
			d_fake_center_reliable ///  
			d_fake_right_reliable /// 
			d_fake_left_reliable ///  
			d_all_true_reliable ///
			d_true_center_reliable /// 
			d_true_right_reliable /// 
			d_true_left_reliable{
					
	eststo: reg `var' $D1 $D2 $D3 $controls , vce(robust)
	test $D1 = $D2
	estadd scalar tt1 = r(p)
	test $D2 = $D3
	estadd scalar tt2 = r(p)
	sum `var' if $D1 == $D2 == $D3 == 0 
	estadd scalar n1 = r(mean)  
			
	}
			
*tables
esttab using "$dir_output/table_news_imputation.tex", replace ///
	se b(3) ///
	stats(tt1 tt2 n1 N r2,  fmt(%9.3f %9.3f %9.3f %9.0f %9.3f) labels("Test = Video (p)" "Video = Both (p)" "Control Mean" "Observations" "R-Squared")) title("News - Imputation") ///
	mtitles( "All Fake" "Neutral Fake" "Right Fake" "Left Fake" "All True" "Neutral True" "Right True" "Left True") ///
	coeflabels(any_form "Test" any_video "Video" any_video_form "Both") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	keep($D1 $D2 $D3)
	
	
	
	
	
	
	
************************************************
** 3. LEE BOUNDS CALCULATIONS                 **
************************************************	


use "./data/cleaned/dip_first_round.dta", clear




* Rename variables due to character limits
rename any_form D1  
rename any_video D2
rename any_video_form D3

rename d_fake_right_reliable Fake_right
rename d_true_right_reliable True_right
rename d_fake_center_reliable Fake_center
rename d_true_center_reliable True_center
rename d_fake_left_reliable Fake_left
rename d_true_left_reliable True_left
rename d_all_fake_reliable  All_fake
rename d_all_true_reliable All_true 




/*
Treatment 	Pr. Response Clean
Control 	0.98
Test	0.85
Video 	0.46
Both	0.49

*/

*Identified probabilities* 
* Y_i \in {0, 1}: outcome 
* R_i \in {0, 1}: response 
* Z_i \in {0, 1}: treatment assignment: 



*		BOOTSTRAPPING FOR INFERENCE  * 


capture program drop boot_bounds
program define boot_bounds, rclass
    syntax varlist(min=2)
	
	// Extract the outcome and predictor variables
    local outcome : word 1 of `varlist'
	local treatment: word 2 of `varlist'
	local p_D1 = 0.85 
	local p_D2 = 0.46 
	local p_D3 = 0.49 
	
	
    // Perform the regression
    reg `outcome' `treatment'
    
    // Retrieve the coefficients
    scalar beta = _b[`treatment']
    scalar intercept = _b[_cons]
    
    // Calculate probabilities and bounds
    local p_yt = abs(intercept + beta)
    local p_yc = intercept
    
    local p1 = `p_`treatment'' / 0.98
    local p0 = 1 - `p1'
    
    local sigma_lb = max(0, (1/`p1') * `p_yc' - `p0' / `p1')
    local sigma_ub = min(1, (1/`p1') * `p_yc')
    
    local delta_lb = `p_yt' - `sigma_ub'
    local delta_ub = `p_yt' - `sigma_lb'
    
    // Return the calculated values
    return scalar beta = beta
    return scalar delta_lb = `delta_lb'
    return scalar delta_ub = `delta_ub'
end

*return list to see the scalars.


// Bootstrap and save results for D1
foreach var in All_fake Fake_center Fake_right Fake_left All_true True_center True_right True_left {
    bootstrap r(beta) r(delta_lb) r(delta_ub), reps(500) saving("./data/cleaned/boot_test_`var'.dta", replace): boot_bounds `var' D1
}
 

// Bootstrap and save results for D2
foreach var in All_fake Fake_center Fake_right Fake_left All_true True_center True_right True_left {
    bootstrap r(beta) r(delta_lb) r(delta_ub), reps(500) saving("./data/cleaned/boot_video_`var'.dta", replace): boot_bounds `var' D2
}


// Bootstrap and save results for D2
foreach var in All_fake Fake_center Fake_right Fake_left All_true True_center True_right True_left {
    bootstrap r(beta) r(delta_lb) r(delta_ub), reps(500) saving("./data/cleaned/boot_both_`var'.dta", replace): boot_bounds `var' D3
}




************************************************
** 4. LEE BOUNDS: TEST VS. CONTROL            **
************************************************




foreach var in All_fake Fake_center Fake_right Fake_left All_true True_center True_right True_left {
    use "./data/cleaned/boot_test_`var'.dta", clear
	rename _bs_1 beta 
	rename _bs_2 lb
	rename _bs_3 ub
	foreach x in beta lb ub{
		 display "Summary for `var' `x'" 
		 sum `x' 
		 local `x'_`var' = r(mean)
		 local `x'_`var'_se = r(sd)
	}
	
}



* Create a matrix with 2 rows and 2 columns
matrix A = J(16, 3, .)

* Store local macro values into the matrix
matrix A[1,1] = `beta_All_fake'
matrix A[1,2] = `lb_All_fake'
matrix A[1,3] = `ub_All_fake'
matrix A[2,1] = `beta_All_fake_se'
matrix A[2,2] = `lb_All_fake_se'
matrix A[2,3] = `ub_All_fake_se'
matrix A[3,1] = `beta_Fake_center'
matrix A[3,2] = `lb_Fake_center'
matrix A[3,3] = `ub_Fake_center'
matrix A[4,1] = `beta_Fake_center_se'
matrix A[4,2] = `lb_Fake_center_se'
matrix A[4,3] = `ub_Fake_center_se'
matrix A[5,1] = `beta_Fake_right'
matrix A[5,2] = `lb_Fake_right'
matrix A[5,3] = `ub_Fake_right'
matrix A[6,1] = `beta_Fake_right_se'
matrix A[6,2] = `lb_Fake_right_se'
matrix A[6,3] = `ub_Fake_right_se'
matrix A[7,1] = `beta_Fake_left'
matrix A[7,2] = `lb_Fake_left'
matrix A[7,3] = `ub_Fake_left'
matrix A[8,1] = `beta_Fake_left_se'
matrix A[8,2] = `lb_Fake_left_se'
matrix A[8,3] = `ub_Fake_left_se'
matrix A[9,1] = `beta_All_true'
matrix A[9,2] = `lb_All_true'
matrix A[9,3] = `ub_All_true'
matrix A[10,1] = `beta_All_true_se'
matrix A[10,2] = `lb_All_true_se'
matrix A[10,3] = `ub_All_true_se'
matrix A[11,1] = `beta_True_center'
matrix A[11,2] = `lb_True_center'
matrix A[11,3] = `ub_True_center'
matrix A[12,1] = `beta_True_center_se'
matrix A[12,2] = `lb_True_center_se'
matrix A[12,3] = `ub_True_center_se'
matrix A[13,1] = `beta_True_right'
matrix A[13,2] = `lb_True_right'
matrix A[13,3] = `ub_True_right'
matrix A[14,1] = `beta_True_right_se'
matrix A[14,2] = `lb_True_right_se'
matrix A[14,3] = `ub_True_right_se'
matrix A[15,1] = `beta_True_left'
matrix A[15,2] = `lb_True_left'
matrix A[15,3] = `ub_True_left'
matrix A[16,1] = `beta_True_left_se'
matrix A[16,2] = `lb_True_left_se'
matrix A[16,3] = `ub_True_left_se'

* Display the matrix to check
matrix list A


putexcel set "$dir_output/test_lee_bounds.xlsx", replace

* Export the matrix to an Excel file
putexcel A1=matrix(A)






************************************************
** 5. LEE BOUNDS: VIDEO VS. CONTROL           **
************************************************




foreach var in All_fake Fake_center Fake_right Fake_left All_true True_center True_right True_left {
    use "./data/cleaned/boot_video_`var'.dta", clear
	rename _bs_1 beta 
	rename _bs_2 lb
	rename _bs_3 ub
	foreach x in beta lb ub{
		 display "Summary for `var' `x'" 
		 sum `x' 
		 local `x'_`var' = r(mean)
		 local `x'_`var'_se = r(sd)
	}
	
}

	
* Create a matrix with 2 rows and 2 columns
matrix B = J(16, 3, .)

* Store local macro values into the matrix
matrix B[1,1] = `beta_All_fake'
matrix B[1,2] = `lb_All_fake'
matrix B[1,3] = `ub_All_fake'
matrix B[2,1] = `beta_All_fake_se'
matrix B[2,2] = `lb_All_fake_se'
matrix B[2,3] = `ub_All_fake_se'
matrix B[3,1] = `beta_Fake_center'
matrix B[3,2] = `lb_Fake_center'
matrix B[3,3] = `ub_Fake_center'
matrix B[4,1] = `beta_Fake_center_se'
matrix B[4,2] = `lb_Fake_center_se'
matrix B[4,3] = `ub_Fake_center_se'
matrix B[5,1] = `beta_Fake_right'
matrix B[5,2] = `lb_Fake_right'
matrix B[5,3] = `ub_Fake_right'
matrix B[6,1] = `beta_Fake_right_se'
matrix B[6,2] = `lb_Fake_right_se'
matrix B[6,3] = `ub_Fake_right_se'
matrix B[7,1] = `beta_Fake_left'
matrix B[7,2] = `lb_Fake_left'
matrix B[7,3] = `ub_Fake_left'
matrix B[8,1] = `beta_Fake_left_se'
matrix B[8,2] = `lb_Fake_left_se'
matrix B[8,3] = `ub_Fake_left_se'
matrix B[9,1] = `beta_All_true'
matrix B[9,2] = `lb_All_true'
matrix B[9,3] = `ub_All_true'
matrix B[10,1] = `beta_All_true_se'
matrix B[10,2] = `lb_All_true_se'
matrix B[10,3] = `ub_All_true_se'
matrix B[11,1] = `beta_True_center'
matrix B[11,2] = `lb_True_center'
matrix B[11,3] = `ub_True_center'
matrix B[12,1] = `beta_True_center_se'
matrix B[12,2] = `lb_True_center_se'
matrix B[12,3] = `ub_True_center_se'
matrix B[13,1] = `beta_True_right'
matrix B[13,2] = `lb_True_right'
matrix B[13,3] = `ub_True_right'
matrix B[14,1] = `beta_True_right_se'
matrix B[14,2] = `lb_True_right_se'
matrix B[14,3] = `ub_True_right_se'
matrix B[15,1] = `beta_True_left'
matrix B[15,2] = `lb_True_left'
matrix B[15,3] = `ub_True_left'
matrix B[16,1] = `beta_True_left_se'
matrix B[16,2] = `lb_True_left_se'
matrix B[16,3] = `ub_True_left_se'

* Display the matrix to check
matrix list B


putexcel set "$dir_output/video_lee_bounds.xlsx", replace

* Export the matrix to an Excel file
putexcel A1=matrix(B)






************************************************
** 5. LEE BOUNDS: BOTH VS. CONTROL            **
************************************************




foreach var in All_fake Fake_center Fake_right Fake_left All_true True_center True_right True_left {
    use "./data/cleaned/boot_both_`var'.dta", clear
	rename _bs_1 beta 
	rename _bs_2 lb
	rename _bs_3 ub
	foreach x in beta lb ub{
		 display "Summary for `var' `x'" 
		 sum `x' 
		 local `x'_`var' = r(mean)
		 local `x'_`var'_se = r(sd)
	}
	
}

	
* Create a matrix with 2 rows and 2 columns
matrix C = J(16, 3, .)

* Store local macro values into the matrix
matrix C[1,1] = `beta_All_fake'
matrix C[1,2] = `lb_All_fake'
matrix C[1,3] = `ub_All_fake'
matrix C[2,1] = `beta_All_fake_se'
matrix C[2,2] = `lb_All_fake_se'
matrix C[2,3] = `ub_All_fake_se'
matrix C[3,1] = `beta_Fake_center'
matrix C[3,2] = `lb_Fake_center'
matrix C[3,3] = `ub_Fake_center'
matrix C[4,1] = `beta_Fake_center_se'
matrix C[4,2] = `lb_Fake_center_se'
matrix C[4,3] = `ub_Fake_center_se'
matrix C[5,1] = `beta_Fake_right'
matrix C[5,2] = `lb_Fake_right'
matrix C[5,3] = `ub_Fake_right'
matrix C[6,1] = `beta_Fake_right_se'
matrix C[6,2] = `lb_Fake_right_se'
matrix C[6,3] = `ub_Fake_right_se'
matrix C[7,1] = `beta_Fake_left'
matrix C[7,2] = `lb_Fake_left'
matrix C[7,3] = `ub_Fake_left'
matrix C[8,1] = `beta_Fake_left_se'
matrix C[8,2] = `lb_Fake_left_se'
matrix C[8,3] = `ub_Fake_left_se'
matrix C[9,1] = `beta_All_true'
matrix C[9,2] = `lb_All_true'
matrix C[9,3] = `ub_All_true'
matrix C[10,1] = `beta_All_true_se'
matrix C[10,2] = `lb_All_true_se'
matrix C[10,3] = `ub_All_true_se'
matrix C[11,1] = `beta_True_center'
matrix C[11,2] = `lb_True_center'
matrix C[11,3] = `ub_True_center'
matrix C[12,1] = `beta_True_center_se'
matrix C[12,2] = `lb_True_center_se'
matrix C[12,3] = `ub_True_center_se'
matrix C[13,1] = `beta_True_right'
matrix C[13,2] = `lb_True_right'
matrix C[13,3] = `ub_True_right'
matrix C[14,1] = `beta_True_right_se'
matrix C[14,2] = `lb_True_right_se'
matrix C[14,3] = `ub_True_right_se'
matrix C[15,1] = `beta_True_left'
matrix C[15,2] = `lb_True_left'
matrix C[15,3] = `ub_True_left'
matrix C[16,1] = `beta_True_left_se'
matrix C[16,2] = `lb_True_left_se'
matrix C[16,3] = `ub_True_left_se'

* Display the matrix to check
matrix list C


putexcel set "$dir_output/both_lee_bounds.xlsx", replace

* Export the matrix to an Excel file
putexcel A1=matrix(C)



	