#!/bin/bash

######
# Date: 17/Nov/2021
# Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
# version: 1.1
# 1.1: changed the name of some directories in the intermediate directory (the name of the directories of 
# intermediate, so now ids_perfect_match are ids_relaxed and ids_not_perfect_match are 
# ids_conservative) and added an option to delete or not the intermediate directory.

# Program Description:
# This program controls all the commands and programs that should be executed in a particular order to 
# complete the flow of many_groups.

# This program receives the following inputs:
# 	-m The directory that contains the directory of each group that is going to be used.
# 			Note: this directory should contain the directories of the different groups to be analysed and only .fasta 
# 				files should be in those directories.
# 	-r The reference genome fasta file.
# 	-s (Optional) If given it is the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23.
# 		If not given the sizes are going to be from 20 to 25.
# 	-p Is the number of cores/threads that is gonna be used, if not given 1 is going to be used.
# 	-o Is the place where the directory with the output files is going to be saved
# 	-d If this flag is used the intermediate folder won't be deleted

######


while getopts "m:r:s:p:o:d:" option
do
case "${option}"
in
m) groups_directory=${OPTARG};;
r) reference_genome=${OPTARG};;
s) vec=${OPTARG};;
p) num_cores=${OPTARG};;
o) output_dir=${OPTARG};;
d) delete_intermediate=${OPTARG};;
:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
esac
done

start_fin=`date +%s`

#This checks if output_files or intermediate already exists
[ -d "intermediate" ] && echo "directory intermediate already exists if you want to run the program please delete it" && exit
[ -d "output_files" ] && echo "directory output_files already exists if you want to run the program please delete it" && exit

IFS=',' read -r -a sizes <<< "$vec"

#Here the variable with the groups that are going to be used is created
cont=0
for directory in $(find ${groups_directory} -type d)
do
	var_temp=${directory##*/}
	if [ -n "$var_temp" ]
	then
		groups_vec[$cont]=$var_temp
		let cont=$cont+1
	fi
done

mkdir -p intermediate
mkdir -p intermediate/dump_reference
mkdir -p intermediate/mod_genome

#A directory for each group is made in mod_genome directory
for group in "${groups_vec[@]}"
do
	mkdir -p intermediate/mod_genome/${group}
done

mkdir -p intermediate/sam_files
for group in "${groups_vec[@]}"
do
	for size_kmer in "${sizes[@]}"
	do
		mkdir -p intermediate/sam_files/${group}/${size_kmer}
	done
done

mkdir -p intermediate/ids_relaxed
for group in "${groups_vec[@]}"
do
	for size_kmer in "${sizes[@]}"
	do
		mkdir -p intermediate/ids_relaxed/${group}/${size_kmer}
	done
done

mkdir -p intermediate/ids_conservative
for group in "${groups_vec[@]}"
do
	for size_kmer in "${sizes[@]}"
	do
		mkdir -p intermediate/ids_conservative/${group}/${size_kmer}
	done
done

mkdir -p intermediate/nums

#A directory for each group is made in nums directory
for group in "${groups_vec[@]}"
do
	mkdir -p intermediate/nums/${group}
done

mkdir -p output_files

#printing the parameters used in the time report file
echo "Parameters:" >> output_files/time_report.txt
echo "Principal group directory: ${principal_group_directory}" >> output_files/time_report.txt
echo "Other group directory: ${other_group_directory}" >> output_files/time_report.txt
echo "Reference genome: ${reference_genome}" >> output_files/time_report.txt
echo "Sizes vector: ${vec}" >> output_files/time_report.txt
echo "Number of cores: ${num_cores}" >> output_files/time_report.txt
echo "Output directory: ${output_dir}" >> output_files/time_report.txt
echo "-d ${delete_intermediate}" >> output_files/time_report.txt
echo ""  >> output_files/time_report.txt
echo "Times:" >> output_files/time_report.txt

#making the kmers files of the reference genome
start=`date +%s`
parallel -P ${num_cores} extrac_seq_perGene_write.py -i ${reference_genome} -o intermediate/dump_reference/{}_reference_genome.fasta -k {} -w 1 ::: ${sizes[@]}
dictionary_directory=intermediate/dump_reference/
end=`date +%s`
echo making kmer files execution time was `expr $end - $start` seconds. >> output_files/time_report.txt


#Here the alignments and the counts of the sizes of the genomes of each group is going to be made
for directory in $(find ${groups_directory} -type d)
do
	var_temp=${directory##*/}
	if [ -n "$var_temp" ]
	then
		start=`date +%s`
		#Note: the false in this line is added to always use the option of filling the gaps in the alignments  
		find ${directory} -name '*'.fasta | parallel -P ${num_cores} database_align.sh {} ${vec} ${dictionary_directory} ${var_temp}/ false
		end=`date +%s`
		echo ${var_temp} alignment execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

		#histogram of the sizes of the genomes is made
		start=`date +%s`
		hist_size.py --nam intermediate/nums/${var_temp}/cont_final.numfin --des output_files/${var_temp}_sizes_hist.jpg
		end=`date +%s`
		echo Concatenating and making the histogram for ${var_temp} execution time was `expr $end - $start` seconds. >> output_files/time_report.txt
	fi
done

#counting the genomes in each group and making a string with the results
start=`date +%s`
first=1
for directory in $(find ${groups_directory} -type d)
do
	var_temp=${directory##*/}
	if [ -n "$var_temp" ]
	then
		if [ "$first" == "1" ]
		then
			counts+=${var_temp}
			counts+=":"
			counts+=$(find ${directory} -name '*'.fasta | wc -l)
			first=0
		else
			counts+=","
			counts+=${var_temp}
			counts+=":"
			counts+=$(find ${directory} -name '*'.fasta | wc -l)
		fi
	fi
done
end=`date +%s`
echo Counting genomes execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#executing the final part that is going to make the wig files
start=`date +%s`
parallel -P ${num_cores} many_groups_counts.sh {} ${reference_genome} ${counts} ${dictionary_directory} ${groups_directory} ::: ${sizes[@]}
end=`date +%s`
echo Making bedgraphs execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#deleting the intermediate folder
if [ ${delete_intermediate} = true ]
then
	rm -r intermediate/
else
	rm -r intermediate/dump_reference/
	rm -r intermediate/mod_genome/
	rm -r intermediate/nums/
	rm -r intermediate/sam_files/
	rm intermediate/*_files_names_conservative.txt
	rm intermediate/*_files_names_relaxed.txt
fi

end_fin=`date +%s`
echo Total execution time was `expr $end_fin - $start_fin` seconds. >> output_files/time_report.txt

#moving the output_files directory
if [ "$(pwd)/" != "${output_dir}" ]
then
	mv output_files/ ${output_dir}
fi