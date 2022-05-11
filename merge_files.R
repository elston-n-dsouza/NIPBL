library(data.table)
library(magrittr)

gnomad_annotations <- fread("input_nipbl_gnomad.tsv")
clinvar_annotations <- fread("input_nipbl_clinvar.tsv")

names (gnomad_annotations) <-  c("CHROM", "POS", "REF", "ALT", "AN", "AF")
names(clinvar_annotations) <- c('CHROM', "POS", "REF", "ALT", "CLNREVSTAT", "CLNSIG")

gnomad_annotations[, CHROM := substr(CHROM, 4,4)]

# Create VEP input file 
gnomad_annotations[, ID := sprintf("%s-%s-%s-%s", CHROM, POS, REF, ALT)]
clinvar_annotations[, ID := sprintf("%s-%s-%s-%s", CHROM, POS, REF, ALT)]


# Read the VEP output files
gnomad_vep <- fread("output_vep_nipbl_gnomad.txt")
clinvar_vep <- fread("output_vep_nipbl_clinvar.txt")


# Filter to MANE Select 
gnomad_vep %<>% .[Feature == 'ENST00000282516']
clinvar_vep %<>% .[Feature == 'ENST00000282516']

setkey(gnomad_annotations, ID)
setkey(gnomad_vep, `#Uploaded_variation`)
setkey(clinvar_annotations, ID)
setkey(clinvar_vep, `#Uploaded_variation`)

fwrite(gnomad_annotations[gnomad_vep], 
    "nipbl_consequences_gnomad.txt", sep="\t")

fwrite(clinvar_annotations[clinvar_vep], "nipbl_consequences_clinvar.txt", sep="\t")
