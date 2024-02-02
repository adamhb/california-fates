#!/usr/bin/env python
# coding: utf-8

# In[2]:


import pandas as pd
import numpy as np
import os
import sys
#Path to the esm_tools.py script
sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools/')
import esm_tools
import importlib
importlib.reload(esm_tools)
pd.set_option('display.max_rows', 1000) 
import shutil
import re
import fnmatch
import math
from matplotlib import pyplot as plt
pd.set_option('display.max_colwidth', None)


# In[3]:


#script params
path_to_param_files = '/glade/u/home/adamhb/ahb_params/fates_api_25/ensembles/CZ2_trans_012524/'
ref_case_name = 'CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69'
ref_rest_dir = '/glade/derecho/scratch/adamhb/CZ2_equilibrium_011824_-17e2acb6a_FATES-5b076b69/rest/1870-01-01-00000/'
new_case_name = 'CZ2_trans_1870_1951_012624_-17e2acb6a_FATES-5b076b69'
new_case_run_dir = '/glade/derecho/scratch/adamhb/CZ2_trans_1870_1951_012624_-17e2acb6a_FATES-5b076b69'


# In[4]:


def extract_substring(s: str) -> str:
    # This regular expression looks for a sequence of characters that are
    # after "ensembles/" and followed by a "/", without including the "/"
    match = re.search(r'ensembles/([^/]*)', s)
    if match:
        # The substring is in the first capturing group
        return match.group(1)
    else:
        # You can change this to return None or an empty string if preferred
        return "No match found"

def get_case_from_reference_param_file(reference_param_file):
    prefix = extract_substring(reference_param_file)
    return prefix + '_-17e2acb6a_FATES-8a054a12'

def find_nc_and_rpointer_files(directory):
    matches = []
    for root, dirnames, filenames in os.walk(directory):
        for filename in fnmatch.filter(filenames, '*.nc'):
            matches.append(os.path.join(root, filename))
        for filename in filenames:
            if "rpointer" in filename:
                matches.append(os.path.join(root, filename))
    return matches

def extract_number_from_filename(filename):
    pattern = re.compile(r'(\d{4})\.nc$')
    match = pattern.search(filename)
    if match:
        return match.group(1)
    else:
        return None

def replace_number_in_filename(filename, new_number):
    # Check if the new number is exactly four digits
    if not re.match(r'^\d{4}$', new_number):
        raise ValueError("The new number must be a four-digit string.")

    # Regular expression to find four-digit numbers between an "_" and "." or at the end of the string
    pattern = re.compile(r'(?<=_)(\d{4})(?=\.|$)')

    # Find all matches
    matches = pattern.findall(filename)

    # Raise an error if there are more than two matches
    if len(matches) > 2:
        raise ValueError("The filename contains more than two four-digit numbers, cannot proceed.")

    # Replace the first occurrence of a four-digit number after "_" and before "." or at the end of the string
    new_filename = pattern.sub(new_number, filename, count=1)

    return new_filename

def replace_two_digit_number(filename):
    # Regular expression to match a two-digit number between two underscores
    pattern = re.compile(r'(?<=_)\d{2}(?=_)')

    # Replace the two-digit number with "01"
    new_filename = pattern.sub("01", filename)

    return new_filename

def replace_before_dot_with_string(original_string, replacement, keyword="FATES"):
    # Check if the keyword "FATES" is in the original string
    if keyword in original_string:
        # Split the original string into two parts at the first dot
        parts = original_string.split('.', 1)
        # Check if there's at least one dot to split on
        if len(parts) > 1:
            # Replace the part before the first dot with the user-defined string
            return replacement + '.' + parts[1]
    # If the keyword isn't found, or there's no dot, return the original string
    return original_string



def transfer_restart_files_to_new_case(ref_param_file,
                                       harmonized_reference_case_name = None, # The prefix in the reference restart files
                                       destination_run_dir = None,
                                       destination_inst_tag = None,
                                       manual_case_name = None,
                                       manual_rundir = None): # The name of the reference case to find the reference run dir
    ref = ref_param_file
    if manual_case_name != None:
        case_name = manual_case_name
    else:
        case_name = get_case_from_reference_param_file(ref)
        
    if manual_rundir != None:    
        case_rundir = manual_rundir
    else:
        case_rundir = os.path.join('/glade/scratch/adamhb/archive',case_name,'run')
    ref_inst_tag = extract_number_from_filename(ref)
    print(ref)
    print(ref_inst_tag)
    all_nc_and_pointer_files = find_nc_and_rpointer_files(case_rundir)
    matching_files = [f for f in all_nc_and_pointer_files if ref_inst_tag in f]
    for i in matching_files:
        new_file_name = replace_before_dot_with_string(os.path.basename(replace_number_in_filename(i,destination_inst_tag)),harmonized_reference_case_name)
        new_full_file_path = os.path.join(destination_run_dir,new_file_name)
        print("Copying",i,"to",new_full_file_path)
        shutil.copy(i,new_full_file_path)

def transfer_restart_files_to_new_case(ref_param_file,
                                       harmonized_reference_case_name = None, # The prefix in the reference restart files
                                       destination_run_dir = None,
                                       destination_inst_tag = None,
                                       manual_case_name = None,
                                       manual_rundir = None): # The name of the reference case to find the reference run dir
    ref = ref_param_file
    if manual_case_name != None:
        case_name = manual_case_name
    else:
        case_name = get_case_from_reference_param_file(ref)
        
    if manual_rundir != None:    
        case_rundir = manual_rundir
    else:
        case_rundir = os.path.join('/glade/scratch/adamhb/archive',case_name,'run')
    ref_inst_tag = extract_number_from_filename(ref)
    print(ref)
    print(ref_inst_tag)
    all_nc_and_pointer_files = find_nc_and_rpointer_files(case_rundir)
    matching_files = [f for f in all_nc_and_pointer_files if ref_inst_tag in f]
    for i in matching_files:
        new_file_name = os.path.basename(replace_number_in_filename(i,destination_inst_tag))
        new_full_file_path = os.path.join(destination_run_dir,new_file_name)
        print("Copying",i,"to",new_full_file_path)
        shutil.copy(i,new_full_file_path)
    

def transfer_all_restart_files_to_new_case(ref_param_files,
                                           harmonized_reference_case_name,
                                           destination_run_dir = None,
                                           manual_case_name = None,
                                           manual_rundir = None):
    inst_nums = list(range(1,len(ref_param_files) + 1))
    print(len(inst_nums))
    for i,ref in enumerate(ref_param_files):
        new_tag = str(inst_nums[i]).rjust(4, '0')
        transfer_restart_files_to_new_case(ref,
                                           harmonized_reference_case_name,
                                           destination_run_dir = destination_run_dir,
                                           destination_inst_tag = new_tag,
                                           manual_case_name = manual_case_name,
                                           manual_rundir = manual_rundir)


# # Execute

# In[5]:


param_files = sorted(os.listdir(path_to_param_files))
transfer_all_restart_files_to_new_case(ref_param_files = param_files,

                                       #reference case name
                                       harmonized_reference_case_name=ref_case_name, # This is arbitrarily on the of the cases contributing to the successful CZ2-PEAS param sets
                                       
                                       #new case run dir
                                       destination_run_dir = new_case_run_dir,

                                       #new case name
                                       manual_case_name=new_case_name,
                                       
                                       #reference case directory where restart files are
                                       manual_rundir = ref_rest_dir)

