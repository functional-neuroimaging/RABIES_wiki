rabies_in=/local_path_to_working_directory/bids_input_folder # here provide the path to your BIDS folder
rabies_out=/local_path_to_working_directory/rabies_out_20260213 # here provide the path to the desired output folder. It is good practice to use a sensible naming + date 
mkdir -p $rabies_out

docker run -it --rm --user $(id -u) \
-v ${rabies_in}:/rabies_input:ro \
-v ${rabies_out}:/rabies_out \
ghcr.io/cobralab/rabies:0.6.0 \
-f -p MultiProc --local_threads 6 \
preprocess /rabies_input /rabies_out \
--bold_only \
--apply_despiking \
--anatomical_resampling 0.15x0.15x0.15 \
--commonspace_resampling ***input_your_image_dimensions***

#--bold_only activates the pipeline infrastructure that only uses functional images (if there are anatomical scans in the BIDS folder, they will be ignored).
#--apply_despiking will apply AFNI's despiking function.
