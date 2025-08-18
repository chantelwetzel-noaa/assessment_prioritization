#C forecast file written by R function SS_writeforecast
#C rerun model to get more complete formatting in forecast.ss_new
#C should work with SS version: 3.3
#C file write time: 2023-06-09 14:55:08
#
1 #_benchmarks
2 #_MSY
0.5 #_SPRtarget
0.4 #_Btarget
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF,  beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
2020 2020 2020 2020 2020 2020 1934 2020 1934 2020
0 #_Bmark_relF_Basis
1 #_Forecast
12 #_Nforecastyrs
1 #_F_scalar
#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_recruits, end_recruits (enter actual year, or values of 0 or -integer to be rel. endyr)
0 0 0 0 -999 0
0 #_Fcast_selex
3 #_ControlRuleMethod
0.02 #_BforconstantF
0.01 #_BfornoF
1 #_Flimitfraction
3 #_N_forecast_loops
3 #_First_forecast_loop_with_stochastic_recruitment
0 #_fcast_rec_option
1 #_fcast_rec_val
0 #_Fcast_MGparm_averaging
2040 #_FirstYear_for_caps_and_allocations
0 #_stddev_of_log_catch_ratio
0 #_Do_West_Coast_gfish_rebuilder_output
1999 #_Ydecl
1 #_Yinit
1 #_fleet_relative_F
# Note that fleet allocation is used directly as average F if Do_Forecast=4 
2 #_basis_for_fcast_catch_tuning
# enter list of fleet number and max for fleets with max annual catch; terminate with fleet=-9999
-9999 -1
# enter list of area ID and max annual catch; terminate with area=-9999
-9999 -1
# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
-9999 -1
2 #_InputBasis
 #_Year Seas Fleet Catch or F
   2023    1     1       1.70
   2023    1     2       3.40
   2023    1     3      24.60
   2023    1     4      35.00
   2024    1     1       1.80
   2024    1     2       3.50
   2024    1     3      25.40
   2024    1     4      36.20
   2025    1     1       3.48
   2025    1     2       5.80
   2025    1     3      44.10
   2025    1     4      62.66
   2026    1     1       3.45
   2026    1     2       5.76
   2026    1     3      43.74
   2026    1     4      62.16
   2027    1     1       3.43
   2027    1     2       5.72
   2027    1     3      43.47
   2027    1     4      61.77
   2028    1     1       3.41
   2028    1     2       5.69
   2028    1     3      43.24
   2028    1     4      61.45
   2029    1     1       3.40
   2029    1     2       5.66
   2029    1     3      43.03
   2029    1     4      61.14
   2030    1     1       3.39
   2030    1     2       5.64
   2030    1     3      42.90
   2030    1     4      60.96
   2031    1     1       3.38
   2031    1     2       5.63
   2031    1     3      42.79
   2031    1     4      60.81
   2032    1     1       3.36
   2032    1     2       5.61
   2032    1     3      42.62
   2032    1     4      60.56
   2033    1     1       3.35
   2033    1     2       5.58
   2033    1     3      42.41
   2033    1     4      60.27
   2034    1     1       3.33
   2034    1     2       5.56
   2034    1     3      42.22
   2034    1     4      60.00
-9999 0 0 0
#
999 # verify end of input 
