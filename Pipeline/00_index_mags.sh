#!/bin/bash
#SBATCH --job-name=index_mags
#SBATCH --partition=short
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G
#SBATCH --output=logs/index_mags_%j.out
#SBATCH --error=logs/index_mags_%j.err

module load bwa-mem2

MAG_LIST="/bigdata/stajichlab/shared/projects/Herptile/Metagenome/Ls_MAG_C/woodfrog_snp_pipeline/MAGs.fofn"
DB=db/all_mags.fa

mkdir -p logs db

cat $MAG_LIST | while read -r mag
do
        n=$(basename $mag .fa)
        perl -p -e "s/>/>$n./" $mag
done > $DB

bwa-mem2 index $DB
