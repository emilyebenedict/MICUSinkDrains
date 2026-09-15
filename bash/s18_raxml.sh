#!/bin/bash

#===============================================================================
# Name         : raxml.sh
# Description  : Infers a maximum-likelihood phylogenetic tree
#                from alignments of nucleotide or protein sequences.
# Usage        : sbatch raxml.sh
# Author       : Luke Diorio-Toth, ldiorio-toth@wustl.edu
# Version      : 2.1
# Created On   : Tue Aug 20 15:51:17 CDT 2019
# Modified On  : Wed Oct 19 14:53:39 CDT 2022
#===============================================================================

#SBATCH --job-name=p_raxml
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G
#SBATCH --output=slurm_out/raxml/z_raxml_%A.out
#SBATCH --error=slurm_out/raxml/z_raxml_%A.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ebenedict@wustl.edu

eval $( spack load --sh raxml+pthreads )

basedir="$PWD"
indir="${basedir}/d28_impact_allgenomes_panaroo_psar"
outdir="${indir}/d14_raxml"

mkdir -p ${outdir}

set -x
time raxmlHPC-PTHREADS \
    -s ${indir}/core_gene_alignment.aln \
    -w ${outdir} \
    -n raxml_core_genome_tree \
    -m GTRGAMMA \
    -f a \
    -T ${SLURM_CPUS_PER_TASK} \
    -N 100 \
    -p 12345 \
    -x 54321
RC=$?
set +x

if [ $RC -eq 0 ]
then
  echo "Job completed successfully"
else
  echo "Error occurred!"
  exit $RC
fi
