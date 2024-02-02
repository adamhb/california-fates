'''
Transfer restart files from src_rundir to dst_rundir

Inputs:
- src_rundir: Directory path where you want to source the restart files
- dst_rundir: Directory path where you want to transfer the new restart files
'''


import sys
sys.path.append('/glade/u/home/adamhb/Earth-System-Model-Tools/')
import esm_tools
import os
import shutil


def main(src_rundir, dst_rundir):

    print("Copying files from {} to {}".format(src_rundir,dst_rundir))

    # If destination directory doesn't exist, create it
    esm_tools.create_directory(dst_rundir)

    src_files = esm_tools.find_nc_and_rpointer_files(src_rundir)
    
    for src_file in src_files:
        basename = os.path.basename(src_file)
        dst_file = os.path.join(dst_rundir,basename)
        shutil.copy(src_file,dst_file)


if __name__ == "__main__":


    if ("--help" in sys.argv):
        print("Usage: <src_rundir> <dst_rundir_dir>")
        print("src_rundir: Directory path where you want to source the restart files")
        print("dst_rundir: Directory path where you want to transfer the new restart files")

        sys.exit()


    src_rundir = sys.argv[1]
    dst_rundir = sys.argv[2]

    main(src_rundir, dst_rundir)


