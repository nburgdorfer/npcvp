#!/bin/bash

DTU_TEST_ROOT="/media/nate/Data/DTU/"
DEPTH_FOLDER="/media/nate/Drive1/Results/NP-CVP-MVSNet/dtu/Output_local/"
OUT_FOLDER="/media/nate/Drive1/Results/NP-CVP-MVSNet/dtu/Output_fused_local/"
FUSIBILE_EXE_PATH="./fusibile"
SCENE_LIST=../dataset/dtu/scan_list.txt

EVAL=/media/nate/Data/Evaluation/dtu/
MATLAB_CODE_DIR=${EVAL}matlab_code/
PYTHON_CODE_DIR=${EVAL}dtu_evaluation/python/
METHOD=npcvp
EVAL_PC_DIR=${EVAL}mvs_data/Points/${METHOD}/
EVAL_RESULTS_DIR=${EVAL}mvs_data/Results/

fusion() {
	python depthfusion.py \
	--dtu_test_root=$DTU_TEST_ROOT \
	--depth_folder=$DEPTH_FOLDER \
	--scene=$1 \
	--out_folder=$OUT_FOLDER \
	--fusibile_exe_path=$FUSIBILE_EXE_PATH \
	--prob_threshold=0.8 \
	--disp_threshold=$2 \
	--num_consistent=$3 \
	--image_height=1200

	# move merged point cloud to evaluation path
	cp ${OUT_FOLDER}${1}consistencyCheck/final3d_model.ply ${EVAL_PC_DIR}${PC_FILE_NAME}
}

evaluate_matlab() {
	## Evaluate the output point clouds
	# delete previous results if 'Results' directory is not empty
	if [ "$(ls -A $EVAL_RESULTS_DIR)" ]; then
		rm -r $EVAL_RESULTS_DIR*
	fi

	USED_SETS="[${SCANS[@]}]"

	# run matlab evaluation on merged output point cloud
	matlab -nodisplay -nosplash -nodesktop -r "clear all; close all; format compact; arg_method='${METHOD}'; UsedSets=${USED_SETS}; run('${MATLAB_CODE_DIR}BaseEvalMain_web.m'); clear all; close all; format compact; arg_method='${METHOD}'; UsedSets=${USED_SETS}; run('${MATLAB_CODE_DIR}ComputeStat_web.m'); exit;" | tail -n +10

}

SCANS=(1 4 9 10 11 12 13 15 23 24 29 32 33 34 48 49 62 75 77 110 114 118)

for SCAN in ${SCANS[@]}
do
	echo -e "\e[1;33mWorking on scan ${SCAN}...\e[0;37m"

	printf -v PADDED_SCAN_NUM "%03d" $SCAN
	SCAN_DIR="scan${PADDED_SCAN_NUM}/"
	PC_FILE_NAME=${METHOD}${PADDED_SCAN_NUM}_l3.ply

	fusion $SCAN_DIR 0.1 2
done

# run evaluation
echo -e "\e[1;33mEvaluating Output...\e[0;37m"
evaluate_matlab $SCANS

echo -e "\e[1;32mDone!\e[0;37m"
