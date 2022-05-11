library(data.table)
library(magrittr)

input_gnomad <- fread("input_nipbl_gnomad.tsv")
input_clinvar <- fread("input_nipbl_clinvar.tsv")

# Name the columns 
names(input_clinvar) <- c('CHROM', "POS", "REF", "ALT", "CLNREVSTAT", "CLNSIG")
names(input_gnomad) <- c("CHROM", "POS", "REF", "ALT", "AN", "AF")

input_gnomad[, CHROM := substr(CHROM, 4,4)]

# Create VEP input file 
input_clinvar[, ID := sprintf("%s-%s-%s-%s", CHROM, POS, REF, ALT)]
input_gnomad[, ID := sprintf("%s-%s-%s-%s", CHROM, POS, REF, ALT)]

fwrite(input_gnomad[,.(CHROM, POS, ID, REF, ALT, ".", ".", "." )], 
    "input_vep_nipbl_gnomad.vcf", sep = "\t", col.names = F)
fwrite(input_clinvar[,.(CHROM, POS, ID, REF, ALT, ".", ".", "." )],
    "input_vep_nipbl_clinvar.vcf", sep = "\t", col.names = F)
