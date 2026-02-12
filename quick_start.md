# Hands-on quick start to using RABIES

This page will provide you with a step-by-step hands-on introduction to running all three stages of the RABIES software, `preprocess`, `confound_correction` and `analysis`, using a Docker container. The pipeline will be tested on a publicly available [testing dataset](https://zenodo.org/record/8349029).

To follow this tutorial, your hardware must allow for running Docker, and you should have ~7Gb of free space to download the RABIES image. Alternatively, the same steps can be conducted using [Singularity/Apptainer](https://apptainer.org/docs/admin/main/installation.html) using a Linux system, although the execution syntax is slightly different (refer to the [RABIES documentation](https://rabies.readthedocs.io/en/latest/running_the_software.html#execution-syntax-with-containerized-installation-singularity-and-docker)).

# Install RABIES and download the testing dataset
Before beginning, pull the RABIES container image (here we use the version `master`, i.e. we use the current master github branch):
```sh
docker pull ghcr.io/cobralab/rabies:master
#IMPORTANTLY, IT IS GENERALLY NOT RECOMMEND TO USE THE MASTER BRANCH, AND INSTEAD USE A SPECIFIC RABIES VERSION. WE ARE MAKING AN EXCEPTION FOR THIS TUTORIAL.
```

And download the testing dataset in the current working directory:
```sh
wget -O test_dataset.zip "https://zenodo.org/records/8349029/files/test_dataset.zip?download=1"
unzip test_dataset.zip
rm test_dataset.zip
```

Inspect the folder, and notice that it was formated following the BIDS convention, which is required to run RABIES:
```sh
$ tree test_dataset
test_dataset
├── sub-PHG001
│   └── ses-3
│       ├── anat
│       │   ├── sub-PHG001_ses-3_acq-RARE_T2w.json
│       │   └── sub-PHG001_ses-3_acq-RARE_T2w.nii.gz
│       └── func
│           ├── sub-PHG001_ses-3_task-rest_acq-EPI_run-1_bold.json
│           └── sub-PHG001_ses-3_task-rest_acq-EPI_run-1_bold.nii.gz
└── sub-PHG002
    └── ses-3
        ├── anat
        │   ├── sub-PHG002_ses-3_acq-RARE_T2w.json
        │   └── sub-PHG002_ses-3_acq-RARE_T2w.nii.gz
        └── func
            ├── sub-PHG002_ses-3_task-rest_acq-EPI_run-1_bold.json
            └── sub-PHG002_ses-3_task-rest_acq-EPI_run-1_bold.nii.gz

8 directories, 8 files
```

# RABIES preprocess stage

To run the first stage of the pipeline, `preprocess`, write a shell script `rabies_preprocess.sh` where you will save your docker execution of RABIES:
```sh
rabies_in=/local_path_to_working_directory/test_dataset # here provide the path to your BIDS folder
rabies_out=/local_path_to_working_directory/rabies_test_dataset_20260213 # here provide the path to the desired output folder. It is good practice to use a sensible naming + date 
mkdir -p $rabies_out

docker run -it --rm --user $(id -u) \
-v ${rabies_in}:/rabies_input:ro \
-v ${rabies_out}:/rabies_out \
ghcr.io/cobralab/rabies:master \
-f -p MultiProc --local_threads 6 \
preprocess /rabies_input /rabies_out \
--bold_only \
--apply_despiking \
--anatomical_resampling 0.3x0.3x0.3 \
--commonspace_resampling 0.25x0.5x0.25 \
--bold_inho_cor method=N4_reg
```

## Line by line breakdown of the Docker-RABIES command:

**Docker parameters...**
* `docker run -it --rm --user $(id -u)`: Some parameters to make sure docker runs without permission issues.
* `-v ${rabies_in}:/rabies_input:ro`: `-v` is required to link local folders/files from your workstation to inside the Docker container where computations happen. Here we are linking the path of the input folder, and it will be accessible as `/rabies_input` inside Docker.
* `-v ${rabies_out}:/rabies_out`: Same as above, but for the output folder.
* `ghcr.io/cobralab/rabies:master`: Here we provide the name of the docker image to be run, i.e. some version of RABIES. In this case we are using the master version.
**RABIES parameters...**
* `-f -p MultiProc --local_threads 6`: We begin to provide parameters to the RABIES command. The initial set of parameters are common across all pipeline stages, for a full list use `docker run ghcr.io/cobralab/rabies:master --help`. Here we are providing `-f` to overwrite previous outputs if present (use at your own risk!), `-p MultiProc` activates multi-threading to that operations are executed in parallel, and `--local_threads 6` sets the maximal number of CPUs to use for that command.
* `preprocess /rabies_input /rabies_out`: Now we specify the pipeline stage to run, i.e. the first stage `preprocess`. We then provide the paths to the input and then output folders. IMPORTANT: the input/output folder paths are defined with the `-v` docker parameters above, so the syntax must be consistent.
* `--anatomical_resampling 0.3x0.3x0.3`: This specifies the resolution at which registration operations are conducted. Here we provide very low resolution for of 0.3mm isotropic to speed things up, but in practice I usually use 0.15mm isotropic. We do not recommend registration in non-isotropic resolution.
* `--commonspace_resampling 0.25x0.5x0.25`: This defines the final resolution of the preprocessed data in commonspace. Here the dimensions are copied from the input functional image header, which were acquired at 0.25x0.5x0.25mm. The order here must follow the RAS axis order convention (right-left, anterior-posterior, and then superior-inferior).  
* `--anat_inho_cor method=N4_reg --bold_inho_cor method=N4_reg`: Here we are changing the default method for inhomogeneity correction for an alternative (`N4_reg`) that runs faster for our quick run, but we recommend leaving the default parameter for most cases.

All other parameters for `preprocess` can be listed with `docker run ghcr.io/cobralab/rabies:master preprocess --help`.

## Inspect preprocess_QC_report

Now you should inspect where each registration step was successful as displayed by the report in `/local_path_to_working_directory/rabies_test_dataset_20260213/preprocess_QC_report`. 
```sh
$ tree rabies_test_dataset_20260213/preprocess_QC_report/
rabies_test_dataset_20260213/preprocess_QC_report/
├── bold_inho_cor
│   ├── sub-PHG001_ses-3_task-rest_acq-EPI_run-1_bold_inho_cor.png
│   └── sub-PHG002_ses-3_task-rest_acq-EPI_run-1_bold_inho_cor.png
├── commonspace_reg_wf.Anat2Unbiased
│   ├── sub-PHG001_ses-3_task-rest_acq-EPI_run-1_bold_RAS_bias_cor_registration.png
│   └── sub-PHG002_ses-3_task-rest_acq-EPI_run-1_bold_RAS_bias_cor_registration.png
├── commonspace_reg_wf.Unbiased2Atlas
│   └── _registration.png
├── template_files
│   └── template_files.png
└── temporal_features
    ├── sub-PHG001_ses-3_task-rest_acq-EPI_run-1_bold_temporal_features.png
    └── sub-PHG002_ses-3_task-rest_acq-EPI_run-1_bold_temporal_features.png

5 directories, 8 files
```
The content of each folder and representative examples are documented in https://rabies.readthedocs.io/en/latest/preproc_QC.html.

# RABIES confound_correction stage

For the next stage, `confound_correction`, we can create a new shell script `rabies_confound_correction.sh` with the following content:
```sh
# IMPORTANT: it is important to keep providing the original input and output folder paths to docker using -v with consistent syntax across different pipeline stages, otherwise RABIES will throw errors saying that files went missing
rabies_in=/local_path_to_working_directory/test_dataset
rabies_out=/local_path_to_working_directory/rabies_test_dataset_20260213
conf_dir=FD_mot6_aCompCor_smooth5 # this is optional, but I usually want to specify a new output folder for the cleaned timeseries, and name this folder depending on the set of parameters specified in the command below

docker run -it --rm --user $(id -u) \
-v ${rabies_in}:/rabies_input:ro \
-v ${rabies_out}:/rabies_out \
ghcr.io/cobralab/rabies:master \
-f -p MultiProc --local_threads 6 \
confound_correction /rabies_out /rabies_out/${conf_dir} \
--frame_censoring FD_censoring=true,FD_threshold=0.05,minimum_timepoint=80 \
--smoothing_filter 0.5 \
--conf_list mot_6 aCompCor_5
```

## RABIES parameters breakdown:
* `confound_correction /rabies_out /rabies_out/${conf_dir}`: now we are running the `confound_correction` stage instead, which requires first the output folder previously generated by the `preprocess` stage, which we previously names `/rabies_out`. Here it is crucial both to provide access to this folder with `-v` syntax that is consistent with how the `preprocess` stage was run, otherwise RABIES will be confused when trying to locate previous outputs. Then, this line also provides the desired output folder path for the new pipeline stage, i.e. `/rabies_out/${conf_dir}` in this case, which will create a new folder inside `/rabies_out` with the naming specified above for the `conf_dir` shell variable.
* `--frame_censoring FD_censoring=true,FD_threshold=0.05,minimum_timepoint=80`: This parameter regulates frame censoring, or 'scrubbing'. Here we apply censoring based on framewise displacement with a threshold of 0.05mm. Also, `minimum_timepoint=80` means that any scan with less than 80 frames left post-censoring will be entirely discarded from further operations. 80 frames is selected here as a heuristic for 'excessive motion', since it corresponds to 2/3 of the original data length of 120 frames here.
* `--smoothing_filter 0.5`: we apply spatial smoothing with a 0.5mm kernel
* `--conf_list mot_6 aCompCor_5`: we apply nuisance regression using the 6 rigid body motion parameters and 5 aCompCor components.

All other parameters for `confound_correction` can be listed with `docker run ghcr.io/cobralab/rabies:master confound_correction --help`.

# RABIES analysis stage

Similarly for the analysis stage, we create a final shell script `rabies_analysis.sh` with the following content:
```sh
# IMPORTANT: it is important to keep providing the original input and output folder paths to docker using -v with consistent syntax across different pipeline stages, otherwise RABIES will throw errors saying that files went missing
rabies_in=/local_path_to_working_directory/test_dataset
rabies_out=/local_path_to_working_directory/rabies_test_dataset_20260213
conf_dir=FD_mot6_aCompCor_smooth5 # same name as in the confound_correction stage

docker run -it --rm --user $(id -u) \
-v ${rabies_in}:/rabies_input:ro \
-v ${rabies_out}:/rabies_out \
-v /home/gdesrosiersgregoire/atlases:/atlases \
ghcr.io/cobralab/rabies:master \
-f -p MultiProc --local_threads 6 \
analysis /rabies_out/$conf_dir /rabies_out/$conf_dir \
--data_diagnosis \
--seed_list SS_frontal_seed ACA_seed
```

## RABIES parameters breakdown:

* `analysis /rabies_out/$conf_dir /rabies_out/$conf_dir`: the `analysis` stage expects to be first provided the output folder from the `confound_correction` stage, and then a folder path for new outputs. Here we use the same output folder as `confound_correction`, but an entirely new output folder could be created if desired.
* `--data_diagnosis`: this will generate a series of visual report that support quality assessment for functional connectivity analysis. The content of those reports are extensively documented elsewhere https://rabies.readthedocs.io/en/latest/analysis_QC.html.
* `--seed_list SS_frontal_seed ACA_seed`: This parameter handles the computation of seed-based connectivity (using pearson correlation). Here we are using 2 pre-built seeds `SS_frontal_seed` and `ACA_seed`, which correspond to the somatomotor area and anterior cingulate cortex.

All other parameters for `analysis` can be listed with `docker run ghcr.io/cobralab/rabies:master analysis --help`.

## Inspect data_diagnosis_datasink
The outputs from the connectivity analysis can be visualized from the `--data_diagnosis` report, in the following folder:
```sh
$ tree rabies_test_dataset_20260213/FD_mot6_aCompCor_smooth5/data_diagnosis_datasink/figure_spatial_diagnosis/
rabies_test_dataset_20260213/FD_mot6_aCompCor_smooth5/data_diagnosis_datasink/figure_spatial_diagnosis/
├── _split_name_sub-PHG001_ses-3_task-rest_acq-EPI_run-1_bold
│   └── sub-PHG001_ses-3_task-rest_acq-EPI_run-1_bold_spatial_diagnosis.png
└── _split_name_sub-PHG002_ses-3_task-rest_acq-EPI_run-1_bold
    └── sub-PHG002_ses-3_task-rest_acq-EPI_run-1_bold_spatial_diagnosis.png

2 directories, 2 files
```

In the PNG file generated for each subject, the rows SBC network 0/1 are the thresholded seed-based connectivity map generated from the two seeds inputed above. Can you see some networks?
