# IMPORTANT: it is important to keep providing the original input and output folder paths to docker using -v with consistent syntax across different pipeline stages, otherwise RABIES will throw errors saying that files went missing
rabies_in=/local_path_to_working_directory/bids_input_folder
rabies_out=/local_path_to_working_directory/rabies_out_20260213
conf_dir=FD_cut30frames_bandpass0.01-0.1_cut30edges_mot6_CSF_smooth5 # this folder name must indicate where the cleaned timeseries were generated at the confound_correction stage
group_ica_dir=group_ica_20 # its best to create a new output folder for the group-ICA run, so that it does not get confused with other analyses

docker run -it --rm --user $(id -u) \
-v ${rabies_in}:/rabies_input:ro \
-v ${rabies_out}:/rabies_out \
-v /home/gdesrosiersgregoire/atlases:/atlases \
ghcr.io/cobralab/rabies:0.6.0 \
-f -p MultiProc --local_threads 6 \
analysis /rabies_out/$conf_dir /rabies_out/$conf_dir/$group_ica_dir \
--group_ica apply=true,dim=20,random_seed=1,disableMigp=true

# --group_ica is the parameter that calls the group ICA decomposition using FSL's MELODIC algorithm
# dim=20 is fixing the decomposition to 20 components, as a general rule of thumb 15 to 30 components is a good range to explore, 
# with large or noisy dataset it is possible to go at higher dimensions
# random_seed=1 makes the algorithm deterministic
# disableMigp=true will turn off the MIGP method of FSL that reduce computational load for large datasets - it is generally more stable to avoid it, unless you have a very large dataset
