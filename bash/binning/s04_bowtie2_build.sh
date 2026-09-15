#!/bin/bash

#===============================================================================
# File Name    : s18_bowtie2_build.sh
# Description  : Indexes a reference genome for Burrows-Wheeler alignment
# Usage        : sbatch s18_bowtie2_build.sh
# Author       : Luke Diorio-Toth, ldiorio-toth@wustl.edu
# Version      : 1.1
# Created On   : Jul  9 2019
# Last Modified: 2023-03-09 by Emily Benedict ebenedict@wustl.edu
#===============================================================================

#SBATCH --time=1-00:00:00 # days-hh:mm:ss
#SBATCH --job-name=5bowtie2_build
#SBATCH --array=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --output=slurm_out/bowtie/z_build_%A.out
#SBATCH --error=slurm_out/bowtie/z_build_%A.out
#SBATCH --mail-user=ebenedict@wustl.edu
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL


eval $( spack load --sh bowtie2 )

basedir="$PWD"
indir="${basedir}/260421_instrain_smal"
outdir="${basedir}/d19_bowtie_scaffolds_smal5"

mkdir -p ${outdir}

set -x
bowtie2-build --threads ${SLURM_CPUS_PER_TASK}  ${indir}/all_smal_st5.fasta ${outdir}/
RC=$?
set +x

if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error occurred!"
  exit $RC
fi
