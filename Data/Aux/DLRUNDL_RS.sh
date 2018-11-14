#!/bin/bash
#$ -o /home/wmrnaq/DWI/logs/
#$ -e /home/wmrnaq/DWI/logs/
#$ -l h_rt=03:00:00
#$ -l h_vmem=5G
#$ -N MMP_DLRN_HCP100UR
#$ -r y
#$ -t 1-100

.  /etc/profile

cd /home/wmrnaq/DWI

module load fsl

SubID=$(sed "${SGE_TASK_ID}q;d" /home/wmrnaq/HCPMassDL/HCP_100UR.txt)
echo "Sub: ${SubID}"

AtlasDir=/home/wmrnaq/bin/Atlas/MMP
AtlasID=MMP
Where2Tmp=/scratch/wmrnaq/DWITmp/${SubID}
Where2=/storage/wmrnaq/DWIRS/${SubID}
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










