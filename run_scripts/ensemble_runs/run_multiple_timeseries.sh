#!/bin/bash

#1.

echo "starting timeseries script" >> log.txt

python -u timeseries_data.py /glade/work/adamhb/processed_output/supIg105_020224/inst_supIg105_020224.npy /glade/work/adamhb/processed_output/supIg105_020224/ts_supIg105_031324.csv CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69 supIg105_020224-1870-1951_-17e2acb6a_FATES-5b076b69 supIg105_020224-1951-2020_-17e2acb6a_FATES-5b076b69 supIg105_020224-2015-2098_-17e2acb6a_FATES-5b076b69 >> /glade/u/home/adamhb/california-fates/run_scripts/ensemble_runs/log.txt 2>&1

echo "finished sup ts" >> log.txt

#2. 
python -u timeseries_data.py /glade/work/adamhb/processed_output/supIg105_020224/inst_supIg105_020224.npy /glade/work/adamhb/processed_output/supIg105ConstCO2_021924-2015-2098_-17e2acb6a_FATES-5b076b69/ts_supIg105_const_CO2_031324.csv None None None supIg105ConstCO2_021924-2015-2098_-17e2acb6a_FATES-5b076b69 >> /glade/u/home/adamhb/california-fates/run_scripts/ensemble_runs/log.txt 2>&1

echo "finished sup CO2 const" >> log.txt

#3.
python -u timeseries_data.py /glade/work/adamhb/processed_output/supIg105_020224/inst_supIg105_020224.npy /glade/work/adamhb/processed_output/HF_020424/ts_HF_031324.csv CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69 HF_020424-1870-1951_-17e2acb6a_FATES-5b076b69 HF_020424-1951-2020_-17e2acb6a_FATES-5b076b69 HF_020424-2015-2098_-17e2acb6a_FATES-5b076b69 >> /glade/u/home/adamhb/california-fates/run_scripts/ensemble_runs/log.txt 2>&1

echo "finished HF original nignition" >> log.txt

#4.
python -u timeseries_data.py /glade/work/adamhb/processed_output/supIg105_020224/inst_supIg105_020224.npy /glade/work/adamhb/processed_output/HF_ig105_021324-2015-2098_-17e2acb6a_FATES-5b076b69/ts_HF_ig105_031324.csv None None None HF_ig105_021324-2015-2098_-17e2acb6a_FATES-5b076b69 >> /glade/u/home/adamhb/california-fates/run_scripts/ensemble_runs/log.txt 2>&1

echo "finished HF n_ignition 105" >> log.txt

#5.
python -u timeseries_data.py /glade/work/adamhb/processed_output/supIg105_020224/inst_supIg105_020224.npy /glade/work/adamhb/processed_output/HFig105ConstCO2_021924-2015-2098_-17e2acb6a_FATES-5b076b69/ts_HFIg105_const_CO2_031324.csv None None None HFig105ConstCO2_021924-2015-2098_-17e2acb6a_FATES-5b076b69 >> /glade/u/home/adamhb/california-fates/run_scripts/ensemble_runs/log.txt 2>&1

echo "finsihed HF n_ignition 105 with const CO2" >> log.txt


