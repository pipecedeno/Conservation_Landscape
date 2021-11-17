#!/bin/bash 

######
# Date: 17/Nov/2021
# Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
# version: 1.0

# Program Description:
# This program is executed before many_groups_counts.py and it will create some files that are necessary
# for that program, it will create the ${size_kmer}_files_names_perfect_match.txt and the 
# ${size_kmer}_files_names_not_perfect_match.txt which will have the directories of the ids that need to be 
# counted to create the wig files.
# Also the amount of kmer for this size is counted in this program.

# Inputs: (this inputs are positional inputs so the order is key for the program to work)
# 1.- size of the kmer for which the wig files is going to be used
# 2.- path to the reference genome
# 3.- vector with the number or genomes for each group, the numbers are separated by ','
# 4.- directory where the files with the kmers is located
######


size_kmer=$1

reference_genome=$2

num_genomes=$3

dictionary_directory=$4

#As many files need to be processed by the python program a file with the name of the programs it needs to process is made
#so only a file is always passed to the program.
for directory in $(find intermediate/ids_perfect_match/ -type d -name ${size_kmer})
do
	echo "${directory}/" >> intermediate/${size_kmer}_files_names_perfect_match.txt
done

for directory in $(find intermediate/ids_not_perfect_match/ -type d -name ${size_kmer})
do
	echo "${directory}/" >> intermediate/${size_kmer}_files_names_not_perfect_match.txt
done

#The count of the number of kmers is made
num_kmers=$(wc -l $(find ${dictionary_directory} -name ${size_kmer}'*'.fasta) | awk '{print $1/2}')

many_groups_counts.py --fil intermediate/${size_kmer}_files_names_perfect_match.txt --fil2 intermediate/${size_kmer}_files_names_not_perfect_match.txt --ref ${reference_genome} --des output_files/ --nmk ${num_kmers} --nmg ${num_genomes} --size ${size_kmer}
