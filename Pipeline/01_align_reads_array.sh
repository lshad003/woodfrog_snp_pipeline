#!/bin/bash -l
#SBATCH --job-name=align_reads_array
#SBATCH --partition=epyc
#SBATCH --cpus-per-task=48
#SBATCH --mem=48G
#SBATCH --time=04-00:00:00
#SBATCH --array=1-40
#SBATCH --output=logs/align_reads_%A_%a.out
#SBATCH --error=logs/align_reads_%A_%a.err

CPU=4
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
module load bwa-mem2
module load samtools

# === CONFIGURATION ===
SAMPLE_FILE=sample_subset_with_paths.tsv
MAG_LIST=MAGs.fofn
OUTDIR=output/bam
DB=db/all_mags.fa
if [[ ! -f $DB  || ! -f $DB.ann ]]; then
        echo "Have not built or indexed the DB:$DB for bwa-mem2 run"
        exit
fi
mkdir -p "$OUTDIR"

# === GET CURRENT SAMPLE ===
tail -n +2 $SAMPLE_FILE | sed -n ${N}p | while read -r SAMPLE_ID FASTQ_GLOB
do
        R1_PATH="${FASTQ_GLOB/\?/1}"
        R2_PATH="${FASTQ_GLOB/\?/2}"

        echo "[Task $SLURM_ARRAY_TASK_ID] Aligning $SAMPLE_ID"
        echo "R1: $R1_PATH"
        echo "R2: $R2_PATH"

        # CRAM format will save space
        BAM=$OUTDIR/${SAMPLE_ID}.cram

        # Skip if already aligned
        if [[ -f "$BAM" ]]; then
                echo "→ Skipping $BAM (already exists)"
                continue
        fi
        TEMP=$SCRATCH/$SAMPLE_ID
        time bwa-mem2 mem -t $CPU "$DB" "$R1_PATH" "$R2_PATH" | \
        samtools sort -@ 4 --reference $DB -O CRAM -T $TEMP -o "$BAM" -
        samtools index "$BAM"
done

echo "[Task $SLURM_ARRAY_TASK_ID] Done for $SAMPLE_ID"

