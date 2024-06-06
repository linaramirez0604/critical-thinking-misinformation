**********************************

/* Outline

1. General 
2. Table 1 - Fake News 
3. Table 2 - Tweets 
4. Table 3 - Discrimination, Ambiguity, Trust

*/


*******************
** 1. GENERAL    **
*******************

use "./data/cleaned/dip_first_round.dta", clear


** define treatment variables
global D1 any_form
global D2 any_video
global D3 any_video_form 

** define controls 
global controls age female high_school postgraduate technical_educ undergraduate bog_dept post

*******************
** 2. FAKE NEWS **
*******************
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
esttab using "$dir_output/table_news.tex", replace ///
	se b(3) ///
	stats(tt1 tt2 n1 N r2,  fmt(%9.3f %9.3f %9.3f %9.0f %9.3f) labels("Test = Video (p)" "Video = Both (p)" "Control Mean" "Observations" "R-Squared")) title("News") ///
	mtitles( "All Fake" "Neutral Fake" "Right Fake" "Left Fake" "All True" "Neutral True" "Right True" "Left True") ///
	coeflabels(any_form "Test" any_video "Video" any_video_form "Both") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	keep($D1 $D2 $D3)



*****************
** 3. TWEETS  **
*****************

estimates clear 


*regressions
foreach var in tweet_a_lack_of_information ///
			tweet_a_report ///
			tweet_b_lack_of_information ///
			tweet_b_report{
					
	eststo: reg `var' $D1 $D2 $D3 $controls , vce(robust)
	test $D1 = $D2
	estadd scalar tt1 = r(p)
	test $D2 = $D3
	estadd scalar tt2 = r(p)
	sum `var' if $D1 == $D2 == $D3 == 0 
	estadd scalar n1 = r(mean)  
			
	}
			
*tables
esttab using "$dir_output/table_tweets.tex", replace ///
	b(3) se /// 
	stats(tt1 tt2 n1 N r2,  fmt(%9.3f %9.3f %9.3f %9.0f %9.3f) labels("Test = Video (p)" "Video = Both (p)" "Control Mean" "Observations" "R-Squared"))  ///
	title("Tweets") ///
	mtitles("A_Inappropriate" "A_Report" "B_Inappropriate" "B_Report") ///
	coeflabels(any_form "Test" any_video "Video" any_video_form "Both") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	keep($D1 $D2 $D3)



	
************************************************
** 4. DISCRIMINATION, AMBIGUITY, TRUST        **
************************************************
estimates clear 

		
*regressions
foreach var in d_discrimination ///
			d_ambiguity_aversion ///
			trust_4 ///
			d_negative_emotions_left ///
			d_negative_emotions_center ///
			d_negative_emotions_right{
					
	eststo: reg `var' $D1 $D2 $D3 $controls , vce(robust)
	test $D1 = $D2
	estadd scalar tt1 = r(p)
	test $D2 = $D3
	estadd scalar tt2 = r(p)
	sum `var' if $D1 == $D2 == $D3 == 0 
	estadd scalar n1 = r(mean)  
			
	}
			
*tables
esttab using "$dir_output/table_mediators.tex", replace ///
	se b(3) stats(tt1 tt2 n1 N r2,  fmt(%9.3f %9.3f %9.3f %9.0f %9.3f) labels("Test = Video (p)" "Video = Both (p)" "Control Mean" "Observations" "R-Squared")) title("Discrimination, Ambiguity and Trust") ///
	mtitles("Discrimination" "Ambiguity Aversion" "Trust" "Dehumanization L" "Dehumanization C" "Dehumanization R") ///
	coeflabels(any_form "Test" any_video "Video" any_video_form "Both") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	keep($D1 $D2 $D3)


	
	
