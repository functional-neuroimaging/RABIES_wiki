# IMPORTANT: it is important to keep providing the original input and output folder paths to docker using -v with consistent syntax across different pipeline stages, otherwise RABIES will throw errors saying that files went missing
rabies_in=/local_path_to_working_directory/bids_input_folder
rabies_out=/local_path_to_working_directory/rabies_out_20260213
conf_dir=FD_cut30frames_bandpass0.01-0.1_cut30edges_mot6_CSF_smooth5 # this is optional, but I usually want to specify a new output folder for the cleaned timeseries, and name this folder depending on the set of parameters specified in the command below

docker run -it --rm --user $(id -u) \
-v ${rabies_in}:/rabies_input:ro \
-v ${rabies_out}:/rabies_out \
ghcr.io/cobralab/rabies:master \
-f -p MultiProc --local_threads 6 \
confound_correction /rabies_out /rabies_out/${conf_dir} \
--frame_censoring FD_censoring=true,FD_threshold=0.05,minimum_timepoint=80 \
--smoothing_filter 0.5 \
--timeseries_interval 30,end \
--TR ***your_TR*** --highpass 0.01 --lowpass 0.1 --edge_cutoff 30 \
--conf_list mot_6 CSF_signal


#`--timeseries_interval 30,end`: Here this will cut out the first 30 frames. This can be done to remove the first volumes that suffer from intensity saturation, since the Gozzi lab raw image usually have a couple saturated frames.
#`--TR ***your_TR*** --highpass 0.01 --lowpass 0.1 --edge_cutoff 30`: this applies a bandpass filter at 0.01-0.1Hz. You need to provide your image TR in seconds. Also `--edge_cutoff 30` removes 30 seconds of data at the beginning and end of the data, since there can be filtering artefacts at the edges.
#`--conf_list mot_6 CSF_signal`: usually the lab regresses 6 motion parameters (or sometimes 24 instead for awake data), and the mean CSF signal
