#!/bin/bash
#$ -o /home/wmrnaq/DWI/logs/
#$ -e /home/wmrnaq/DWI/logs/
#$ -l h_rt=02:00:00
#$ -l h_vmem=10G
#$ -N HCP100UR_DLDL
#$ -r y
#$ -t 1

.  /etc/profile

cd /home/wmrnaq/DWI

module load fsl

SubID=$(sed "${SGE_TASK_ID}q;d" /home/wmrnaq/HCPMassDL/HCP_100UR.txt)
echo "Sub: ${SubID}"

AtlasDir=/home/wmrnaq/bin/Atlas/MMP
AtlasID=MMP
Where2Tmp=/scratch/wmrnaq/DWITmp/${SubID}
Where2=/storage/wmrnaq/DWIRS
wb_command=/storage/essicd/workbench/bin_rh_linux64/wb_command

DirID=LR
RunID=1

rm -rf ${Where2Tmp}

mkdir -p ${Where2Tmp}/RS
mkdir -p ${Where2Tmp}/fsaverage_LR32k
mkdir -p ${Where2Tmp}/fsaverage_LR32k/ROIs_gii
mkdir -p ${Where2Tmp}/fsaverage_LR32k/ROIs
mkdir -p ${Where2Tmp}/Diffusion.bedpostX
mkdir -p ${Where2}

#_________________________________________________________________________________________________
#___________________________________Download form S3 Bucket_______________________________________
#_________________________________________________________________________________________________

AWS_ACCESS_KEY="XX"
AWS_SECRET_KEY="XX"

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




#================= Resting-state download and parcellated

s3get hcp-openaccess-temp/HCP_1200/${SubID}/MNINonLinear/Results/rfMRI_REST${RunID}_${DirID}/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii \
${Where2Tmp}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii

echo "RS Downloaded into: ${Where2Tmp}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii"

$wb_command -cifti-parcellate ${Where2Tmp}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii \
${AtlasDir}/Q1-Q6_RelatedParcellation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii COLUMN \
${Where2}/RS${RunID}_${SubID}_${DirID}_${AtlasID}.ptseries.nii

echo "Time series extracted into: ${Where2}/RS${RunID}_${SubID}_${DirID}_${AtlasID}.ptseries.nii"

#FREE UP MEMORY
rm -rf ${Where2Tmp}/RS/rfMRI_REST${RunID}_${DirID}_Atlas_MSMAll_hp2000_clean.dtseries.nii

#================= DWI Download

while read readfsaveragefilename
do
	s3get hcp-openaccess-temp/HCP_1200/${SubID}/T1w/fsaverage_LR32k/${SubID}${readfsaveragefilename} ${Where2Tmp}/fsaverage_LR32k/${SubID}${readfsaveragefilename}
done<Aux/readfsaveragefiles.txt

while read readbedpostXfilename; do
	s3get hcp-openaccess-temp/HCP_1200/${SubID}/T1w/Diffusion.bedpostX/${readbedpostXfilename} ${Where2Tmp}/Diffusion.bedpostX/${readbedpostXfilename}
done<Aux/readbedpostXfiles.txt

echo "DWI fsaverage and bedpostX has been downloaded..."

#================ DWI Analysis

$wb_command -cifti-separate ${AtlasDir}/Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_LEFT  ${Where2Tmp}/fsaverage_LR32k/LEFT.label.gii
$wb_command -cifti-separate ${AtlasDir}/Q1-Q6_RelatedParcellation210.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_RIGHT ${Where2Tmp}/fsaverage_LR32k/RIGHT.label.gii

$wb_command -gifti-all-labels-to-rois ${Where2Tmp}/fsaverage_LR32k/LEFT.label.gii 1  ${Where2Tmp}/fsaverage_LR32k/LEFT.func.gii
$wb_command -gifti-all-labels-to-rois ${Where2Tmp}/fsaverage_LR32k/RIGHT.label.gii 1 ${Where2Tmp}/fsaverage_LR32k/RIGHT.func.gii

for i in `seq 1 7`; do
        $wb_command -metric-merge ${Where2Tmp}/fsaverage_LR32k/ROIs/right-roi-${i}.func.gii -metric ${Where2Tmp}/fsaverage_LR32k/RIGHT.func.gii -column ${i}
        surf2surf -i ${Where2Tmp}/fsaverage_LR32k/${SubID}.R.white_MSMAll.32k_fs_LR.surf.gii -o ${Where2Tmp}/fsaverage_LR32k/ROIs_gii/right-roi-${i}.gii --values=${Where2Tmp}/fsaverage_LR32k/ROIs/right-roi-${i}.func.gii
        echo ${Where2Tmp}/fsaverage_LR32k/ROIs_gii/right-roi-${i}.gii >> ${Where2Tmp}/fsaverage_LR32k/seeds.txt
done


for i in `seq 1 7`; do
        $wb_command -metric-merge ${Where2Tmp}/fsaverage_LR32k/ROIs/left-roi-${i}.func.gii  -metric ${Where2Tmp}/fsaverage_LR32k/LEFT.func.gii -column ${i}
        surf2surf -i ${Where2Tmp}/fsaverage_LR32k/${SubID}.L.white_MSMAll.32k_fs_LR.surf.gii -o ${Where2Tmp}/fsaverage_LR32k/ROIs_gii/left-roi-${i}.gii --values=${Where2Tmp}/fsaverage_LR32k/ROIs/left-roi-${i}.func.gii
	echo ${Where2Tmp}/fsaverage_LR32k/ROIs_gii/left-roi-${i}.gii  >> ${Where2Tmp}/fsaverage_LR32k/seeds.txt
done


#================== DWI Network
probtrackx2 \
--samples=${Where2Tmp}/Diffusion.bedpostX/merged \
--mask=${Where2Tmp}/Diffusion.bedpostX/nodif_brain_mask \
--seed=${Where2Tmp}/fsaverage_LR32k/seeds.txt \
--loopcheck --forcedir --network --omatrix1 --nsamples=20 -V 1 --dir=${Where2}/DWINetwork

#FREE UP MEMORY
rm -rf ${Where2Tmp}/fsaverage_LR32k/
rm -rf ${Where2Tmp}/Diffusion.bedpostX/
