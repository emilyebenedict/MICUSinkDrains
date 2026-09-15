#!/bin/bash
#===============================================================================
# Name         : s01_fastqc.sh
# Description  : Runs basic QC on raw and trimmed illumina reads
# Usage        : sbatch s00_fastQC.sh
# Author       : Luke Diorio-Toth, ldiorio-toth@wustl.edu
# Version      : 1.4
# Created On   : 2019_01_08
# Modified On  : Mon Jun 27 13:06:20 CDT 2022
#===============================================================================
#
#Submission script for HTCF
#SBATCH --job-name=fastqc
#SBATCH --array=1-40%10
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --output=slurm_out/fastqc/z_fastqc_%a_%A.out
#SBATCH --error=slurm_out/fastqc/z_fastqc_%a_%A.out

# load latest version of fastqc on spack (fastqc@0.11.9)
eval $( spack load --sh /ldosddd )

basedir="$PWD"
rawin="/lts/gdlab/raw_data/2025/250331_MICUSink_EEB"
cleanin="${basedir}/d01_clean_shortreads"
rawout="${basedir}/d02_read_qc"
cleanout="${basedir}/d02_read_qc/clean_reads"
mkdir -p ${rawout}
mkdir -p ${cleanout}
export JAVA_ARGS="-Xmx8000M"
sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/micusink_r1_names.txt`
gtac_name=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/gtac_names.txt`
set -x

time fastqc ${rawin}/${gtac_name}_R1_001.fastq.gz \
            ${rawin}/${gtac_name}_R2_001.fastq.gz \
            -o ${rawout} \
            -t ${SLURM_CPUS_PER_TASK}

time fastqc ${cleanin}/${sample}_FW_clean.fastq.gz \
            ${cleanin}/${sample}_RV_clean.fastq.gz \
            ${cleanin}/${sample}_UP_clean.fastq.gz \
            -o ${cleanout} \
            -t ${SLURM_CPUS_PER_TASK}

RC=$?
set +x
if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error Occurred in ${sample}!"
  exit $RC
fi
