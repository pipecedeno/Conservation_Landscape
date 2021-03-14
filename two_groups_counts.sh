#!/bin/bash

#Here the some specific files are selected and some specific numbers are calculated to give the correct
#inputs to the python program that will create the output files

size_kmer=$1

reference_genome=$2

num_principal_genomes=$3

num_other_genomes=$4

dictionary_directory=$5

princ_name=$6

other_name=$7

num_kmers=$(wc -l $(find ${dictionary_directory} -name ${size_kmer}'*'.fasta.dump) | awk '{print $1/2}')

principal_file=$(find intermediate/sam_files/ -name ${size_kmer}_${princ_name}_resul_file.samfinal)

other_file=$(find intermediate/sam_files/ -name ${size_kmer}_${other_name}_resul_file.samfinal)

two_groups_counts.py --psf ${principal_file} --osf ${other_file} --ref ${reference_genome} --des output_files/ --nmk ${num_kmers} --ngp ${num_principal_genomes} --nog ${num_other_genomes} --pgn ${princ_name} --ogg ${other_name}

