#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/../../configs/local_paths.sh

export DIAR_EXPERIMENT="diarizen_large"
DIAR_EXPERIMENT_PATH="${SRC_ROOT}/diar_exp/${DIAR_EXPERIMENT}"
MANIFEST_DIR="${SRC_ROOT}/data/manifests"
MODEL="BUT-FIT/diarizen-wavlm-large-s80-md"

# Define cutsets array
CUTSETS=("ami-sdm_test_sc_cutset")

# Set up diarized cutsets path
export DIARIZED_CUTSETS_PATH="${DIAR_EXPERIMENT_PATH}/diarized_cutsets"
mkdir -p "$DIARIZED_CUTSETS_PATH"

# Run diarization for each cutset
for CUTSET in "${CUTSETS[@]}"; do
    echo "Processing cutset: $CUTSET"

    # Run diarization
    "$SRC_ROOT/sge_tools/python" "$SRC_ROOT/utils/diarizen_to_diar.py" \
        --model="$MODEL" \
        --input_cutset="${MANIFEST_DIR}/${CUTSET}.jsonl.gz" \
        --output_dir="${DIAR_EXPERIMENT_PATH}/${CUTSET}"

    # Prepare diarized cutset from RTTM directory
    "$SRC_ROOT/sge_tools/python" "$SRC_ROOT/utils/prepare_diar_cutset_from_rttm_dir.py" \
        --lhotse_manifest_path="${MANIFEST_DIR}/${CUTSET}.jsonl.gz" \
        --rttm_dir="${DIAR_EXPERIMENT_PATH}/$CUTSET" \
        --out_manifest_path="${DIARIZED_CUTSETS_PATH}/${CUTSET}.jsonl.gz"
done