#!/bin/bash
#SBATCH --time      0-05:00:00
#SBATCH --nodes     1
#SBATCH --partition allgpu
#SBATCH --job-name  training
#SBATCH --output    /gpfs/dust/cms/user/coradine/test_out.txt
#SBATCH --error     /gpfs/dust/cms/user/coradine/test_err.txt

export LD_PRELOAD=""                 # useful on max-display nodes, harmless on others
source /etc/profile.d/modules.sh     # make the module command available
module load cuda/11.8
module load maxwell mamba
. mamba-init
mamba activate mambaDM

nvidia-smi
export CUDNN_PATH=$(dirname $(python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)"))
export LD_LIBRARY_PATH=${CUDNN_PATH}/lib
echo $CUDNN_PATH
echo $LD_LIBRARY_PATH

# Base path
# BASE_PATH="/nfs/dust/cms/user/stafford/For_Emanuele/reconn/skims/"
BASE_PATH="/gpfs/dust/cms/user/coradine/DATA/"
# Array of subfolders
#SUBFOLDERS=(
#    "TTTo2L2Nu_TuneCP5_13TeV-powheg-pythia8/"
#)

SUBFOLDERS=(
    "DM_30_SM_70/"
    "DM_90_SM_10/"
)

#    "DM_30_SM_70/"
#    "DM_90_SM_10/"

# Loop through each subfolder
for SUBFOLDER in "${SUBFOLDERS[@]}"; do
    # Construct full path
    FULL_PATH="${BASE_PATH}${SUBFOLDER}"

    # Check if local subfolder exists, if not, create it
    if [ ! -d "${SUBFOLDER}" ]; then
        mkdir -p "${SUBFOLDER}"
    fi

    # Run the commands
    python model_bcls.py "${FULL_PATH}traindata.hdf5" "${FULL_PATH}validatedata.hdf5" --output "${SUBFOLDER}" >> "${SUBFOLDER}log_bcls.txt" 2>&1 &
    wait
    python plot_validation_bcls.py "${FULL_PATH}traindata.hdf5" "${FULL_PATH}validatedata.hdf5" --model_bcls "${SUBFOLDER}model_bcls.hdf5" --output "${SUBFOLDER}" >> "${SUBFOLDER}log_validate_bcls.txt" 2>&1 &
    wait
    python model_tt.py "${FULL_PATH}traindata.hdf5" "${FULL_PATH}validatedata.hdf5" --output "${SUBFOLDER}" >> "${SUBFOLDER}log_tt.txt" 2>&1 &
    wait
    python plot_validation.py "${FULL_PATH}traindata.hdf5" "${FULL_PATH}validatedata.hdf5"  -b "${SUBFOLDER}model_bcls.hdf5" --model_tt "${SUBFOLDER}model_tt.hdf5" --output "${SUBFOLDER}" >> "${SUBFOLDER}log_validate.txt" 2>&1 &
done
