# **Wood Frog Gut Metagenome SNP Analysis Pipeline**

This repository documents the pipeline for calling intraspecies SNPs in metagenome-assembled genomes (MAGs) from Lithobates sylvaticus (wood frog) fecal microbiomes. Metagenomic reads from multiple samples are aligned to a curated, non-redundant set of MAGs to detect single-nucleotide polymorphisms (SNPs) within microbial populations. This reference-based SNP calling approach enables investigation of how microbial strains vary across samples, particularly in response to Basidiobolus treatment, revealing fine-scale genetic variation within the same species across experimental groups.

-------------------------------------------------------

## Pipeline Overview

### 1. Sample Preparation

We use a manually curated list of high-quality, dereplicated MAGs and a metadata file linking each sample ID to its paired-end FASTQ files.
- MAGs are stored in:
`/bigdata/stajichlab/shared/projects/Herptile/Metagenome/Ls_MAG_C/drep/dRep95/dereplicated_genomes/`

- Sample read paths (R1/R2) are stored in:
`woodfrog_samples.csv` with the format:
`SAMPLE_ID,FASTQ_PATH_WITH_R?`

### 2. Read Alignment

Reads are aligned to each MAG using BWA-MEM2. This step is parallelized via SLURM array jobs for performance.

- Script:   `01_align_reads_array.sh`

- Outputs: Sorted and indexed BAM files for each sample-MAG pair

- Output location:
`/bigdata/stajichlab/shared/projects/Herptile/Metagenome/Ls_MAG_C/woodfrog_snp_pipeline/data/output/bam/`

