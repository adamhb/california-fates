'''
Returns a timeseries for one inst tag within a case series

Inputs:
-tag: tag number (integer) to get the time series of
-output_path: path to where you want the output including the .csv file extension
-c1: PEAS case name (basename)
-c2: 1870-1951 case name
-c3: 1951-2020 case name
-c4: 2015-2098 case name

Output:
-timeseries of 4 cases stitched together (CSV)
'''

import sys

def main(tag,output_path,c1,c2,c3,c4):
    sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools/')
    import numpy as np
    import esm_tools
    import pandas as pd
    import os

    dir_name = os.path.dirname(output_path)
    if not os.path.isdir(dir_name):
        
        raise ValueError("Output path {} not valid".format(output_path))

    tag = esm_tools.inst_to_tag([tag])[0]

    cases = [c1,c2,c3,c4]
    

    years = [list(range(1520, 1570)), list(range(1870,1951)),\
            list(range(1951,2020)), list(range(2015,2099))]


    #years = [list(range(1820, 1823)), list(range(1870,1873)),\
    #        list(range(1951,1954)), list(range(2015,2018))]


    ts = pd.DataFrame()
    for i,c in enumerate(cases):
        if (c == None) or (c == "None"):
            print("Encountered None")
            continue

        else:
            tmp = esm_tools.get_ts(c,years[i],tag)
            ts = pd.concat([ts,tmp],axis = 0)
    
    ts.to_csv(output_path)



if __name__ == "__main__":
    

    if ("--help" in sys.argv):
        print('-tag: tag to include (int)')
        print('-output_path: path to where you want the output including the .csv file extension')
        print('-c1: PEAS case name (basename)')
        print('-c2: 1870-1951 case name')
        print('-c3: 1951-2020 case name')
        print('-c4: 2015-2098 case name')

        sys.exit()


    tag = sys.argv[1]
    output_path = sys.argv[2]
    c1 = sys.argv[3]
    c2 = sys.argv[4]
    c3 = sys.argv[5]
    c4 = sys.argv[6]

    main(tag,output_path,c1,c2,c3,c4)







