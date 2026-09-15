#!/bin/bash
#===============================================================================
# Name         : s07_concoct_while.sh
# Usage        : sbatch s07_concoct_while.sh
# Created On   : 2023-09-10
# Author       : Jian Ryou
#===============================================================================
#
#Submission script for HTCF
#SBATCH --time=6-23:00:00 # days-hh:mm:ss
#SBATCH --job-name=concoct
#SBATCH --mail-type=END
#SBATCH --mail-user=ebenedict@wustl.edu
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --output=slurm_out/concoct/z_concoct_%a.out
#SBATCH --error=slurm_out/concoct/z_concoct_%a.err

# Set up conda environment
# load samtools
eval $( spack load --sh samtools@1.7 )
# load miniconda
eval $( spack load --sh /buvzc6u )

CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate /ref/gdlab/software/envs/genome_binning

#set up directories
basedir="$PWD"
assembly_in="${basedir}/d03_spades"
bam_in="${basedir}/d05_bowtie_mapped_reads"
outdir="${basedir}/d06_prep_dastool/concoct"

mkdir -p ${outdir}


#barcodes=`sed -n ${SLURM_ARRAY_TASK_ID}p ${basedir}/bwa_completed_samples.txt`
barcodes=${basedir}/samplelist.txt

# Read the barcodes list file line by line and run concoct for each barcode
while IFS= read -r barcode; do
        # Determine output directory name based on barcode
        bindir="${outdir}/${barcode}_bins"

        # Create output directory
        mkdir -p "${bindir}"

#       samtools index ${bam_in}/${barcode}_mappedreads_sorted.bam

        #### Run concoct #####
        # You will need original contigs assembled into a contigs.fa and mapped reads from filtlong mapped to the assembly. These are$

        # First cut contigs into smaller parts
        cut_up_fasta.py ${assembly_in}/${barcode}/scaffolds.fasta -c 10000 -o 0 --merge_last -b ${outdir}/${barcode}_contigs_10K.bed $

        # Generate table with coverage depth information per sample and subcontig using indexed bam files 
        concoct_coverage_table.py ${outdir}/${barcode}_contigs_10K.bed ${bam_in}/${barcode}_mappedreads_sorted.bam > ${outdir}/${barc$

        # Run concoct
        concoct --composition_file ${outdir}/${barcode}_contigs_10K.fa -t 8 --coverage_file ${outdir}/${barcode}_coverage_table.tsv -$

        # Merge subcontig clustering into original contig clustering 
        merge_cutup_clustering.py ${outdir}/${barcode}_clustering_gt1000.csv > ${outdir}/${barcode}_clustering_merged.csv

        # Extract bins as individual FASTA
        extract_fasta_bins.py ${assembly_in}/${barcode}/scaffolds.fasta ${outdir}/${barcode}_clustering_merged.csv --output_path ${bi$
done < ${barcodes}
