#!/bin/bash
#===============================================================================
# File Name    : s20_bowtie_map.sh
# Description  : Maps reads from each sample against the indexed db
#                and produces a sorted .bam file
# Usage        : sbatch s20_bowtie_map.sh
# Author       : Luke Diorio-Toth
# Version      : 1.1
# Created On   : Wed Jan 12 13:33:17 CST 2022
# Last Modified: 2023-03-09 by Emily Benedict, ebenedict@wustl.edu
#===============================================================================
#SBATCH --job-name=sbowtie_map
#SBATCH --array=1-187%50
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=slurm_out/bowtie/z_bowtie_map_%a_%A.out
#SBATCH --error=slurm_out/bowtie/z_bowtie_map_%a_%A.out
#SBATCH --mail-user=ebenedict@wustl.edu
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

eval $( spack load --sh bowtie2 )
eval $( spack load --sh samtools@1.7 )

# the /6p5wlkk is because there are multiple copies of samtools and this selects one to load

basedir="$PWD"
indir="${basedir}/d19_bowtie_scaffolds_smal5"
readsdir="/lts/gdlab/users/current/ebenedict/sinkHGT_wip/260216_scratch/directSRS/all_rounds/d01_clean_shortreads"
outdir="${basedir}/d19_bowtie_mapped_reads_smal5"

sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/platesweep_samples.txt`

mkdir -p ${outdir}

set -x
time bowtie2 -p ${SLURM_CPUS_PER_TASK} \
    -x ${indir}/smal5 \
    -S ${outdir}/${sample}_mappedreads.sam \
    -1 ${readsdir}/${sample}_FW_clean.fastq.gz \
    -2 ${readsdir}/${sample}_RV_clean.fastq.gz \

time samtools view -bS ${outdir}/${sample}_mappedreads.sam \
        > ${outdir}/${sample}_mappedreads.bam
time samtools sort ${outdir}/${sample}_mappedreads.bam \
        -o ${outdir}/${sample}_mappedreads_sorted.bam
time samtools index ${outdir}/${sample}_mappedreads_sorted.bam > ${outdir}/${sample}_mappedreads_sorted.bam.bai


# You only need the sorted .bam file, so I 
# delete the sam and unsorted bam to save disk space
#rm ${outdir}/${sample}_mappedreads.sam
#rm ${outdir}/${sample}_mappedreads.bam

RC=$?
set +x

if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error occurred in ${sample}!"
  exit $RC
fi
