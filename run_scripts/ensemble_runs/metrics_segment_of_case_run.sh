#!/bin/bash

case_tag=HF_020424
# Params that will change for each user
case_root=/glade/u/home/adamhb/cases
case_output_root=/glade/derecho/scratch/adamhb
param_dir_root=/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles
processed_output_root=/glade/work/adamhb/processed_output
case_name_suffix="_-17e2acb6a_FATES-5b076b69"
METRICS_LOCKFILE="tmp/metrics.lock"
f2015_2098_case_name="${case_tag}-2015-2098${case_name_suffix}"
f2015_2098_case_path="${case_root}/${f2015_2098_case_name}"
src_data=${case_output_root}/${f2015_2098_case_name}/lnd/hist
output_dir_path_2015_2098=${processed_output_root}/${f2015_2098_case_name}
output_file_path_2015_2098="${output_dir_path_2015_2098}/${case_tag}_2058-2098.csv"

# If the output folder doesn't already exist then make it
if test -e ${output_dir_path_2015_2098}; then
    echo "${output_dir_path_2015_2098} already exists" >> log.txt
else
    mkdir $output_dir_path_2015_2098
fi

# If the output doesn't already exist then make it
if test -e ${output_file_path_2015_2098}; then
    echo "${output_file_path_2015_2098} already exists" >> log.txt
else
    echo "Looking for lock file" >> log.txt
    # And if the metrics file is not already running
    if test -e ${METRICS_LOCKFILE}; then
        echo "Metrics script is still running" >> log.txt
        echo "-------------------------------------" >> log.txt
    else
        touch $METRICS_LOCKFILE
        echo "Creating metrics for ${f2015_2098_case_name}" >> log.txt
        source activate env4
        python get_case_metrics.py $src_data 2058 2098 $output_file_path_2015_2098
        conda deactivate
        rm $METRICS_LOCKFILE
    fi
fi
