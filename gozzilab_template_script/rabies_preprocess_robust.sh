# this script is a robust version of the preprocessing pipeline, using anatomical scans i.e. without --bold_only, 
# and using --bold_robust_inho_cor to generate a EPI template from which precise EPI masks can be inherited.
# After creating a precise EPI mask, the mask is used for brain extraction when aligned to the anatomical image 
# by selecting brain extraction options with --bold2anat_coreg

rabies_in=/local_path_to_working_directory/bids_input_folder # here provide the path to your BIDS folder
rabies_out=/local_path_to_working_directory/rabies_out_20260213 # here provide the path to the desired output folder. It is good practice to use a sensible naming + date 
mkdir -p $rabies_out

docker run -it --rm --user $(id -u) \
-v ${rabies_in}:/rabies_input:ro \
-v ${rabies_out}:/rabies_out \
ghcr.io/cobralab/rabies:0.6.0 \
-f -p MultiProc --local_threads 6 \
preprocess /rabies_input /rabies_out \
--anatomical_resampling 0.15x0.15x0.15 \
--commonspace_resampling ***input_your_image_dimensions*** \
--bold_robust_inho_cor apply=true --bold_inho_cor method=SyN \
--bold2anat_coreg masking=true,brain_extraction=true,keep_mask_after_extract=true
