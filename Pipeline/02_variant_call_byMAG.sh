#!/usr/bin/bash -l
#SBATCH --job-name=variant_call_byMAG
#SBATCH --partition=epyc
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH -a 1-162
#SBATCH --time=02-00:00:00
#SBATCH --output=logs/variant_call_byMAG_%a.out
#SBATCH --error=logs/variant_call_byMAG_%a.err

module load bcftools
CPU=1
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


# === CONFIGURATION ===
CRAM_DIR=output/bam
DB=db/all_mags.fa
MAGLIST=MAGs.fofn
OUTDIR=output/vcf_gz
FOFN=$SCRATCH/MAGs.fofn
mkdir -p "$OUTDIR"

# === GET CURRENT SAMPLE ===
find ${CRAM_DIR} -name "*.cram" > $FOFN

# === GET CURRENT SAMPLE ===
cat $MAGLIST | sed -n ${N}p | while read -r MAGPATH
do
    MAGNAME=$(basename $MAGPATH .fa)
    grep "^>" $MAGPATH | perl -p -e "s/^>/${MAGNAME}./" > $SCRATCH/MAG_regions.txt

    echo "🔍 Calling SNPs for $MAGNAME"
    time bcftools mpileup -f "$DB" -Ob --threads $CPU -o $SCRATCH/$MAGNAME.bcf -b $FOFN -R $SCRATCH/MAG_regions.txt
    time bcftools call -vmO z -o "$OUTDIR/$MAGNAME.vcf.gz" --threads $CPU $SCRATCH/$MAGNAME.bcf --ploidy 1
    if [ -f $OUTDIR/$MAGNAME.vcf.gz ]; then
        echo "✅ Done: $OUTDIR/${MAGNAME}.vcf.gz"
    fi
done
