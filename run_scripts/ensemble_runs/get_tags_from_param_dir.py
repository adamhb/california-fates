'''
Inputs
    param_dir: path to directory where there are parameter files that you want to extract the tags from"

Output
   print the tags with leading zeros
'''

import sys

def main(param_dir):

    import os
    import re
    files = os.listdir(param_dir)
    pattern = r'_(\d{4})\.nc'
    tags = []

    for f in files:

        # Finding all matches
        tags.append(re.findall(pattern, f)[0])
   
    print(" ".join(sorted(tags)))



if __name__ == "__main__":


    if ("--help" in sys.argv):
        print("Usage: <param_dir>")
        print("param_dir: Directory path to parameter files that you want to extract the tags from")
        sys.exit()


    param_dir = sys.argv[1]

    main(param_dir)
