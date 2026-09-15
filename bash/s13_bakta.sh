#!/bin/bash
#===============================================================================
# File Name    : bakta.sh
# Description  : Annotation of assembled bacterial genomes, MAGs, and plasmids
# Usage        : sbatch bakta.sh
# Author       : Luke Diorio-Toth, ldiorio-toth@wustl.edu
# Version      : 1.0
# Modified     : Fri Oct 14 08:14:59 CDT 2022
# Created      : Fri Oct 14 08:14:59 CDT 2022
#===============================================================================
#Submission script for HTCF
#SBATCH --time=1-0:00:00 # days-hh:mm:ss
#SBATCH --job-name=si_bakta
#SBATCH --array=1-112%50
#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --output=slurm_out/bakta/y_bakta_%A_%a.out
#SBATCH --error=slurm_out/bakta/z_bakta_%A_%a.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ebenedict@wustl.edu


#-134%30
eval $( spack load --sh py-bakta@1.5.1)
eval $( spack load --sh trnascan-se)

basedir="$PWD"
indir="${basedir}/d03_impact_spades/all_scaffolds"
outdir="${basedir}/d26_impact_bakta/smal"
dbdir="/ref/gdlab/data/bakta_db/db-v4.0/db"

mkdir -p ${outdir}
sample=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/impact_smal_samples.txt`

set -x
time bakta \
  --db ${dbdir} \
  --min-contig-length 200 \
  --prefix ${sample} \
  --output ${outdir}/${sample} \
  --threads ${SLURM_CPUS_PER_TASK} \
  --output ${outdir}/${sample} \
  ${indir}/${sample}_scaffolds.*

RC=$?
set +x


# Output if job was successful
if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error occurred!"
  exit $RC
