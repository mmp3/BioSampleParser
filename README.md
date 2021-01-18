# BioSampleParser
![alt text](https://raw.githubusercontent.com/angelolimeta/BioSampleParser/master/Biosampleparser.png)

A tool designed to provide users with easier access to study metadata.

BioSampleParser takes the following study identifiers as input:
* European Nucleotide Archive (EMBL-EBI) accession number, e.g. PRJNA397906.
* NCBI BioProject ID, e.g. 397906.

It then queries NCBI BioSample for any samples related to the study, downloads sample metadata in .xml format and parses it into a tabular format of choice (Data frame object in R, or .tsv file).

## Setup and Usage


Install some R package dependencies:
``` r
install.package("xml2","rentrez","docopts")
```

Note that the `xml2` package may require you to install xml2 via `apt-get` in ubuntu first.

Download BioSampleParser.R into a directory in PATH.

Call it from the command line via Rscript. Here is an example usage:

`Rscript BioSampleParser.R <query> <output>`


## List of all arguments

query
* character, ENA ID or NCBI BioProject ID for the study of interest

output
* filename for TSV-formatted output file.

