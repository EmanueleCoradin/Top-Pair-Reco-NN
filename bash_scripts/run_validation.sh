#!/bin/bash
source ~/DM/bin/activate
source /cvmfs/sft.cern.ch/lcg/views/setupViews.sh LCG_104 x86_64-el9-gcc11-opt
# Base path
BASE_PATH="/nfs/dust/cms/user/stafford/For_Emanuele/reconn/skims/"
INPUT_MODEL="TTTo2L2Nu_TuneCP5_13TeV-powheg-pythia8/"
INPUT_PATH="./${INPUT_MODEL}"

# Array of subfolders
SUBFOLDERS=(
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_100_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_150_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_200_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_250_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_300_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_350_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_400_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_450_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_500_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_1_Mphi_50_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_20_Mphi_100_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_30_Mphi_100_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_40_Mphi_100_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_45_Mphi_100_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_49_Mphi_100_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_51_Mphi_100_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
    "_TTbarDMJets_Dilepton_scalar_LO_Mchi_55_Mphi_100_TuneCP5_13TeV_madgraph_mcatnlo_pythia8/"
)
    
# Loop through each subfolder
for SUBFOLDER in "${SUBFOLDERS[@]}"; do
    # Construct full path
    FULL_PATH="${BASE_PATH}${SUBFOLDER}"

    # Check if local subfolder exists, if not, create it
    if [ ! -d "${SUBFOLDER}" ]; then
        mkdir -p "${SUBFOLDER}"
    fi

    # Run the commands
    nohup python plot_validation_bcls.py "${BASE_PATH}${INPUT_PATH}traindata.hdf5" "${FULL_PATH}validatedata.hdf5" --model_bcls "${INPUT_PATH}model_bcls.hdf5" --output "${SUBFOLDER}" >> "${SUBFOLDER}log_validate_bcls.txt" 2>&1 &
    wait
    nohup python plot_validation.py "${BASE_PATH}${INPUT_PATH}traindata.hdf5" "${FULL_PATH}validatedata.hdf5"  -b "${INPUT_PATH}model_bcls.hdf5" --model_tt "${INPUT_PATH}model_tt.hdf5" --output "${SUBFOLDER}" >> "${SUBFOLDER}log_validate.txt" 2>&1 &
done
