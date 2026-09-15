#!/bin/bash

#===============================================================================
# File Name    : s05_quast.sh
# Description  : This script will use quast to calculate qc stats on assemblies
# Usage        : sbatch s05_quast.sh
# Author       : Luke Diorio-Toth, ldiorio-toth@wustl.edu
# Version      : 1.2
# Created On   : Tue Feb  4 20:05:08 CST 2020
# Last Modified: Thu Jul 14 14:36:01 CDT 2022
#===============================================================================

#SBATCH --job-name=quast
#SBATCH --array=1-140%20
#SBATCH --time=1-00:00:00 # days-hh:mm:ss
#SBATCH --output=slurm_out/quast/z_quast_%a_%A.out
#SBATCH --error=slurm_out/quast/z_quast_%a_%A.out

eval $( spack load --sh py-quast@5.2.0 )

#store the base directory
basedir="$PWD"
indir="${basedir}/d03_spades"
outdir="${basedir}/d04_assembly_qc/quast"

#make the output directory
mkdir -p ${outdir}

#store sample name for this array task
sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/seq_list.txt`

mkdir -p ${outdir}/${sample}

set -x
time quast.py ${indir}/${sample}/scaffolds.fasta -l ${sample} -o ${outdir}/${sample}
RC=$?
set +x

if [ $RC -eq 0 ]
then
    echo "Job completed successfully"
else
    echo "Error Occurred in ${sample}!"
    exit $RC
fi
