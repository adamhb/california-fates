#!/bin/bash

#Function to display usage information
usage() {
  echo "Usage: $0 [<case_tag> e.g."supIg105_020224"] [<new_param_dir_name> e.g. "params_supIg105_020224"]
                  [<param_name> e.g. "fates_fire_nignitions"] [param_value e.g. 0.105]
                  [<ref_param_dir_name> e.g."CZ2_trans_110923_01"] [benchmarking_run (0|1)]" >&2
  exit 1
}

# Display help if no arguments are provided or if the user specifies --help
if [[ $# -eq 0 || "$1" == "--help" ]]; then
  usage
fi

# Display positional arguments
echo "Positional arguments: $@"




# Script set up
cd /glade/u/home/adamhb/california-fates/run_scripts/ensemble_runs
exec 2> log.txt
the_time=$(date)
echo >> log.txt
echo "Script is being sweeped ${the_time}" >> log.txt




# Params that will change each run
case_tag=$1
new_param_dir_name=$2
param_name=$3
param_value=$4
ref_param_dir_name=$5
benchmarking_run=$6

# Params that might change
eq_case_name="CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69"
case_name_suffix="_-17e2acb6a_FATES-5b076b69"
peas_metrics=/glade/work/adamhb/processed_output/CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69/eq_metrics_020624.csv
inst_array=/glade/work/adamhb/processed_output/supIg105_020224/inst_supIg105_020224.npy


# Params that will change for each user
case_root=/glade/u/home/adamhb/cases
case_output_root=/glade/derecho/scratch/adamhb
param_dir_root=/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles
processed_output_root=/glade/work/adamhb/processed_output

################
##### Main #####
################

echo "Case tag: ${case_tag}" >> log.txt
here_path=$(pwd)

# Define variables
eq_case_path=${case_root}/${eq_case_name}

f1870_1951_case_name="${case_tag}-1870-1951${case_name_suffix}"
f1870_1951_case_path=${case_root}/${f1870_1951_case_name}

f1951_2020_case_name="${case_tag}-1951-2020${case_name_suffix}"
f1951_2020_case_path="${case_root}/${f1951_2020_case_name}"

f2015_2098_case_name="${case_tag}-2015-2098${case_name_suffix}"
f2015_2098_case_path="${case_root}/${f2015_2098_case_name}"


# Create new set of parameters
ref_param_dir=${param_dir_root}/${ref_param_dir_name}
new_param_dir=${param_dir_root}/${new_param_dir_name}


timeseries_dir=${processed_output_root}/${case_tag}

############################
# Stage 1. Run 1870 to 1951#
############################

# If the 1870 to 1951 case doesn't already exist then run it.

#1
if test -e ${f1870_1951_case_path}; then
    echo "1870 to 1951 case already exists" >> log.txt

#1
else
    echo "Running 1870 to 1951" >> log.txt

    echo "Making param directory" >> log.txt
    source activate env4
    python create_params.py $ref_param_dir $new_param_dir $param_name $param_value  
    conda deactivate

    # Build 1870 to 1951 
    ./f1870_1951.sh $case_tag $new_param_dir
    
    # Transfer restart files from equilibrium case to 1870-1951 case
    src_dir=${case_output_root}/${eq_case_name}/rest/1870-01-01-00000
    dst_dir=${case_output_root}/${f1870_1951_case_name}/run
    
    source activate env4
    python transfer_rest.py $src_dir $dst_dir  
    conda deactivate

    cd $f1870_1951_case_path
    `./case.submit`
    cd ${here_path}
#1
fi # Check if 1870-1951 case already exists



#############################
# Stage 2. Run 1951 to 2020 #
#############################

# If the 1951 to 2020 case doesn't already exist and the 1870 to 1951 case
# finished successfully then run the 1951 to 2020 case

# Check if case already exists
#2
if test -e ${f1951_2020_case_path}; then
    echo "1951 to 2020 case already exists" >> log.txt
#2
else
    echo "Checking if I should start 1951 to 2020" >> log.txt

    #Check if prior case is done running
    case_status_1870_1951="${f1870_1951_case_path}/CaseStatus"
    
    #3
    if tail -n 2 "${case_status_1870_1951}" | head -n 1 | grep -q "st_archive success"; then
        echo "1870 to 1951 case is finished running" >> log.txt
        echo "Running 1951 to 2020" >> log.txt
    
         # Build 1951 to 2020 
	./f1951_2020.sh $case_tag $new_param_dir 2>> log.txt
	
	# Transfer restart files from 1870-1951 case to 1951-2020 case
	src_dir=${case_output_root}/${f1870_1951_case_name}/rest/1951-01-01-00000
	dst_dir=${case_output_root}/${f1951_2020_case_name}/run
	
        source activate env4
        python transfer_rest.py $src_dir $dst_dir  
	conda deactivate

	cd $f1951_2020_case_path
	`./case.submit`
	cd $here_path
    #3
    else
        echo "1870 to 1951 case not complete...will try later" >> log.txt
        #exit

    #3
    fi # Check if prior case is done running
#2
fi # Check if 1951-2020 cases already exists


#############################
# Stage 3. Run 2015 to 2098 #
#############################

case_status_1951_2020="${f1951_2020_case_path}/CaseStatus"

#4
if test -e ${f2015_2098_case_path}; then
    echo "2015 to 2098 case already exists" >> log.txt
#4
else
    # Check if prior case is done running
    #5
    if tail -n 2 "${case_status_1951_2020}" | head -n 1 | grep -q "st_archive success"; then
        echo "1951 to 2020 case is finished running" >> log.txt
        echo "Running SSP3 (2015-2098)" >> log.txt

        #Build SSP3 case
        ./SSP3-70.sh $case_tag $new_param_dir

        # Transfer restart files from 1951-2020 case to 2015-2098 case
        src_dir=${case_output_root}/${f1951_2020_case_name}/rest/2015-01-01-00000
        dst_dir=${case_output_root}/${f2015_2098_case_name}/run
        
        source activate env4
        python transfer_rest.py $src_dir $dst_dir  
        conda deactivate

        cd $f2015_2098_case_path
        `./case.submit`
        cd $here_path
    #5
    else
        echo "1951 to 2020 case not complete...will try again later" >> log.txt
        #exit

    #5
    fi # Check if prior case is done running
#4
fi # Check if 2015-2098 case already exists



###########################
# Stage 4. Process output #
###########################

#If all cases are done running process the output data

case_status_2015_2098="${f2015_2098_case_path}/CaseStatus"

if tail -n 2 "${case_status_1951_2020}" | head -n 1 | grep -q "st_archive success"; then
    ##################################
    # 4a. Early 21st century metrics #
    ##################################

    # Header
    src_data=${case_output_root}/${f1951_2020_case_name}/lnd/hist
    output_dir_path_1951_2020=${processed_output_root}/${f1951_2020_case_name}
    output_file_path_1951_2020="${output_dir_path_1951_2020}/${case_tag}_1970-2010.csv"
    METRICS_LOCKFILE="tmp/metrics.lock"

    # If the early 2st century metrics dir doesn't already exist
    # then create it
    #7
    if test -e ${output_dir_path_1951_2020}; then
        echo #"${output_dir_path_1951_2020} already exists" >> log.txt
    else
        mkdir $output_dir_path_1951_2020
    #7
    fi


    # If the output doesn't already exist
    #8
    if test -e ${output_file_path_1951_2020}; then
        echo "Early 20th century metrics file already exists" >> log.txt
    else
        # And get_case_metrics.py is not already running
        #9
        if test -e ${METRICS_LOCKFILE}; then
            echo "Metrics (Early 20th century) script is still running" >> log.txt
            #exit
        #9
        else
            touch $METRICS_LOCKFILE
            echo "Creating metrics for ${f1951_2020_case_name}"
            source activate env4
            python get_case_metrics.py $src_data 1970 2010 $output_file_path_1951_2020  
            conda deactivate
            rm $METRICS_LOCKFILE
        #9
        fi # Is it running?
    #8
    fi # Do metrics already exist?
fi # Is the case done running



# If final case is done running
if tail -n 2 "${case_status_2015_2098}" | head -n 1 | grep -q "st_archive success"; then


    #################################
    # 4b. Late 21st century metrics #
    #################################


    # Header
    src_data=${case_output_root}/${f2015_2098_case_name}/lnd/hist
    output_dir_path_2015_2098=${processed_output_root}/${f2015_2098_case_name}
    output_file_path_2015_2098="${output_dir_path_2015_2098}/${case_tag}_2058-2098.csv"

    # If the output folder doesn't already exist then make it
    # 10
    if test -e ${output_dir_path_2015_2098}; then
        echo #"${output_dir_path_2015_2098} already exists" >> log.txt
    #10
    else
        mkdir $output_dir_path_2015_2098
    #10
    fi

    # If the output doesn't already exist then make it
    #11
    if test -e ${output_file_path_2015_2098}; then
        echo "Late 20th century metrics file already exists" >> log.txt

    else
        # And if the metrics file is not already running
        #12
        if test -e ${METRICS_LOCKFILE}; then
            echo "Metrics script is still running" >> log.txt
            #exit
        #12
        else
            touch $METRICS_LOCKFILE
            echo "Creating metrics for ${f2015_2098_case_name}" >> log.txt
            source activate env4
            python get_case_metrics.py $src_data 2058 2098 $output_file_path_2015_2098  
            conda deactivate
            rm $METRICS_LOCKFILE
        #12
        fi #Is it running?
    #11
    fi
    ##########################################
    # Stage 4c. Get inst tags for timeseries #
    ##########################################

    # If the the timeseries data directory doesn't exist make it
        #13
    if test -e ${timeseries_dir}; then
        echo #"${timeseries_dir} already exists" >> log.txt
        #13
    else
        mkdir $timeseries_dir
        #13
    fi

    #Only do this if its a benchmarking run
    if [ $benchmarking_run -eq 1 ]; then

        # Header
        inst_array="${timeseries_dir}/inst_${case_tag}.npy"

      
        # If the array of instances to include doesn't already exist, create it
        # 14
        if test -e ${inst_array}; then
            echo "${inst_array} already exists"
        # 14
        else
            echo "Making array of tags to include in analysis" >> log.txt
            source activate env4
            python fire_response.py $peas_metrics $output_file_path_1951_2020 $inst_array  
            conda deactivate
        #14
        fi

    else
        echo "Not a benchmarking run using default array" >> log.txt
    fi
    ########################################
    # Stage 4d. Create the timeseries data #
    ########################################

    # HEADER
    TS_LOCKFILE="tmp/ts.lock"
    ts_data="${timeseries_dir}/ts_${case_tag}.csv"
    echo "ts_data $ts_data"
    # If the timeseries data don't already exist
    #15
    if test -e ${ts_data}; then
        echo "${ts_data} already exists" >> log.txt
    #15
    else
        #If the timeseries data isn't already running
        #16
        if test -e ${TS_LOCKFILE}; then
            echo "TS script is still running" >> log.txt
            #exit
        # Run the timeseries script
        #16
        else
            echo "Making time series data" >> log.txt
            touch $TS_LOCKFILE
            source activate env4
            python timeseries_data.py ${inst_array} ${ts_data} ${eq_case_name} ${f1870_1951_case_name} ${f1951_2020_case_name} ${f2015_2098_case_name} >> log.txt 2>&1
            conda deactivate
            rm $TS_LOCKFILE
        #16
        fi #Is it still running?
    #15
    fi #Do data exist?
fi # Is the final case done running

echo "End of script" >> log.txt










