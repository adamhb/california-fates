import sys
import netCDF4 as nc4
import xarray as xr
import numpy as np
import pandas as pd
import warnings
warnings.filterwarnings('ignore')
sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools/')
import esm_tools
import os

def assign_multi_dim_variable_to_netcdf(file_path, variable_name, new_value):
    with nc4.Dataset(file_path, 'r+') as dataset:
        if variable_name in dataset.variables:
            # Access the variable
            variable = dataset.variables[variable_name]

            # Assign a value
            # The way you assign depends on the shape and dimensions of the variable
            # For a single-value variable:

            variable[...] = new_value  # Replace new_value with the value you want to assign
            #print("Changed {} to {}".format(variable_name,new_value))
            # For a multi-dimensional variable, specify indices or slices
            # Example for a 2D variable (like temperature at a specific time and place):
            # variable[time_index, place_index] = new_value

            #print(f"Value {new_value} assigned to {variable_name}.")
        else:
            print(f"Variable {variable_name} not found in the dataset.")

def find_matching_files(directory):
    """
    Finds and returns a list of file names in the specified directory that contain
    both 'clm2_' and '.r.' in their file names.

    :param directory: String, the path to the directory where the files are located
    :return: List of strings, the file names that match the criteria
    """
    matching_files = []
    for filename in os.listdir(directory):
        if "clm2_" in filename and ".r." in filename:
            matching_files.append(filename)
    return matching_files


def SDI_one_scls(tph,dbh):
    return tph * (dbh/25.4)**1.6

def rest_file_to_df(path_to_rest):
    rest_file = xr.open_dataset(path_to_rest,decode_times=False)
    df = pd.DataFrame({'pft':rest_file.fates_pft.values,
                       'dbh':rest_file.fates_dbh,
                       'n':rest_file.fates_nplant.values,
                       'patch_area':rest_file.fates_area,
                       'patch_age':rest_file.fates_age,
                       'cwd':rest_file.fates_ag_cwd_vec_001,
                       'leaf_litt':rest_file.fates_leaf_fines_vec_001})
    return df

def check_relative_SDI(df,size_thresh = 10):
    m2_per_ha = 10000

    df = df.copy()    
    
    #bins = np.arange(0,200,15)

    bins = np.array([5,20,40,60,80,100,120,140,180,250,400,np.inf])
    max_sdi = 902 # [trees ha -1] North et al., 2022
    
    df['patch_area'].replace(0, np.nan, inplace=True)
    df['patch_age'].replace(0, np.nan, inplace=True)
    df['patch_area'].ffill(inplace=True)
    df['patch_age'].ffill(inplace=True)

    not_shrub = df['pft'] != 4.0
    big_enough = df['dbh'] > size_thresh
    
    df = df.loc[not_shrub & big_enough]
    
    df['scls'] = pd.cut(df['dbh'],bins = bins)
    print(df['scls'].unique())
    size_classes = sorted(df['scls'].unique())
    size_classes_mid = [s.mid for s in size_classes]
   
    df['patch_frac'] = df['patch_area'] / m2_per_ha

    if 'nplant_treated' in df.columns:
        n_col = 'nplant_treated'
        print("Calculating SDI on treated stand")
    else:
        n_col = 'n'
    
    df['patch_level_n_per_ha'] = df[n_col] / df['patch_area'] * m2_per_ha
    
    df2 = df.groupby(['patch_frac','scls']).sum()['patch_level_n_per_ha'].reset_index()
    df2['patch_level_n_per_ha_x_patch_frac'] = df2['patch_frac'] * df2['patch_level_n_per_ha']

    df3 = df2.groupby('scls').sum()['patch_level_n_per_ha_x_patch_frac'].reset_index()
    df3.rename(columns={'patch_level_n_per_ha_x_patch_frac':'site_n_per_ha'},inplace = True)

    print(df3)
    
    sdi_vals = []
    for i,scls in enumerate(size_classes):
        tph = list(df3.loc[df3['scls'] == scls]['site_n_per_ha'])[0]
        sdi_i = SDI_one_scls(tph,size_classes_mid[i])
        sdi_vals.append(sdi_i)

    
    sdi = np.array(sdi_vals).sum()
    
    return sdi/max_sdi


def treat_forest(path_to_rest_file,debug = True):

    '''
    Forest restoration treatment
    '''
    print("Treating",path_to_rest_file)
    df = rest_file_to_df(path_to_rest_file)
    df = df.copy()

    tree = df['pft'].isin([1.0,2.0,3.0,5.0])
    not_pine = df['pft'] != 1.0
    small = df['dbh'] < 50
    big = df['dbh'] > 75
    medium = (df['dbh'] >= 50) & (df['dbh'] <= 75)

    # Calculate relative SDI
    r_sdi = check_relative_SDI(df)
    print("Relative sdi before treatment:",r_sdi)

    
    if r_sdi < 0.25:
        print("Not thinning, because forest is already thin")
        df['nplant_treated'] = df['n']

    else:
        print("Need to thin. Removing small trees.")
        treatment_i = 0
        
        while (r_sdi > 0.25) & (treatment_i < 5):
            
            treatment_i += 1
            if treatment_i == 1:
                n_col = 'n'
            else:
                n_col = 'nplant_treated'
        
            # Remove 50% of small trees (< 50 cm dbh)
            df['nplant_treated'] = np.where(tree & small, df[n_col] * 0.5, df[n_col])
        
            # Calculate relative SDI
            r_sdi = check_relative_SDI(df)
            print("Relative sdi after treatment",treatment_i,":",r_sdi)
    
        if r_sdi < 0.25:
            print("Forest is thin enough without removing larger trees")

        else:
            print("Removing medium-sized trees")
            
            while (r_sdi > 0.25) & (treatment_i < 11):
                
                treatment_i += 1
                
                df['nplant_treated'] = np.where(tree & medium & not_pine,
                                                df['nplant_treated'] * 0.65,
                                                df['nplant_treated'])
                
                r_sdi = check_relative_SDI(df)
                print("Relative sdi after teatment",treatment_i,":",r_sdi)
        
    # Remove CWD and leaf litter
    debris_reduction_factor = 0.36 # This scaler is a mean across fuel classes derived from 3 studies see postdoc/treatments
    df['cwd'] = df['cwd'] * debris_reduction_factor
    df['leaf_litt'] = df['leaf_litt'] * debris_reduction_factor


    #Reassign
    if debug == False:
        print("Altering restart file:",path_to_rest_file)
        print(len(df))
        print(df.info())
        assign_multi_dim_variable_to_netcdf(path_to_rest_file,"fates_nplant",df['nplant_treated'].values)
        assign_multi_dim_variable_to_netcdf(path_to_rest_file,"fates_ag_cwd_vec_001",df['cwd'].values)
        assign_multi_dim_variable_to_netcdf(path_to_rest_file,"fates_leaf_fines_vec_001",df['leaf_litt'].values)
    else:
        return

def log_forest(path_to_rest_file, debug = False):

    '''
    Forest restoration treatment
    '''

    rest_file = xr.open_dataset(path_to_rest_file,decode_times=False)
    df = pd.DataFrame({'pft':rest_file.fates_pft.values,'n':rest_file.fates_nplant.values,
                       'dbh':rest_file.fates_dbh})
    
    pine = df['pft'] == 1.0
    cedar = df['pft'] == 2.0
    fir = df['pft'] == 3.0
    big_tree = df['dbh'] > 75
    small_tree = df['dbh'] < 45
    medium_tree = (df['dbh'] >= 45) & (df['dbh'] <= 75)

    # Log all large conifers (> 75 cm dbh)

    # Log 95 % of large trees of all species
    df['nplant_logged'] = np.where( (pine | cedar | fir) & big_tree, (1.0 - 0.95) * df['n'], df['n'])

    # Log 73% of medium pines
    df['nplant_logged'] = np.where(pine & medium_tree, (1.0-0.73) * df['n'], df['nplant_logged'])

    # Log 13% of medium cedars
    df['nplant_logged'] = np.where(cedar & medium_tree, (1.0-0.13) * df['n'], df['nplant_logged'])

    # Log 33% of medium firs
    df['nplant_logged'] = np.where(fir & medium_tree, (1.0-0.33) * df['n'], df['nplant_logged'])

    #Reassign
    if debug == False:
        print("Changing file")
        assign_multi_dim_variable_to_netcdf(path_to_rest_file,"fates_nplant",  df['nplant_logged'].values)
    else:
        print("Debug mode")
        return 

def main(path_to_rest,log_vs_treat):
    
    files_to_treat = sorted(find_matching_files(path_to_rest))
    paths_files_to_treat = [os.path.join(path_to_rest,f) for f in files_to_treat]
    for file in paths_files_to_treat:
        print(file)
        print("flag",log_vs_treat)
        print("type",type(log_vs_treat))
        if log_vs_treat == '1':
            print("Logging forest")
            log_forest(file,debug = False)
        if log_vs_treat == '2':
            print("Treating forest")
            treat_forest(file,debug = False)

if __name__ == "__main__":


    if ("--help" in sys.argv):
        print("Usage: <path_to_rest> <log_vs_treat>")
        print("path_to_rest: Directory path where the restart files are that you want to treat")
        print("log_vs_treat: Integer flag indicating if you want to log (1) or treat (2)")

        sys.exit()


    path_to_rest = sys.argv[1]
    log_vs_treat = sys.argv[2]

    main(path_to_rest,log_vs_treat)
