'''
This script creates a report showing if each ensemble member
passed ecological expectations for forest response to fire suppression.

For members that didn't pass all criteria, it shows how it failed

Inputs:
- peas_metrics: path to a csv file storing forest metrics data for
the PEAS era
- sup_metrics: path to a csv file storing forest metrics data for
the suppression era
- output_path: file path for storing array of passing members (.npy)

Outputs:
- the list of members passing the fire response test (output_path.npy)
'''

import numpy as np
import pandas as pd
import sys

def main(peas_metrics,sup_metrics,output_path):
    
    peas = pd.read_csv(peas_metrics)
    sup = pd.read_csv(sup_metrics)

    # Check that data have the same number of rows
    # and that the last instance is the same
    

    # Ecological expectations for response to fire suppression
    # Note shrub cover could be reduced initially, but then subsequently increase
    # if the fire regime is tending towards high severity fire. Therefore, its
    # not used here for a criterion for filtering. The same could be said of oaks.

    # A suppressed forest should have:

    # 1. Less burned area
    # 2. More severe fire
    # 3. Increased tree stem density
    
    passing = np.array(
    (peas['Burned_area'] > sup['Burned_area']) &\
    (peas['TreeStemD'] < sup['TreeStemD']) &\
    (peas['Pct_high_severity_1700'] <= sup['Pct_high_severity_1700']), dtype=object)

    passing_members = np.array(peas[passing]['inst_tag'])
    print(passing_members.shape[0],"passing members")
    np.save(output_path, passing_members) 

if __name__ == "__main__":


    if ("--help" in sys.argv):
        print("peas_metrics: path to forest metrics in PEAS era (CSV)")
        print("sup_metrics: path to forest metrics in suppression era (CSV)")
        print("<output_path>.npy: where to store list of passing members")

        sys.exit()


    peas_metrics = sys.argv[1]
    sup_metrics = sys.argv[2]
    output_path = sys.argv[3]

    main(peas_metrics,sup_metrics,output_path)

