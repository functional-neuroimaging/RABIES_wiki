These are instructions for using brkraw_convert.py, which can convert individual bruker files using a more recent version of the brkraw package.

# Prepare a python environment

```sh
conda create -n brkraw
conda activate brkraw
conda install -y pip
python -m pip install brkraw==0.5.7 # this is the package version I used
brkraw init # press enter or Y for option listed
```

## Using brkraw_convert.py

Print the --help:
```sh
conda activate brkraw # make sure your conda environment is ON
python RABIES_wiki/brkraw_to_bids/brkraw_convert.py --help
```
Basic usage (example with the raw folder 20220802_155402_ag220802d_ag220802d_1_1/):
```sh
python RABIES_wiki/brkraw_to_bids/brkraw_convert.py /path_to_bruker_folder/20220802_155402_ag220802d_ag220802d_1_1 /path_to_output_BIDS_folder/bids_dataset --anat_scan_id 4 --func_scan_id 5
```
`--anat_scan_id 4 --func_scan_id 5` are key parameters: it must correspond to the scan # of the raw bruker file for the anatomical and functional scans (usually 4 and 5 is the standard protocol, but it can vary from project to project).

Check the output:
```sh
$ tree bids_dataset/
bids_dataset/
└── sub-ag220802d
    ├── anat
    │   └── sub-ag220802d_T2w.nii.gz
    └── func
        └── sub-ag220802d_bold.nii.gz

3 directories, 2 files
```