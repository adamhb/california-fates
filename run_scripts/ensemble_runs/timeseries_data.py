'''
Returns a timeseries for a series of cases

Inputs:
-tags: path to .npy of tags to include
-output_path: path to where you want the output including the .csv file extension
-c1: PEAS case name (basename)
-c2: 1870-1951 case name
-c3: 1951-2020 case name
-c4: 2015-2098 case name

Output:
-timeseries of 4 cases stitched together (CSV)
'''

import sys

def main(tags,output_path,c1,c2,c3,c4):
    sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools/')
    import numpy as np
    import esm_tools
    import pandas as pd
    import os

    dir_name = os.path.dirname(output_path)
    if not os.path.isdir(dir_name):
        
        raise ValueError("Output path {} not valid".format(output_path))

    tags = np.load(tags)
    tags = esm_tools.inst_to_tag(tags)

    cases = [c1,c2,c3,c4]
    

    years = [list(range(1820, 1870)), list(range(1870,1951)),\
            list(range(1951,1996)), list(range(2015,2099))]


    #years = [list(range(1820, 1823)), list(range(1870,1873)),\
    #        list(range(1951,1954)), list(range(2015,2018))]


    ts = pd.DataFrame()
    for i,c in enumerate(cases):
        for t in tags:
            if (c == None) or (c == "None"):
                print("Encountered None")
                continue

            else:
                tmp = esm_tools.get_ts(c,years[i],t)
                ts = pd.concat([ts,tmp],axis = 0)
    
    ts.to_csv(output_path)



if __name__ == "__main__":
    

    if ("--help" in sys.argv):
        print('-tags: .npy of tags to include')
        print('-output_path: path to where you want the output including the .csv file extension')
        print('-c1: PEAS case name (basename)')
        print('-c2: 1870-1951 case name')
        print('-c3: 1951-2020 case name')
        print('-c4: 2015-2098 case name')

        sys.exit()


    tags = sys.argv[1]
    output_path = sys.argv[2]
    c1 = sys.argv[3]
    c2 = sys.argv[4]
    c3 = sys.argv[5]
    c4 = sys.argv[6]

    main(tags,output_path,c1,c2,c3,c4)







