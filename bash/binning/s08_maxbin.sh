#!/bin/bash
#===============================================================================
#
# File Name    : s09_maxbin.sh
# Description  : Run MaxBin on metagenomic assemblies.
# Usage        : sbatch s09_maxbin.sh
# Author       : Robert Thaenert
# Version      : 1.0
# Created On   : 05/03/2022
# Last Modified: 05/03/2022
#===============================================================================
#
#Submission script for HTCF
#SBATCH --job-name=maxbin
#SBATCH --cpus-per-task=16
#SBATCH --array=1-20
#SBATCH --mem=32G
#SBATCH --output=slurm_out/maxbin/x_maxbin2_metaspades2redo_%a.out
#SBATCH --error=slurm_out/maxbin/y_maxbin2_metaspades_2redo_%a.err


eval $( spack load --sh miniconda3@4.10.3 )
#eval $( spack load --sh hmmer@3.3.2 )
#eval $( spack load --sh bowtie2@2.4.2 )
#eval $( spack load --sh fraggenescan@1.31 )
CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate /home/gmark/conda_env/maxbin

#basedir if you want
basedir="$PWD"

#set output directory
indir="${basedir}/d03_spades"
indir2="${basedir}/d01_clean_shortreads"
outdir="${basedir}/d06_prep_dastool/maxbin2d"

# Read in the slurm array task
sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/samplelist.txt`

#make output directory
mkdir -p ${outdir}
mkdir -p ${outdir}/${sample}

set -x

run_MaxBin.pl -min_contig_length 1500 -thread 8 -out ${outdir}/${sample}/${sample} -contig ${indir}/${sample}/scaffolds.fasta -reads ${indir2}/${sample}_FW_clean.fastq.gz -reads2 ${indir2}/${sample}_RV_clea$

RC=$?
set +x

if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error Occurred in ${sample}!"
  exit $RC
fi
