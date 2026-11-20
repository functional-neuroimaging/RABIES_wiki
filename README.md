# RABIES at the Gozzi Lab

This repository gathers the recommendations for using [RABIES](https://github.com/CoBrALab/RABIES) (Rodent Automated BOLD Improvement of EPI Sequences) for rodent fMRI processing at the Gozzi lab.

## Getting started

If you are new to RABIES, start with the official introductory tutorial to learn the basics:
https://rabies.readthedocs.io/en/latest/tutorials/first_run.html

## Contents

- **[brkraw_to_bids/](brkraw_to_bids/)**: how to convert a raw Bruker dataset to BIDS format, which RABIES needs as input.
- **[gozzilab_template_script/](gozzilab_template_script/)**: template scripts with the standard RABIES calls that reproduce the lab's standard pipeline:
  - `rabies_preprocess_basic.sh`: preprocessing that uses functional scans only (`--bold_only`)
  - `rabies_preprocess_robust.sh`: preprocessing that also uses the anatomical scans, for more precise EPI masking and registration
  - `rabies_confound_correction_legacy.sh`: the confound correction parameters historically used in the original Gozzilab pipeline
  - `rabies_analysis_QC.sh`: example to produce data quality reports and seed-based analysis
  - `rabies_group_ica.sh`: how to run a group ICA
