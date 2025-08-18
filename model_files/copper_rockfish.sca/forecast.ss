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
13 #_Nforecastyrs
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
   2023    1     1       1.10
   2023    1     2       0.80
   2023    1     3      19.20
   2023    1     4       5.70
   2024    1     1       1.10
   2024    1     2       0.80
   2024    1     3      19.90
   2024    1     4       5.90
   2025    1     1       1.78
   2025    1     2       1.34
   2025    1     3      32.06
   2025    1     4       9.35
   2026    1     1       1.77
   2026    1     2       1.33
   2026    1     3      31.93
   2026    1     4       9.31
   2027    1     1       1.77
   2027    1     2       1.33
   2027    1     3      31.81
   2027    1     4       9.28
   2028    1     1       1.76
   2028    1     2       1.32
   2028    1     3      31.66
   2028    1     4       9.23
   2029    1     1       1.75
   2029    1     2       1.31
   2029    1     3      31.46
   2029    1     4       9.18
   2030    1     1       1.74
   2030    1     2       1.30
   2030    1     3      31.28
   2030    1     4       9.12
   2031    1     1       1.73
   2031    1     2       1.30
   2031    1     3      31.11
   2031    1     4       9.07
   2032    1     1       1.72
   2032    1     2       1.29
   2032    1     3      30.90
   2032    1     4       9.01
   2033    1     1       1.71
   2033    1     2       1.28
   2033    1     3      30.75
   2033    1     4       8.97
   2034    1     1       1.70
   2034    1     2       1.28
   2034    1     3      30.60
   2034    1     4       8.93
   2025    1     1       1.51
   2025    1     2       1.13
   2025    1     3      27.15
   2025    1     4       7.92
   2025    1     1       1.51
   2025    1     2       1.13
   2025    1     3      27.15
   2025    1     4       7.92
   2026    1     1       1.52
   2026    1     2       1.14
   2026    1     3      27.39
   2026    1     4       7.99
   2027    1     1       1.54
   2027    1     2       1.15
   2027    1     3      27.64
   2027    1     4       8.06
   2028    1     1       1.55
   2028    1     2       1.16
   2028    1     3      27.86
   2028    1     4       8.13
   2029    1     1       1.56
   2029    1     2       1.17
   2029    1     3      28.01
   2029    1     4       8.17
   2030    1     1       1.56
   2030    1     2       1.17
   2030    1     3      28.15
   2030    1     4       8.21
   2031    1     1       1.57
   2031    1     2       1.18
   2031    1     3      28.27
   2031    1     4       8.25
   2032    1     1       1.57
   2032    1     2       1.18
   2032    1     3      28.35
   2032    1     4       8.27
   2033    1     1       1.58
   2033    1     2       1.19
   2033    1     3      28.44
   2033    1     4       8.30
   2034    1     1       1.58
   2034    1     2       1.19
   2034    1     3      28.49
   2034    1     4       8.31
   2025    1     1       0.63
   2025    1     2       0.48
   2025    1     3      11.40
   2025    1     4       3.33
   2026    1     1       0.72
   2026    1     2       0.54
   2026    1     3      12.94
   2026    1     4       3.77
   2027    1     1       0.80
   2027    1     2       0.60
   2027    1     3      14.47
   2027    1     4       4.22
   2028    1     1       0.88
   2028    1     2       0.66
   2028    1     3      15.82
   2028    1     4       4.61
   2029    1     1       0.94
   2029    1     2       0.71
   2029    1     3      16.93
   2029    1     4       4.94
   2030    1     1       0.99
   2030    1     2       0.74
   2030    1     3      17.88
   2030    1     4       5.21
   2031    1     1       1.04
   2031    1     2       0.78
   2031    1     3      18.71
   2031    1     4       5.46
   2032    1     1       1.08
   2032    1     2       0.81
   2032    1     3      19.44
   2032    1     4       5.67
   2033    1     1       1.12
   2033    1     2       0.84
   2033    1     3      20.11
   2033    1     4       5.87
   2034    1     1       1.15
   2034    1     2       0.87
   2034    1     3      20.76
   2034    1     4       6.06
-9999 0 0 0
#
999 # verify end of input 
