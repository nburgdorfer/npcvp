DATASET_ROOT="/media/nate/Data/DTU/"

# Task name
CKPT_DIR=/media/nate/Data/Models/NP-CVP-MVSNet/dtu/
CKPT_NAME="model_000010.ckpt"

# Checkpoint
LOAD_CKPT_DIR="${CKPT_DIR}${CKPT_NAME}"

# Output dir
OUT_DIR=/media/nate/Drive1/Results/NP-CVP-MVSNet/dtu/Output_local/

CUDA_VISIBLE_DEVICES=0 python eval.py \
\
--info=$TASK_NAME \
--mode="test" \
\
--dataset="dtu" \
--dataset_root=$DATASET_ROOT \
--scene_list=./dataset/dtu/scan_list.txt \
--imgsize=1200 \
--depth_h=1152 \
--depth_w=1600 \
--vselection="mvsnet" \
--nsrc=4 \
--nbadsrc=0 \
--nscale=4 \
--gtdepth=1 \
--eval_precision=16 \
--feature_ch 8 16 32 64 \
--gwc_groups 2 4 4 8 \
--target_d 8 16 32 48 \
\
--init_search_mode='uniform' \
--costmetric='gwc_weighted_sum' \
\
--batch_size=1 \
\
--loadckpt=$LOAD_CKPT_DIR \
--logckptdir=$CKPT_DIR \
\
--outdir=$OUT_DIR
