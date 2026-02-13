from pathlib import Path
from brkraw.core import layout as layout_core
import brkraw as brk
import argparse
import os

def generate_BIDS(brkraw_input_folder, bids_nii_output, anat_scan_id = 4 , func_scan_id = 5, session = None, run = None):
    loader = brk.load(brkraw_input_folder)
    bids_nii_output = os.path.abspath(bids_nii_output) # convert to absolute path
    if session is None:
        anat_layout_template=bids_nii_output + "/sub-{Subject.ID}/anat/sub-{Subject.ID}"
        func_layout_template=bids_nii_output + "/sub-{Subject.ID}/func/sub-{Subject.ID}"
    else:
        anat_layout_template=bids_nii_output + "/sub-{Subject.ID}"+f"/ses-{session}"+"/anat/sub-{Subject.ID}"+f"_ses-{session}"
        func_layout_template=bids_nii_output + "/sub-{Subject.ID}"+f"/ses-{session}"+"/func/sub-{Subject.ID}"+f"_ses-{session}"
    if run is None:
        anat_layout_template+="_T2w"
        func_layout_template+="_bold"
    else:
        anat_layout_template+=f"_run-{str(run)}_T2w"
        func_layout_template+=f"_run-{str(run)}_bold"


    if anat_scan_id is not None:
        out_path = layout_core.render_layout(
            loader,
            scan_id=anat_scan_id,
            layout_template=anat_layout_template,
        )
        Path(out_path).parent.mkdir(parents=True, exist_ok=True)
        print(out_path)

        nii = loader.convert(anat_scan_id, reco_id=1)
        if nii is None:
            raise RuntimeError("Conversion returned no output.")
        if isinstance(nii, tuple):
            for i, img in enumerate(nii, start=1):
                img.to_filename(f"{out_path}_part{i}.nii.gz")
        else:
            nii.to_filename(f"{out_path}.nii.gz")

    if func_scan_id is not None:
        out_path = layout_core.render_layout(
            loader,
            scan_id=func_scan_id,
            layout_template=func_layout_template,
        )
        Path(out_path).parent.mkdir(parents=True, exist_ok=True)
        print(out_path)

        nii = loader.convert(func_scan_id, reco_id=1)
        if nii is None:
            raise RuntimeError("Conversion returned no output.")
        if isinstance(nii, tuple):
            for i, img in enumerate(nii, start=1):
                img.to_filename(f"{out_path}_part{i}.nii.gz")
        else:
            nii.to_filename(f"{out_path}.nii.gz")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Load a NIfTI timeseries in chunks, downsample each frame, and generate a downsampled timeseries file."
    )
    parser.add_argument("brkraw_input_folder", help="Input Bruker raw folder path")
    parser.add_argument("bids_nii_output", help="Output BIDS folder path")
    parser.add_argument(
        "--anat_scan_id",
        type=int,
        default=4,
        help="Folder # within the Bruker raw folder for the functional scan.",
    )
    parser.add_argument(
        "--func_scan_id",
        type=int,
        default=5,
        help="Folder # within the Bruker raw folder for the functional scan.",
    )
    parser.add_argument(
        "--session",
        type=str,
        help="Optional: Specify a session ID.",
    )
    parser.add_argument(
        "--run",
        type=int,
        help="Optional: Specify the run # within this specific session.",
    )

    args = parser.parse_args()
    generate_BIDS(args.brkraw_input_folder, 
                  args.bids_nii_output, 
                  args.anat_scan_id, 
                  args.func_scan_id, 
                  args.session, 
                  args.run)
