clear all
set more off

set scheme cleanplots

*paths
if "`c(username)'" == "gelkouh" {
	global parent `"/Users/gelkouh/Library/CloudStorage/OneDrive-Personal/Documents/School/UChicago/Year 3/ECON 28000/PAPER/econ-28000-spring-2022"'
}

global data `"$parent/data"'

*https://www.openicpsr.org/openicpsr/project/128841/version/V2/view
*global broadband_availability_speed `"nanda_brdband_zcta_2014-2020_01P.dta"'

*https://github.com/BroadbandNow/Open-Data
global competition_pricing `"broadband_data_opendatachallenge.csv"'

*make output directory
cap mkdir `"$parent/output"'


import delimited `"$data/$competition_pricing"', clear

describe
summarize

replace accesstoterrestrialbroadband = substr(accesstoterrestrialbroadband,1,length(accesstoterrestrialbroadband)-1)
encode accesstoterrestrialbroadband , gen(percent)

encode population, gen(pop_num)
encode lowestpricedterrestrialbroadband, gen(lowestprice_num)


*Regressions

eststo price1: reg lowestprice_num allprovidercount_2020, absorb(state)
eststo price2: reg lowestprice_num c.allprovidercount_2020##c.pop_num, absorb(state)
eststo price3: reg lowestprice_num c.allprovidercount_2020##c.pop_num##c.percent, absorb(state)

eststo quality1: reg averagembps allprovidercount_2020, absorb(state)
eststo quality2: reg averagembps c.allprovidercount_2020##c.pop_num, absorb(state)
eststo quality3: reg averagembps c.allprovidercount_2020##c.pop_num##c.percent, absorb(state)

esttab price1 quality1 price2 quality2 price3 quality3 using "$parent/output/reg_table.tex", ///
	keep(allprovidercount_2020 pop_num percent) ///
	order(allprovidercount_2020 pop_num percent) ///
	mtitles("Price" "Quality" "Price" "Quality" "Price" "Quality" "Price" "Quality")  ///
	coeflabels(allprovidercount_2020 "Num. Providers" pop_num "Population" percent "Pct. Broadband Access")  ///
	tex  replace compress

*Figures
	
binscatter averagembps allprovidercount_2020, absorb(state) ///
	ytitle("Average Download Speed (Mbps)", size(small)) xtitle("Number of Broadband Providers", size(small))
	graph export "$parent/output/wavg_vs_N_state_fe.pdf", replace
	
binscatter fastestaveragembps allprovidercount_2020, absorb(state) ///
	ytitle("Fastest Average (90th Percentile) Download Speed (Mbps)", size(small)) xtitle("Number of Broadband Providers", size(small))
	graph export "$parent/output/wbest_vs_N_state_fe.pdf", replace

binscatter lowestprice_num allprovidercount_2020, absorb(state) ///
	ytitle("Lowest Priced Terrestrial Broadband Plan ($/month)", size(small)) xtitle("Number of Broadband Providers", size(small))
	graph export "$parent/output/p_vs_N_state_fe.pdf", replace
	
binscatter lowestprice_num averagembps, absorb(state) ///
	ytitle("Lowest Priced Terrestrial Broadband Plan ($/month)", size(small)) xtitle("Average Download Speed (Mbps)", size(small))
	graph export "$parent/output/p_vs_wavg_state_fe.pdf", replace

	
/*
use `"$data/$broadband_availability_speed"', clear

describe
summarize

encode zcta19 , gen(zcta19e)

preserve

collapse (mean) tot_hs_providers, by(year)
line tot_hs_providers year

restore
preserve 

collapse (mean) avg_download_speed, by(year)
line avg_download_speed year

restore

xtset zcta19e year

xtreg avg_download_speed tot_hs_providers
