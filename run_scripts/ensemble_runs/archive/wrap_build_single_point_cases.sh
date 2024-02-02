#!/bin/bash

n=$1  # Get the number 'n' from the first argument

for (( i=1; i<=n; i++ )); do
   number_with_leading_zero=$(printf "%02d" $i)
   
   ./build_single_point_cases_equilib.sh $number_with_leading_zero
   #echo $number_with_leading_zero
done

