# 🧬 woodfrog_snp_pipeline

This repository contains a modular SNP association analysis pipeline tailored for species-level investigations in the wood frog (*Lithobates sylvaticus*) gut metagenome project.

## 1. Sample Preparation

This pipeline begins with a curated set of dereplicated metagenome-assembled genomes (MAGs) derived from *Lithobates sylvaticus* fecal samples.

### a. MAG Reference Construction

We compiled 162 dereplicated MAGs from:  
`/bigdata/stajichlab/shared/projects/Herptile/Metagenome/Ls_MAG_C/drep/dRep95/dereplicated_genomes/`


These MAGs were listed in a file:
`MAGs.fofn`


Each line in `MAGs.fofn` contains the full path to a single MAG `.fa` file.

These MAGs were concatenated into a single reference FASTA file:
`db/all_mags.fa`


This reference was used for building the BWA index and mapping reads for downstream SNP discovery.

### b. Sample Metadata and Read Paths

Read file paths and sample IDs are defined in:

`woodfrog_samples.csv`


The file has two columns:

- `SAMPLE_ID`: Unique sample identifier (e.g., `UHM102.10840`)
- `FASTQ_PATH_WITH_R?`: Base path to raw reads, ending in `_R1.fastq.gz` and `_R2.fastq.gz` (for paired-end sequencing)

### c. Outputs from This Step

- `db/all_mags.fa`: Combined reference FASTA of all MAGs  
- `db/all_mags.fa.*`: BWA index files generated from `all_mags.fa`

---

## 2. Mapping Reads to MAG Reference

Metagenomic reads were mapped to a concatenated reference file composed of all dereplicated MAGs. This step used BWA-MEM2 for efficient alignment, and outputs were stored in CRAM format to reduce disk usage.

### a. Reference Construction and Indexing

The MAG reference was constructed by renaming all contigs in the MAGs with their MAG ID prefix using `perl`, then concatenating into a single FASTA using:

`rename_mag_contigs.sh`


The reference was indexed with BWA-MEM2, using:
`01_align_reads_array.sh`


This ensures contig names are unique across MAGs and that the reference is searchable for alignment.

### b. Read Mapping with BWA-MEM2 (Array Job)

Reads were aligned to the `all_mags.fa` reference using a SLURM array job:

`01_align_reads_array.sh`


Each job handled one row from the `sample_subset_with_paths.tsv` file, which contains:

- `SAMPLE_ID`: Unique sample identifier  
- `FASTQ_PATH_WITH_R?`: Path to FASTQ files using `?` as a placeholder for 1 and 2

---

## 3. SNP Calling

We performed SNP calling using `bcftools` on the CRAM-aligned reads against the `all_mags.fa` reference.

All BAM/CRAM alignments were processed together using `bcftools mpileup` and `bcftools call`:

- Script:  
`02_variant_call_combined.sh`

- Output:  
`output/vcf_gz/all_samples.vcf.gz`


This ensures consistent variant representation across samples for downstream frequency calculations.

---

## 4. MAF Matrix Generation

This step converts genotype information in VCF files into a matrix of minor allele frequencies (MAF) per SNP across all samples using this:

`generate_maf_matrices_from_vcf.py`


This matrix serves as the input for downstream association testing and visualization.

### Inputs

- `.vcf.gz` files for each MAG (jointly called SNPs per MAG)  
- Sample CRAM files (used during SNP calling)  
- MAG identifiers embedded in VCF filenames

### Output

- One file per MAG:  

`*_maf_matrix.tsv`


- Tab-delimited format with:
- **Rows**: SNPs (formatted as `MAG_ID.k141_POS_REF_ALT`)  
- **Columns**: Samples (e.g., `output/bam/UHM102.35766.cram`)  
- **Values**: Estimated MAF (range: 0.0–1.0; NA if missing)

### Notes

- SNPs are encoded as: `MAG.contig_POS_REF_ALT`  
- Heterozygous calls (`1/0` or `0/1`) are treated as `0.5`  
- Homozygous alternate (`1/1`) = `1.0`; homozygous reference (`0/0`) = `0.0`  
- Missing calls are represented as `NA`




