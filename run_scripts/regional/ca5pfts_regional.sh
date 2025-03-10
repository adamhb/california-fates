#!/bin/bash                                                                                                                                                       

#==========================================================================================
#
#    This script generates a case for a single-point simulation for a user-defined site. 
# It assumes all the site-specific data files (SITE_NAME) are located in the 
# SITE_BASE_PATH folder.
#
# Developed by: Marcos Longo < m l o n g o -at- l b l -dot- g o v >
#               18 Jun 2021 09:45 PDT
# Based on scripts developed by Ryan Knox and Shawn Serbin.

# Edit by: Xiulin Gao < x i u l i n g a o -at- l b l -dot- g o v>
# edits are made so this script runs regional simulation on cheyenne using NUOPC driver and 
# customized cliamte forcing (WRF forcing)

#     This script does not take any arguments. Instead, the beginning of the script has
# many variables to control the simulation settings.
#==========================================================================================


#--- Main settings.
export HESM="CTSM"              # Host "Earth System Model". (E3SM, CESM, CTSM)
export PROJECT="UCDV0027"            # Project (may not be needed)
export MACH="cheyenne"       # Machine used for preparing the case
export PARTITION="regular"
export RUN_TIME="12:00:00"
#---~---



#--- Case handling options.
export CASE_SUBMIT=false   # Should the script submit the run after creating case?
export CASE_WAIT=true     # Should the script lock the terminal until the run finishes?
                          #   (ignored if CASE_SUBMIT=false)
#---~---



#---~---
#    Debugging settings
#
# - DEBUG_LEVEL. The higher the number, the more information will be provided (at the 
#   expense of running slower).  0 means no debugging (typical setting for scientific 
#   analysis), 6 means very strict debugging (useful when developing the code).
# - USE_FATES. Logical flag (true or false).  This option allows running the native 
#   host land model (CLM or ELM) without FATES, which may be useful for some debugging.
#---~---
export DEBUG_LEVEL=0
export USE_FATES=true
#---~---



#---~---
#    Path settings:
#
# WORK_PATH: The main working path (typically <host_model>/cime/scripts)
# CASE_ROOT: The main path where to create the directory for this case.
# SIMUL_ROOT: The main path where to create the directory for the simulation output.
#
# In all cases, use XXXX in the part you want to be replaced with either E3SM or CTSM.
#---~---
export WORK_PATH="${HOME}/XXXX/cime/scripts"
export CASE_ROOT="/glade/u/home/adamhb/cases"
export SIMUL_ROOT="/glade/scratch/adamhb/archive"
#---~---


#---~---
#   Main case settings.  These variables will control compilation settings and the 
# case name for this simulation.  It is fine to leave these blank, in which case the
# script will use default settings.
#---~---
export COMP=""
export CO2=400
#export CASE_PREFIX="strip-AVBA-N01T09-transient"
export CASE_PREFIX="regional-test-ahb"
#export CASE_PREFIX="test"
#---~---


#---~---
#   Append git commit to the case name?
#---~---
export APPEND_GIT_HASH=false
#---~---



#---~---
#   Grid resolution.  If this is a standard ELM/CLM grid resolution, variables defined
# in the site information block below will be ignored.  In case you want to use the 
# site information, set RESOL to YYY_USRDAT. (The host model will be replaced later 
# in the script).
#---~---
export RESOL="147x151_california" # Grid resolution
#---~---


#---~---
#   Site information.  This is used only if RESOL is XXX_USRDAT.
#
#     To keep things in a somewhat standardised format, we recommend creating a base 
# directory (SITE_BASE_PATH) where each set of site data (SITE_NAME) will be stored.
# (The full path for the sets of a certain file being ${SITE_BASE_PATH}/${SITE_NAME}
#
#     The site-specific path should contain (1) a sub-directory CLM1PT
# containing the meteorological drivers, (2) the domain and surface data specific for
# this site, and (3) optionally the forest structure data (ED2 pss/css files).
# In case you would like to set other sites and are familiar with R, check for 
# Marcos' pre-processing tools on GitHub:
# 1.  https://github.com/mpaiao/FATES_Utils 
#     Tools available for meteorological driver and domain and surface data.
# 2.  https://github.com/mpaiao/ED2_Support_Files/tree/master/pss%2Bcss_processing
#     ED2 tools to generate pss/css files. A brief tutorial is provided in 
#     https://github.com/EDmodel/ED2/wiki/Initial-conditions (additional adaptations
#     might be needed for FATES).
#---~---
# Path containing all the data sets.
#export SITE_BASE_PATH="/glade/scratch/adamhb/my_subset_data"
export SITE_BASE_PATH="/glade/work/xiugao/fates-input"
# Sub-directory with data sets specific to this site.
export SITE_NAME="ca-wrf-grassland"
# mesh file (it must be in the SITE_NAME sub-directory).
export HLM_USRDAT_DOMAIN="wrf_CA_unstruct.nc"
# land mask file
export HLM_USRDAT_MASK="oakgrass-strip.nc"
#export HLM_USRDAT_MASK="wrf_CA_grass-woodland.nc"
# Surface data file (it must be in the SITE_NAME sub-directory).
export HLM_USRDAT_SURDAT="surfdata_wrf_CA_hist_16pfts_CMIP6_1981_c220715.nc"
# Initiation file for model start from prrevious restart file  
export HLM_FINIDAT=""
#export HLM_FINIDAT=""
# Calendar type for the meteorological drivers ('NO_LEAP' or 'GREGORIAN')
export METD_CALENDAR="NO_LEAP"
# CDL file containing FATES parameters (it must be in the SITE_NAME sub-directory).
#---~---


#---~---
#    Provide the parameter file, in case a site-specific file exists.  This file must
# be in the SITE_NAME sub-directory.  In case no site-specific parameter file is provided
# (i.e. FATES_PARAMS_BASE=""), the case will use the default parameters, but beware that
# results may be very bad.
#---~---
export FATES_PARAMS_BASE="ca_5pfts_100523_0009.cdl"
#---~---


#---~---
#    In case the inventory/lidar initialisation is sought, provide the file name of the
# control file specification (the control file should be in the SITE_NAME sub-directory). 
# Otherwise, do not set this variable (INVENTORY_BASE="")
#
#  For additional information, check
# https://github.com/NGEET/fates/wiki/Model-Initialization-Modes#Inventory_Format_Type_1
#---~---
export INVENTORY_BASE=""
#---~---


#---~---
#    XML settings to change.  In case you don't want to change any settings, leave this 
# part blank.  Otherwise, the first argument is the variable name, the second argument is
# the value.  Make sure to add single quotes when needed.  If you want, you can use the 
# generic XXX for variables that may be either CLM or ELM (lower case xxx will replace
# with the lower-case model name).  The code will interpret it accordingly.
#
# Example:
#
# No change in xml settings:
# xml_settings=()
#
# Changes in xml settings
# xml_settings=("DOUT_S_SAVE_INTERIM_RESTART_FILES TRUE"
#               "DOUT_S                            TRUE"
#               "STOP_N                            10"
#               "XXX_FORCE_COLDSTART               on"
#               "RUN_STARTDATE                     '2001-01-01'")
#---~---
xml_settings=("DEBUG                             FALSE"
              "RUN_STARTDATE                     1951-01-01"
              "STOP_N                            10"
              "STOP_OPTION                       nyears"
              "REST_N                            1"
              "RESUBMIT                          0"
              "CONTINUE_RUN                      FALSE"
              "YYY_FORCE_COLDSTART               on"
              "DATM_YR_START                     1951"
              "DATM_YR_END                       1979")
#---~---



#---~---
#    Parameter settings to change.  In case you don't want to change any parameter, 
# leave this part blank.  Otherwise, the first argument is the variable name, the second 
# argument is the PFT number (or zero if it is a global parameter), and the third argument 
# is the value.
#
# Example:
#
# No change in parameter settings:
#prm_settings=("fates_allom_d2ca_coefficient_min 1 0.012"
#               "fates_allom_d2ca_coefficient_max 1 0.012"
#               "fates_allom_crown_depth_frac  1  0.5"
#               "fates_mort_scalar_coldstress  1  0.6"
#               "fates_mort_scalar_coldstress  2  0.77"
#               "fates_mort_freezetol          1  -20"
#               "fates_nonhydro_smpsc          1  -461093"
#               "fates_nonhydro_smpsc          2  -281875"
#               "fates_mort_freezetol          2  -5"
#               "fates_recruit_seed_alloc_mature 1 0.3"
#               "fates_recruit_seed_alloc        1  0"
#               "fates_fire_bark_scaler          1  0.07"
#               "fates_fire_drying_ratio        66000"
#               "fates_fire_threshold           250"
#               "fates_fire_FBD                  5 5.5"
#               "fates_grperc                  2 0.45")
# Changes in xml settings
# prm_settings=("fates_phen_drought_threshold  0 -203943.2"
#               "fates_alloc_storage_cushion   1       1.2"
#               "fates_alloc_storage_cushion   2       2.4"
#               "fates_leaf_vcmax25top         1  30.94711"
#               "fates_leaf_vcmax25top         2  46.42066")
#---~---
#prm_settings=("fates_allom_amode                      1         2"
#              "fates_allom_agb1                       1         0.0628"
#              "fates_allom_agb2                       1         2.584"
#              "fates_allom_agb3                       1         -999.9"
#              "fates_allom_agb4                       1         -999.9"
#              "fates_allom_lmode                      1         2"
#              "fates_allom_d2bl1                      1         0.3"
#              "fates_allom_d2bl2                      1         1.64366"
#              "fates_allom_d2bl3                      1         -999.9"
#              "fates_allom_d2ca_coefficient_max       1         0.5186"
#              "fates_allom_d2ca_coefficient_min       1         0.5186"
#              "fates_allom_hmode                      1         2"
#              "fates_allom_d2h1                       1         46.5041"
#              "fates_allom_d2h2                       1         -0.01157"
#              "fates_allom_d2h3                       1         0.855482"
#              "fates_leaf_long                        1         1.5"
#              "fates_leaf_slamax                      1         0.006"
#              "fates_leaf_slatop                      1         0.006"
#              "fates_fire_bark_scaler                 1         0.15"
#              "fates_mort_bmort                       1         0.014"
#              "fates_wood_density                     1         0.72"
#              "fates_leaf_stomatal_slope_ballberry    1         8.88"
#              "fates_leaf_vcmax25top                  1         60"
#              "fates_allom_crown_depth_frac           1         0.2"
#              "fates_fire_alpha_SH                    1         0.1"
#              "fates_mort_hf_sm_threshold             1         0.4"
#              "fates_nonhydro_smpsc                   1         -650000"
#              "fates_mort_scalar_hydrfailure          1         0.2"
#              "fates_mort_scalar_cstarvation          1         0.2"
#              "fates_recruit_init_density             1         0.3"
#              "fates_mort_freezetol                   1         -5"
#              "fates_phen_evergreen                   1         1"
#              "fates_phen_season_decid                1         0"
#              "fates_phenflush_fraction               1         0"
#              "fates_fnrt_prof_a                      1         7"
#              "fates_fnrt_prof_b                      1         1"
#              "fates_recruit_seed_dbh_repro_threshold 1         90"
#              "fates_recruit_seed_alloc_mature        1         0"
#              "fates_turnover_fnrt                    1         3"    
#              "fates_alloc_storage_cushion            2         1.44616666666667"
#              "fates_allom_amode                      2         1"
#              "fates_allom_agb1                       2         0.00206078"
#              "fates_allom_agb2                       2         1.209238"
#              "fates_allom_agb3                       2         1.614535"
#              "fates_allom_agb4                       2         0"
#              "fates_allom_agb_frac                   2         1"
#              "fates_allom_lmode                      2         1"
#              "fates_allom_d2bl1                      2         0.000434"
#              "fates_allom_d2bl2                      2         1.915118" 
#              "fates_allom_d2bl3                      2         0"
#              "fates_allom_hmode                      2         3"
#              "fates_allom_d2h1                       2         0.1476171"
#              "fates_allom_d2h2                       2         0.6995105"
#              "fates_allom_dbh_maxheight              2         9"
#              "fates_allom_fmode                      2         1"
#              "fates_allom_fnrt_prof_a                2         8.10666666666667"
#              "fates_allom_fnrt_prof_b                2         6.06833333333333"
#              "fates_allom_smode                      2         2"
#              "fates_allom_l2fr                       2         1"
#              "fates_allom_d2ca_coefficient_max       2         0.02913376"
#              "fates_allom_d2ca_coefficient_min       2         0.02913376"
#              "fates_allom_blca_expnt_diff            2         -0.671656"
#              "fates_allom_la_per_sa_int              2         1000"
#              "fates_frag_seed_decay_rate             2         0"
#              "fates_fire_drying_ratio                0         38769.258"
##              "fates_fire_fuel_energy                 0         9079.75"
#              "fates_fire_nignitions                  0         0.07831"
#              "fates_grperc                           2         0.488666666666667"
#              "fates_leaf_slamax                      2         0.058909"
#              "fates_leaf_slatop                      2         0.058909"
#              "fates_leaf_stomatal_intercept          2         111673.333333333"
#              "fates_leaf_stomatal_slope_ballberry    2         16.47125"
#              "fates_leaf_vcmax25top                  2         56.152"
#              "fates_mort_hf_sm_threshold             2         0.5"
#              "fates_mort_scalar_cstarvation          2         2.68166666666667"
#              "fates_mort_scalar_hydrfailure          2         5.18166666666667"
#              "fates_nonhydro_smpsc                   2         -194166.666666667"
#              "fates_nonhydro_smpso                   2         -37347"
#              "fates_phen_drought_threshold           0         0.13575"
#              "fates_recruit_seed_alloc               2         0"
#              "fates_recruit_seed_dbh_repro_threshold 2         3.00916666666667"
#              "fates_recruit_seed_alloc_mature        2         0.2485"
#              "fates_recruit_height_min               2         0.244666666666667"
#              "fates_recruit_init_density             2         100"
#              "fates_rad_leaf_rhonir                  2         0.35"
#              "fates_rad_leaf_clumping_index          2         0.77"
#              "fates_turb_leaf_diameter               2         0.01249"
#              "fates_wood_density                     2         0.001"
#)
#---~---



#---~---
#    Additional settings for the host land model namelist.  First argument is the namelist
# variable name, and second argument (and beyond) is/are the values.  IMPORTANT: If the
# argument is a character, enclose the character part in quotes.  If multiple values are
# to be passed, the comma shall not be enclosed in quotes.  If the string is long, you can
# break them into multiple lines using backslash (\). The backslash will not be printed.
#
# Example:
#
# No change in namelist settings:
# hlm_settings=()
#
# Changes in xml settings
# hlm_settings=("hist_empty_htapes  .true."
#               "hist_fincl1        'GPP_BY_AGE', 'PATCH_AREA_BY_AGE', 'BA_SCLS',\
#                                   'FSH','EFLX_LH_TOT'")
#
# Notes:
# 1. For variable names, you can use hlm or HLM as a wildcard for the host land model. 
# 2. Note that variables in CLM and ELM are not always the same. The script will always
#    build the case, but runs will fail if the list of output variables includes any
#    variable that is not recognised by the host model.
#---~---
if ${USE_FATES}
then
   hlm_settings=("hist_empty_htapes .true."
                 "fates_spitfire_mode    1"
                 "use_fates .true." 
                 "use_fates_planthydro .false." 
                 "use_fates_ed_st3 .false." 
                 "use_fates_inventory_init .false." 
                 "use_bedrock .true." 
                 "use_fates_ed_prescribed_phys .false." 
                 "use_fates_logging .false." 
                 "use_fates_cohort_age_tracking .true." 
                 "fates_parteh_mode 1" 
                 "use_fates_sp .false." 
                 "hist_fincl1       'FATES_BASALAREA_SZPF','FATES_VEGC_PF','FATES_NPLANT_PF'")
else
   hlm_settings=("hist_empty_htapes .true."
                 "fates_parteh_mode      1"
                 "hist_fincl1       'AR','EFLX_LH_TOT','FSH','ELAI','FIRE','FLDS',\
                                    'FSDS','FSR','GPP','HR','NEP','ELAI','ESAI','TLAI',\
                                    'TSAI','TBOT','QBOT','PBOT','QVEGE','QVEGT','QSOIL',\
                                    'FSH_V','FSH_G','FGR','BTRAN','Qtau','ZWT','ZWT_PERCH',\
                                    'SMP','TSA','TV','TREFMNAV','TREFMXAV','TG','Q2M',\
                                    'RAIN','QDIRECT_THROUGHFALL','QDRIP','QOVER',\
                                    'QDRAI','QINTR','USTAR','U10'")
fi
#---~---


#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#                  CHANGES BEYOND THIS POINT ARE FOR SCRIPT DEVELOPMENT ONLY!
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------



#---~---
#  Define the host Earth System Model from upper-case CIME_MODEL.
#---~---
export HESM=$(echo ${HESM} | tr '[:lower:]' '[:upper:]')
#---~---

#--- Update cade and simulation paths, in case a generic name was provided.
export WORK_PATH=$(echo ${WORK_PATH}           | sed s@"XXXX"@"${HESM}"@g)
export CASE_ROOT=$(echo ${CASE_ROOT}           | sed s@"XXXX"@"${HESM}"@g)
export SIMUL_ROOT=$(echo ${SIMUL_ROOT}         | sed s@"XXXX"@"${HESM}"@g)
#---~---

#--- Current date.
export TODAY=$(date +"%Y-%m-%d")
#---~---

#--- Current path.
export HERE_PATH=$(pwd)
#---~---

#--- Site path.
export SITE_PATH="${SITE_BASE_PATH}/${SITE_NAME}"
#---~---


#---~---
#   Make changes to some of the settings based on the host model.
#---~---
case "${HESM}" in
E3SM)
   #---~---
   # E3SM-FATES
   #---~---

   #--- Set CIME model.
   export CIME_MODEL="e3sm"
   #---~---

   #--- Set host land model. Set both upper case and lower case for when needed.
   export hlm="elm"
   export HLM="ELM"
   #---~---

   #--- Main path for host model
   export HOSTMODEL_PATH=$(dirname $(dirname ${WORK_PATH}))
   #---~---

   #--- Additional options for "create_newcase"
   export NEWCASE_OPTS=""
   #---~---

   #--- Main source path for FATES.
   export FATES_SRC_PATH="${HOSTMODEL_PATH}/components/elm/src/external_models/fates"
   #---~---

   #--- In case compilates settings is not defined, use the default settings.
   if ${USE_FATES} && [[ "${COMP}" == "" ]]
   then
      export COMP="IELMFATES"
   elif [[ "${COMP}" == "" ]]
   then
      export COMP="IELMBGC"
   fi
   #---~---

   ;;
CTSM|CESM)
   #---~---
   # CESM-FATES or CTSM-FATES
   #---~---

   #--- Set CIME model.
   export CIME_MODEL="cesm"
   #---~---

   #--- Set host land model. Set both upper case and lower case for when needed.
   export hlm="clm"
   export HLM="CLM"
   #---~---


   #--- Main path for host model
   export HOSTMODEL_PATH=$(dirname $(dirname ${WORK_PATH}))
   #---~---

   #--- Additional options for "create_newcase"
   export NEWCASE_OPTS="--run-unsupported"
   #---~---

   #--- Main source path for FATES.
   export FATES_SRC_PATH="${HOSTMODEL_PATH}/src/fates"
   #---~---


   #--- In case compilates settings is not defined, use the default settings.
   if ${USE_FATES} && [[ "${COMP}" == "" ]]
   then
      export COMP="I2000Clm51Fates"
   elif [[ "${COMP}" == "" ]]
   then
      export COMP="I2000Clm51Bgc"
   fi
   #---~---

   ;;
esac
#---~---


#--- Define version of host model and FATES
export HLM_HASH="${HLM}-$(cd ${HOSTMODEL_PATH};  git log -n 1 --pretty=%h)"
export FATES_HASH="FATES-$(cd ${FATES_SRC_PATH}; git log -n 1 --pretty=%h)"
#---~---


#--- Define setting for single-point
#export V_HLM_USRDAT_NAME="WRF-SPARSE_NAME"
#---~---


#--- Substitute wildcards in the resolution with the actual model
#export RESOL=$(echo "${RESOL}" | sed s@"YYY"@"${HLM}"@g | sed s@"yyy"@"${hlm}"@g)
#---~---


#---~---
#   Set default case name prefix in case none was provided.
#---~---
if [[ "${CASE_PREFIX}" == "" ]]
then
   export CASE_PREFIX="SX_${COMP}_${MACH}_${TODAY}"
fi
#---~---


#---~---
#   Append github commit hash, or a simple host-model / FATES tag.
#---~---
if ${USE_FATES} && ${APPEND_GIT_HASH}
then
   export CASE_NAME="${CASE_PREFIX}_${HLM_HASH}_${FATES_HASH}"
elif ${APPEND_GIT_HASH}
then
   export CASE_NAME="${CASE_PREFIX}_${HLM_HASH}_BigLeaf"
elif ${USE_FATES}
then
   export CASE_NAME="${CASE_PREFIX}_${HLM}_FATES"
else
   export CASE_NAME="${CASE_PREFIX}_${HLM}_BigLeaf"
fi
#---~---


#---~---
#    Set paths for case and simulation.
#---~---
export CASE_PATH="${CASE_ROOT}/${CASE_NAME}"
export SIMUL_PATH="${SIMUL_ROOT}/${CASE_NAME}"
#---~---



#--- Namelist for the host land model.
export USER_NL_HLM="${CASE_PATH}/user_nl_${hlm}"
export USER_NL_DATM="${CASE_PATH}/user_nl_datm_streams"
#---~---





#---~---
#  In case the case exists, warn user before assuming it's fine to delete files.
#---~---
if [[ -s ${CASE_PATH} ]] || [[ -s ${SIMUL_PATH} ]]
then
   #---~---
   #    Check with user if it's fine to delete existing case.
   #---~---
   echo    " Case directories (${CASE_NAME}) already exist, proceeding will delete them."
   echo -n " Proceed (y|N)?   "
   read proceed
   proceed=$(echo ${proceed} | tr '[:upper:]' '[:lower:]')
   #---~---


   #---~---
   #    We give one last chance for users to cancel before deleting the files.
   #---~---
   case "${proceed}" in
   y|yes)
      echo "---------------------------------------------------------------------"
      echo " FINAL WARNING!"
      echo " I will start deleting files in 5 seconds."
      echo " In case you change your mind, press Ctrl+C before the time is over."
      echo "---------------------------------------------------------------------"
      when=6
      echo -n " - "
      while [[ ${when} -gt 1 ]]
      do
         let when=${when}-1
         echo -n " ${when}..."
         sleep 1
      done
      echo " Time is over!"



      #--- Delete files.
      /bin/rm -rvf ${CASE_PATH} ${SIMUL_PATH}
      #---~---

      ;;
   *)
      echo " - Script interrupted, files were kept."
      exit 0
      ;;
   esac
   #---~---
fi
#---~---



#---~---
#    Move to the main cime path.
#---~---
cd ${WORK_PATH}
#---~---


#---~---
#    Create the new case
#---~---
./create_newcase --case=${CASE_PATH} --res=${RESOL} --compset=${COMP} --mach=${MACH}       \
   --project=${PROJECT}  ${NEWCASE_OPTS}
cd ${CASE_PATH}
#---~---


#---~---
#     Set the CIME output to the main CIME path.
#---~---
./xmlchange CIME_OUTPUT_ROOT="${SIMUL_ROOT}"
./xmlchange DOUT_S_ROOT="${SIMUL_PATH}"
./xmlchange PIO_DEBUG_LEVEL="${DEBUG_LEVEL}"
./xmlchange JOB_WALLCLOCK_TIME="${RUN_TIME}"
./xmlchange JOB_QUEUE="${PARTITION}"
./xmlchange PIO_TYPENAME="pnetcdf"
./xmlchange DOUT_S_SAVE_INTERIM_RESTART_FILES="TRUE"
#---~---


#---~---
#     In case this is a user-defined site simulation, set the user-specified paths.
# DATM_MODE must be set to CLM1PT, even when running E3SM-FATES.
#---~---
case "${RESOL}" in
147x151_california)
   ./xmlchange DATM_MODE="CLMGSWP3v1"
   ./xmlchange CLM_CO2_TYPE="constant"
   ./xmlchange CCSM_CO2_PPMV=${CO2}
   ./xmlchange CALENDAR="${METD_CALENDAR}"
   #./xmlchange ${V_HLM_USRDAT_NAME}="${SITE_NAME}"
   ./xmlchange ATM_DOMAIN_MESH="${SITE_PATH}/${HLM_USRDAT_DOMAIN}"
   ./xmlchange LND_DOMAIN_MESH="${SITE_PATH}/${HLM_USRDAT_DOMAIN}"
   ./xmlchange MASK_MESH="${SITE_PATH}/${HLM_USRDAT_MASK}"
#   ./xmlchange DIN_LOC_ROOT_CLMFORC="${SITE_BASE_PATH}"

   ;;
esac
#---~---


#---~---
#     Set the PE layout for a single-site run (unlikely that users would change this).
#---~---
./xmlchange NTASKS_ATM=40    # if use all processors give  -4
./xmlchange NTASKS_LND=40
./xmlchange NTASKS_ROF=40
./xmlchange NTASKS_ICE=40
./xmlchange NTASKS_OCN=40
./xmlchange NTASKS_CPL=40
./xmlchange NTASKS_GLC=40
./xmlchange NTASKS_WAV=40
./xmlchange NTASKS_ESP=1

./xmlchange NTHRDS_ATM=1
./xmlchange NTHRDS_LND=1
./xmlchange NTHRDS_ROF=1
./xmlchange NTHRDS_ICE=1
./xmlchange NTHRDS_OCN=1
./xmlchange NTHRDS_CPL=1
./xmlchange NTHRDS_GLC=1
./xmlchange NTHRDS_WAV=1
./xmlchange NTHRDS_ESP=1

./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_LND=0
./xmlchange ROOTPE_ROF=0
./xmlchange ROOTPE_ICE=0
./xmlchange ROOTPE_OCN=0
./xmlchange ROOTPE_CPL=0
./xmlchange ROOTPE_GLC=0
./xmlchange ROOTPE_WAV=0
./xmlchange ROOTPE_ESP=0

#---~---



#---~---
#     Change XML configurations if needed.
#---~---
if [[ ${#xml_settings[*]} -gt 0 ]]
then
   #--- Loop through the options to update.
   echo " + Update XML settings."
   for x in ${!xml_settings[*]}
   do
      #--- Retrieve settings.
      xml_id=$(echo ${xml_settings[x]}  | awk '{print $1}')
      xml_id=$(echo ${xml_id}           | sed s@"YYY"@${HLM}@g | sed s@"yyy"@${hlm}@g)
      xml_val=$(echo ${xml_settings[x]} | awk '{print $2}')
      echo " ID = ${xml_id}; VAL = ${xml_val}"
      #---~---

      #--- Update settings.
      ./xmlchange ${xml_id}="${xml_val}"
      #---~---

   done
   #---~---
else
   #--- No changes needed.
   echo " + No XML changes required."
   #---~---
fi
#---~---


#--- Initial case set up.
./case.setup
#---~---


#--- Define meteorological driver path
DATM_PATH="${SITE_PATH}/CLM1PT_data"

#--- List all files with full path so we can append this to user_nl_datm

DATM_FILE=$(/bin/ls -m ${DATM_PATH}/{1951..2020}*.nc)
SOLAR_FILE="CLMGSWP3v1.Solar:datafiles = ${DATM_FILE}"
PRECIP_FILE="CLMGSWP3v1.Precip:datafiles = ${DATM_FILE}"
TPQW_FILE="CLMGSWP3v1.TPQW:datafiles = ${DATM_FILE}"

# if specific forcing files (e.g. files between 1981 and 2020,usually same as DATM_YR_START and DATM_YR_END) are needed instead of all files 

#DATM_FILE=$(/bin/ls -d -m ${DATM_PATH}/{1981..2020}*.nc | tr '\n' '\\')

#---~---
#    Append the surface and forcing data information to the namelist, in case we are using 
#---~---
case "${RESOL}" in
147x151_california)
   # Append surface data file to the namelist.
   HLM_SURDAT_FILE="${SITE_PATH}/${HLM_USRDAT_SURDAT}"
   MESH_FILE="${SITE_PATH}/${HLM_USRDAT_DOMAIN}"
  echo "fsurdat = '${HLM_SURDAT_FILE}'"    >> ${USER_NL_HLM}
  echo "CLMGSWP3v1.Solar:mapalgo = nn"   >> ${USER_NL_DATM}
  echo "CLMGSWP3v1.Solar:tintalgo = linear" >> ${USER_NL_DATM}
  echo "CLMGSWP3v1.Solar:meshfile = ${MESH_FILE}"  >> ${USER_NL_DATM}
  echo "${SOLAR_FILE}" | sed -e 's/$/ \\/' -e '$s/ \\$//' >> ${USER_NL_DATM}
#  echo "CLMGSWP3v1.Solar:datafiles = '${DATM_FILE}'" >> ${USER_NL_DATM}                                                                                     
  echo "CLMGSWP3v1.Precip:mapalgo = nn"  >> ${USER_NL_DATM}
  echo "CLMGSWP3v1.Precip:tintalgo = linear" >> ${USER_NL_DATM}
  echo "CLMGSWP3v1.Precip:meshfile = ${MESH_FILE}" >> ${USER_NL_DATM}
  echo "${PRECIP_FILE}" | sed -e 's/$/ \\/' -e '$s/ \\$//' >> ${USER_NL_DATM}
#  echo "CLMGSWP3v1.Precip:datafiles = ${DATM_FILE}" >> ${USER_NL_DATM}                                                                                    
  echo "CLMGSWP3v1.TPQW:mapalgo = nn"    >> ${USER_NL_DATM}
  echo "CLMGSWP3v1.TPQW:tintalgo = linear" >> ${USER_NL_DATM}
  echo "CLMGSWP3v1.TPQW:meshfile = ${MESH_FILE}"   >> ${USER_NL_DATM}
  echo "${TPQW_FILE}" | sed -e 's/$/ \\/' -e '$s/ \\$//'  >> ${USER_NL_DATM}
#  echo "CLMGSWP3v1.TPQW:datafiles = ${DATM_FILE}" >> ${USER_NL_DATM}                                                                                     
   ;;
esac
#---~---


#--- Preview namelists
./preview_namelists
#---~---


#---~---
#
# WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! 
# WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! 
# WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! 
# WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! 
#
#     This part modifies the stream file, in case incoming long wave radiation is not
# available.  You should not need to change anything in here.
#---~---
# Find the first met driver.
 case "${RESOL}" in
 147x151_california)
   #--- Define files with meteorological driver settings.
   HLM_USRDAT_ORIG="${SIMUL_PATH}/run/datm.streams.txt.CLM1PT.${RESOL}"
   HLM_USRDAT_USER="${SIMUL_PATH}/user_datm.streams.txt.CLM1PT.${RESOL}"
   #---~---
   

   ANY_METD_NC=$(/bin/ls -1 ${DATM_PATH}/????-??.nc 2> /dev/null | wc -l)
   if [[ ${ANY_METD_NC} ]]
   then
      #--- Load one netCDF file.
       METD_NC_1ST=$(/bin/ls -1 ${DATM_PATH}/????-??.nc 2> /dev/null | head -1)
      ANY_FLDS=$(ncdump -h ${METD_NC_1ST} 2> /dev/null | grep FLDS | wc -l)
      if [[ ${ANY_FLDS} -eq 0 ]]
      then
         #--- Incoming long wave radiation is absent.  Modify the stream file
         /bin/cp ${HLM_USRDAT_ORIG} ${HLM_USRDAT_USER}
         $(sed -i '@FLDS@d' ${HLM_USRDAT_USER})
         #---~---
      fi
      #---~---
   else
      #--- Report error.
      echo "FATAL ERROR!"
      echo " ANY_METD_NC = ${ANY_METD_NC}"
      echo " Meteorological drivers not found in ${DATM_PATH}".
      echo " Make sure all the met driver files are named as yyyy-mm.nc"
      exit 91
      #---~---
   fi
   #---~---
   ;;
esac
#---~---


#---~---
#     Include settings for initiation file from restart file of last simulaiton
#---~---
if ${USE_FATES} && [[ "${HLM_FINIDAT}" != "" ]]
then 
    
   #---Set initiation file with full path. 
   FINIDAT_FILE="${SITE_PATH}/${HLM_FINIDAT}"
   #---~---

   #--- Instruct the host land model to use the restart file.
   touch ${USER_NL_HLM}
   echo "finidat = '${FINIDAT_FILE}'" >> ${USER_NL_HLM}
   #---~---

fi

#---~---
#     Include settings for the inventory initialisation.
#---~---
if ${USE_FATES} && [[ "${INVENTORY_BASE}" != "" ]]
then

   #--- Set inventory file with full path.
   INVENTORY_FILE="${SITE_PATH}/${INVENTORY_BASE}"
   #---~---


   #--- Instruct the host land model to use the modified parameter set. 
   touch ${USER_NL_HLM}
   echo "use_fates_inventory_init = .true."                   >> ${USER_NL_HLM}
   echo "fates_inventory_ctrl_filename = '${INVENTORY_FILE}'" >> ${USER_NL_HLM}
   #---~---

fi
#---~---


#---~---
#     Create parameter file, and change PFT parameters if needed.
#---~---
if ${USE_FATES}
then

   #--- Identify original parameter file
   if [[ "${FATES_PARAMS_BASE}" == "" ]]
   then
      FATES_PARAMS_ORIG="${FATES_SRC_PATH}/parameter_files/fates_params_default.cdl"
   else
      FATES_PARAMS_ORIG="/glade/scratch/adamhb/my_subset_data/ca-wrf-grassland/ca_5pfts_100523_0009.cdl"
   fi
   #---~---


   #--- Create a local parameter file.
   echo " + Create local parameter file from $(basename ${FATES_PARAMS_ORIG})."
   FATES_PARAMS_CASE="${CASE_PATH}/fates_params_${CASE_NAME}.nc"
   ncgen -o ${FATES_PARAMS_CASE} ${FATES_PARAMS_ORIG}
   #---~---


   #---~---
   #   Check whether or not to edit parameters
   #---~---
   if [[ ${#prm_settings[*]} -gt 0 ]]
   then

      #--- Set python script for updating parameters.
      MODIFY_PARAMS_PY="${FATES_SRC_PATH}/tools/modify_fates_paramfile.py"
      #---~---


      #--- Loop through the parameters to update.
      echo " + Create local parameter file."
      for p in ${!prm_settings[*]}
      do
         #--- Retrieve settings.
         prm_var=$(echo ${prm_settings[p]} | awk '{print $1}')
         prm_pft=$(echo ${prm_settings[p]} | awk '{print $2}')
         prm_val=$(echo ${prm_settings[p]} | awk '{print $3}')
         #---~---

         #--- Update parameters.
         case ${pft_num} in
         0)
            ${MODIFY_PARAMS_PY} --var ${prm_var} --val ${prm_val}                          \
               --fin ${FATES_PARAMS_CASE} --fout ${FATES_PARAMS_CASE} --O
            ;;
         *)
            ${MODIFY_PARAMS_PY} --var ${prm_var} --pft ${prm_pft} --val ${prm_val}         \
               --fin ${FATES_PARAMS_CASE} --fout ${FATES_PARAMS_CASE} --O
            ;;
         esac
         #---~---
      done
      #---~---
   fi
   #---~---


   #--- Instruct the host land model to use the modified parameter set. 
   touch ${USER_NL_HLM}
   echo "fates_paramfile = '${FATES_PARAMS_CASE}'" >> ${USER_NL_HLM}
   #---~---
else
   #--- No changes needed.
   echo " + No parameter settings required."
   #---~---
fi
#---~---


#---~---
# Add other variables to the namelist of the host land model.
#---~---
if  [[ ${#hlm_settings[*]} -gt 0 ]]
then
   #--- Loop through the options to update.
   echo " + Update host land model settings."
   for h in ${!hlm_settings[*]}
   do
      #--- Retrieve settings.
      hlm_id=$(echo ${hlm_settings[h]}  | awk '{print $1}')
      hlm_id=$(echo ${hlm_id}           | sed s@"YYY"@${HLM}@g | sed s@"yyy"@${hlm}@g)
      hlm_val=$(echo ${hlm_settings[h]} | awk '{for(i=2;i<=NF;++i)printf $i""FS ; print ""}')
      #---~---

      #--- Check whether or not this is a FATES variable.
      is_fates_var=$(echo ${hml_id} | grep -i fates | wc -l)
      #---~---


      #---~---
      #   Check whether this is a FATES variable.  In case it is and USE_FATES is false,
      # we ignore the variable.
      #---~---
      if ${USE_FATES} || [[ ${is_fates_var} -eq 0 ]]
      then
         #--- Update namelist
         echo " ID = ${hlm_id}; VAL = ${hlm_val}"
         touch ${USER_NL_HLM}
         echo "${hlm_id} = ${hlm_val}" >> ${USER_NL_HLM}
         #---~---
      else
         #--- Do not update.  Instead, warn the user.
         echo " Ignoring ${hlm_id} as this a FATES variable, and USE_FATES=false."
         #---~---
      fi
      #---~---
   done
   #---~---
else
   #--- No changes needed.
   echo " + No PFT parameter settings required."
   #---~---
fi
#---~---



#--- Build case.
./case.build --clean
./case.build 2>&1 | tee ./cb_output.log
#---~---



#--- Check that job ran successfully. If so, see if the case should be submitted.
is_success=$(grep "MODEL BUILD HAS FINISHED SUCCESSFULLY" ./cb_output.log | wc -l)
if [[ ${is_success} -eq 0 ]]
then
   echo " Model was not successfully built, check logs..."
   exit 99
elif ${CASE_SUBMIT} && ${CASE_WAIT}
then
   echo " Submit the case."
   ./case.submit 2>&1 | tee ./cs_output.log
   echo " Case simulation ended."
elif ${CASE_SUBMIT}
then
   echo " Submit the case."
   ./case.submit 1> ./cs_output.log 2>&1 &
   echo " Simulation is running in background.  Check progress by using:"
   echo "    tail -f ${CASE_PATH}/cs_output.log"
else
   echo " Case is ready to run. You can submit by using:"
   echo "    (cd ${CASE_PATH}; ./case.submit | tee ./cs_output.log)"
fi
#---~---


#--- Return to the original path.
cd ${HERE_PATH}
#---~---

