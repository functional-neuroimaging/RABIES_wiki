# Raw file conversion and BIDS formatting using brkraw

## Prepare a dedicated python environment and run the conversion

```sh
conda create -n brkraw python=3.7 #we're using an old python version because also the brkraw version that we want is an older one
conda activate brkraw
pip install brkraw==0.3.11 # this is the version that supports excel file based conversion

brkraw bids_helper <input_directory_with_your_bruker_files> <name_of_xlsx_file> # generates the excel file for convertion
############################## Check and edit your excel file ##############################
brkraw bids_convert <path_to_bruker_scans> <path_to_xlsx_file> -o <path_to_directory_for_converted_scans>
```
For more thorough instructions, and an example for how to edit the excel file, consult this dedicated documentation https://github.com/CoBrALab/documentation/wiki/bruker2nifti-conversion.

## Why not use the latest version of brkraw?

There is almost no BIDS support on the latest version, (as of March 12, 2026). It seems that they are in the process of developing a brkraw tool for bids.
This is because they realized that BIDS specs are constantly evolving and they don't have the capacity to keep updating the brkraw package to keep up with them. To use the latest version, we have to either convert files one by one or the correct subject name needs to be specified when creating the subject in Paravision (which the gozzi lab doesn't do) ie the metadata needs to be correct.

However, for our purposes, their old version of the package worked well (the 0.3.11). It produces an excel file with bids related columns that you can easily modify. Then, simply provide this excel file and it will convert + rename your raw bruker files according to what is in the excel sheet. While it may be insufficient for other complex MRI modalities, for simple EPI and anatomical scans, it works well.
