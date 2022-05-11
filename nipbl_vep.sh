#!/bin/bash 

VEP_CACHE='/well/whiffin/projects/vep'
ASSEMBLY='GRCh38'

# Filter vcf to 5' UTR regions 
echo 'Filtering to NIPBL'
module load BCFtools

# Create index for the clinvar file
tabix -p vcf clinvar.vcf.gz -f

# Run tabix
# Different chr rep for clinvar 
tabix -p vcf -h /well/whiffin/shared/gnomAD/gnomad.genomes.v3.1.1.sites.chr5.vcf.bgz chr5:36876769-36877178 chr5:36953618-36953696 > input_nipbl_gnomad.vcf
tabix -p vcf -h clinvar.vcf.gz 5:36876769-36877178 5:36953618-36953696 > input_nipbl_clinvar.vcf

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%AC\t%AF\n' input_nipbl_gnomad.vcf > input_nipbl_gnomad_headerless.tsv
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/CLNREVSTAT\t%INFO/CLNSIG\n' input_nipbl_clinvar_headerless.vcf > input_nipbl_clinvar.tsv

# Add column headers
echo $'CHROM\t\POS\tREF\tALT\tAC\tAF' | cat -  input_nipbl_gnomad_headerless.tsv > input_nipbl_gnomad.tsv
echo $'CHROM\t\POS\tREF\tALT\tCLNREVSTAT\tCLNSIG' | cat -  input_nipbl_clinvar_headerless.tsv > input_nipbl_clinvar.tsv


# Run R to prep the files for 
module purge 
module load R

Rscript prep_files.R



# Run VEP on gnomAD
# Run using qlogin -q short.qc -pe shmem 5
module purge
module load VEP
vep \
--assembly GRCh38 \
--force_overwrite \
--species homo_sapiens \
--cache \
--fasta ${VEP_CACHE}/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
--mane \
--mane_select \
--canonical \
--offline \
--tab \
--fork 10 \
--dir_cache ${VEP_CACHE} \
--plugin UTRannotator \
-i input_vep_nipbl_gnomad.vcf \
-o output_vep_nipbl_gnomad.txt

# Run VEP on ClinVar

vep \
--assembly GRCh38 \
--force_overwrite \
--species homo_sapiens \
--cache \
--fasta ${VEP_CACHE}/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
--mane \
--mane_select \
--canonical \
--fork 10 \
--offline \
--tab \
--dir_cache ${VEP_CACHE} \
--plugin UTRannotator \
-i input_vep_nipbl_clinvar.vcf \
-o output_vep_nipbl_clinvar.txt


vep \
--assembly GRCh38 \
--force_overwrite \
--species homo_sapiens \
--cache \
--fasta ${VEP_CACHE}/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
--mane \
--mane_select \
--canonical \
--fork 10 \
--offline \
--tab \
--dir_cache ${VEP_CACHE} \
--plugin UTRannotator \
-i additional_vars.vcf \
-o additional_vars.txt


# Run R to merge the annotations with VEP consequences 
module purge 
module load R
Rscript merge_files.R