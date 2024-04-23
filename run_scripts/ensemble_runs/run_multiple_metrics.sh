#!/bin/bash

# Define the array of numbers
numbers=(01 04 05 06 08 09 10)

# Loop through the array and print each number
for case_number in "${numbers[@]}"
do
    echo "Working on ${case_number}"
    src_data=/glade/derecho/scratch/adamhb/CZ2_equilibrium_041924_${case_number}_-17e2acb6a_FATES-1449c787/lnd/hist

    echo $src_data

    output_file_path=/glade/work/adamhb/processed_output/CZ2_equilibrium_041924_XX_-17e2acb6a_FATES-1449c787/peas150_metrics_${case_number}.csv

    echo $output_file_path

    python get_case_metrics.py $src_data 1279 1319 $output_file_path

done

