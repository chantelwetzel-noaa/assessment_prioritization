#C 2015 Assessent of Kelp Greenling (Berger, Arnold, Rodomsky) run with SSv3.24u
1 #_N_Growth_Patterns
1 #_N_Morphs_Within_GrowthPattern
#_Cond 1 #_Morph_between/within_stdev_ratio (no read if N_morphs=1)
#_Cond 1 #vector_Morphdist_(-1_in_first_val_gives_normal_approx)
#Recruitment occurs in season 2 (summer)
#1 # N recruitment designs goes here if N_GP*nseas*area>1
#0 # placeholder for recruitment interaction request
#1 2 1 # recruitment design element for GP=1, seas=2, area=1
#_Cond 0 # N_movement_definitions goes here if N_areas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
1#_Nblock_Patterns
1#_blocks_per_pattern
# begin and end years of blocks
2004 2014 # For selectivities of all recreational fleets with comp data (ocean fishery only) due to 10 inch size limit in 2004-> 0 and 1 year olds only
0.5 #_fracfemale
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
#2 #_N_breakpoints
# 4 15 # age(real) at M breakpoints
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=not implemented; 4=not implemented
1 #_Growth_Age_for_L1 (minimum age for growth calcs)
11 #_Growth_Age_for_L2 (999 to use as Linf) (maximum age for growth calcs)
0.0 #_SD_add_to_LAA
0 #_CV_Growth_Pattern: 0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A)
6 #_maturity_option: read an empirical length-maturity vector by population length bins
0 0 0 0 0 0 0	0 0 0 0	0 0 0.115 0.25 0.7933 0.944 1 1	1 1 1 1	1 1 1 1	1 1 1 1
 #_placeholder for empirical age-maturity by growth pattern
2 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b
0 #hermaphrodite
3 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
2 #_env/block/dev_adjust_method (1=standard; 2=with logistic trans to keep within base parm bounds)
#_growth_parms
#GP_1_Female
#LO   HI    INIT     PRIOR   PR_type SD      PHASE   env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
0.1   0.60  0.360    -1.02   3      0.437    -2      0       0       0         0         0          0     0 #1 F_M
-10   30    20       20   0      10        3      0       0       0         0         0          0     0 #2 F_L@Amin (Amin is age entered above)
20    60    38.51    38.51   0      10       3       0       0       0         0         0          0     0 #3 F_L@Amax
0.1   1     0.3    0.3   0      0.5      3       0       0       0         0         0          0     0 #4 F_VBK
0.05  0.15   0.1      0.1    -1      0.8      3      0       0       0         0         0          0     0 #5 CV@LAAFIX
-0.3  0.3   0      0    -1      0.8      -3      0       0       0         0         0          0     0 # CV@LAAFIX2
#GP_1:::Male 
-0.60   0.60  -0.12516   -1.15    -3      0.438    -2      0       0       0         0         0          0     0 #1 M_M
-10   30    0        12      0      10       -3      0       0       0         0         0          0     0 #2 M_L@Amin (Amin is age entered above)
-20    60    0    37.33   0      10       3       0       0       0         0         0          0     0 #3 M_L@Amax
-3   3     0    0   0      0.5      -3       0       0       0         0         0          0     0 #4 M_VBK
-0.3  0.3   0      0    -1      0.8      -3      0       0       0         0         0          0     0 #5 CV@LAAFIX
-0.3  0.3   0      0    -1      0.5      -3      0       0       0         0         0          0     0 # CV@LAAFIX2
#LW_female
#LO   HI    INIT        PRIOR       PR_type SD      PHASE   env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
0     1     6.81E-06    6.81E-06   0       0.8     -3      0       0       0         0         0          0     0 #WL_intercept_female 
1     5     3.2114      3.2114     0       0.8     -3      0       0       0         0         0          0     0 #WL_slope_female
#Female_maturity
1     60    29.34       29.34       0       0.8     -3      0       0       0         0         0          0     0 #mat_intercept #L50
-3    3     -1          -1          0       0.8     -3      0       0       0         0         0          0     0 #mat_slope 
#Fecundity
-3    3     1           1           0       0.8     -3      0       0       0         0         0          0     0 #Eggs/kg_inter_Fem
-3    3     0           0           0       0.8     -3      0       0       0         0         0          0     0 #Eggs/kg_slope_wt_Fem
#LW_Male
0     1     9.76E-06   9.76E-06    0       0.8     -3      0       0       0         0         0          0     0 #WL_intercept_male
1     5     3.1164     3.1164      0       0.8     -3      0       0       0         0         0          0     0 #WL_slope_male
#LO   HI    INIT        PRIOR       PR_type SD      PHASE   env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
#Allocate_R_by_areas_x_gmorphs
0     1     1           1           0       0.8     -3      0       0       0         0         0          0     0 #frac to GP 1 in area 1
#Allocate_R_by_areas
0     1     1           1           0       0.8     -3      0       0       0         0         0          0     0 #frac R in area 1
#Allocate_R_by_season
#LO   HI    INIT     PRIOR   PR_type SD      PHASE   env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
0     1     1           1           0       0.8     -3      0       0       0         0         0          0     0 #frac R in season 1
#CohortGrowDev
#SS3 manual says it must be given a value of 1 and a negative phase
#LO   HI    INIT     PRIOR   PR_type SD      PHASE   env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
0     1     1        1       -1      0       -4      0       0       0         0         0          0     0
#_Cond 0 #custom_MG-env_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-environ parameters
#_Cond 0 #custom_MG-block_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-block parameters
#_seasonal_effects_on_biology_parms
0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,L1,K,Malewtlen1,malewtlen2,L1,K
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#_Cond -4 #_MGparm_Dev_Phase
#
#_Spawner-Recruitment
3 #_SR_function
#_LO HI  INIT PRIOR PR_type SD     PHASE
5    15  7    7     -1      10     1 #Ln(R0)
0.2  1   0.70 0.70  0       0.09   -3 #steepness(h)
0    2   0.65 0.45  -1      0.2    -3 #sigmaR
-5   5   0    0     -1       1      -3 #Env_link_parameter
-5   5   0    0     -1      0.2    -3 # SR_R1_offset
0    0   0    0     -1      0      -3 # SR_autocorr
0 #_SR_env_link
0 #_SR_env_target_0=none;1=devs;_2=R0;_3=steepness
1 #do_recdev: 0=none; 1=devvector; 2=simple deviations
1980 # first year of main recr_devs; early devs can preceed this era
2012 # last year of main recr_devs; forecast devs start in following year
5 #_recdev phase
1 # (0/1) to read 13 advanced options
0 #_Cond 0 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
-4 #_recdev_early_phase
0 #_Cond 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
1 #_Cond 1 #_lambda for prior_fore_recr occurring before endyr+1
1980 #_last_early_yr_nobias_adj_in_MPD
1984 #_first_yr_fullbias_adj_in_MPD
2010 #_last_yr_fullbias_adj_in_MPD
2014 #_first_recent_yr_nobias_adj_in_MPDadj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)
0.81 #max bias
0 #period of cycles in recruitment
-5 #min rec_dev
5 #max rec_dev
0 #67 #_read_recdevs
#_end of advanced SR options
#
#Fishing Mortality info
0.3 # F ballpark for tuning early phases
-2001 # F ballpark year (neg value to disable)
3 # F_Method: 1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
4 # max F or harvest rate, depends on F_Method
# no additional F input needed for Fmethod 1
# read overall start F value; overall phase; N detailed inputs to read for Fmethod 2
# NUM ITERATIONS, FOR CONDITION 3
5 # read N iterations for tuning for Fmethod 3 (recommend 3 to 7)
#Fleet Year Seas F_value se phase (for detailed setup of F_Method=2)
#_initial_F_parms
#_LO HI INIT PRIOR  PR_type SD PHASE
0    1  0    0.0001 0       99 -1 #Fleet1_Commercial
0    1  0    0.0001 0       99 -1 #Fleet2_Ocean
0    1  0    0.0001 0       99 -1 #Fleet3_Estuary
0    1  0    0.0001 0       99 -1 #Fleet4_Shore
0    1  0    0.0001 0       99 -1 #Fleet5_Special Projects

#_Q_setup
#D=devtype(<0=mirror, 0/1=none, 2=cons, 3=rand, 4=randwalk)
#E=0=num/1=bio, F=err_type
#DISCUSS WHICH OPTION FOR Q (0 OR 1, OR 2)
#do power, env-var, extra SD, dev type
#do power for commercial CPUE, estimating extra SD, estimating q
0 0 0 0 #Fleet1_Commercial
0 0 0 0 #Fleet2_Ocean
0 0 0 0 #Fleet3_Estuary
0 0 0 0 #Fleet4_Shore
0 0 0 0 #Fleet5_Special projects
0 0 1 0 #Fleet6 Logbook
0 0 1 0 #Fleet7 Onboard Observer
0 0 1 0 #Fleet8 ORBS
#_Cond 0 #_If q has random component, then 0=read one parm for each fleet with random q; 1=read a parm for each year of index
#parameter lines for extra SD for fishery CPUE and surveys
#Prior type -1 = none, 0=normal, 1=symmetric beta, 2=full beta, 3=lognormal
#_LO    HI INIT PRIOR  PR_type SD PHASE
0       2  0.5  1      -1      99 3 # Fleet6 Logbook
0       2  0.5  1      -1      99 3 # Fleet7 Onboard Observer
0       2  0.5  1      -1      99 3 # Fleet8 ORBS
#
#Seltype(1,2*Ntypes,1,4) #SELEX_&_RETENTION_PARAMETERS
#discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead
#_Pattern Discard Male Special
24 0 0 0 #Fleet1_Commercial
24 0 0 0 #Fleet2_Ocean
24 0 0 0 #Fleet3_Estuary
24 0 0 0 #Fleet4_Shore
0 0 0 0 #Fleet_Special Projects
15 0 0 1 #Fleet6 Logbook (includes commercial only so ok to mirror)
15 0 0 2 #Fleet7 Onboard Observer (includes ocean boat only so ok to mirror)
15 0 0 2 #Fleet8 ORBS (includes ocean boat only so ok to mirror)
#Age_selectivity #set_to_1
10 0 0 0 #Fleet1_Commercial
10 0 0 0 #Fleet2_Ocean
10 0 0 0 #Fleet3_Estuary
10 0 0 0 #Fleet4_Shore
11 0 0 0 #Fleet5_Special Projects
10 0 0 0 #Fleet6 Logbook
10 0 0 0 #Fleet7 Onboard Observer
10 0 0 0 #Fleet8 ORBS
#Selectivity parameters
# ALL DOUBLE-NORMALS, BUT FIXED AS ASYMPTOTIC
#_LO    HI      INIT    PRIOR   PR_type SD      PHASE   env-var use_dev dev_minyr   dev_maxyr  dev_SD  Block   Block_Fxn
# Fleet group 1: Commercial
24      45      36      36      -1      50      4       0       0       0           0          0       0       0 # PEAK
-10      5       -8      -8      -1      50      -5      0       0       0           0          0       0       0 # TOP (logistic)
0       9       3.3     3.3     -1      50      5       0       0       0           0          0       0       0 # Asc WIDTH exp
-9       9       2       2       -1      50      5      0       0       0           0          0       0       0 # Desc WIDTH exp
-9      9       -8      -8      -1      50      -5      0       0       0           0          0       0       0 # INIT (logistic)
-9      9       -8       -8       -1      50    5      0       0       0           0          0       0       0 # FINAL (logistic)
## Fleet group 2: Rec Ocean
24      45      36      36      -1      50      4       0       0       0           0          0       0       0 # PEAK
-10      5       -5      -5      -1      50      -9      0       0       0           0          0       0       0 # TOP (logistic)
0       9       4     4     -1      50      5       0       0       0           0          0       1       1 # Asc WIDTH exp
0       9       8       8       -1      50      -9      0       0       0           0          0       0       0 # Desc WIDTH exp
-9      9       -8      -8      -1      50      -9      0       0       0           0          0       0       0 # INIT (logistic)
-9      9       8       8       -1      50      -9      0       0       0           0          0       0       0 # FINAL (logistic)
## Fleet group 3: Rec Estuary
10      45      16      16      -1      50      4       0       0       0           0          0       0       0 # PEAK
-10      5       -5      -5      -1      50      5      0       0       0           0          0       0       0 # TOP (logistic)
0       9       5       5       -1      50      5       0       0       0           0          0       0       0 # Asc WIDTH exp
-9       9       4      4       -1      50   5      0       0       0           0          0       0       0 # Desc WIDTH exp
-9      9       -8      -8      -1      50      -5      0       0       0           0          0       0       0 # INIT (logistic)
-9      9       -2       -2       -1      50      5      0       0       0           0          0       0       0 # FINAL (logistic)

## Fleet group 4: Rec Shore-based
6      20      6      6      -1      50      -4       0       0       0           0          0       0       0 # PEAK
-10      9    -9      -9      -1      50      -5      0       0       0           0          0       0       0 # TOP (logistic)
0       9       5       5       -1      50      -5       0       0       0           0          0       0       0 # Asc WIDTH exp
-9       9       4       4       -1      50      5      0       0       0           0          0       0       0 # Desc WIDTH exp
-9      9       8      8      -1      50      -5      0       0       0           0          0       0       0 # INIT (logistic)
-9      9       0       0       -1      50      5      0       0       0           0          0       0       0 # FINAL (logistic)
## Fleet group 5: Special Projects
1    1      1      1      -1      50      -5       0       0       0           0          0       0       0 # PEAK
1      1       1      1      -1      50      -5      0       0       0           0          0       0       0 # TOP (logistic)
#
1 #_custom block setup (0/1)
#Ascending limb parameter for recreational ocean fishery due to regulation change (size limit set to 10 inches in 2004)
#LO   HI   INIT   PRIOR   PR_TYPE   SD    PHASE
-3    0   -1      -1       -1       99    5 #Asc WIDTH, 2004-2014 (additive: base param + block param)
#-5    5   2        2       -1       99    5 #Shore time-varying selectivity (peak)
#-2    2   0        0       -1       99    5 #Shore time-varying selectivity (des width)
#-4    4   0        0       -1       99    5 #Shore time-varying selectivity (final logistic)
#
1 #logistic bounding
# Tag loss and Tag reporting parameters go next
0 # TG_custom: 0=no read; 1=read if tags exist
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0 #_placeholder if no parameters
1 #_Variance_adjustments_to_input_values
#F1 F2 F3 F4 F5    F6   F7  F8   
  0  0  0  0  0     0    0  0   #_add_to_survey_CV
  0  0  0  0  0     0    0  0   #_add_to_discard_stddev
  0  0  0  0  0     0    0  0  #_add_to_bodywt_CV
  1.012	0.0795	0.2162	0.2382  1 1        1   1 #_mult_by_lencomp_N
  1  1  1  1  1     1    1  1   #_mult_by_agecomp_N
  1  1  1  1  1     1    1  1   #_mult_by_size-at-age_N
# 
4 #_maxlambdaphase
1 #_sd_offset
10 # number of changes to make to default Lambdas (default value is 1.0)
# Like_comp codes: 1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch;
# 9=init_equ_catch; 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin
#like_comp   fleet/survey    phase    value    sizefreq_method
 1 6 1 1 1 # logbook
 1 7 1 1 1 # onboard CPFV
 1 8 1 1 1 # dockside ORBS
 4 1 1 1 1 #_lencomp: commercial
 4 2 1 1 1 #_lencomp: ocean boat
 4 3 1 1 1 #_lencomp: estuary boat
 4 4 1 1 1 #_lencomp: shore 
 5 2 1 1 1 #_agecomp: ocean
 5 1 1 1 1 #_agecomp: commercial
 5 5 1 1 1 #_agecomp: special projects
 
#
0 # (0/1) read specs for more stddev reporting
# 1 1 -1 5 1 5 # selex type, len/age, year, N selex bins, Growth pattern, N growth ages
# -5 16 27 38 46 # vector with selex std bin picks (-1 in first bin to self-generate)
# 1 2 14 26 40 # vector with growth std bin picks (-1 in first bin to self-generate)
999
