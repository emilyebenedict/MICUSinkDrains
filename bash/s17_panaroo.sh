#!/bin/bash

#===============================================================================
# File Name    : panaroo_bakta.sh
# Description  : Runs the panaroo pangenome tool on genomes annotated by bakta
# Usage        : sbatch panaroo_bakta.sh
# Author       : Luke Diorio-Toth
# Version      : 1.4
# Created On   : Thu Aug 15 14:44:06 CDT 2019
# Last Modified: Tue Oct 18 15:32:58 CDT 2022
#===============================================================================

#SBATCH --job-name=p_panaroo
#SBATCH --cpus-per-task=12
#SBATCH --mem=20G
#SBATCH --output=slurm_out/panaroo/x_panaroo_%A.out
#SBATCH --error=slurm_out/panaroo/y_panaroo_%A.err
#SBATCH --mail-type=END
#SBATCH --mail-user=ebenedict@wustl.edu

eval $( spack load --sh py-panaroo@1.2.10 )

basedir="$PWD"
indir="${basedir}/d26_impact_bakta/psar/gffs"
outdir="${basedir}/d28_impact_allgenomes_panaroo_psar"

mkdir -p ${outdir}

set -x
time panaroo \
        -i ${indir}/*.gff3 \
        -o ${outdir} \
        --clean-mode strict \
        --core_threshold 0.95 \
        -a core \
        --aligner mafft \
        --remove-invalid-gene \
        -t ${SLURM_CPUS_PER_TASK}

RC=$?

set +x
if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error occurred!"
  exit $RC
fi
