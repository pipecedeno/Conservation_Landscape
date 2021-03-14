#!/bin/bash

#Here the some specific files are selected and some specific numbers are calculated to give the correct
#inputs to the python program that will create the output files

size_kmer=$1

reference_genome=$2

num_genomes=$3

dictionary_directory=$4

groups_directory=$5

#As many files need to be processed by the python program a file with the name of the programs it needs to process is made
#so only a file is always passed to the program.
for directory in $(find ${groups_directory} -type d)
do
	var_temp=${directory##*/}
	if [ -n "$var_temp" ]
	then
		find intermediate/sam_files/ -name ${size_kmer}_${var_temp}_resul_file.samfinal >> intermediate/${size_kmer}_files_names.txt
	fi
done

#The count of the number of kmers is made
num_kmers=$(wc -l $(find ${dictionary_directory} -name ${size_kmer}'*'.fasta.dump) | awk '{print $1/2}')

many_groups_counts.py --fil intermediate/${size_kmer}_files_names.txt --ref ${reference_genome} --des output_files/ --nmk ${num_kmers} --nmg ${num_genomes}
