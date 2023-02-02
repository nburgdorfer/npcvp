#!/bin/bash

#DATASET=training
DATASET=intermediate

TRAINING_SET=dtu
#TRAINING_SET=blended_mvs

TNT_TEST_ROOT="/media/Data/nate/TNT/${DATASET}/"
COLMAP_DIR=/media/Data/nate/TNT/colmap/
DEPTH_FOLDER="/media/Data/nate/Results/NP-CVP-MVSNet/tnt/Output_${DATASET}_${TRAINING_SET}/"
OUT_FOLDER="/media/Data/nate/Results/NP-CVP-MVSNet/tnt/Output_${DATASET}_${TRAINING_SET}_fused/"
FUSIBILE_EXE_PATH="./fusibile"
SCENE_LIST=../dataset/tnt/${DATASET}_list.txt
EVAL_CODE_DIR=/media/Data/nate/Evaluation/tnt/TanksAndTemples/python_toolbox/evaluation/

fusion() {
	SCENE=$1
	DISP_TH=$2
	NUM_CONS=$3

	#	## compute the alignment for mvsnet -> GT
    #	echo -e "\e[1;33mComputing scene alignmment...\e[0;37m"
	#	python -u ../tools/alignment/compute_alignment.py \
	#			-a ${DEPTH_FOLDER}${SCENE}/cam/ \
	#			-b ${COLMAP_DIR}Cameras/${SCENE}/ \
	#			-t ${COLMAP_DIR}Cameras/${SCENE}/alignment.txt \
	#			-o ${DEPTH_FOLDER}${SCENE}/cam/alignment.txt

	#	## convert mvsnet cameras into .log format (w/ alignment)
    #	echo -e "\e[1;33mCreating tnt camera file...\e[0;37m"
	#	python -u ../tools/conversion/convert_to_log.py \
	#			-d ${DEPTH_FOLDER}${SCENE}/cam/ \
	#			-f mvsnet \
	#			-a ${DEPTH_FOLDER}${SCENE}/cam/identity_trans.txt \
	#			-o ${DEPTH_FOLDER}${SCENE}/cam/camera_pose.log

	python depthfusion.py \
	--dtu_test_root=$TNT_TEST_ROOT \
	--depth_folder=$DEPTH_FOLDER \
	--scene=${SCENE} \
	--out_folder=$OUT_FOLDER \
	--fusibile_exe_path=$FUSIBILE_EXE_PATH \
	--dataset=tnt \
	--prob_threshold=0.8 \
	--disp_threshold=${DISP_TH} \
	--num_consistent=${NUM_CONS} \
	--image_height=1080
}

evaluate() {
	SCENE=$1
	PLY=$2

    cd ${EVAL_CODE_DIR}
	echo -e "\e[1;33mRunning Tanks and Temples evaluation...\e[0;37m"
    python -u run.py \
			--dataset-dir ${EVAL_CODE_DIR}../../../eval_data/${SCENE}/ \
			--traj-path ${DEPTH_FOLDER}${SCENE}/cam/camera_pose.log \
			--ply-path ${PLY}
}

#SCENES=(Barn Caterpillar Ignatius Truck)
#DISP_TH=(0.35 0.20 0.55 0.30)
#NUM_CONSIST=(3 6 2 3)

SCENES=(Family Francis Horse Lighthouse M60 Panther Playground Train)
DISP_TH=(0.25 0.25 0.20 0.30 0.25 0.20 0.25 0.25)
NUM_CONSIST=(4 4 7 5 4 4 5 5)
i=0

for SCENE in ${SCENES[@]}
do
	echo "Working on scene ${SCENE} ($i)"
	fusion ${SCENE} ${DISP_TH[$i]} ${NUM_CONSIST[$i]}
    #evaluate $SCENE ${OUT_FOLDER}${SCENE}/consistencyCheck/final3d_model.ply &
	#wait

	let i=$i+1
done
