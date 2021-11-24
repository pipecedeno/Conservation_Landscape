#!/bin/bash

######
# Date: 17/Nov/2021
# Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
# version: 1.1
# 1.1: changed the name of the directories of intermediate, so now ids_perfect_match are ids_relaxed and 
# ids_not_perfect_match are ids_conservative

# Program Description:
# This program is used to aligned the reference kmers to a genome, so it can be runned in parallel. It uses
# razers3 to do the alignment of the kmers and it will process the output file two times, the first one for the
# relaxed track were only the id of the kmers that have MD:Z:size_kmer in their line (for example, for size 20
# MD:Z:20 should be in the line) will be saved to the file, and the second time the output file is processed with
# normal_process_sam.py or fill_process_sam.py which will save different ids depending if the flag -x or -y was 
# given or not in the command line, for the many_groups flow the program fill_process_sam.py is always used.

# Inputs (this are positional inputs so the order is key for the program to work): 
# 1.- genome file were the kmers are going to be aligned
# 2.- vector of the sizes to be used, the numbers are separated by commas
# 3.- directory were the files with the kmers are saved
# 4.- output directory were the files with the ids are saved, this is so the program can be executed for different
# 	groups.
# 5.- flag to know if normal_process_sam.py is used (true is normal_process_sam.py is going to be used)
######


file=$1

vec=$2

covid_dictionary_directory=$3

resp_directory=$4

normal_process=$5


IFS=',' read -r -a sizes <<< "$vec"

#First the genome file is processed to delete all characters that are not ATCG or N
name=$( basename $file .fasta )
delete_non_atcg_bases.py -f ${file} -o intermediate/mod_genome/${name}_mod.fasta

mod_fasta=intermediate/mod_genome/${name}_mod.fasta

#here the kmers are aligned to the modified genome file and depending of the flag it is if the gaps are going
#to be filled or not for the conservative track, only the ids of the reference kmers that were aligned are saved
#to make the next file
for size_kmer in "${sizes[@]}"
do
	#instructions for covid genomes	
	reads=$(find ${covid_dictionary_directory} -name ${size_kmer}'*'.fasta)
	
	razers3 -ng -mN -i 95 ${mod_fasta} ${reads} -o intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam

	#alignment for relaxed track
	grep "MD:Z:${size_kmer}" intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam | awk '{print $1}' | uniq > intermediate/ids_relaxed/${resp_directory}${size_kmer}/${name}.sam
	
	#alignment for conservative track
	if [ ${normal_process} = true ]
	then
		#echo "normal"
		normal_process_sam.py -f intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam -s ${size_kmer} | uniq > intermediate/ids_conservative/${resp_directory}${size_kmer}/${name}.sam
	else
		#echo "fill"
		fill_process_sam.py -f intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam -s ${size_kmer} | uniq > intermediate/ids_conservative/${resp_directory}${size_kmer}/${name}.sam
	fi

	#This instruction is going to be used to delete the sam file
	rm intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam
	let size_kmer=$size_kmer+1
done

#This line is for deleting the modified genomes that only have ATCG or N
rm ${mod_fasta}

#this is for counting the size of the genome to later make the histogram of the sizes and now
#the output is appended to the same file, so the cat isn't necessary
grep -v ">" ${file} | wc | awk '{print $3-$2}' >> intermediate/nums/${resp_directory}cont_final.numfin
