'''
Filters an ensemble based on ecological criteria for
a pre-Euro-American settlement dry mixed conifer forest

Input:
-- PEAS_metrics: path to a csv file that holds the forest structural
and fire metrics required to filter the ensemble

Output:
-- prints a list of tag numbers that meet the criteria
'''
import sys
import pandas as pd
import numpy as np

def main(PEAS_metrics):

    df = pd.read_csv(PEAS_metrics)
    print(df.shape[0],"members evaluated")
    
    
    ########Ecological Criteria for Pre-Euro-American Forest#######

    # There should be at least 5 trees ha-1 larger than 40 cm dbh
    enough_large_trees = df["TreeStemD_40"] > 5
    
    # There should be at least 5 percent total shrub cover
    enough_shrubs = df["Pct_shrub_cover"] > 0.05
    
    # Pine should not be failing
    enough_pine = df["BA_pine"] > 0.1
    
    # There should be no more than 2 pfts failing
    coexistence_filter = df["FailedPFTs"] < 3
    
    # AGB should be at least 2 Kg of Carbon per m2
    enough_agb = df["AGB"] > 2
    
    # Burned area should be between 1 and 11 percent per year
    # This is the range in Williams+ 2023 and Mallek+ and then I added +- 2 perecnt
    burned_area = (df['Burned_area'] > 0.01) & (df['Burned_area'] < 0.11) 

    # Percent of fires burning at high severity (3500 kw m-1) should be 20%
    # Note the actual range is estimated to be 1-6, but using this exact range
    # would cull too many parameters

    phs = df['Pct_high_severity_3500'] < 20 
    
    # All filters
    criteria = enough_large_trees & enough_shrubs & enough_pine &\
                  coexistence_filter & enough_agb & burned_area & phs

    df_passing = df[criteria]
    
    passing_inst = np.array(df_passing['inst'])
    passing_inst = [str(i).zfill(4) for i in passing_inst]

    print(df_passing.shape[0],"passing")
    print("Passings members",passing_inst)
    
    import datetime

    # Get the current date and time
    current_datetime = datetime.datetime.now()




    # Open a file for appending ('a' mode), creating it if it doesn't exist
    with open('filter_log.txt', 'a') as file:
        print("Timestamp:",file=file)
        print(current_datetime, file=file)
        print('Filtered PEAS ensemble based on data from:', file=file)  # Print a string to the file
        print(PEAS_path, file=file)
        print("Passings members", file=file)
        print(np.array(df_passing['inst']), file=file)
        print('-----------------------------',file=file)

if __name__ == "__main__":


    if ("--help" in sys.argv):
        print('-PEAS_metrics: path to file containing the PEAS metrics')
        sys.exit()


    PEAS_path = sys.argv[1]

    main(PEAS_path)

