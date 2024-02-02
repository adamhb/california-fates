import numpy as np
import sys
sys.path.append('glade/u/home/adamhb/Earth-System-Model-tools')
import esm_tools

def get_ts(case,years,tag):
    
    '''
    Returns a time series df (pandas df) of forest structural and composition metrics for one case and one tag

    Inputs:
    -years: list of years. Inclusive of the end year.
    -tag: the inst_tag of the ensemble member to filter for (string, e.g. '0001')
    '''
    
    model_output_root = '/glade/derecho/scratch/adamhb'
    running_mean_window = 36 #months

    print("Working on",case,"-",tag)
    
    ds = esm_tools.load_fates_output_data(model_output_root=model_output_root,
                            case_name = case,
                            years = years,
                            fields = full_time_series_fields,
                            inst_tag = tag,
                            manual_path = None)
    
    dates = [esm_tools.convert_cftime_to_datetime(ds.time.values[i]) for i in range(len(ds.time.values))]
    

    ts_vars = ["inst_tag","Date","BA_conifer","BA_pine","BA_cedar","BA_fir","BA_oak",
               "TreeStemD","Pct_shrub_cover_canopy","Pct_shrub_cover","Burned_area",
               "Pct_conifer_cover_canopy","Pct_oak_cover_canopy","Combustible_fuel"]

    ts_dict = {}
    for i in ts_vars:
        ts_dict[i] = None

    ts_dict['inst_tag'] = [tag] * len(dates)               
    ts_dict["Date"] = dates
    ts_dict['BA_conifer'] = esm_tools.get_conifer_basal_area_over_time(ds,dbh_min=10)
    ts_dict['BA_oak'] = esm_tools.get_oak_basal_area_over_time(ds,dbh_min = 10)
    ts_dict['TreeStemD'] = esm_tools.get_total_stem_den(ds,trees_only=True,dbh_min=10,over_time=True)
    ts_dict['Pct_shrub_cover'] = esm_tools.get_pft_level_crown_area(ds,pft_index = 3,canopy_area_only = False,over_time=True)
    ts_dict['Pct_shrub_cover_canopy'] = esm_tools.get_pft_level_crown_area(ds,pft_index = 3,canopy_area_only = True,over_time=True)
    ts_dict['Pct_oak_cover_canopy'] = esm_tools.get_pft_level_crown_area(ds,pft_index = 4,canopy_area_only = True,over_time=True)
    ts_dict['Pct_conifer_cover_canopy'] = esm_tools.get_conifer_crown_area(ds,canopy_area_only = True, over_time = True)
    burn_frac = esm_tools.get_mean_annual_burn_frac(ds,over_time=True)
    ts_dict['Burned_area'] = running_mean(burn_frac, running_mean_window)
    ts_dict['Combustible_fuel'] = esm_tools.get_combustible_fuel(ds,timeseries = True)


    # Get the running mean of PHS
    iterations = len(ds.time) // running_mean_window
    PHS_dates = []
    PHS_3500 = []
    PHS_1700 = []
    for i in range(iterations):
        start_time_index = i * running_mean_window
        end_time_index = min(start_time_index + running_mean_window, len(ds.time))
        mid_time_index = start_time_index + (running_mean_window // 2)
        mid_date = convert_cftime_to_datetime(ds.time.values[mid_time_index])
        PHS_dates.append(mid_date)
        PHS_3500.append(esm_tools.get_PHS_FLI_thresh_isel(ds,start_time_index,end_time_index,3500))
        PHS_1700.append(esm_tools.get_PHS_FLI_thresh_isel(ds,start_time_index,end_time_index,1700))
    PHS_dict = {}
    PHS_dict['Date']= PHS_dates
    PHS_dict['Pct_high_severity_1700'] = PHS_1700
    PHS_dict['Pct_high_severity_3500'] = PHS_3500
    df_PHS = pd.DataFrame(PHS_dict)
    df = pd.DataFrame(ts_dict)
    
    return df, df_PHS
