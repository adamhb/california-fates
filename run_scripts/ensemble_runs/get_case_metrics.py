'''
This script creates summary metrics for a FATES run and
saves them in a csv file

See "my_metrics" list below for calculated metrics.

Inputs:
- src_data_path: path to directory containing the model output
- start_yr: start year for calculating metrics
- end_yr: end year for calculating metrics
- dst_file_path: path to the csv file that will hold the output
Output:
- csv file containing a summary of the case metrics
'''

import sys
sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools/')
import os
import esm_tools
import xarray as xr
import numpy as np
import pandas as pd

def main(src_data_path, start_yr, end_yr, dst_file_path):

    n_years_for_structural_metrics = 5
    print("Mean of last",n_years_for_structural_metrics,"for forest structure")

    pft_names = ["pine","cedar","fir","shrub","oak"]

    fields = ['FATES_SEED_PROD_USTORY_SZ','FATES_VEGC_AP','FATES_BURNFRAC',
              'FATES_NPLANT_PF','FATES_NPLANT_SZPF','FATES_NPLANT_RESPROUT_PF',
              'FATES_FIRE_INTENSITY_BURNFRAC','FATES_IGNITIONS',
              'FATES_MORTALITY_FIRE_SZPF','FATES_BASALAREA_SZPF','FATES_CANOPYCROWNAREA_APPF',
              'FATES_CANOPYCROWNAREA_PF','FATES_CROWNAREA_PF',
              'FATES_CROWNAREA_APPF','FATES_FUEL_AMOUNT_APFC','FATES_NPLANT_SZPF','FATES_FUEL_AMOUNT_APFC',
              'FATES_PATCHAREA_AP','FATES_CROWNAREA_PF','FATES_VEGC_ABOVEGROUND','FATES_NPP_PF']


    my_metrics = ["inst_tag","BA","BA_pine","BA_cedar","BA_fir","BA_shrub","BA_oak",
                  "AGB","TreeStemD","TreeStemD_40","TreeStemD_60","TreeStemD_80",
                  "TreeStemD_100","ResproutD_oak","ResproutD_shrub","ShannonE","NPP",
                  "FailedPFTs","Pct_shrub_cover_canopy","Pct_shrub_cover","Combustible_fuel",
                  "Burned_area","Pct_high_severity_1700","Pct_high_severity_3500"]

    bench_dict = {}
    for i in my_metrics:
        bench_dict[i] = []

    #inst_tags = esm_tools.get_unique_inst_tags(src_data_path)

    # These tags passed the forest structural criteria for a pre-Euro-American forest
    # as simulated on derecho. See /glade/work/adamhb/processed_output/filter_PEAS.py for details
    
    inst_tags = ['0001', '0002', '0003', '0005', '0008', '0013', '0014',
    '0015', '0017', '0022', '0023', '0024', '0025', '0026', '0027', '0029',
    '0030', '0031', '0033', '0038', '0042', '0045', '0046', '0048', '0050', '0051', '0052', '0053']



    for inst_tag in inst_tags:
        
        print("Getting metrics for",inst_tag)
       
        # Filter to just the files we have to load into xarray
        inst_files = esm_tools.filter_output_files(src_data_path,inst_tag,start_yr,end_yr)
        
        # Load into xarray

        print("Loading data into xarray")
        ds_decadal = esm_tools.multiple_netcdf_to_xarray(inst_files,fields)
        print(ds_decadal.time)
        ds = ds_decadal.sel(time = slice(str((int(end_yr) - (n_years_for_structural_metrics - 1) )) + '-01-01', None))
        print(ds.time)

        bench_dict['inst_tag'].append(inst_tag)

        if "BA" in bench_dict.keys():
                
            ## Pft-specific BA
            pft_level_ba = esm_tools.get_pft_level_basal_area(ds)
            
            for i in range(len(pft_names)):
                pft_name = pft_names[i]
                bench_dict['BA_' + pft_name].append(pft_level_ba[i])

            ## Shannon equitability index (wrt BA) ##
            bench_dict['ShannonE'].append(esm_tools.shannon_equitability(pft_level_ba))

            ## Number of failed pfts ##
            bench_dict['FailedPFTs'].append(esm_tools.get_n_failed_pfts(pft_level_ba,ba_thresh=0.1))
            
            ## Total BA
            pft_level_ba_no_shrub = np.delete(pft_level_ba,3)
            bench_dict['BA'].append(pft_level_ba_no_shrub.sum())

        ## Stem density [N ha-1] ##
        if "TreeStemD" in bench_dict.keys():
            
            ## Total tree stem density
            bench_dict["TreeStemD"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=10))
            bench_dict["TreeStemD_40"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=40))
            bench_dict["TreeStemD_60"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=60))
            bench_dict["TreeStemD_80"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=80))
            bench_dict["TreeStemD_100"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=100))
            
        if "ResproutD_oak" in bench_dict.keys():
            bench_dict["ResproutD_oak"].append(esm_tools.get_resprout_stem_den(ds,4))
                
        if "ResproutD_shrub" in bench_dict.keys():
            bench_dict["ResproutD_shrub"].append(esm_tools.get_resprout_stem_den(ds,3))
            
        ## AGB [kg C m-2]
        if "AGB" in bench_dict.keys():
            bench_dict["AGB"].append(esm_tools.get_AGB(ds))
            
        ## Total NPP [kg C m-2]
        if "NPP" in bench_dict.keys():
            bench_dict["NPP"].append(esm_tools.get_total_npp(ds))
            
        ## Shrub canopy layer cover [m2 m-2]
        if "Pct_shrub_cover_canopy" in bench_dict.keys():
            bench_dict["Pct_shrub_cover_canopy"].append(esm_tools.get_pft_level_crown_area(ds,pft_index = 3))
                
        if "Pct_shrub_cover" in bench_dict.keys():    
            bench_dict["Pct_shrub_cover"].append(esm_tools.get_pft_level_crown_area(ds,pft_index = 3,canopy_area_only = False))
            
        ## Fuel Load
        if "Combustible_fuel" in bench_dict.keys():
            bench_dict["Combustible_fuel"].append(esm_tools.get_combustible_fuel(ds))
            
        if "Burned_area" in bench_dict.keys():
            bench_dict["Burned_area"].append(esm_tools.get_mean_annual_burn_frac(ds_decadal))
                    
        if "Pct_high_severity_1700" in bench_dict.keys():
            bench_dict["Pct_high_severity_1700"].append(esm_tools.get_PHS_FLI_thresh(ds_decadal,1700))
                
        if "Pct_high_severity_3500" in bench_dict.keys():
            bench_dict["Pct_high_severity_3500"].append(esm_tools.get_PHS_FLI_thresh(ds_decadal,3500))

    # Write output to a csv
    pd.DataFrame(bench_dict).to_csv(dst_file_path)



if __name__ == "__main__":
    

    if ("--help" in sys.argv):
        print('-src_data_path: path to directory containing the model output')
        print('-start_yr: start year for calculating metrics')
        print('-end_yr: end year for calculating metrics')
        print('-dst_file_path: path to the csv file that will hold the output')
        sys.exit()


    src_data_path = sys.argv[1]
    start_yr = sys.argv[2]
    end_yr = sys.argv[3]
    dst_file_path = sys.argv[4]

    main(src_data_path, start_yr, end_yr, dst_file_path)

