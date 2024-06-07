#!/bin/bash -l
#PBS -N job_array_ts
#PBS -A UCDV0027
#PBS -J 1-5
#PBS -l select=1:ncpus=1:mem=5GB
#PBS -l walltime=02:00:00
#PBS -q casper
#PBS -j oe

# Array of numbers corresponding to each case
#tags=(0042 0061 0066 0074 0076) # PEAS good tags
#tags=(0041 0060 0065 0073 0075) # SUP good tags 1870 to 2020 AND SSP3 with TREATMENT
tags=(0041 0060 0064 0072 0074) # Good tags SSP3 without TREATMENT

peas_case_name=equilibrium_700yrs_050924_01_-17e2acb6a_FATES-1449c787
f1870_to_1950_case_name=supIg_1.25_051424-1870-1951_-17e2acb6a_FATES-1449c787
f1951_to_2015_case_name=supIg_1.25_051424-1951-2020_-17e2acb6a_FATES-1449c787
SSP3_treated_case_name=supIg_1.25_051424-2015-2098-TREATED_-17e2acb6a_FATES-1449c787
SSP3_case_name=supIg_1.25_051424_wo0061-2015-2098_-17e2acb6a_FATES-1449c787
SSP3_continuous_treatment_case_name=supIg_1.25_052124_continuous-2015-2098-TREATED_-17e2acb6a_FATES-1449c787


#processed_output_dir=/glade/work/adamhb/processed_output/f1870_to_2015_051624
#processed_output_dir=/glade/work/adamhb/processed_output/SSP3_treated_051624
#processed_output_dir=/glade/work/adamhb/processed_output/SSP3_not_treated_051624
processed_output_dir=/glade/work/adamhb/processed_output/SSP3_continuous_treatment_052124

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

output_path=${processed_output_dir}/ts_2015-2098_${tag}.csv
echo "Output file path: $output_path"

# Load conda and activate the specified environment
module load conda
conda activate env4

# Run Python script for each case
python timeseries_data_parallel.py $tag $output_path None None None $SSP3_continuous_treatment_case_name \
1830 1870 1870 1951 1951 2015 2015 2099

# Optional: Deactivate conda environment
conda deactivate

