#!/bin/bash

#SBATCH --job-name=train-tswhisper
#SBATCH --nodes=1
#SBATCH --gpus=4
#SBATCH --output=./exp_out_logs/%x_%j.out          ### Slurm Output file, %x is job name, %j is job id
#SBATCH --error=./exp_out_logs/%x_%j.out           ### Slurm Error file, %x is job name, %j is job id\

export N_GPUS=4
export CUDA_VISIBLE_DEVICES="$(seq -s ',' 0 $((N_GPUS-1)))"

./scripts/training/run_train.sh "$@"
