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

def main(tag,output_path,c1,c2,c3,c4,y1,y2,y3,y4,y5,y6,y7,y8):
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
    

    years = [list(range(int(y1), int(y2))), list(range(int(y3),int(y4))),\
            list(range(int(y5),int(y6))), list(range(int(y7),int(y8)))]

    #years = [list(range(1520, 1570)), list(range(1870,1951)),\
    #        list(range(1951,1996)), list(range(2015,2020))]


    #years = [list(range(1820, 1823)), list(range(1870,1873)),\
    #        list(range(1951,1954)), list(range(2015,2018))]


    ts = pd.DataFrame()
    for i,c in enumerate(cases):
        if (c == None) or (c == "None"):
            print("Encountered None")
            continue

        else:
            print("Making time series for",c,"tag:",tag,"for years:",years[i])
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
        print('-y1: start year of PEAS case')
        print('-y2: end year of PEAS case')
        print('-y3: start year of 1870 to 1951 case')
        print('-y4: end year of 1870 to 1950 case')
        print('-y5: start year of 1951 to 2020 case')
        print('-y6: end year of 1951 to 2020 case')
        print('-y7: start year of 2015-2098 case')
        print('-y8: end year of 2015-2098 case')

        sys.exit()


    tag = sys.argv[1]
    output_path = sys.argv[2]
    c1 = sys.argv[3]
    c2 = sys.argv[4]
    c3 = sys.argv[5]
    c4 = sys.argv[6]
    y1 = sys.argv[7]
    y2 = sys.argv[8]
    y3 = sys.argv[9]
    y4 = sys.argv[10]
    y5 = sys.argv[11]
    y6 = sys.argv[12]
    y7 = sys.argv[13]
    y8 = sys.argv[14]

    main(tag,output_path,c1,c2,c3,c4,y1,y2,y3,y4,y5,y6,y7,y8)







