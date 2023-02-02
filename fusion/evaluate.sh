#!/bin/bash

# path params
DTU_DIR=/media/nate/Data/Fusion/dtu/np_cvp_mvsnet/
MODEL=../DMFNet/models/dmfnet_model.pt
OUTPUT_DIR=/media/nate/Data/Fusion/dtu/Output/
EVAL=/media/nate/Data/Evaluation/dtu/
MATLAB_CODE_DIR=${EVAL}matlab_code/
PYTHON_CODE_DIR=${EVAL}dtu_evaluation/python/
METHOD=fusion
EVAL_PC_DIR=${EVAL}mvs_data/Points/${METHOD}/
EVAL_RESULTS_DIR=${EVAL}mvs_data/Results/
ALIGN=alignment.txt
PLY_EX_PATH=../DMFNet/src/cpp_utils/point_cloud_builder/build/
RENDER_EX_PATH=../DMFNet/src/cpp_utils/render/build/
TEST_EX=../DMFNet/src/test.py
GIPUMA_EXE=/home/nate/dev/research/Fusion/fusibile/fusibile


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

# define testing set
SCANS=(1 4 9 10 11 12 13 15 23 24 29 32 33 34 48 49 62 75 77 110 114 118)

