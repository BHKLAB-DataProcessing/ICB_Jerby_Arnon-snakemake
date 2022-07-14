from snakemake.remote.S3 import RemoteProvider as S3RemoteProvider
S3 = S3RemoteProvider(
    access_key_id=config["key"], 
    secret_access_key=config["secret"],
    host=config["host"],
    stay_on_remote=False
)
prefix = config["prefix"]
filename = config["filename"]
data_source  = "https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Jerby_Arnon-data/main/"

rule get_MultiAssayExp:
    input:
        S3.remote(prefix + "processed/CLIN.csv"),
        S3.remote(prefix + "processed/EXPR.csv"),
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "annotation/Gencode.v19.annotation.RData")
    output:
        S3.remote(prefix + filename)
    resources:
        mem_mb=4000
    shell:
        """
        Rscript -e \
        '
        load(paste0("{prefix}", "annotation/Gencode.v19.annotation.RData"))
        source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/get_MultiAssayExp.R");
        saveRDS(
            get_MultiAssayExp(study = "Jerby_Arnon", input_dir = paste0("{prefix}", "processed")), 
            "{prefix}{filename}"
        );
        '
        """

rule download_annotation:
    output:
        S3.remote(prefix + "annotation/Gencode.v19.annotation.RData")
    shell:
        """
        wget https://github.com/BHKLAB-Pachyderm/Annotations/blob/master/Gencode.v19.annotation.RData?raw=true -O {prefix}annotation/Gencode.v19.annotation.RData 
        """

rule format_clin:
    input:
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CLIN.txt")
    output:
        S3.remote(prefix + "processed/CLIN.csv")
    shell:
        """
        Rscript scripts/Format_CLIN.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_expr:
    input:
        S3.remote(prefix + "download/EXPR.txt.gz"),
        S3.remote(prefix + "processed/cased_sequenced.csv")
    output:
        S3.remote(prefix + "processed/EXPR.csv")
    shell:
        """
        Rscript scripts/Format_EXPR.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_cased_sequenced:
    input:
        S3.remote(prefix + "download/CLIN.txt")
    output:
        S3.remote(prefix + "processed/cased_sequenced.csv")
    shell:
        """
        Rscript scripts/Format_cased_sequenced.R \
        {prefix}download \
        {prefix}processed \
        """

rule process_downloaded_data:
    input:
        S3.remote(prefix + "download/1-s2.0-S0092867418311784-mmc1.xlsx"),
        S3.remote(prefix + "download/1-s2.0-S0092867418311784-mmc6.xlsx")
    output:
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "download/EXPR.txt.gz")
    shell:
        """
        Rscript scripts/format_downloaded_data.R \
        {prefix}download
        """

rule download_data:
    output:
        S3.remote(prefix + "download/1-s2.0-S0092867418311784-mmc1.xlsx"),
        S3.remote(prefix + "download/1-s2.0-S0092867418311784-mmc6.xlsx")
    shell:
        """
        wget 'https://ars.els-cdn.com/content/image/1-s2.0-S0092867418311784-mmc1.xlsx' -O {prefix}download/1-s2.0-S0092867418311784-mmc1.xlsx 
        wget 'https://ars.els-cdn.com/content/image/1-s2.0-S0092867418311784-mmc6.xlsx' -O {prefix}download/1-s2.0-S0092867418311784-mmc6.xlsx
        """ 
