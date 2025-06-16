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

Reads are aligned to each MAG using BWA-MEM2. 

- Script:   `01_align_reads_array.sh`

- Outputs: Sorted and indexed BAM files for each sample-MAG pair

- Output location:
`/bigdata/stajichlab/shared/projects/Herptile/Metagenome/Ls_MAG_C/woodfrog_snp_pipeline/data/output/bam/`

### 3. SNP Calling

SNPs are called per sample-MAG pair using `bcftools mpileup` and `bcftools call`.

- Script: `02_call_snps.sh`
- Output: Raw VCF files for each sample-MAG pair
- Output location: `.../woodfrog_snp_pipeline/data/output/vcf/`

### 4. SNP Filtering and Allele Frequency Estimation

- SNPs are filtered based on minimum depth, quality, or presence across samples.
- Allele frequencies are computed using custom scripts or tools like `vcftools` or `bcftools query`.

- Output: Filtered SNP matrix and major allele frequency table
- Output location: `.../woodfrog_snp_pipeline/data/output/frequency_tables/`


### 5. Association Analysis

- We use linear regression models to identify SNPs associated with treatment groups.
- Scripts written in Python or R ingest frequency matrices and metadata to test for associations.

- Script: `03_snp_association_analysis.py`
- Output: Association statistics per SNP (e.g., p-values, beta coefficients)
- Output location: `.../woodfrog_snp_pipeline/results/association_results.csv`

### 6. Visualization

- Visualizations include Manhattan plots and SNP heatmaps to summarize associations.
- R or Python plotting scripts take in association data and SNP annotations.

- Scripts: `04_plot_manhattan.R`, `05_plot_heatmap.py`
- Output: PDF and PNG visualizations
- Location: `.../woodfrog_snp_pipeline/results/figures/`

