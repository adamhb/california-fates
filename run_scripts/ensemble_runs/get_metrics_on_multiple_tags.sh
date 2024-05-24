#!/bin/bash -l
#PBS -N job_array
#PBS -A UCDV0027
#PBS -J 1-82
#PBS -l select=1:ncpus=1:mem=5GB
#PBS -l walltime=05:00:00
#PBS -q casper
#PBS -j oe

echo "PBS_ARRAY_INDEX: $PBS_ARRAY_INDEX"

param_dir=/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_050924_01
src_data=/glade/derecho/scratch/adamhb/equilibrium_700yrs_050924_01_-17e2acb6a_FATES-1449c787/lnd/hist

echo "Source data path: $src_data"

# Call Python script and capture the output
tags=($(python get_tags_from_param_dir.py $param_dir))

# Now you can use this array in your bash script
#echo "Formatted numbers: ${tags[@]}"


# Ensure PBS_ARRAY_INDEX is being captured and is numerical
if [ -z "$PBS_ARRAY_INDEX" ]; then
    echo "PBS_ARRAY_INDEX is not set. Exiting."
    exit 1
fi

# Determine the tag using PBS_ARRAYID
tag=${tags[$PBS_ARRAY_INDEX-1]}
echo "Working on tag: ${tag}"

output_file_path=/glade/work/adamhb/processed_output/equilibrium_700yrs_050924_01/peas700_metrics_${tag}.csv
echo "Output file path: $output_file_path"

# Load conda and activate the specified environment
module load conda
conda activate env4

# Run Python script for each case
python get_case_metrics_1tag.py $src_data 1829 1869 $output_file_path $tag

# Optional: Deactivate conda environment
conda deactivate

