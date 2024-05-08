#!/bin/bash -l
#PBS -N job_array_ts
#PBS -A UCDV0027
#PBS -J 1-8
#PBS -l select=1:ncpus=1:mem=5GB
#PBS -l walltime=02:00:00
#PBS -q casper
#PBS -j oe

# Array of numbers corresponding to each case
tags=(0011 0024 0048 0054 0064 0065 0067 0092)

# Output the current PBS_ARRAYID for debugging
echo "PBS_ARRAY_INDEX: $PBS_ARRAY_INDEX"

# Ensure PBS_ARRAY_INDEX is being captured and is numerical
if [ -z "$PBS_ARRAY_INDEX" ]; then
    echo "PBS_ARRAY_INDEX is not set. Exiting."
    exit 1
fi

# Determine the case number using PBS_ARRAYID
tag=${tags[$PBS_ARRAY_INDEX-1]}

echo "Working on tag: ${tag}"

output_path=/glade/work/adamhb/processed_output/CZ2_equilibrium_700yrs_042524_01_-17e2acb6a_FATES-1449c787/ts_${tag}.csv
echo "Output file path: $output_path"

# Load conda and activate the specified environment
module load conda
conda activate env4

# Run Python script for each case
python timeseries_data_parallel.py $tag $output_path CZ2_equilibrium_700yrs_042524_01_-17e2acb6a_FATES-1449c787 sup_043024-1870-1951_-17e2acb6a_FATES-1449c787 sup_043024-1951-2020_-17e2acb6a_FATES-1449c787 None

# Optional: Deactivate conda environment
conda deactivate

