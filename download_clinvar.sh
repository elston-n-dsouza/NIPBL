VEP_CACHE='/well/whiffin/projects/vep'
ASSEMBLY='GRCh38'

# Download clinvar
echo 'Downloading ClinVars Weekly Release'
curl \
"ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar.vcf.gz" \
    --output clinvar.vcf.gz
