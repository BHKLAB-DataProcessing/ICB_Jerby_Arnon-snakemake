args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" )
rownames(clin) = clin$Sample

patient = sort( unique( clin$Sample ) )

case = as.data.frame( cbind( patient , rep( 0 , length(patient) ) , rep( 0 , length(patient) ) , rep( 1 , length(patient) ) ) )
colnames(case) = c( "patient" , "snv" , "cna" , "expr" )
rownames(case) = patient

case$snv = as.numeric( as.character( case$snv ) )
case$cna = as.numeric( as.character( case$cna ) )
case$expr = as.numeric( as.character( case$expr ) )


write.table( case , file=file.path(output_dir, "cased_sequenced.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )


