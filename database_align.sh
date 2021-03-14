#!/bin/bash

#This program first creates the bowtie database of the file of the input, then it align all
#the kmers that were produced for the sies selected and will only save the id of the kmer 
#which is the position of the kmer in the reference genome and this numbers will be appended 
#in the same file, which we tested that wont hve any problem when using many cores/threads.
#Finally it will delete the bowtie database as it wont be necessary anymore and will count the
#kmers of this genome.

file=$1

vec=$2

covid_dictionary_directory=$3

resp_directory=$4

output_name=$5

IFS=',' read -r -a sizes <<< "$vec"

#First the database of bowtie is made
name=$( basename $file .fasta )
bowtie2-build -f $file intermediate/bowtie_db/${resp_directory}$name

#here all the kmers of all different sizes are aligned to the database, but only the perfect alignments are
#saved, which is what the grep does, and then the awk only saves the column of the id of the sequence that
#was aligned and that is appended into the output file. 
for size_kmer in "${sizes[@]}"
do
	#instructions for covid genomes	
	reads=$(find ${covid_dictionary_directory} -name ${size_kmer}'*'.fasta.dump)
	bowtie2 -f -x intermediate/bowtie_db/${resp_directory}$name -U $reads --no-unal --no-hd | grep "MD:Z:${size_kmer}" | awk '{print $1}' >> intermediate/sam_files/${size_kmer}${output_name}
	let size_kmer=$size_kmer+1
done

#This line is for deleting the bowtie databases that are going to be created 
rm intermediate/bowtie_db/${resp_directory}${name}.*

#this is for counting the size of the genome to later make the histogram of the sizes and now
#the output is appended to the same file, so the cat isn't necessary
grep -v ">" ${file} | wc | awk '{print $3-$2}' >> intermediate/nums/${resp_directory}cont_final.numfin
