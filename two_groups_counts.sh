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

two_groups_counts.py --psf intermediate/ids_perfect_match/${princ_name}/${size_kmer}/ --osf intermediate/ids_perfect_match/${other_name}/${size_kmer}/ --pnp intermediate/ids_not_perfect_match/${princ_name}/${size_kmer}/ --onp intermediate/ids_not_perfect_match/${other_name}/${size_kmer}/ --ref ${reference_genome} --des output_files/ --nmk ${num_kmers} --ngp ${num_principal_genomes} --nog ${num_other_genomes} --pgn ${princ_name} --ogg ${other_name} --size ${size_kmer}

