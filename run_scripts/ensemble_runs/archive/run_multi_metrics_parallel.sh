#!/bin/bash -l
#PBS -N case_metrics_ahb
#PBS -A UCDV0027
#PBS -J 1-17%17
#PBS -l select=1:ncpus=1:mem=10GB
#PBS -l walltime=08:00:00
#PBS -q casper
#PBS -j oe

# Array of numbers corresponding to each case
numbers=(01 02 03 04 05 06 07 09 11 12 13 15 16 17 18 19 20)

# Determine the case number using PBS_ARRAYID
case_number=${numbers[$PBS_ARRAYID-1]}

echo "Working on ${case_number}"
src_data=/glade/derecho/scratch/adamhb/CZ2_equilibrium_042324_${case_number}_-17e2acb6a_FATES-1449c787/lnd/hist

echo "src_data: ${src_data}"

output_file_path=/glade/work/adamhb/processed_output/CZ2_equilibrium_042324_XX_-17e2acb6a_FATES-1449c787/peas200_metrics_${case_number}.csv

echo "output file path: ${output_file_path}"

# Load conda and activate the specified environment
module load conda
conda activate env4

# Run Python script for each case
python get_case_metrics.py $src_data 1329 1369 $output_file_path

# Optional: Deactivate conda environment
conda deactivate

