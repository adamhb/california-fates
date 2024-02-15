#!/bin/bash

case_status_2015_2098="/glade/u/home/adamhb/cases/HF_020424-2015-2098_-17e2acb6a_FATES-5b076b69/CaseStatus"

if tail -n 2 "${case_status_2015_2098}" | head -n 1 | grep -q "st_archive success"; then
    echo "Cases done running"
else
    echo "Cases not done running"
fi
