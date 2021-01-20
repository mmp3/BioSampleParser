#!/usr/bin/env Rscript

'Biosample parser.

Usage:
  Biosample_parser.R [options] <query>  <output>

Options:
    -f=<file>  filename of local XML file containing Biosample data fetched from Entrez. If not provided, then will fetch automatically from NCBI using the <query> argument.

Arguments:
    query  character, ENA ID or NCBI BioProject ID for the study of interest
    output filename to which a TSV-formatted file will be written containing the parsed metadata from the Biosample entries.
'  ->  doc

require(docopt)
args <- docopt(doc, version = 'Biosample parser')
#print(args)

# BioSampleParser converts metadata, obtained from NCBI Biosample in xml format, to a 
# more easily interpretable tabular format, i.e. data frame object or .tsv file. 
# This also allows the user to easily use the metadata for further processinginstall.packages("rentrez").
#BioSampleParser = function(query = NULL, filePath = NULL, file.tsv = NULL){


  
require(xml2)
require(rentrez)
require(data.table)

filePath  <-  args$f
if (is.null(filePath)) {
	if (is.null(args$query)){
		warning("Please specify either a NCBI BioProject query or a path to a BioSample .xml file")
	    return(NULL)
	} # query is null

	# Query NCBI BioProject for identifier
	EntrezResult = entrez_search(db="bioproject", term = args$query)
	BioProjectID = EntrezResult$ids
	if (length(BioProjectID) == 0){
		warning("NCBI BioProject found zero hits for the specified query")
		return(NULL)
	} 

	# Query NCBI BioSample for all related samples belonging to the BioProject ID
	EntrezResult = entrez_link(dbfrom = "bioproject", id = BioProjectID, db = "biosample")
	BioSampleList = EntrezResult$links$bioproject_biosample_all
	if (length(BioSampleList) == 0){
		warning("Unable to find any associated BioSamples for the specified BioProject ID")
		return(NULL)
	}

	# Fetch all BioSample results in .xml format
	meta_xml = entrez_fetch(db="biosample", id = BioSampleList, rettype = "xml")
	# Read queried xml file
	meta = read_xml(meta_xml)
} else {
	# Read xml file from path
	meta = read_xml(filePath)
} # filePath

# Convert to list
meta_list = as_list(meta)


# Initialize empty data frame
meta_dt  <-  data.table()

# Fill data frame with values from .xml file
show(cat("fill.\n"))
for (i in 1:length(meta_list$BioSampleSet)) {
	# iterate over BioSample objects
	bsdt  <-  data.table( dummyfillertmp = "") # dummy so that initializes to 1 row.

	# ID
	for (j in 1:length(meta_list$BioSampleSet[[i]]$Ids)) {
		varname  <-  attributes(meta_list$BioSampleSet[[i]]$Ids[[j]])$db
		value  <-  meta_list$BioSampleSet[[i]]$Ids[[j]][[1]]
		bsdt[, (varname) := value ]
	} # j, ids
	

	# Store Biosample Description
	for (j in 1:length(meta_list$BioSampleSet[[i]]$Description)) {
		varname  <-  names(meta_list$BioSampleSet[[i]]$Description)
		value  <-  meta_list$BioSampleSet[[i]]$Description[[j]][[1]][[1]]
		bsdt[, (varname) := value ]
	} # j, description

	# Store Biosample Attributes
	for (j in 1:length(meta_list$BioSampleSet[[i]]$Attributes)) {
		attribs  <-  attributes(meta_list$BioSampleSet[[i]]$Attributes[[j]])
		varname  <-  attribs[[1]]

		value  <-  meta_list$BioSampleSet[[i]]$Attributes[[j]][[1]]
		bsdt[, (varname) := value ]
	} # j, attributes

	bsdt[, dummyfillertmp := NULL]

	meta_dt  <-  rbind( meta_dt , bsdt , fill = TRUE )
} # i, BioSamples


### output file
if (!is.null(args$output)){
	show(cat("write output file.\n"))
	fwrite( meta_dt , file = args$output , sep = "\t" , col.names = TRUE )
}
