'''
This script creates a new directory containing new and updated FATES parameter files.

Note: some paths are hardcoded in main function

Inputs:
- ref_param_dir: The reference directory containing parameter files to use as a starting point
- new_param_dir: The new directory where the new parameters will be stored
- param_name: The name of the fates param to change
- new_param_value: The new value of the parameter 

Output:
- A directory of updated parameter files
'''

import sys


def main(ref_param_dir, new_param_dir, param_name, new_param_value):
    
    sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools/')
    import glob
    import os
    import esm_tools
    import shutil
    
    print("new param value",new_param_value)
    print("new param value type:",type(new_param_value))
    print("Making new_param_dir:",new_param_dir)

    esm_tools.create_directory(new_param_dir)

    # Create a list of the reference parameter files
    ref_files = esm_tools.list_files_matching_pattern(ref_param_dir, '*.nc')
    print("Reference files:", ref_files)

    # Loop over reference parameter files
    for ref_file in ref_files:
	    
        # Copy the reference param file to the new directory
        dst_file = os.path.join(new_param_dir,os.path.basename(ref_file))
        shutil.copy(ref_file,dst_file)

        # Update the new param file  
        esm_tools.assign_variable_to_netcdf(dst_file,param_name,new_param_value)

    print("Created new parameter directory:")
    print(new_param_dir)

if __name__ == "__main__":
    

    if ("--help" in sys.argv) | (len(sys.argv) < 5):
        print("Usage: <ref_param_dir> <new_param_dir> <param_name> <new_param_value>")
        print("ref_param_dir: The reference directory containing parameter")
        print("new_param_dir: The new directory")
        print("param_name: The name of the fates param to change")
        print("new_param_value: The new value of the parameter") 

        sys.exit()


    ref_param_dir = sys.argv[1]
    new_param_dir = sys.argv[2]
    param_name = sys.argv[3]
    new_param_value = sys.argv[4]

    main(ref_param_dir, new_param_dir, param_name, new_param_value)


