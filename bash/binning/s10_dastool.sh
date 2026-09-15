#!/bin/bash
#===============================================================================
#
# File Name    : s12_dastool.sh
# Description  : Run dasTool
# Usage        : sbatch s12_dastool.sh
# Author       : Robert Thaenert
# Version      : 1.0
# Created On   : 5/10/2022
#===============================================================================
#
#Submission script for HTCF
#SBATCH --job-name=dasTool
#SBATCH --array=1-187%20
#SBATCH --cpus-per-task=8
#SBATCH --mem=4G
#SBATCH --output=slurm_out/dasTool/x_dasTool_%a.out
#SBATCH --error=slurm_out/dasTool/y_dasTool_%a.err
#SBATCH --mail-user=ebenedict@wustl.edu
#SBATCH --mail-type=END

eval $( spack load --sh miniconda3@4.10.3 )

CONDA_BASE=$(conda info --base)

source $CONDA_BASE/etc/profile.d/conda.sh

conda activate /ref/gdlab/software/envs/Das_Tool

#basedir if you want
basedir="$PWD"

#set output directory
outdir="${basedir}/d07_DasTool"

# Read in the slurm array task
sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/samplelist.txt`

#make output directory
mkdir -p ${outdir}
mkdir -p ${outdir}/${sample}

set -x

DAS_Tool -i ${basedir}/d06_prep_dastool/concoct/${sample}_bins/${sample}_step5.txt,${basedir}/d06_prep_dastool/maxbin2/${sample}/${sample}_step5.txt, -l concoct,maxbin -c ${basedir}/d03_spades/${sample}/scaffolds.fasta -o ${outdir}/${sample}/${sample} --search_eng$

RC=$?
set +x

if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error Occurred in ${sample}!"
  exit $RC
fi
