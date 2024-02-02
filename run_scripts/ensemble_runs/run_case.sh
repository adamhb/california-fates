#!/bin/bash

cd /glade/u/home/adamhb/california-fates/run_scripts/ensemble_runs
the_time=$(date)
echo "Script is being sweeped ${the_time}" >> log.txt

# Params that will change each run
benchmarking_run="TRUE"
case_tag="test3"
new_param_dir_name="test_param_013124"
param_name="fates_fire_nignitions"
param_value=0.11

# Params that might change
eq_case_name="CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69"
case_name_suffix="_-17e2acb6a_FATES-5b076b69"
ref_param_dir_name="CZ2_trans_110923_01"
peas_metrics=/glade/work/adamhb/processed_output/CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69/ensemble_output_CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69_with_fire_metrics_20240122135437.csv



# Params that will change for each user
case_root=/glade/u/home/adamhb/cases
case_output_root=/glade/derecho/scratch/adamhb
param_dir_root=/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles
processed_output_root=/glade/work/adamhb/processed_output

################
##### Main #####
################

here_path=$(pwd)



# Define variables
f1870_1951_case_name="${case_tag}-1870-1951${case_name_suffix}"
f1870_1951_case_path=${case_root}/${f1870_1951_case_name}

f1951_2020_case_name="${case_tag}-1951-2020${case_name_suffix}"
f1951_2020_case_path="${case_root}/${f1951_2020_case_name}"

f2015_2098_case_name="${case_tag}-2015-2098${case_name_suffix}"
f2015_2098_case_path="${case_root}/${f2015_2098_case_name}"


# Stage 1. Run 1870 to 1951

# If the 1870 to 1951 case doesn't already exist then run it.
if test -e $f1870_1951_case_path; then
    echo "Run 1870 to 1951 already exists" >> log.txt
else
    echo "Running 1870 to 1951" >> log.txt

    # Create new set of parameters
    ref_param_dir=${param_dir_root}/${ref_param_dir_name}
    new_param_dir=${param_dir_root}/${new_param_dir_name}
    
    python create_params.py $ref_param_dir $new_param_dir $param_name $param_value
    
    # Build 1870 to 1951 
    ./f1870_1951.sh $case_tag $new_param_dir
    
    # Transfer restart files from equilibrium case to 1870-1951 case
    src_dir=${case_output_root}/${eq_case_name}/rest/1870-01-01-00000
    dst_dir=${case_output_root}/${f1870_1951_case_name}/run
    python transfer_rest.py $src_dir $dst_dir
    
    cd $f1870_1951_case_path
    ./case.submit
    cd $here_path
fi # Check if 1870-1951 case already exists




# Stage 2. Run 1951 to 2020

# If the 1951 to 2020 case doesn't already exist and the 1870 to 1951 case
# finished successfully then run the 1951 to 2020 case

# Check if case already exists
if test -e $f1951_2020_case_path; then
    echo "Run 1951 to 2020 already exists" >> log.txt
else
    #Check if prior case is done running
    
    case_status_1870_1951="${f1870_1951_case_path}/CaseStatus"

    if tail -n 2 "$case_status_1870_1951" | head -n 1 | grep -q "st_archive success"; then
        echo "1870 to 1951 case is finished running" >> log.txt
        echo "Running 1951 to 2020" >> log.txt
    
         # Build 1951 to 2020 
	./f1951_2020.sh $case_tag $new_param_dir
	
	# Transfer restart files from 1870-1951 case to 1951-2020 case
	src_dir=${case_output_root}/${f1870_1951_case_name}/rest/1951-01-01-00000
	dst_dir=${case_output_root}/${f1951_2020_case_name}/run
	python transfer_rest.py $src_dir $dst_dir
	
	cd $f1951_2020_case_path
	./case.submit
	cd $here_path
  
    else
        echo "1870 to 1951 case not complete..." >> log.txt
    
    fi # Check if prior case is done running
fi # Check if 1951-2020 cases already exists



# Stage 3. Run 2015 to 2098

if test -e $f2015_2098_case_path; then
    echo "2015 to 2098 case already exists" >> log.txt
else
    # Check if prior case is done running

    case_status_1951_2020="${f1951_2020_case_path}/CaseStatus"

    if tail -n 2 "$case_status_1951_2020" | head -n 1 | grep -q "st_archive success"; then
        echo "1951 to 2020 case is finished running" >> log.txt
        echo "Running SSP3 (2015-2098)" >> log.txt

        #Build SSP3 case
        ./SSP3-70.sh $case_tag $new_param_dir

         # Transfer restart files from 1951-2020 case to 2015-2098 case
        src_dir=${case_output_root}/${f1951_2020_case_name}/rest/2015-01-01-00000
        dst_dir=${case_output_root}/${$f2015_2098_case_name}/run
        python transfer_rest.py $src_dir $dst_dir

        cd $f2015_2098_case_path
        ./case.submit
        cd $here_path

    else
        echo "1951 to 2020 case not complete..." >> log.txt

    fi # Check if prior case is done running
fi # Check if 2015-2098 case already exists


# Stage 4. If all cases are done running create forest metrics,
# fire response test, and figures

case_status_2015_2098="${f2015_2098_case_path}/CaseStatus"
if tail -n 2 "$case_status_2015_2098" | head -n 1 | grep -q "st_archive success"; then
    
    # 4a. Early 21st century metrics
    src_data=${case_output_root}/${f1951_2020_case_name}/lnd/hist
    output_dir_path_1951_2020=${processed_output_root}/${f1951_2020_case_name}
    output_file_path_1951_2020=${output_dir_path_1951_2020}/${case_tag}_1970-2010.csv 

    # If the output folder doesn't already exist then make it
    if test -e $output_dir_path_1951_2020; then
        echo "${output_dir_path_1951_2020} already exists" >> log.txt
    else
        mkdir $output_dir_path_1951_2020
    fi

    # If the output doesn't already exist then make it
    if test -e $output_file_path_1951_2020; then
        echo "$output_file_path_1951_2020 already exists" >> log.txt
    else
        echo "Creating metrics for ${f1951_2020_case_name}"
        python get_case_metrics.py $src_data 1970 2010 $output_file_path_1951_2020    
    fi

    # 4b. Late 21st century metrics

    src_data=${case_output_root}/${f2015_2098_case_name}/lnd/hist
    output_dir_path_2015_2098=${processed_output_root}/${f2015_2098_case_name}
    output_file_path_2015_2098=${output_dir_path_2015_2098}/${case_tag}_2058-2098.csv

    # If the output folder doesn't already exist then make it
    if test -e $output_dir_path_2015_2098; then
        echo "${output_dir_path_2015_2098} already exists" >> log.txt
    else
        mkdir $output_dir_path_2015_2098
    fi

    # If the output doesn't already exist then make it
    if test -e $output_file_path_2015_2098; then
        echo "$output_file_path_2015_2098 already exists" >> log.txt
    else
        echo "Creating metrics for ${f2015_2098_case_name}"
        python get_case_metrics.py $src_data 2058 2098 $output_file_path_2015_2098    
    fi


    # Stage 5. Store a record of the fire response test for use in filtering the timeseries data
    # when generating figures

    # Create path where we will store the timeseries data
    $timeseries_dir=${processed_output_root}/${case_tag}

    # Create file name where we will store the array of instances to
    # include in the timeseries analysis
    $inst_array=$timeseries_dir/inst_${case_tag}.npy

    # If the the timeseries data directory doesn't exist make it
    if test -e $timeseries_dir; then
        echo "$timeseries_dir already exists" >> log.txt
    else
        mkdir $timeseries_dir

    # If the array of instances to include doesn't already exist, create it
    if test -e $inst_array; then
        echo "$inst_array already exists"
    else
        python fire_response.py $peas_metrics $output_file_path_1951_2020 $fire_report



    # Stage 6. Create the timeseries data
    # Make timeseries of 1820 to 1869, 1870 to 1950, 1951 to 2014, 2015 to 2098



    # Stage 7. Make time series figure

    # Stage 8. Separate script: quanify results (as per my journal)


else
    echo "Cases are not done running. Will hold off on calculating metrics" >> log.txt
fi #Are cases finished running



# Stage 6. Make timeseries figure







echo "-------------------------------------" >> log.txt








