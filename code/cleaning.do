**********************************

/* Outline 

1. Import data 
2. General variables 
3. Treatment variabels 
4. Control variables 
5. Outcome variables 
6. Duplicates, IDs & pre vs. post
7. Save final data


*/




************************
** 1. IMPORT DATA     **
************************

	
import delimited "./data/raw/Round_1.csv", clear



***************************
** 2. GENERAL VARIABLES  **
***************************

** Date 
gen date2 = date(date, "YMD")
format date2 %td
drop date
rename date2 date


** Age 
gen age = 2022 - year_of_birth 
label variable age "Age of the participants"


** Rename variables 
rename ie_confidence_a trust_1
rename ie_confidence_b trust_2
rename ie_confidence_c trust_3
rename ie_confidence_d trust_4
rename ie_confidence_e trust_5
rename ie_confidence_f trust_6
rename ie_confidence_g trust_7
rename ie_confidence_h trust_8
rename ie_confidence_i trust_9


** Clean municipality variable 
replace municipality = strtrim(municipality)
replace municipality = "Bogotá D.C." if municipality == "bogota" | municipality == "BOGOTA" | municipality == "Bogot" | municipality == "Bogota" | municipality == "Bogota Dc" | municipality == "Bogotá" | municipality == "Bogotá Dc"
replace municipality = "Calamar" if municipality == "Calamarl"
replace municipality = "Calarcá" if municipality == "Calarca"
replace municipality = "Jamundí" if municipality == "Jamundi"
replace municipality = "Medellín" if municipality == "Medellin"



********************************
** 3. TREATMENT VARIABELS     **
********************************

** creating the 13 treatment variables based on score, video and various forms (confianza, deshum, discri, ambiguedad)


gen treatment = ""
replace treatment = "control" if score == . & video == "No"

replace treatment = "only_v_trust" if score == . & video == "Sí" & form == "Confianza"
replace treatment = "only_v_dehumanization" if score == . & video == "Sí" & form == "Deshumanización"
replace treatment = "only_v_discrimination" if score == . & video == "Sí" & form == "Discriminización"
replace treatment = "only_v_ambiguity" if score == . & video == "Sí" & form == "Tolerancia a la ambigüedad"

replace treatment = "only_f_trust" if score != . & video == "No" & form == "Confianza"
replace treatment = "only_f_dehumanization" if score !=  . & video == "No" & form == "Deshumanización"
replace treatment = "only_f_discrimination" if score !=  . & video == "No" & form == "Discriminización"
replace treatment = "only_f_ambiguity" if score !=  . & video == "No" & form == "Tolerancia a la ambigüedad"

replace treatment = "v_f_trust" if score != . & video == "Sí" & form == "Confianza"
replace treatment = "v_f_dehumanization" if score !=  . & video == "Sí" & form == "Deshumanización"
replace treatment = "v_f_discrimination" if score !=  . & video == "Sí" & form == "Discriminización"
replace treatment = "v_f_ambiguity" if score !=  . & video == "Sí" & form == "Tolerancia a la ambigüedad"


** create dummy variables for each treatment 

foreach i in only_f_ambiguity only_f_dehumanization only_f_discrimination only_f_trust only_v_ambiguity only_v_dehumanization only_v_discrimination only_v_trust v_f_ambiguity v_f_dehumanization v_f_discrimination v_f_trust{
	
	gen `i' = 0 
	replace `i' = 1 if treatment == "`i'"
	
}


** create alternative treatment variables 

gen any_treatment = 0 
replace any_treatment = 1 if treatment != ""

gen any_form = 0 
replace any_form = 1 if treatment == "only_f_trust" | treatment == "only_f_dehumanization" | treatment == "only_f_discrimination" | treatment == "only_f_ambiguity"

gen any_video = 0 
replace any_video = 1 if treatment == "only_v_trust" | treatment == "only_v_dehumanization" | treatment == "only_v_discrimination" | treatment == "only_v_ambiguity" 

gen any_video_form = 0 
replace any_video_form = 1 if treatment == "v_f_trust" | treatment == "v_f_dehumanization" | treatment == "v_f_discrimination" | treatment == "v_f_ambiguity" 




****************************
** 4. CONTROL VARIABLES   **
****************************

** replace Spanish entries with English ones and create dummy variables 

* gender 
replace gender = "male" if gender == "Hombre"
replace gender = "female" if gender == "Mujer"
replace gender = "other" if gender == "Otro"

gen male = 0 
replace male = 1 if gender == "male"
label variable male "Dummy variable for gender = male (vs. female and other)"


gen female = 0 
replace female = 1 if gender == "female"
label variable female "Dummy variable for gender = female (vs. female and other)"

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



******************************
** 5. OUTCOME VARIABLES     **
******************************


** fake news
gen fake_right = (fake_news_i + fake_news_j + fake_news_f + fake_news_r)/4
label variable fake_right "Average score fake news: right leaning"

gen fake_left = (fake_news_d + fake_news_g + fake_news_h + fake_news_o)/4
label variable fake_left "Average score fake news: left leaning"

gen fake_center = (fake_news_a + fake_news_m)/2 
label variable fake_center "Average score fake news: center"


** true news
gen true_right = (fake_news_s + fake_news_e + fake_news_b)/3
label variable true_right "Average score true news: right leaning"

gen true_left = (fake_news_c + fake_news_l + fake_news_q)/3 
label variable true_left "Average score true news: left leaning"

gen true_center = (fake_news_k + fake_news_p + fake_news_n)/3 
label variable true_center "Average score true news: center"


** all fake news 
gen all_fake = (fake_news_i + fake_news_j + fake_news_f + fake_news_r + fake_news_d + fake_news_g + fake_news_h + fake_news_o + fake_news_a + fake_news_m)/10 
label variable all_fake "Average score fake news"


** all true news 
gen all_true = (fake_news_s + fake_news_e + fake_news_b + fake_news_c + fake_news_l + fake_news_q + fake_news_k + fake_news_p + fake_news_n)/9
label variable all_true "Average score true news"


********************************************************************************

** Dummy reliable **

** dummy variable for perceiving the *fake* news as very reliable (reliable = 1)
gen d_fake_right_reliable = 0 
replace d_fake_right_reliable = 1 if fake_right >= 4
label variable d_fake_right_reliable "Dummy fake news (right) reliable"

gen d_fake_left_reliable = 0 
replace d_fake_left_reliable = 1 if fake_left >= 4
label variable d_fake_left_reliable "Dummy fake news (left) reliable"

gen d_fake_center_reliable = 0 
replace d_fake_center_reliable = 1 if fake_center >= 4
label variable d_fake_center_reliable "Dummy fake news (center) reliable"

gen d_all_fake_reliable = 0 
replace d_all_fake_reliable = 1 if all_fake >= 4
label variable d_all_fake_reliable "Dummy fake news (all) reliable"



** dummy variable for perceiving the *true* news as very reliable (reliable = 1)
gen d_true_right_reliable = 0 
replace d_true_right_reliable = 1 if true_right >= 4
label variable d_true_right_reliable "Dummy true news (right) reliable"

gen d_true_left_reliable = 0 
replace d_true_left_reliable = 1 if true_left >= 4
label variable d_true_left_reliable "Dummy true news (left) reliable"

gen d_true_center_reliable = 0 
replace d_true_center_reliable = 1 if true_center >= 4
label variable d_true_center_reliable "Dummy true news (center) reliable"

gen d_all_true_reliable = 0 
replace d_all_true_reliable = 1 if all_true >= 4
label variable d_all_true_reliable "Dummy true news (all) reliable"

********************************************************************************

** Dummy unreliable **


** dummy variable for perceiving the *fake* news as very unreliable (unreliable = 1)
gen d_fake_right_unreliable = 0 
replace d_fake_right_unreliable = 1 if fake_right <= 2
label variable d_fake_right_unreliable "Dummy fake news (right) unreliable"

gen d_fake_left_unreliable = 0 
replace d_fake_left_unreliable = 1 if fake_left <= 2
label variable d_fake_left_unreliable "Dummy fake news (left) unreliable"

gen d_fake_center_unreliable = 0 
replace d_fake_center_unreliable = 1 if fake_center <= 2
label variable d_fake_center_unreliable "Dummy fake news (center) unreliable"

gen d_all_fake_unreliable = 0 
replace d_all_fake_unreliable = 1 if all_fake <= 2
label variable d_all_fake_unreliable "Dummy fake news (all) unreliable"



** dummy variable for perceiving the *true* news as very reliable (unreliable = 1) 
gen d_true_right_unreliable = 0 
replace d_true_right_unreliable = 1 if true_right <= 2
label variable d_true_right_unreliable "Dummy true news (right) unreliable"

gen d_true_left_unreliable = 0 
replace d_true_left_unreliable = 1 if true_left <= 2
label variable d_true_left_unreliable "Dummy true news (left) unreliable"

gen d_true_center_unreliable = 0 
replace d_true_center_unreliable = 1 if true_center <= 2
label variable d_true_center_unreliable "Dummy true news (center) unreliable"

gen d_all_true_unreliable = 0 
replace d_all_true_unreliable = 1 if all_true <= 2
label variable d_all_true_unreliable "Dummy true news (all) unreliable"


********************************************************************************

** Variables for questions about ambiguity **

*Order necessity
gen ambiguity_order_necessity = (ie_ambiguity_tolerance_a + ie_ambiguity_tolerance_b)/2 
label variable ambiguity_order_necessity "Average score ambiguity order necessity"

*Ambiguity aversion
gen ambiguity_aversion = (ie_ambiguity_tolerance_c + ie_ambiguity_tolerance_d)/2 
label variable ambiguity_aversion "Average score ambiguity aversion"

*Ambiguity decision
gen ambiguity_decision = (ie_ambiguity_tolerance_e + ie_ambiguity_tolerance_f + ie_ambiguity_tolerance_g)/3 
label variable ambiguity_decision "Average score ambiguity decision"


*Deal with reverse coded variables
replace ie_ambiguity_tolerance_i = 6 - ie_ambiguity_tolerance_i
replace ie_ambiguity_tolerance_j = 6 - ie_ambiguity_tolerance_j


*Ambiguity predictability
gen ambiguity_predictability = (ie_ambiguity_tolerance_h + ie_ambiguity_tolerance_i)/2 
label variable ambiguity_predictability "Average score ambiguity predictability"

gen ambiguity_closedminded = ie_ambiguity_tolerance_j
label variable ambiguity_closedminded "Average score ambiguity closed mindedness"

*********
*********


*dummy necessity of order (1,2 i.e. disagree)
gen d_ambiguity_necessity = 0 
replace d_ambiguity_necessity = 1 if ambiguity_order_necessity <= 2
label variable d_ambiguity_necessity "Dummy for low order of ambiguity necessity"


*dummy aversion (1,2 i.e. disagree)
gen d_ambiguity_aversion = 0 
replace d_ambiguity_aversion = 1 if ambiguity_aversion <= 2 
label variable d_ambiguity_aversion "Dummy for low ambiguity aversion"

*dummy decision (1,2, i.e. disagree)
gen d_ambiguity_decision = 0
replace d_ambiguity_decision = 1 if ambiguity_decision <= 2 
label variable d_ambiguity_decision "Dummy for low ambiguity decision"

*dummy predictability (1,2, i.e. disagree)
gen d_ambiguity_predictability = 0
replace d_ambiguity_predictability = 1 if ambiguity_predictability <= 2 
label variable d_ambiguity_predictability "Dummy for low ambiguity predictability"

*dummy closed mindedness (1,2, i.e. disagree)
gen d_ambiguity_closedminded = 0
replace d_ambiguity_closedminded = 1 if ambiguity_closedminded <= 2 
label variable d_ambiguity_closedminded "Dummy for low ambiguity closed mindedness"

********************************************************************************

** Variables for questions about everyday discrimination the respondents are facing **

*discrimination index 
gen discrimination_index = (ie_discrimination_a + ie_discrimination_b + ie_discrimination_c + ie_discrimination_d + ie_discrimination_e + ie_discrimination_f)/6
label variable discrimination_index "Average score discrimination index"

*dummy for low discrimination 
gen d_discrimination = 0 
replace d_discrimination = 1 if discrimination_index <= 2 
label variable d_discrimination "Dummy for low discrimination"


********************************************************************************

** Dummy Dehumanization **

** Negative Emotions 

*dummy negative emotions left 
gen d_negative_emotions_left = 0
replace d_negative_emotions_left = 1 if strpos(ie_dehumanization_left, "Imprudencia") > 0 | strpos(ie_dehumanization_left, "Aburrición") > 0 | strpos(ie_dehumanization_left, "Sospecha") > 0 | strpos(ie_dehumanization_left, "Vergüenza") > 0
label variable d_negative_emotions_left "Dummy for negative emotions: left leaning"

*dummy negative emotions right 
gen d_negative_emotions_right = 0
replace d_negative_emotions_right = 1 if strpos(ie_dehumanization_right, "Imprudencia") > 0 | strpos(ie_dehumanization_right, "Aburrición") > 0 | strpos(ie_dehumanization_right, "Sospecha") > 0 | strpos(ie_dehumanization_right, "Vergüenza") > 0
label variable d_negative_emotions_right "Dummy for negative emotions: right leaning"

*dummy negative emotions center 
gen d_negative_emotions_center = 0
replace d_negative_emotions_center = 1 if strpos(ie_dehumanization_center, "Imprudencia") > 0 | strpos(ie_dehumanization_center, "Aburrición") > 0 | strpos(ie_dehumanization_center, "Sospecha") > 0 | strpos(ie_dehumanization_center, "Vergüenza") > 0
label variable d_negative_emotions_center "Dummy for positive emotions: center"


** Positive Emotions 

*dummy positive emotions left 
gen d_positive_emotions_left = 0
replace d_positive_emotions_left = 1 if strpos(ie_dehumanization_left, "Dedicación") > 0 | strpos(ie_dehumanization_left, "Trabajo") > 0 | strpos(ie_dehumanization_left, "Disciplina") > 0 | strpos(ie_dehumanization_left, "Educación") > 0 | strpos(ie_dehumanization_left, "Cordialidad") > 0 | strpos(ie_dehumanization_left, "Compasión") > 0 
label variable d_positive_emotions_left "Dummy for positive emotions: left leaning"

*dummy positive emotions right 
gen d_positive_emotions_right = 0
replace d_positive_emotions_right = 1 if strpos(ie_dehumanization_right, "Dedicación") > 0 | strpos(ie_dehumanization_right, "Trabajo") > 0 | strpos(ie_dehumanization_right, "Disciplina") > 0 | strpos(ie_dehumanization_right, "Educación") > 0 | strpos(ie_dehumanization_right, "Cordialidad") > 0 | strpos(ie_dehumanization_right, "Compasión") > 0 
label variable d_positive_emotions_right "Dummy for positive emotions: left leaning"

*dummy positive emotions center 
gen d_positive_emotions_center = 0
replace d_positive_emotions_center = 1 if strpos(ie_dehumanization_center, "Dedicación") > 0 | strpos(ie_dehumanization_center, "Trabajo") > 0 | strpos(ie_dehumanization_center, "Disciplina") > 0 | strpos(ie_dehumanization_center, "Educación") > 0 | strpos(ie_dehumanization_center, "Cordialidad") > 0 | strpos(ie_dehumanization_center, "Compasión") > 0 
label variable d_positive_emotions_center "Dummy for positive emotions: center"




********************************************************************************

** Dummy Trust ** 
// Note: trust_4 and trust_5 are only answered with yes or no

gen d_trust_1 = 0 
replace d_trust_1 = 1 if trust_1 >= 3
label variable d_trust_1 "Dummy for trust_1 trustworthy"

gen d_trust_2 = 0 
replace d_trust_2 = 1 if trust_2 >= 3
label variable d_trust_2 "Dummy for trust_2 trustworthy"

gen d_trust_3 = 0 
replace d_trust_3 = 1 if trust_3 >= 3
label variable d_trust_3 "Dummy for trust_3 trustworthy"

gen d_trust_6 = 0 
replace d_trust_6 = 1 if trust_6 >= 5
label variable d_trust_6 "Dummy for trust_6 trustworthy"

gen d_trust_7 = 0 
replace d_trust_7 = 1 if trust_7 >= 5
label variable d_trust_7 "Dummy for trust_7 trustworthy"

gen d_trust_8 = 0 
replace d_trust_8 = 1 if trust_8 >= 5
label variable d_trust_8 "Dummy for trust_8 trustworthy"

gen d_trust_9 = 0 
replace d_trust_9 = 1 if trust_9 >= 5
label variable d_trust_9 "Dummy for trust_9 trustworthy"




********************************************
** 6. DUPLICATES, IDs & PRE vs. POST      **
********************************************


** Pre & Post ** 
//Observations until 980 are not affected by the launch of the website

gen count = _n 
gen post = 0 
label variable post "Indicator for observations after the launch of the website"
replace post = 1 if count > 980
drop count

********************************************************************************


** ID variables ** 
// Note: the variable id_last_four should have 4 digits; however, there are 274 observations that have less than 4 digits; drop these

drop if id_last_four < 999

********************************************************************************


** Duplicates ** 
duplicates tag id_last_four last_name_initial, generate(dup)
drop if dup > 0
drop dup


************************************************
** 7. Save data set                              **
************************************************

save "./data/cleaned/dip_first_round.dta", replace

