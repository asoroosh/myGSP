#!/bin/bash
#$ -cwd
#$ -V
#$ -o $HOME/DWI/logs/ -e $HOME/DWI/logs/ 
#$ -N HCPUR_DLDL_MMP
#$ -q himem.qh
#$ -r y
#$ -t 1-100

source ~/.bashrc

PHOME=/users/nichols/scf915/DWI
PSTRG=/well/nichols/users/scf915/HCP_100UR
cd $PHOME

SendMeToHeadNode="ssh rescomp1"
s3get="sh ~/bin/s3get.sh"

echo "Loading modules..."
module load fsl
module use -a /mgmt/modules/eb/modules/all
module load ConnectomeWorkbench/1.3.2

echo "Initialising the stuff..."
SubID=$(sed "${SGE_TASK_ID}q;d" ${HOME}/bin/HCP100UR/HCP_100UR.txt)
echo "Sub: ${SubID}"

AtlasID=MMP
AtlasDir="${HOME}/bin/Atlas/${AtlasID}"
AtlasFileName="Q1-Q6_RelatedParcellation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii"

AWS_HCP_BUCKET=hcp-openaccess
Where2=${PSTRG}/${SubID}
wb_command=/mgmt/modules/eb/software/ConnectomeWorkbench/1.3.2/bin_rh_linux64/wb_command

DirID=LR
RunID=1

mkdir -p ${Where2}/RS
mkdir -p ${Where2}/fsaverage_LR32k
mkdir -p ${Where2}/fsaverage_LR32k/ROIs_gii
mkdir -p ${Where2}/fsaverage_LR32k/ROIs
mkdir -p ${Where2}/Diffusion.bedpostX
mkdir -p ${Where2}

#====================================================================================================
#====================================================================================================

echo "Resting-state download and analysis..."
#================= Resting-state download and parcellated

${SendMeToHeadNode} ${s3get} \
${AWS_HCP_BUCKET}/HCP_1200/${SubID}/MNINonLinear/Results/rfMRI_REST${RunID}_${DirID}/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii \
${Where2}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii

echo "RS Downloaded into: ${Where2}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii"

$wb_command -cifti-parcellate ${Where2}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii \
${AtlasDir}/$AtlasFileName COLUMN \
${Where2}/RS${RunID}_${SubID}_${DirID}_${AtlasID}.ptseries.nii

echo "Time series extracted into: ${Where2}/RS${RunID}_${SubID}_${DirID}_${AtlasID}.ptseries.nii"

echo "DWI download..."
#================= DWI Download ===================================

while read -u10 readfsaveragefilename; do
	echo "Downloading ${SubID}.${readfsaveragefilename}"
	${SendMeToHeadNode} ${s3get} \
	${AWS_HCP_BUCKET}/HCP_1200/${SubID}/T1w/fsaverage_LR32k/${SubID}${readfsaveragefilename} \
	${Where2}/fsaverage_LR32k/${SubID}${readfsaveragefilename}
done 10< $PHOME/Aux/readfsaveragefiles.txt

while read -u10 readbedpostXfilename; do
	echo "Downloading: ${readbedpostXfilename}"
	${SendMeToHeadNode} ${s3get} \
	${AWS_HCP_BUCKET}/HCP_1200/${SubID}/T1w/Diffusion.bedpostX/${readbedpostXfilename} \
	${Where2}/Diffusion.bedpostX/${readbedpostXfilename}
done 10< $PHOME/Aux/readbedpostXfiles.txt

echo "DWI fsaverage and bedpostX has been downloaded..."

#================ DWI Analysis ====================================
echo "DWI analysis..."

$wb_command -cifti-separate ${AtlasDir}/${AtlasFileName} COLUMN -label CORTEX_LEFT  ${Where2}/fsaverage_LR32k/LEFT_${AtlasID}.label.gii
$wb_command -cifti-separate ${AtlasDir}/${AtlasFileName} COLUMN -label CORTEX_RIGHT ${Where2}/fsaverage_LR32k/RIGHT_${AtlasID}.label.gii

$wb_command -gifti-all-labels-to-rois ${Where2}/fsaverage_LR32k/LEFT_${AtlasID}.label.gii  1  ${Where2}/fsaverage_LR32k/LEFT_${AtlasID}.func.gii
$wb_command -gifti-all-labels-to-rois ${Where2}/fsaverage_LR32k/RIGHT_${AtlasID}.label.gii 1  ${Where2}/fsaverage_LR32k/RIGHT_${AtlasID}.func.gii

for i in `seq 1 62`; do
	echo "================Right ROI: ${i} ${AtlasID}"
        
	$wb_command -metric-merge ${Where2}/fsaverage_LR32k/ROIs/right-roi-${i}_${AtlasID}.func.gii \
	-metric ${Where2}/fsaverage_LR32k/RIGHT_${AtlasID}.func.gii \
	-column ${i}
        
	surf2surf -i ${Where2}/fsaverage_LR32k/${SubID}.R.white_MSMAll.32k_fs_LR.surf.gii \
	-o ${Where2}/fsaverage_LR32k/ROIs_gii/right-roi-${i}_${AtlasID}.gii \
	--values=${Where2}/fsaverage_LR32k/ROIs/right-roi-${i}_${AtlasID}.func.gii
        
	echo ${Where2}/fsaverage_LR32k/ROIs_gii/right-roi-${i}_${AtlasID}.gii >> ${Where2}/fsaverage_LR32k/seeds_${AtlasID}.txt
done

for i in `seq 1 62`; do
	echo "================Left ROI: ${i} ${AtlasID}"
        
	$wb_command -metric-merge ${Where2}/fsaverage_LR32k/ROIs/left-roi-${i}_${AtlasID}.func.gii  \
	-metric ${Where2}/fsaverage_LR32k/LEFT_${AtlasID}.func.gii \
	-column ${i}
        
	surf2surf -i ${Where2}/fsaverage_LR32k/${SubID}.L.white_MSMAll.32k_fs_LR.surf.gii \
	-o ${Where2}/fsaverage_LR32k/ROIs_gii/left-roi-${i}_${AtlasID}.gii \
	--values=${Where2}/fsaverage_LR32k/ROIs/left-roi-${i}_${AtlasID}.func.gii
	
	echo ${Where2}/fsaverage_LR32k/ROIs_gii/left-roi-${i}_${AtlasID}.gii  >> ${Where2}/fsaverage_LR32k/seeds_${AtlasID}.txt
done

echo "DWI Network analysis..."
#================== DWI Network
probtrackx2 \
--samples=${Where2}/Diffusion.bedpostX/merged \
--mask=${Where2}/Diffusion.bedpostX/nodif_brain_mask \
--seed=${Where2}/fsaverage_LR32k/seeds_${AtlasID}.txt \
--loopcheck --forcedir --network --omatrix1 --nsamples=1000 -V 0 --dir=${Where2}/DWINetwork_${AtlasID}

echo "Done & Dusted, mate!"
