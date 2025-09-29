#!/bin/bash

source "$(dirname ${BASH_SOURCE[0]})/../../configs/local_paths.sh"
export PYTHONPATH="$(dirname ${BASH_SOURCE[0]})/../:$PYTHONPATH"

# SRC_ROOT is defined in local_paths.sh
DATA_DIR=$SRC_ROOT/data
DATA_SCRIPTS_PATH=$SRC_ROOT/scripts/data
MANIFESTS_DIR=$DATA_DIR/manifests

mkdir -p $DATA_DIR
mkdir -p $MANIFESTS_DIR

for ov in "sparse_2_0" "sparse_2_0.05" "sparse_2_0.1" "sparse_2_0.15" "sparse_2_0.2" "sparse_3_0" "sparse_3_0.05" "sparse_3_0.1" "sparse_3_0.15" "sparse_3_0.2"; do
    for type in "clean" "noisy"; do
        python $DATA_SCRIPTS_PATH/sparselsmix_to_lhotse.py --mixture_metadata $DATA_DIR/tmp/SparseLibriMix/metadata/${ov}/metadata.json \
            --mixture_wavs_dir $DATA_DIR/sparselibrimix/$ov/wav16000/mix_$type \
            --output_manifest $MANIFESTS_DIR/sparselibrimix_mix_${type}_${ov}_sc_test_cutset.jsonl.gz
    done
done