library(readxl) 
library(data.table)

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_excel_functions.R")

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]

clin <- read_and_format_excel(
  input_path=file.path(work_dir, '1-s2.0-S0092867418311784-mmc1.xlsx'),
  sheetname='TableS1C_ValCo2'
)
clin <- clin[order(clin$Sample), ]
colnames(clin) <- c("Sample", "Sex", "RECIST", "t.pfs", "pfs")
clin$Sex[clin$Sex == 'NA'] <- NA
clin$RECIST[clin$RECIST == 'NA'] <- NA
clin$pfs[clin$pfs == 'NA'] <- NA
clin$t.pfs[clin$t.pfs == 'NA'] <- NA

clin$t.pfs <- as.numeric(as.character(clin$t.pfs))
clin$pfs <- as.integer(clin$pfs)

write.table( clin , file=file.path(work_dir, 'CLIN.txt') , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )

expr <- read_and_format_excel(
  input_path=file.path(work_dir, '1-s2.0-S0092867418311784-mmc6.xlsx'),
  sheetname='TableS6B_ValCo2.gene.expression'
)
colnames(expr)[1] <- 'gene'
expr[2:dim(expr)[2]] <- sapply(expr[2:dim(expr)[2]], as.numeric)

gz <- gzfile(file.path(work_dir, 'EXPR.txt.gz'), "w")
write.table( expr , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
close(gz)