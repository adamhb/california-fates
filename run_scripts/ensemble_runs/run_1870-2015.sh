#!/bin/bash
# This script advances the transient simulations of a case group from 1870 to 2020
# This script should be called after the 1870 to 1951 case is submitted.
# CHECK NEW PARAM DIR PATH

#Function to display usage information
usage() {
  echo "Usage: $0 [<case_tag> e.g."supIg105_020224"]"
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
the_time=$(date)
echo
echo "Script is being sweeped ${the_time}"

# Params that will change each run
case_tag=$1


# Params that might change
#eq_case_name="CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69"
case_name_suffix="_-17e2acb6a_FATES-1449c787"
#peas_metrics=/glade/work/adamhb/processed_output/CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69/eq_metrics_020624.csv
#inst_array=/glade/work/adamhb/processed_output/supIg105_020224/inst_supIg105_020224.npy


# Params that will change for each user
case_root=/glade/u/home/adamhb/cases
case_output_root=/glade/derecho/scratch/adamhb
param_dir_root=/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles
processed_output_root=/glade/work/adamhb/processed_output


################
##### Main #####
################

echo "Case tag: ${case_tag}"
here_path=$(pwd)

# Define variables
#eq_case_path=${case_root}/${eq_case_name}

f1870_1951_case_name="${case_tag}-1870-1951${case_name_suffix}"
f1870_1951_case_path=${case_root}/${f1870_1951_case_name}

echo "f1870_1951_case_path:${f1870_1951_case_path}"

f1951_2020_case_name="${case_tag}-1951-2020${case_name_suffix}"
f1951_2020_case_path="${case_root}/${f1951_2020_case_name}"

f2015_2098_case_name="${case_tag}-2015-2098${case_name_suffix}"
f2015_2098_case_path="${case_root}/${f2015_2098_case_name}"

f2015_2098_TREATED_case_name="${case_tag}-2015-2098-TREATED${case_name_suffix}"
f2015_2098_TREATED_case_path="${case_root}/${f2015_2098_TREATED_case_name}"

# Create new set of parameters
#ref_param_dir=${param_dir_root}/${ref_param_dir_name}

new_param_dir="${param_dir_root}/${case_tag}_01"
processed_output_dir=${processed_output_root}/${case_tag}

echo "Parameter directory: ${new_param_dir}"

# Check that 1870 to 1951 exists
if test -e ${f1870_1951_case_path}; then
    echo "1870 to 1951 case exists. Good!"
else
    echo "Error: Build and submit 1870 to 1951 case first."
    exit
fi # Check if 1870-1951 case exists


# Run 1951 to 2020 case

# If the 1951 to 2020 case doesn't already exist and the 1870 to 1951 case
# finished successfully then run the 1951 to 2020 case

# Check if 1951 to 2020 case already exists
if test -e ${f1951_2020_case_path}; then
    echo "1951 to 2020 case already exists and was probably submitted"
else
    echo "1951 to 2020 case does not yet exist"
    echo "Checking if I should make it"

    #Check if prior case is done running
    case_status_1870_1951="${f1870_1951_case_path}/CaseStatus"
    
    if tail -n 2 "${case_status_1870_1951}" | head -n 1 | grep -q "st_archive success"; then
        echo "1870 to 1951 case is finished running"
        echo "I will start running the 1951 to 2020 case"
    
         # Build 1951 to 2020 
	./f1951_2020.sh $case_tag $new_param_dir
	
	# Transfer restart files from 1870-1951 case to 1951-2020 case
	src_dir=${case_output_root}/${f1870_1951_case_name}/rest/1951-01-01-00000
	dst_dir=${case_output_root}/${f1951_2020_case_name}/run

        echo "Transfering restart files from ${src_dir} to ${dst_dir}"

        source activate env4
        python transfer_rest.py $src_dir $dst_dir  
	conda deactivate

	cd $f1951_2020_case_path
	`./case.submit`
	cd $here_path
    else
        echo "1870 to 1951 case not complete...will try later"

    fi # Check if prior case is done running
fi # Check if 1951-2020 case already exists



# Check if 2015 to 2098 case already exists
if test -e ${f2015_2098_case_path}; then
    echo "2015 to 2098 case already exists"
else
    # Check if prior case is done running
    case_status_1951_2020="${f1951_2020_case_path}/CaseStatus"
    if tail -n 2 "${case_status_1951_2020}" | head -n 1 | grep -q "st_archive success"; then
        echo "1951 to 2020 case is finished running"
        echo "Running SSP3 (2015-2098)"

        #Build SSP3 case
        ./SSP3-70.sh $case_tag $new_param_dir 0

        # Transfer restart files from 1951-2020 case to 2015-2098 case
        src_dir=${case_output_root}/${f1951_2020_case_name}/rest/2015-01-01-00000
        dst_dir=${case_output_root}/${f2015_2098_case_name}/run
        
        source activate env4
        python transfer_rest.py $src_dir $dst_dir  
        conda deactivate

        cd $f2015_2098_case_path
        `./case.submit`
        cd $here_path
    else
        echo "1951 to 2020 case not complete...will try again later"
    fi # Check if prior case is done running
fi # Check if 2015-2098 case already exists


# Check if 2015 to 2098 TREATED case already exists
if test -e ${f2015_2098_TREATED_case_path}; then
    echo "2015 to 2098 TREATED case already exists"
else
    # Check if prior case is done running
    case_status_1951_2020="${f1951_2020_case_path}/CaseStatus"
    if tail -n 2 "${case_status_1951_2020}" | head -n 1 | grep -q "st_archive success"; then
        echo "1951 to 2020 case is finished running"
        echo "Running SSP3 (2015-2098) TREATED"

        #Build SSP3 case
        ./SSP3-70.sh $case_tag $new_param_dir 1

        # Transfer restart files from 1951-2020 case to 2015-2098 case
        src_dir=${case_output_root}/${f1951_2020_case_name}/rest/2015-01-01-00000
        dst_dir=${case_output_root}/${f2015_2098_TREATED_case_name}/run

        source activate env4

        # Transfer restart files
        python transfer_rest.py $src_dir $dst_dir
        
        # Treat the forest
        python log_or_treat_forest.py $dst_dir 2

        conda deactivate


        cd $f2015_2098_TREATED_case_path
        `./case.submit`
        cd $here_path
    else
        echo "1951 to 2020 case not complete...will try again later"
    fi # Check if prior case is done running
fi # Check if 2015-2098 case already exists


#If all cases are done running process the output data
#if test -e ${f1951_2020_case_path}; then
#   case_status_1951_2020="${f1951_2020_case_path}/CaseStatus"
#   if tail -n 2 "${case_status_1951_2020}" | head -n 1 | grep -q "st_archive success"; then
#      echo "The 1951 to 2020 case is done"
#   fi
#fi

echo "End of sweep"










