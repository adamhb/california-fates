#!/bin/bash -l
#PBS -N job_array
#PBS -A UCDV0027
#PBS -J 1-18
#PBS -l select=1:ncpus=1:mem=5GB
#PBS -l walltime=05:00:00
#PBS -q casper
#PBS -j oe

# Array of numbers corresponding to each case
numbers=(02 03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20)

# Output the current PBS_ARRAYID for debugging
echo "PBS_ARRAY_INDEX: $PBS_ARRAY_INDEX"

# Ensure PBS_ARRAY_INDEX is being captured and is numerical
if [ -z "$PBS_ARRAY_INDEX" ]; then
    echo "PBS_ARRAY_INDEX is not set. Exiting."
    exit 1
fi

# Determine the case number using PBS_ARRAYID
case_number=${numbers[$PBS_ARRAY_INDEX-1]}

echo "Working on case number: ${case_number}"
src_data=/glade/derecho/scratch/adamhb/ml_supported_ensemble_050224_${case_number}_-17e2acb6a_FATES-1449c787/lnd/hist
echo "Source data path: $src_data"

output_file_path=/glade/work/adamhb/processed_output/ml_supported_ensemble_050224_XX_-17e2acb6a_FATES-1449c787/peas150_metrics_${case_number}.csv
echo "Output file path: $output_file_path"

# Load conda and activate the specified environment
module load conda
conda activate env4

# Run Python script for each case
python get_case_metrics.py $src_data 1269 1319 $output_file_path

# Optional: Deactivate conda environment
conda deactivate

