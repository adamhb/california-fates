#./SSP3-70-const-CO2.sh HFig105ConstCO2_021924 /glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/params_HF_ig105_021324 HF_ig105_021324-2015-2098_-17e2acb6a_FATES-5b076b69

#python transfer_rest.py /glade/derecho/scratch/adamhb/HF_020424-1951-2020_-17e2acb6a_FATES-5b076b69/rest/2015-01-01-00000 /glade/derecho/scratch/adamhb/HFig105ConstCO2_021924-2015-2098_-17e2acb6a_FATES-5b076b69/run


./SSP3-70-const-CO2.sh supIg105ConstCO2_021924 /glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/params_supIg105_020224 supIg105_020224-1951-2020_-17e2acb6a_FATES-5b076b69

python transfer_rest.py /glade/derecho/scratch/adamhb/supIg105_020224-1951-2020_-17e2acb6a_FATES-5b076b69/rest/2015-01-01-00000 /glade/derecho/scratch/adamhb/supIg105ConstCO2_021924-2015-2098_-17e2acb6a_FATES-5b076b69/run

cd /glade/u/home/adamhb/cases/supIg105ConstCO2_021924-2015-2098_-17e2acb6a_FATES-5b076b69

./case.submit
