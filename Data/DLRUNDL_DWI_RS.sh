#!/bin/bash
#$ -cwd
#$ -V
#$ -o $HOME/DWI/logs/
#$ -e $HOME/DWI/logs/
#$ -q testG.q
#$ -N HCP100UR_DLDL
#$ -r y
#$ -t 1-1

PHOME=/users/nichols/scf915/DWI
PSTRG=/well/nichols/users/scf915/HCP_100UR
cd $PHOME

echo "Loading modules..."
module load fsl
module use -a /mgmt/modules/eb/modules/all
module load ConnectomeWorkbench/1.3.2

echo "Initialising the stuff..."
SubID=$(sed "${SGE_TASK_ID}q;d" ${HOME}/bin/HCP100UR/HCP_100UR.txt)
echo "Sub: ${SubID}"

AtlasID=MMP
AtlasDir=${HOME}/bin/Atlas/${AtlasID}

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

#_________________________________________________________________________________________________
#___________________________________Download form S3 Bucket_______________________________________
#_________________________________________________________________________________________________

AWS_ACCESS_KEY=$AWS_ACCESS_KEY_ID
AWS_SECRET_KEY=$AWS_SECRET_ACCESS_KEY

function s3get {
        #helper functions_________________________________________________
        function fail { echo "$1" > /dev/stderr; exit 1; }

        #dependency check_________________________________________________
        if ! hash openssl 2>/dev/null; then fail "openssl not installed"; fi
        if ! hash curl 2>/dev/null; then fail "curl not installed"; fi

        #params_________________________________________________
        path="${1}"
        bucket=$(cut -d '/' -f 1 <<< "$path")
        key=$(cut -d '/' -f 2- <<< "$path")
        region="${2:-us-west-1}"

        #echo "Bucket: ${bucket}, Path: ${path}, Key: ${key}"

        #load creds_________________________________________________
        access="$AWS_ACCESS_KEY"
        secret="$AWS_SECRET_KEY"

        #validate_________________________________________________
        if [[ "$bucket" = "" ]]; then fail "missing bucket (arg 1)"; fi;
        if [[ "$key" = ""    ]]; then fail "missing key (arg 1)"; fi;
        if [[ "$region" = "" ]]; then fail "missing region (arg 2)"; fi;
        if [[ "$access" = "" ]]; then fail "missing AWS_ACCESS_KEY (env var)"; fi;
        if [[ "$secret" = "" ]]; then fail "missing AWS_SECRET_KEY (env var)"; fi;

        #compute signature_________________________________________________
        contentType="text/html; charset=UTF-8"
        date="`date -u +'%a, %d %b %Y %H:%M:%S GMT'`"
        resource="/${bucket}/${key}"
        string="GET\n\n${contentType}\n\nx-amz-date:${date}\n${resource}"
        signature=`echo -en $string | openssl sha1 -hmac "${secret}" -binary | base64`

        #get!_________________________________________________
        curl -H "x-amz-date: ${date}" \
                         -H "Content-Type: ${contentType}" \
             -H "Authorization: AWS ${access}:${signature}" \
                            "https://s3.amazonaws.com${resource}" \
                   -o "$2"
}
#_________________________________________________________________________________________________________________________

echo "Resting-state download and analysis..."
#================= Resting-state download and parcellated

s3get ${AWS_HCP_BUCKET}/HCP_1200/${SubID}/MNINonLinear/Results/rfMRI_REST${RunID}_${DirID}/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii \
${Where2}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii

echo "RS Downloaded into: ${Where2}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii"

$wb_command -cifti-parcellate ${Where2Tmp}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii \
${AtlasDir}/Q1-Q6_RelatedParcellation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii COLUMN \
${Where2}/RS${RunID}_${SubID}_${DirID}_${AtlasID}.ptseries.nii

echo "Time series extracted into: ${Where2}/RS${RunID}_${SubID}_${DirID}_${AtlasID}.ptseries.nii"

#FREE UP MEMORY
#rm -rf ${Where2}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii

echo "DWI download..."
#================= DWI Download

while read readfsaveragefilename
do
	s3get ${AWS_HCP_BUCKET}/HCP_1200/${SubID}/T1w/fsaverage_LR32k/${SubID}${readfsaveragefilename} ${Where2Tmp}/fsaverage_LR32k/${SubID}${readfsaveragefilename}
done<Aux/readfsaveragefiles.txt

while read readbedpostXfilename; do
	s3get ${AWS_HCP_BUCKET}/HCP_1200/${SubID}/T1w/Diffusion.bedpostX/${readbedpostXfilename} ${Where2}/Diffusion.bedpostX/${readbedpostXfilename}
done<Aux/readbedpostXfiles.txt

echo "DWI fsaverage and bedpostX has been downloaded..."

#================ DWI Analysis
echo "DWI analysis..."

$wb_command -cifti-separate ${AtlasDir}/Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_LEFT  ${Where2}/fsaverage_LR32k/LEFT.label.gii
$wb_command -cifti-separate ${AtlasDir}/Q1-Q6_RelatedParcellation210.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_RIGHT ${Where2}/fsaverage_LR32k/RIGHT.label.gii

$wb_command -gifti-all-labels-to-rois ${Where2}/fsaverage_LR32k/LEFT.label.gii 1  ${Where2}/fsaverage_LR32k/LEFT.func.gii
$wb_command -gifti-all-labels-to-rois ${Where2}/fsaverage_LR32k/RIGHT.label.gii 1 ${Where2}/fsaverage_LR32k/RIGHT.func.gii

for i in `seq 1 180`; do
        $wb_command -metric-merge ${Where2}/fsaverage_LR32k/ROIs/right-roi-${i}.func.gii -metric ${Where2}/fsaverage_LR32k/RIGHT.func.gii -column ${i}
        surf2surf -i ${Where2}/fsaverage_LR32k/${SubID}.R.white_MSMAll.32k_fs_LR.surf.gii -o ${Where2}/fsaverage_LR32k/ROIs_gii/right-roi-${i}.gii --values=${Where2}/fsaverage_LR32k/ROIs/right-roi-${i}.func.gii
        echo ${Where2}/fsaverage_LR32k/ROIs_gii/right-roi-${i}.gii >> ${Where2}/fsaverage_LR32k/seeds.txt
done


for i in `seq 1 180`; do
        $wb_command -metric-merge ${Where2}/fsaverage_LR32k/ROIs/left-roi-${i}.func.gii  -metric ${Where2}/fsaverage_LR32k/LEFT.func.gii -column ${i}
        surf2surf -i ${Where2}/fsaverage_LR32k/${SubID}.L.white_MSMAll.32k_fs_LR.surf.gii -o ${Where2}/fsaverage_LR32k/ROIs_gii/left-roi-${i}.gii --values=${Where2Tmp}/fsaverage_LR32k/ROIs/left-roi-${i}.func.gii
	echo ${Where2}/fsaverage_LR32k/ROIs_gii/left-roi-${i}.gii  >> ${Where2}/fsaverage_LR32k/seeds.txt
done

echo "DWI Network analysis..."
#================== DWI Network
probtrackx2 \
--samples=${Where2}/Diffusion.bedpostX/merged \
--mask=${Where2}/Diffusion.bedpostX/nodif_brain_mask \
--seed=${Where2}/fsaverage_LR32k/seeds.txt \
--loopcheck --forcedir --network --omatrix1 --nsamples=20 -V 1 --dir=${Where2}/DWINetwork

#FREE UP MEMORY
#rm -rf ${Where2Tmp}
