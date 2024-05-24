#!/bin/bash

# Script set up
cd /glade/u/home/adamhb/california-fates/run_scripts/ensemble_runs
the_time=$(date)
here_path=$(pwd)
echo
echo "Script is being sweeped ${the_time}"
case_name=$1
case_path="/glade/u/home/adamhb/cases/${case_name}"
echo "Case path: ${case_path}"
case_status="${case_path}/CaseStatus"
rest_path="/glade/derecho/scratch/adamhb/${case_name}/rest"
run_path="/glade/derecho/scratch/adamhb/${case_name}/run"
echo "Run path: ${run_path}"
# Get the most recently created subdirectory
cd $rest_path
latest_subdir=$(ls -t -d */ | head -n 1)
# Remove the trailing slash
latest_subdir=${latest_subdir%/}
cd $here_path
# Print the variable to verify
echo "The most recently created restart files are for: $latest_subdir"
#src_dir=${rest_path}/${latest_subdir}
#echo "src path: ${src_dir}"

#if $latest_subdir .eq. "2099-01-01-00000";
#   echo "done. exiting"
#   exit

#exit

if tail -n 2 "${case_status}" | head -n 1 | grep -q "st_archive success"; then
    echo "Finished next 14 year simulation. Time to treat and resubmit."

    # Transfer restart files from 1951-2020 case to 2015-2098 case
    #src_dir=${case_output_root}/${f1951_2020_case_name}/rest/2015-01-01-00000
    #dst_dir=${case_output_root}/${f2015_2098_TREATED_case_name}/run

    source activate env4
    # Transfer restart files
    #python transfer_rest.py $src_dir $dst_dir
    # Treat the forest

    echo "Treating restart files"
    python log_or_treat_forest.py $run_path 2
    conda deactivate


    cd $case_path
    ./xmlchange CONTINUE_RUN=TRUE
    `./case.submit`
    cd $here_path

else
    echo "Case is still running"
fi

echo "End of sweep"
echo
