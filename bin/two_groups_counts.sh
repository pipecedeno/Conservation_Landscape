#!/bin/bash

######
# Date: 17/Nov/2021
# Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
# version: 1.1
# 1.1: changed the name of the directories of intermediate, so now ids_perfect_match are ids_relaxed and 
# ids_not_perfect_match are ids_conservative

# Program Description:
# This program will execute the program two_groups_counts.py and is used so that program can be parallelized.
# It only receives the inputs and calculate the amount of kmers for the size_kmer.

# Inputs: (this inputs are positional inputs so the order is key for the program to work)
# 1.- size of the kmer for which the wig files is going to be used
# 2.- path to the reference genome
# 3.- number of genomes in the principal group
# 4.- number of genomes in the other group
# 5.- directory where the files with the kmers is located
# 6.- name of the principal group (this is just to name the file)
# 7.- name of the other group (this is just the name the file)
######

size_kmer=$1

reference_genome=$2

num_principal_genomes=$3

num_other_genomes=$4

dictionary_directory=$5

princ_name=$6

other_name=$7

num_kmers=$(wc -l $(find ${dictionary_directory} -name ${size_kmer}'*'.fasta) | awk '{print $1/2}')

two_groups_counts.py --psf intermediate/ids_relaxed/${princ_name}/${size_kmer}/ --osf intermediate/ids_relaxed/${other_name}/${size_kmer}/ --pnp intermediate/ids_conservative/${princ_name}/${size_kmer}/ --onp intermediate/ids_conservative/${other_name}/${size_kmer}/ --ref ${reference_genome} --des output_files/ --nmk ${num_kmers} --ngp ${num_principal_genomes} --nog ${num_other_genomes} --pgn ${princ_name} --ogg ${other_name} --size ${size_kmer}

