import pandas as pd
import glob
import os
import netCDF4 as nc4
import sys
sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools')
import esm_tools
import re
import math
import shutil
import numpy as np
import seaborn as sns

def copy_and_rename_param_files(param_file_paths,inst_per_new_case, new_param_subdir_base_name,
                                param_subdir_root = '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles'):
    '''
    This is a function that takes a list of successful ensemble members, read's the file path to the parameter file of each successful ensemble member,
    and moves these old param files into new param file subdirs then creates a new param file subdir
    '''
    param_file_paths = np.array(param_file_paths)
    inst_per_new_case = min(inst_per_new_case,len(param_file_paths))

    path_to_ensemble_prov = '/glade/u/home/adamhb/ensemble_provenance_logs'
    n_cases = math.ceil(len(param_file_paths) / inst_per_new_case)
    case_numbers = [str(i).zfill(2) for i in range(1,n_cases + 1)]
    new_param_subdir_base_path = os.path.join(param_subdir_root,new_param_subdir_base_name)
    new_param_subdir_paths = [new_param_subdir_base_path + "_" + case_number for case_number in case_numbers]
    [os.mkdir(p) for p in new_param_subdir_paths if os.path.exists(p) == False]

    dst_file_paths = []
    for case_number in case_numbers:
        for inst_tag in [str(i).zfill(4) for i in range(1,inst_per_new_case + 1)]:
            dst_file_paths.append(f'{param_subdir_root}/{new_param_subdir_base_name}_{case_number}/ca_5pfts_100523_{inst_tag}.nc')

    if len(dst_file_paths) != len(param_file_paths):
        print("srcn",len(param_file_paths))
        print("dstn",len(dst_file_paths))
        print("Error in number of dst files")
        return

    pd.DataFrame({'src':param_file_paths,'dst':dst_file_paths}).to_csv(f'{path_to_ensemble_prov}/{new_param_subdir_base_name}_provenence.csv')

    for i in range(len(param_file_paths)):
        print("Copying",param_file_paths[i],"to",dst_file_paths[i])
        shutil.copy(param_file_paths[i],dst_file_paths[i])

param_file_paths = ['/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_042524_01/ca_5pfts_100523_0011.nc', '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_042524_01/ca_5pfts_100523_0024.nc', '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_042524_01/ca_5pfts_100523_0048.nc', '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_042524_01/ca_5pfts_100523_0054.nc', '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_042524_01/ca_5pfts_100523_0064.nc', '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_042524_01/ca_5pfts_100523_0065.nc', '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_042524_01/ca_5pfts_100523_0067.nc', '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/equilibrium_700yrs_042524_01/ca_5pfts_100523_0092.nc', ['/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_14/ca_5pfts_100523_0084.nc','/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_15/ca_5pfts_100523_0059.nc','/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_16/ca_5pfts_100523_0084.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_19/ca_5pfts_100523_0037.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0113.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_10/ca_5pfts_100523_0003.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_11/ca_5pfts_100523_0031.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_14/ca_5pfts_100523_0048.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_20/ca_5pfts_100523_0022.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_06/ca_5pfts_100523_0103.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_20/ca_5pfts_100523_0050.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_05/ca_5pfts_100523_0128.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_15/ca_5pfts_100523_0061.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_17/ca_5pfts_100523_0019.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0057.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_17/ca_5pfts_100523_0052.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_15/ca_5pfts_100523_0071.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_20/ca_5pfts_100523_0064.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_20/ca_5pfts_100523_0009.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_05/ca_5pfts_100523_0061.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0128.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_02/ca_5pfts_100523_0021.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_07/ca_5pfts_100523_0012.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_05/ca_5pfts_100523_0081.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0056.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_16/ca_5pfts_100523_0031.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0042.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_15/ca_5pfts_100523_0004.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_09/ca_5pfts_100523_0087.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_19/ca_5pfts_100523_0020.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_14/ca_5pfts_100523_0062.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_03/ca_5pfts_100523_0015.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_14/ca_5pfts_100523_0098.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_20/ca_5pfts_100523_0074.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0127.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_09/ca_5pfts_100523_0057.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_19/ca_5pfts_100523_0052.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_16/ca_5pfts_100523_0024.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_03/ca_5pfts_100523_0108.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_11/ca_5pfts_100523_0027.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_07/ca_5pfts_100523_0032.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_11/ca_5pfts_100523_0071.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_05/ca_5pfts_100523_0066.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_07/ca_5pfts_100523_0059.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_09/ca_5pfts_100523_0052.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_16/ca_5pfts_100523_0016.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_15/ca_5pfts_100523_0123.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_17/ca_5pfts_100523_0100.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_18/ca_5pfts_100523_0070.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_10/ca_5pfts_100523_0103.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_17/ca_5pfts_100523_0020.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_09/ca_5pfts_100523_0062.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_15/ca_5pfts_100523_0127.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_02/ca_5pfts_100523_0041.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_18/ca_5pfts_100523_0014.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_02/ca_5pfts_100523_0097.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0013.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_08/ca_5pfts_100523_0069.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_15/ca_5pfts_100523_0015.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0104.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_12/ca_5pfts_100523_0064.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_12/ca_5pfts_100523_0092.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_18/ca_5pfts_100523_0037.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_18/ca_5pfts_100523_0117.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_02/ca_5pfts_100523_0123.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_15/ca_5pfts_100523_0095.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_18/ca_5pfts_100523_0110.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_16/ca_5pfts_100523_0058.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0103.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0037.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_08/ca_5pfts_100523_0023.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_17/ca_5pfts_100523_0128.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_09/ca_5pfts_100523_0091.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_09/ca_5pfts_100523_0061.nc',
 '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/ml_supported_ensemble_2560_050224_04/ca_5pfts_100523_0093.nc']


print(param_file_paths)

#copy_and_rename_param_files(param_file_paths,inst_per_new_case, new_param_subdir_base_name)



