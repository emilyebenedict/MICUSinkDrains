#!/bin/bash
#SBATCH --job-name=gtdbtk_classify_drep
#SBATCH --cpus-per-task=8
#SBATCH --mem=200G
#SBATCH --output=slurm_out/gtdbtk/classify_%A.out
#SBATCH --error=slurm_out/gtdbtk/classify_%A.err
#SBATCH --mail-user=ai.z@wustl.edu
#SBATCH --mail-type=END,FAIL

set -euo pipefail
set -x
export PATH=/home/ai.z/miniconda3/bin:$PATH
source /home/ai.z/miniconda3/etc/profile.d/conda.sh

# --- GTDB-Tk database ---
export GTDBTK_DATA_PATH="/ref/gdlab/data/gtdbtk_db/release220/"

# --- Input: dRep representatives ---
GENOME_DIR="/scratch/gdlab/ebenedict/sinkHGT/micusink_isolates/allrounds/d03_impact_spades/all_scaffolds"

# --- Output ---
OUT_DIR="/scratch/gdlab/ebenedict/sinkHGT/micusink_isolates/allrounds/d25_impact_gtdbtk"
mkdir -p "${OUT_DIR}"

# --- Run using your labmate's env ---
conda run -n gtdbtk_env gtdbtk classify_wf \
  --genome_dir "${GENOME_DIR}" \
  -x fasta \
  --out_dir "${OUT_DIR}" \
  --cpus "${SLURM_CPUS_PER_TASK}" \
  --pplacer_cpus "${SLURM_CPUS_PER_TASK}" \
  --mash_db /ref/gdlab/data/gtdbtk_db/release220/
