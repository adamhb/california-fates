#!/bin/bash
#---------------------------------------
#
# Polly Buotte; June 16, 2023
#
# Creates and builds a multi-instance, single point case
# Does not submit so you can double check settings if you want to
# Runs from anywhere, so you can store it in any directory
#
#---------------------------------------
#change this to point to your CTSM/cime/scripts directory
export cime_scripts_root=/glade/u/home/pbuotte/git/ctsm_220712/cime/scripts

#change this to point to the directoiry where you want the case to be created 
export CASE_ROOT=/glade/u/home/pbuotte/Earthshot/fates_cases

#change this to what you want the actual case directoty to be called - it will be created
export TAG=UTA_9pft_ensemble
export CASE_NAME=${CASE_ROOT}/${TAG}

#change this to point to the base name of your parameter file (without the _0001, etc)
export PARAM_FILE=fates_params_9BET_sizemort_6_8_9.nc

#change this to point to the directory where the paramneter files are stored
export PARAM_DIR=/glade/u/home/pbuotte/Earthshot/input_data/param_files/AZ_9PFT

#change this to the directory where the surface data file is stored
export SURFDAT_DIR=/glade/

#change this to the name of your surface data file
export SURFDAT_FILE=filename

#change this to the number of parameter files (ensemble members) you want to run
export ninst=18

cd ${cime_scripts_root}

#I think I have your project code here, but double check!
./create_newcase --case=${CASE_NAME} --compset 2000_DATM%GSWP3v1_CLM50%FATES_SICE_SOCN_SROF_SGLC_SWAV --res CLM_USRDAT --mach cheyenne --project UCBK0034 --run-unsupported -q regular --compiler intel --ninst=$ninst --multi-driver

cd ${CASE_NAME}

#----Set run type preferences, change these as you need to-------
./xmlchange STOP_N=30
./xmlchange RUN_STARTDATE='1970-01-01'
./xmlchange STOP_OPTION=nyears
./xmlchange DATM_YR_START=1970
./xmlchange DATM_YR_END=2000
./xmlchange DATM_YR_ALIGN=1970

./xmlchange PTS_LAT=0.733
./xmlchange PTS_LON=32.693

./case.setup
./xmlchange JOB_QUEUE=economy

#---------change namelist options in user_nl_clm----------
# set hist_nhtfrq=0 for monthly
# change hist_mfilt to be equal to your STOP_N+1
# if your parameter files are named base_name_1.nc instead of base_name_0001.nc, change the
# _$expstr to _$ending in the fates_paramfile line below
    for x  in `seq 1 1 $ninst`; do
        expstr=$(printf %04d $x)
        ending=$x
        echo $expstr
        cat > user_nl_clm_$expstr <<EOF
use_fates = .true.
fates_paramfile = '${PARAM_DIR}/${PARAM_FILE}_$expstr'
hist_nhtfrq = -8760
fates_spitfire_mode=0
use_fates_inventory_init = .false.
hist_mfilt = 201
fsurdat = '${SURFDAT_DIR}/${SURFDAT_FILE}'
EOF
	done
./case.build

