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

reg lowestprice_num allprovidercount_2020
reg lowestprice_num allprovidercount_2020 pop_num
reg lowestprice_num allprovidercount_2020 pop_num percent 
areg lowestprice_num allprovidercount_2020 pop_num, absorb(state)
areg lowestprice_num allprovidercount_2020 pop_num, absorb(county)


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
