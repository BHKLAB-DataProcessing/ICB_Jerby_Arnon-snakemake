args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')

clin = cbind( clin[ , c( "Sample","Sex","RECIST","t.pfs","pfs" ) ] , "Melanoma" , "PD-1/PD-L1" , NA , NA , NA , NA , NA , NA , NA , NA , NA )
colnames(clin) = c( "patient" , "sex" , "recist"  ,"t.pfs"  , "pfs"  , "primary" , "drug_type" , "response.other.info" , "response" , "age" , "histo" , "stage" , "t.os" , "os" , "dna" , "rna" )

clin$recist = ifelse(clin$recist %in% "MR" , "SD" ,
				ifelse(clin$recist %in% "na" , NA , clin$recist ))
clin$t.pfs = clin$t.pfs * 12
clin$rna = "tpm"

clin$response = Get_Response( data=clin )

clin = clin[ , c("patient" , "sex" , "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os" ) ]

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

