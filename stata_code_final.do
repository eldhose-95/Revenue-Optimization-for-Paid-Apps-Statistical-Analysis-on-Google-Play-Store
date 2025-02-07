use "C:\Users\ev00246\OneDrive - University of Surrey\eldhose_surrey\SE\Assessment\MANM526-FINAL PROJECT DATA-2023-24"
browse

label variable product_id "product_id"
label variable name "app name"
label variable developer "developer name"
label variable version "app version"
label variable release_date "app release date"
label variable devices "devices"
label variable active "active"
label variable price "app price"
label variable is_paid "is_paid"
label variable size "app size"
label variable rating "app rating"
label variable num_langs "number of languages"
label variable main_category "app main_category"
label variable monetization_strategies "monetization_strategies"
label variable age_target "target age"
label variable revenue "app revenue"

gen type = 1 if main_category == "Games"
replace type = 0 if main_category != "Games"

gen log_rev = log(revenue)
gen log_price = log(price)

label variable log_price "Natural log of app price"
label variable log_rev "Natural log of app revenue"
label variable type "app type"

//TASK 2 : Descriptive Analysis

//Provide a two-way table that depicts the summary statistics of the variables for subsamples of game and non-game apps, as well as the full sample in one table
tabstat size rating  log_rev log_price, statistics(count mean min max sd) by (type) columns(statistics) longstub

//Apply an appropriate test to evaluate if there is any statistically significant difference (at 0.05 significance level) across categories regarding the app revenue (logged)
oneway log_rev main_category
 
//Apply an appropriate test to evaluate if there is any statistically significant difference (at 0.05 significance level) between games and non-game apps regarding the app revenue (logged) 
ztest log_rev,by(type)

// Provide the correlation matrix of the main variables
corr log_rev size rating num_langs log_price 

//TASK 3 : Exploratory Analysis

// distribution or skewness of variables
histogram log_price, normal
histogram log_rev, normal
histogram rating, normal
histogram size, normal
histogram num_langs, normal

// checking the possibility of outliers
graph box log_rev
graph box rating
graph box log_price
graph box num_langs
graph box size
graph box log_rev, over(type)
graph box log_price, over(type)

//TASK 4

// Regression Analysis
encode age_target, generate( age_target_dum )
encode monetization_strategies, generate( monetization_strategies_dum)
encode main_category, generate( main_category_dum )
//Model 1
reg log_rev rating log_price i.monetization_strategies_dum  i.age_target_dum  num_langs i.main_category_dum
// Q1.1
margins monetization_strategies_dum
marginsplot
// Q1.2
margins age_target_dum
marginsplot
// Q2
// Model 2
reg log_rev rating log_price i.monetization_strategies_dum i.age_target_dum c.rating#i.monetization_strategies_dum num_langs i.main_category_dum
margins monetization_strategies_dum
marginsplot

//TASK 5

// Diagnostics and Robustness Analysis

//Heteroskedasticity
// Q1
// Model 3
reg log_rev rating log_price i.monetization_strategies_dum  i.age_target_dum  num_langs i.main_category_dum
predict fitted
predict resid, residual
twoway (scatter resid  fitted), yline(0)
drop fitted resid
hettest
imtest, white
 
reg log_rev rating log_price i.monetization_strategies_dum  i.age_target_dum  num_langs i.main_category_dum, vce(robust)


// Q2
gen log_price_sq = log_price * log_price
// Model 4
reg log_rev rating log_price log_price_sq i.monetization_strategies_dum  i.age_target_dum  num_langs i.main_category_dum
twoway (scatter log_rev log_price ) (lowess  log_rev log_price )
twoway (qfit log_rev log_price )

// Exporting tables to word

ssc install estout, replace

cd "C:\Users\ev00246\OneDrive - University of Surrey\eldhose_surrey\SE\Assessment"

// summary statistics
set more off
eststo clear
estpost tabstat size rating  log_rev log_price, statistics(count mean min max sd) by (type) columns(statistics) listwise 
eststo s1
esttab s1 using SummaryStatOutput.rtf, cells("count mean min max sd") replace label


//correlation output
set more off
eststo clear
estpost corr log_rev size rating num_langs log_price , matrix listwise 
eststo c1
esttab c1 using corr_table.rtf, replace label unstack not

// regression output model 1 (baseline model)
set more off
eststo clear
reg log_rev rating log_price i.monetization_strategies_dum  i.age_target_dum  num_langs i.main_category_dum
eststo m1
esttab m1 using reg_model_1_table.rtf, replace ar2(3) b(3) se(3) r2(3) label compress

// regression output model 2
set more off
eststo clear
reg log_rev rating log_price i.monetization_strategies_dum i.age_target_dum c.rating#i.monetization_strategies_dum num_langs i.main_category_dum
eststo m1
esttab m1 using reg_model_2_table.rtf, replace ar2(3) b(3) se(3) r2(3) label compress

//regression output Model 1 and Model 3 comparison
set more off
eststo clear
reg log_rev rating log_price i.monetization_strategies_dum  i.age_target_dum  num_langs i.main_category_dum
eststo m1
reg log_rev rating log_price i.monetization_strategies_dum  i.age_target_dum  num_langs i.main_category_dum, vce(robust)
eststo m3
esttab m1 m3 using reg_comp_table.rtf, replace ar2(3) b(3) se(3) r2(3) label compress 


// regression output model 4
set more off
eststo clear
reg log_rev rating log_price log_price_sq i.monetization_strategies_dum  i.age_target_dum  num_langs i.main_category_dum
eststo m1
esttab m1 using reg_model_4_table.rtf, replace ar2(3) b(3) se(3) r2(3) label compress










 

