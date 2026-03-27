# IMPORTANT: it is important to keep providing the original input and output folder paths to docker using -v with consistent syntax across different pipeline stages, otherwise RABIES will throw errors saying that files went missing
rabies_in=/local_path_to_working_directory/bids_input_folder
rabies_out=/local_path_to_working_directory/rabies_out_20260213
conf_dir=FD_cut30frames_bandpass0.01-0.1_cut30edges_mot6_CSF_smooth5 # this folder name must indicate where the cleaned timeseries were generated at the confound_correction stage

docker run -it --rm --user $(id -u) \
-v ${rabies_in}:/rabies_input:ro \
-v ${rabies_out}:/rabies_out \
-v /home/gdesrosiersgregoire/atlases:/atlases \
ghcr.io/cobralab/rabies:0.6.0 \
-f -p MultiProc --local_threads 6 \
analysis /rabies_out/$conf_dir /rabies_out/$conf_dir \
--data_diagnosis \
--seed_list SS_frontal_seed ACA_seed

#* `--data_diagnosis`: this will generate a series of visual report that support quality assessment for functional connectivity analysis. The content of those reports are extensively documented elsewhere https://rabies.readthedocs.io/en/latest/analysis_QC.html.
#* `--seed_list SS_frontal_seed ACA_seed`: This parameter handles the computation of seed-based connectivity (using pearson correlation). Here we are using 2 pre-built seeds `SS_frontal_seed` and `ACA_seed`, which correspond to the somatomotor area and anterior cingulate cortex.
