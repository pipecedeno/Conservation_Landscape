In this folder there are the genomes used for the article about CovDif.

This folder contains the following groups of data:
-covid_clades: it has the sequences of the clades (G, GH, GR, GV, L, O, S and V) downloaded for the dates mentioned in the supplemental material of the article. The folder contains the ids of the sequences and also the compressed files of the fasta sequences.
-covid_variants: it has the fasta files for each of the variants used (b.1.1.7, b.1.351, b.1.427, b.1.525 and p.1). The folder contains the ids of the sequences and also the compressed files of the fasta sequences.
-environmental_sequences: It has the compressed sequences of the environmental files used (non covid genomes) and also the headers of the sequences and ids.
-genomes_for_bimester_conservation: it has the compressed files used for the graphs of conservation of some variants across different bimester.

To uuncompress the files the following command can be used:

tar -xf <file_name.tar.xz>

To uncompress the files of the environmental sequences the command the following command can be used:

ls *.tar.xz | parallel tar -xf {}

It uses parallel so the command doesn't need to be done more than a thousand times manually.
