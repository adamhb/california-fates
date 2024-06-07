'''
This script creates summary metrics for a FATES run and
saves them in a csv file

See "my_metrics" list below for calculated metrics.

Inputs:
- src_data_path: path to directory containing the model output
- start_yr: start year for calculating metrics
- end_yr: end year for calculating metrics
- dst_file_path: path to the csv file that will hold the output
- tag: the tag you want to analyze
Output:
- csv file containing a summary of the case metrics
'''

import sys

def main(src_data_path, start_yr, end_yr, dst_file_path, tag):
    import sys
    sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools/')
    import os
    import esm_tools
    import xarray as xr
    import numpy as np
    import pandas as pd


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


    my_metrics = ["inst_tag","AGCD","BA_conifer","BA_trees","BA_pine","BA_cedar","BA_fir","BA_shrub","BA_oak",
                  "TreeStemD","TreeStemD_40","TreeStemD_60","TreeStemD_80",
                  "TreeStemD_100","ResproutD_oak","ResproutD_shrub","ShannonE","NPP",
                  "FailedPFTs","Pct_shrub_cover_canopy","Pct_shrub_cover","Combustible_fuel",
                  "Pct_conifer_cover_canopy","Pct_pine_cover_canopy","Pct_cedar_cover_canopy",
                  "Pct_fir_cover_canopy","Pct_oak_cover_canopy",
                  "Burned_area","AWFI",
                  "Pct_high_severity_1700","Pct_high_severity_3500","Pct_high_severity_1025"]

    bench_dict = {}
    for i in my_metrics:
        bench_dict[i] = []

    # These tags passed the forest structural criteria for a pre-Euro-American forest
    # as simulated on derecho. See /glade/work/adamhb/processed_output/filter_PEAS.py for details
    
    #inst_tags = ['0001', '0002', '0003', '0005', '0008', '0013', '0014',
    #'0015', '0017', '0022', '0023', '0024', '0025', '0026', '0027', '0029',
    #'0030', '0031', '0033', '0038', '0042', '0045', '0046', '0048', '0050', '0051', '0052', '0053']

    #inst_tags = esm_tools.inst_to_tag(list(range(1,129)))
    
    print("Tag inside python script",tag)
    print("Tag type:",type(tag))

    # Filter to just the files we have to load into xarray
    inst_files = esm_tools.filter_output_files(src_data_path,tag,start_yr,end_yr)

    # Load into xarray

    print("Loading data into xarray")
    ds_decadal = esm_tools.multiple_netcdf_to_xarray(inst_files,fields)
    ds = ds_decadal.sel(time = slice(str((int(end_yr) - (n_years_for_structural_metrics - 1) )) + '-01-01', None))

    bench_dict['inst_tag'].append(tag)

    if "BA_trees" in bench_dict.keys():
            
        ## Pft-specific BA
        pft_level_ba = esm_tools.get_pft_level_basal_area(ds,dbh_min = 10)
        
        for i in range(len(pft_names)):
            pft_name = pft_names[i]
            bench_dict['BA_' + pft_name].append(pft_level_ba[i])

        pft_level_ba_for_shannon = esm_tools.get_pft_level_basal_area(ds,dbh_min = 0)

        ## Shannon equitability index (wrt BA) ##
        bench_dict['ShannonE'].append(esm_tools.shannon_equitability(pft_level_ba_for_shannon))

        ## Number of failed pfts ##
        bench_dict['FailedPFTs'].append(esm_tools.get_n_failed_pfts(pft_level_ba,ba_thresh=0.1))
        
        ## Total BA
        pft_level_ba_no_shrub = np.delete(pft_level_ba,3)
        bench_dict["BA_trees"].append(pft_level_ba_no_shrub.sum())

        ## BA conifer
        bench_dict['BA_conifer'].append(esm_tools.get_conifer_basal_area_over_time(ds,dbh_min = 10, snapshot = True))

    ## Stem density [N ha-1] ##
    if "TreeStemD" in bench_dict.keys():
        
        ## Total tree stem density
        bench_dict["TreeStemD"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=10))
        bench_dict["TreeStemD_40"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=40))
        bench_dict["TreeStemD_60"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=60))
        bench_dict["TreeStemD_80"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=80))
        bench_dict["TreeStemD_100"].append(esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=100))
    

    # No size min on the resprout stem density!
    if "ResproutD_oak" in bench_dict.keys():
        bench_dict["ResproutD_oak"].append(esm_tools.get_resprout_stem_den(ds,4))
            
    if "ResproutD_shrub" in bench_dict.keys():
        bench_dict["ResproutD_shrub"].append(esm_tools.get_resprout_stem_den(ds,3))
        
    ## AGB [kg C m-2]
    if "AGB" in bench_dict.keys():
        bench_dict["AGB"].append(esm_tools.get_AGB(ds))
    
    ## AGCD [kg C m-2]
    if "AGCD" in bench_dict.keys():
        bench_dict["AGCD"].append(esm_tools.get_AGCD(ds))

    ## Total NPP [kg C m-2]
    if "NPP" in bench_dict.keys():
        bench_dict["NPP"].append(esm_tools.get_total_npp(ds))
        
    ## Shrub canopy layer cover [m2 m-2]
    if "Pct_shrub_cover_canopy" in bench_dict.keys():
        bench_dict["Pct_shrub_cover_canopy"].append(esm_tools.get_pft_level_crown_area(ds,pft_index = 3))
    
    if "Pct_pine_cover_canopy" in bench_dict.keys():
        bench_dict["Pct_pine_cover_canopy"].append(esm_tools.get_pft_level_crown_area(ds,pft_index = 0,canopy_area_only = True,over_time=False))
    
    if "Pct_cedar_cover_canopy" in bench_dict.keys():
        bench_dict["Pct_cedar_cover_canopy"].append(esm_tools.get_pft_level_crown_area(ds,pft_index = 1,canopy_area_only = True,over_time=False))
   
    if "Pct_fir_cover_canopy" in bench_dict.keys():
        bench_dict["Pct_fir_cover_canopy"].append(esm_tools.get_pft_level_crown_area(ds,pft_index = 2,canopy_area_only = True,over_time=False))

    if "Pct_conifer_cover_canopy" in bench_dict.keys():
        bench_dict["Pct_conifer_cover_canopy"].append(esm_tools.get_conifer_crown_area(ds,canopy_area_only = True, over_time = False))

    if "Pct_oak_cover_canopy" in bench_dict.keys():
        bench_dict["Pct_oak_cover_canopy"].append(esm_tools.get_pft_level_crown_area(ds,pft_index = 4,canopy_area_only = True,over_time=False))

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

    if "Pct_high_severity_1025" in bench_dict.keys():
        bench_dict["Pct_high_severity_1025"].append(esm_tools.get_PHS_FLI_thresh(ds_decadal,1025))
    
    if "AWFI" in bench_dict.keys():
        bench_dict["AWFI"].append(esm_tools.get_awfi(ds,over_time = False))


    # Write output to a csv
    pd.DataFrame(bench_dict).to_csv(dst_file_path)



if __name__ == "__main__":
    

    if ("--help" in sys.argv):
        print('-src_data_path: path to directory containing the model output')
        print('-start_yr: start year for calculating metrics')
        print('-end_yr: end year for calculating metrics')
        print('-dst_file_path: path to the csv file that will hold the output')
        print('-tag: tag that you want to analyze')
        sys.exit()


    src_data_path = sys.argv[1]
    start_yr = sys.argv[2]
    end_yr = sys.argv[3]
    dst_file_path = sys.argv[4]
    tag = sys.argv[5]

    main(src_data_path, start_yr, end_yr, dst_file_path,tag)

