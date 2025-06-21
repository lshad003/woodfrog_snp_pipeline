# **Wood Frog Gut Metagenome SNP Analysis Pipeline**

This repository documents the pipeline for calling intraspecies SNPs in metagenome-assembled genomes (MAGs) from Lithobates sylvaticus (wood frog) fecal microbiomes. Metagenomic reads from multiple samples are aligned to a curated, non-redundant set of MAGs to detect single-nucleotide polymorphisms (SNPs) within microbial populations. This reference-based SNP calling approach enables investigation of how microbial strains vary across samples, particularly in response to Basidiobolus treatment, revealing fine-scale genetic variation within the same species across experimental groups.

-------------------------------------------------------

## Pipeline Overview

### 1. Sample Preparation
This pipeline begins with a curated set of dereplicated metagenome-assembled genomes (MAGs) derived from *Lithobates sylvaticus* fecal samples.

#### a. MAG Reference Construction

We compiled 162 dereplicated MAGs from: `/bigdata/stajichlab/shared/projects/Herptile/Metagenome/Ls_MAG_C/drep/dRep95/dereplicated_genomes/`
These MAGs were listed in a file: `MAGs.fofn` 
Each line in `MAGs.fofn` contains the full path to a single MAG `.fa` file.

These MAGs were concatenated into a single reference FASTA file:

`db/all_mags.fa`


This reference was used for building the BWA index and mapping reads for downstream SNP discovery.

#### b. Sample Metadata and Read Paths

Read file paths and sample IDs are defined in:`woodfrog_samples.csv`


The file has two columns:

- `SAMPLE_ID`: Unique sample identifier (e.g., UHM102.10840)
- `FASTQ_PATH_WITH_R?`: Base path to raw reads, ending in `_R1.fastq.gz` and `_R2.fastq.gz` (for paired-end sequencing)

#### c. Outputs from This Step

- `db/all_mags.fa`: Combined reference FASTA of all MAGs
- `db/all_mags.fa.*`: BWA index files generated from `all_mags.fa`




### 2. Mapping Reads to MAG Reference

Metagenomic reads were mapped to a concatenated reference file composed of all dereplicated MAGs. This step used BWA-MEM2 for efficient alignment, and outputs were stored in CRAM format to reduce disk usage.

#### a. Reference Construction and Indexing

The MAG reference was constructed by renaming all contigs in the MAGs with their MAG ID prefix using `perl`, then concatenating into a single FASTA:

``bash
MAG_LIST="MAGs.fofn"
DB="db/all_mags.fa"
mkdir -p db logs

cat $MAG_LIST | while read -r mag; do
    n=$(basename $mag .fa)
    perl -p -e "s/>/>$n./" $mag
done > $DB``

The reference was indexed with BWA-MEM2:

`bwa-mem2` index $DB

This ensures contig names are unique across MAGs and that the reference is searchable for alignment.

#### b. Read Mapping with BWA-MEM2 (Array Job)

Reads were aligned to the `all_mags.fa` reference using a SLURM array job (`01_align_reads_array.sh`). Each job handled one row from the `sample_subset_with_paths.tsv` file, which contains:

- `SAMPLE_ID` (unique sample identifier)

- `FASTQ_PATH_WITH_R?` (path to FASTQ files using ? as a placeholder for 1 and 2)
