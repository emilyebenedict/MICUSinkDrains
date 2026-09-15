#!/bin/bash
#===============================================================================
# File Name    : mlst.sh
# Description  : Scan many genomes against PubMLST typing schemes
# Usage        : sbatch mlst.sh
# Author       : Luke Diorio-Toth
# Version      : 1.1
# Created On   : Wed Oct 12 19:29:07 CDT 2022
# Last Modified: Wed Oct 12 19:29:07 CDT 2022
#===============================================================================
#
#Submission script for HTCF
#SBATCH --time=1-0:00:00 # days-hh:mm:ss
#SBATCH --job-name=mlst
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --output=slurm_out/mlst/z_mlst_%A.out
#SBATCH --error=slurm_out/mlst/z_mlst_%A.out

#eval $( spack load --sh miniconda3@4.10.3 )

#CONDA_BASE=$(conda info --base)
#source $CONDA_BASE/etc/profile.d/conda.sh

#conda activate /ref/gdlab/software/envs/mlst

eval $( spack load --sh mlst )

basedir="$PWD"
indir="${basedir}/d03_impact_spades/all_scaffolds"
outdir="${basedir}/d31_impact_updated_mlst_260713"

mkdir -p ${outdir}

sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/all_hqgenome_names.txt`

set -x
time mlst --csv \
  --blastdb /ref/gdlab/data/mlst_db/2026-06-08/blast/mlst.fa \
  --datadir /ref/gdlab/data/mlst_db/2026-06-08/pubmlst \
  --threads ${SLURM_CPUS_PER_TASK} \
  ${indir}/*.fasta >> ${outdir}/260713_impact_updated_mlst.csv
RC=$?
set +x

# Output if job was successful
if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error occurred!"
  exit $RC
fi
