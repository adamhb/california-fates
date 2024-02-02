#!/bin/bash

# Case build script for CLM-FATES single point simulations
# with custom soil and meteorology for ensemble or single-instance
# simulations.

# Adam Hanbury-Brown -- 080823
# This script was developed based on prior
# scripts developed by Marcos Longo, Polly Buotte, and Jessie Needham

#Name the case
export CASE_NAME="STAN_equilibrium_110623"
export NINST=36
export CIME_PATH="${HOME}/CTSM/cime/scripts" # dir for cime scripts
export HERE_PATH=$(pwd)
export HOSTMODEL_PATH=${HOME}/CTSM
export FATESMODEL_PATH="${HOSTMODEL_PATH}/src/fates"
export HLM_HASH="${HLM}-$(cd ${HOSTMODEL_PATH};   git log -n 1 --pretty=%h)"
export FATES_HASH="FATES-$(cd ${FATESMODEL_PATH}; git log -n 1 --pretty=%h)"
export CASE_NAME="${CASE_NAME}_${HLM_HASH}_${FATES_HASH}"
export CASE_ROOT="/glade/u/home/adamhb/cases" # dir to put cases
export CASE_PATH="${CASE_ROOT}/${CASE_NAME}"


# Set fates parameter file(s)

# Base name of your parameter file (without the _0001, etc)
export PARAM_FILE_BASE_NAME=ca_5pfts_100523

# Directory where the parameter files are stored
export PARAM_DIR_BASE=${HOME}/ahb_params/fates_api_25
export PARAM_DIR=${PARAM_DIR_BASE}/ensembles/STAN_equilibrium_110623
export PARAM_FILE_BASE_PATH=${PARAM_DIR}/${PARAM_FILE_BASE_NAME}

# Define the component settings
export RES="CLM_USRDAT"
export COMPSET="I2000Clm51Fates"
export MACH="cheyenne"       
export PROJECT="UCDV0027"

# Set driver data
export SITE_NAME="stan_wrf_1950_1980" # dir for site-specific datasets
export SITE_BASE_PATH="/glade/scratch/adamhb/my_subset_data" # dir for site datasets
export SITE_PATH="${SITE_BASE_PATH}/${SITE_NAME}"
export SURF_DATA="surfdata_my_point_hist_16pfts_Irrig_CMIP6_ahb_simyr2000_c230323.nc"
export SURF_PATH="${SITE_PATH}/${SURF_DATA}"
export METD_CALENDAR="NO_LEAP"

# Run settings 
export RUN_TIME="12:00:00"
export QUEUE="economy"
export DEBUG_LEVEL=0

# Output settings
export SIMUL_ROOT="/glade/scratch/adamhb/archive" # dir to put output
export SIMUL_PATH="${SIMUL_ROOT}/${CASE_NAME}"

cd ${CIME_PATH}

# Create case
./create_newcase --case=${CASE_PATH} --res=${RES} --compset=${COMPSET} --mach=${MACH} --project=${PROJECT} --run-unsupported --ninst=${NINST}

cd ${CASE_PATH}

# Driver data settings
./xmlchange CLM_USRDAT_NAME="${SITE_NAME}"
./xmlchange DIN_LOC_ROOT_CLMFORC="${SITE_BASE_PATH}"
./xmlchange DATM_MODE="1PT"
./xmlchange CLM_CO2_TYPE="constant"
./xmlchange CCSM_CO2_PPMV=280
./xmlchange PTS_LON=240.0213
./xmlchange PTS_LAT=38.1776
./xmlchange DATM_YR_START=1951 #get 1950 data in there too if it exists (check email from Xiulin)
./xmlchange DATM_YR_END=1979
./xmlchange CLM_FORCE_COLDSTART="on"
DATM_PATH="${SITE_PATH}/CLM1PT_data"

# Run settings
./xmlchange STOP_OPTION="nyears"
./xmlchange STOP_N=100
./xmlchange RESUBMIT=3
./xmlchange RUN_STARTDATE="1900-01-01"
./xmlchange CALENDAR="${METD_CALENDAR}"
./xmlchange JOB_WALLCLOCK_TIME="${RUN_TIME}"
./xmlchange JOB_QUEUE=${QUEUE}

# Output settings
./xmlchange CIME_OUTPUT_ROOT="${SIMUL_ROOT}"
./xmlchange DOUT_S_ROOT="${SIMUL_PATH}"
./xmlchange PIO_DEBUG_LEVEL="${DEBUG_LEVEL}"


# Create user_nl_clm for each ensemble member

for x in `seq 1 1 $NINST`; do

expstr=$(printf %04d $x)
echo $expstr

cat >> user_nl_clm_${expstr} <<EOF
fsurdat = '${SURF_PATH}'
hist_empty_htapes = .true. 
fates_spitfire_mode = 1 
fates_paramfile = '${PARAM_FILE_BASE_PATH}_${expstr}.nc' 
use_fates = .true. 
use_fates_planthydro = .false. 
use_fates_ed_st3 = .false. 
use_fates_inventory_init = .false. 
use_bedrock = .true. 
use_fates_ed_prescribed_phys = .false. 
use_fates_logging = .false. 
use_fates_cohort_age_tracking = .true. 
fates_parteh_mode = 1 
use_fates_sp = .false. 
hist_fincl1 = 'FATES_NPLANT_PF','FATES_MORTALITY_PF','FATES_NPATCHES', 'FATES_VEGC_PF','FATES_MORTALITY_CANOPY_SZAP','FATES_MORTALITY_USTORY_SZAP', 'FATES_MORTALITY_BACKGROUND_SZPF','FATES_MORTALITY_HYDRAULIC_SZPF', 'FATES_MORTALITY_CSTARV_SZPF','FATES_MORTALITY_FIRE_SZPF', 'FATES_MORTALITY_CROWNSCORCH_SZPF','FATES_MORTALITY_CANOPY_SZ', 'FATES_MORTALITY_USTORY_SZ','FATES_PATCHAREA_AP','FATES_CANOPYAREA_AP', 'FATES_VEGC_AP','FATES_CROWNAREA_CLLL','FATES_DDBH_CANOPY_SZAP', 'FATES_DDBH_USTORY_SZAP','FATES_NPLANT_SZAPPF','FATES_NPLANT_SZPF', 'FATES_NPLANT_ACPF','FATES_NPLANT_CANOPY_SZPF','FATES_NPLANT_USTORY_SZPF', 'FATES_STOREC_CANOPY_SZPF','FATES_STOREC_USTORY_SZPF','FATES_CWD_ABOVEGROUND_DC', 'FATES_DDBH_SZPF','FATES_BASALAREA_SZPF','FATES_RECRUITMENT_PF','FATES_GPP', 'FATES_GPP_SZPF','FATES_NPP_SZPF','FATES_NPP_PF','FATES_NPP_APPF','FATES_NCOHORTS', 'FATES_NPATCH_AP','FATES_VEGC_APPF','FATES_SCORCH_HEIGHT_APPF', 'FATES_LAISUN_Z_CLLL','FATES_LAISHA_Z_CLLL','FATES_LAISUN_Z_CLLLPF', 'FATES_LAISHA_Z_CLLLPF','FATES_PARSUN_Z_CLLLPF','FATES_PARSHA_Z_CLLLPF', 'FATES_LAI_AP','QVEGT','QVEGE','BTRAN','QSOIL','TLAI','TBOT','RAIN', 'QBOT','Q2M','FATES_SEED_PROD_USTORY_SZ','FATES_SEED_PROD_CANOPY_SZ', 'FATES_SEEDS_IN','FATES_VEGC_ABOVEGROUND', 'FATES_VEGC_ABOVEGROUND_SZPF', 'FATES_LITTER_IN','FATES_LITTER_OUT', 'FATES_CROWNAREA_PF','FATES_CANOPYCROWNAREA_PF','FATES_CANOPYAREA_HT', 'FATES_BURNFRAC','FATES_IGNITIONS','FATES_FIRE_INTENSITY_BURNFRAC', 'FATES_DISTURBANCE_RATE_FIRE','FATES_FUEL_AMOUNT','FATES_SEED_BANK','FATES_SEEDBANK_PF' 'FATES_SEEDS_IN','FATES_SEED_ALLOC_SZPF','FATES_MORTALITY_SENESCENCE_SZPF', 'FATES_AUTORESP_SZPF','FATES_MAINTAR_SZPF','SMP','FATES_CROWNAREA_PF', 'FATES_PARPROF_DIR_CLLL','FATES_PARPROF_DIF_CLLL','FATES_PARPROF_DIR_CLLLPF', 'FATES_PARPROF_DIF_CLLLPF','FATES_FUEL_AMOUNT_AP', 'FATES_FIRE_INTENSITY_BURNFRAC_AP', 'FATES_BURNFRAC_AP', 'FATES_FUEL_AMOUNT_APFC', 'FATES_FUEL_AMOUNT','FATES_FDI', 'FATES_FIRE_INTENSITY','FATES_FUELCONSUMED','FATES_SCORCH_HEIGHT_APPF', 'FATES_FUEL_MEF','FATES_FUEL_EFF_MOIST','FATES_FUEL_MOISTURE_FC','FATES_ROS', 'FATES_NESTEROV_INDEX','FATES_DISTURBANCE_RATE_FIRE','FATES_NET_C_UPTAKE_CLLL', 'FATES_CROWNAREA_CLLL','FATES_FUEL_BULKD','FATES_FUEL_SAV','FATES_CANOPYCROWNAREA_APPF', 'FATES_MORTALITY_FREEZING_SZPF','FATES_MORTALITY_IMPACT_SZPF', 'FATES_CROWNAREA_APPF','SNOW','SOILPSI','H2OSOI','RH2M','Rnet','Rainf','TSA','FATES_STOREC_PF','FATES_LEAFC_PF','FATES_MORTALITY_TERMINATION_SZPF','FATES_MORTALITY_LOGGING_SZPF','FATES_MORTALITY_FREEZING_SZPF','FATES_MORTALITY_AGESCEN_SZPF','FATES_MORTALITY_IMPACT_SZPF','FATES_NPLANT_RESPROUT_PF'
EOF

done


# Set the PE layout

./xmlchange NTASKS_ATM=1
./xmlchange NTASKS_CPL=1
./xmlchange NTASKS_GLC=1
./xmlchange NTASKS_OCN=1
./xmlchange NTASKS_WAV=1
./xmlchange NTASKS_ICE=1
./xmlchange NTASKS_LND=1
./xmlchange NTASKS_ROF=1
./xmlchange NTASKS_ESP=1
./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_CPL=0
./xmlchange ROOTPE_GLC=0
./xmlchange ROOTPE_OCN=0
./xmlchange ROOTPE_WAV=0
./xmlchange ROOTPE_ICE=0
./xmlchange ROOTPE_LND=0
./xmlchange ROOTPE_ROF=0
./xmlchange ROOTPE_ESP=0
./xmlchange NTHRDS_ATM=1
./xmlchange NTHRDS_CPL=1
./xmlchange NTHRDS_GLC=1
./xmlchange NTHRDS_OCN=1
./xmlchange NTHRDS_WAV=1
./xmlchange NTHRDS_ICE=1
./xmlchange NTHRDS_LND=1
./xmlchange NTHRDS_ROF=1
./xmlchange NTHRDS_ESP=1


# Set up the case
./case.setup
#./preview_namelists # Creates namelist and other model input files by running each
# component's buildnml script.

./case.build --clean
./case.build

# Return to the original path.
cd ${HERE_PATH}
echo "Created new case: ${CASE_PATH}"
