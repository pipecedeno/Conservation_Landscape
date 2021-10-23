#!/bin/bash

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
	grep "MD:Z:${size_kmer}" intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam | awk '{print $1}' | uniq > intermediate/ids_perfect_match/${resp_directory}${size_kmer}/${name}.sam
	
	#alignment for conservative track
	if [ ${normal_process} = true ]
	then
		#echo "normal"
		normal_process_sam.py -f intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam -s ${size_kmer} | uniq > intermediate/ids_not_perfect_match/${resp_directory}${size_kmer}/${name}.sam
	else
		#echo "fill"
		fill_process_sam.py -f intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam -s ${size_kmer} | uniq > intermediate/ids_not_perfect_match/${resp_directory}${size_kmer}/${name}.sam
	fi

	#This instruction is going to be used to delete the sam file
	rm intermediate/sam_files/${resp_directory}${size_kmer}/${name}.sam
	let size_kmer=$size_kmer+1
done

#This line is for deleting the bowtie databases that are going to be created 
rm ${mod_fasta}

#this is for counting the size of the genome to later make the histogram of the sizes and now
#the output is appended to the same file, so the cat isn't necessary
grep -v ">" ${file} | wc | awk '{print $3-$2}' >> intermediate/nums/${resp_directory}cont_final.numfin
