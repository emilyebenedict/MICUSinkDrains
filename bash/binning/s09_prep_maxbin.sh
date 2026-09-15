#!/bin/bash
#===============================================================================
#
# File Name    : s11_prep_maxbin.sh
# Description  : Prep the maxbin2 output for dasTool
# Usage        : sbatch s11_prep_maxbin.sh
# Author       : Robert Thaenert
# Version      : 1.0
# Created On   : 5/10/2022
#===============================================================================
#
#Submission script for HTCF
#SBATCH --job-name=dTprep_maxbin
#SBATCH --array=1-187%20
#SBATCH --mem=1G
#SBATCH --output=slurm_out/maxbin/x_dTprepMaxbin_%a.out
#SBATCH --error=slurm_out/maxbin/y_dTprepMaxbin_%a.err

#basedir if you want
basedir="$PWD"

#set output directory
outdir="${basedir}/d06_prep_dastool/maxbin2"

# Read in the slurm array task
sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/samplelist.txt`

set -x

grep '>' ${outdir}/${sample}/${sample}*fasta > ${outdir}/${sample}/${sample}_step1.txt

sed 's/:>/\t/g' ${outdir}/${sample}/${sample}_step1.txt > ${outdir}/${sample}/${sample}_step2.txt
sed 's/.fasta//g' ${outdir}/${sample}/${sample}_step2.txt > ${outdir}/${sample}/${sample}_step3.txt
sed 's,.*/,,g' ${outdir}/${sample}/${sample}_step3.txt > ${outdir}/${sample}/${sample}_step4.txt

awk -F'\t' -v OFS='\t' '{print $2,$1}' ${outdir}/${sample}/${sample}_step4.txt > ${outdir}/${sample}/${sample}_step5.txt

rm ${outdir}/${sample}/${sample}_step1.txt
rm ${outdir}/${sample}/${sample}_step2.txt
rm ${outdir}/${sample}/${sample}_step3.txt
rm ${outdir}/${sample}/${sample}_step4.txt

RC=$?
set +x

if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error Occurred in ${sample}!"
  exit $RC
fi
