#!/bin/bash

#===============================================================================
# Name         : s00_trimmomatic.sh
# Description  : Trims adapter sequences and low-quality bases from illumina
#              : reads, producing a "cleaned" set of paried reads
# Usage        : sbatch s00_trimmomatic.sh
# Author       : Luke Diorio-Toth, ldiorio-toth@wustl.edu
# Version      : 1.3
# Created On   : 2019_01_08
# Modified On  : 2023-06-29 by Emily Benedict, ebenedict@wustl.edu
#===============================================================================

#SBATCH --job-name=trimmomatic
#SBATCH --array=1-40%10
#SBATCH --cpus-per-task=4
#SBATCH --mem=1G
#SBATCH --output=slurm_out/trimmomatic/z_trim_%a_%A.out
#SBATCH --error=slurm_out/trimmomatic/z_trim_%a_%A.out
#SBATCH --mail-user=ebenedict@wustl.edu
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval $( spack load --sh trimmomatic )

basedir="$PWD"
indir="/lts/gdlab/raw_data/2025/250331_MICUSink_EEB"
outdir="${basedir}/d01_clean_shortreads"

mkdir -p ${outdir}

# need to declare memory explicitely
export JAVA_ARGS="-Xmx1000M"

# choose which adapters to use:
# NexteraPE-PE.fa,
# TruSeq2-PE.fa, TruSeq2-SE.fa,
# TruSeq3-PE-2.fa, TruSeq3-PE.fa, TruSeq3-SE.fa
adapt="/ref/gdlab/data/trimmomatic_adapters/0.39/NexteraPE-PE.fa"

# samplelist.txt contains a list of all file names
sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/micusink_r1_names.txt`
gtac_name=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/gtac_names.txt`

# R1 = fwd and R2 = rev
# P = paired, UP = unpaired
set -x
time trimmomatic \
    PE \
    -phred33 \
    -trimlog \
    ${outdir}/Paired_${sample}_trimlog.txt \
    ${indir}/${gtac_name}_R1_001.fastq.gz \
    ${indir}/${gtac_name}_R2_001.fastq.gz \
    ${outdir}/${sample}_FW_clean.fastq.gz \
    ${outdir}/${sample}_FW_clean_UP.fastq.gz \
    ${outdir}/${sample}_RV_clean.fastq.gz \
    ${outdir}/${sample}_RV_clean_UP.fastq.gz \
    ILLUMINACLIP:${adapt}:2:30:10:1:true \
    SLIDINGWINDOW:4:20 \
    LEADING:10 \
    TRAILING:10 \
    MINLEN:60
RC=$?
set +x

# combine unpaired reads into a single fastq and delete redundant files
cat ${outdir}/${sample}_FW_clean_UP.fastq.gz \
    ${outdir}/${sample}_RV_clean_UP.fastq.gz \
    > ${outdir}/${sample}_UP_clean.fastq.gz
rm ${outdir}/${sample}_FW_clean_UP.fastq.gz
rm ${outdir}/${sample}_RV_clean_UP.fastq.gz 

if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error occurred in ${sample}!"
  exit $RC
fi
