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
# complete the two_groups flow

# Inputs:
# 	-c The group of interest directory. (only .fasta files should be in this directory)
# 	-n The other group directory. (only .fasta files should be in this directory)
# 	-r The reference_genome fasta file.
# 	-s (Optional) If given it is the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23.
# 		If not given the sizes are going to be from 20 to 25.
# 	-p (Optional) Is the number of cores/threads that is gonna be used, if not given 1 is going to be used.
# 	-o Is the place where the directory with the output files is going to be saved
# 	-x Do not fill the gaps of kmers with N in the groups of interest.
# 	-y Do not fill the gaps of kmers with N in the other group.
# 	-d If this flag is used the intermediate folder won't be deleted
######




while getopts "x:y:c:n:r:s:p:o:d:" option
do
case "${option}"
in
c) principal_group_directory=${OPTARG};;
n) other_group_directory=${OPTARG};;
r) reference_genome=${OPTARG};;
s) vec=${OPTARG};; #contains the values of the sizes
p) num_cores=${OPTARG};;
o) output_dir=${OPTARG};;
x) normal_process_princ=${OPTARG};;
y) normal_process_other=${OPTARG};;
d) delete_intermediate=${OPTARG};;
:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
esac
done



start_fin=`date +%s`

#This checks if output_files or intermediate already exists
[ -d "intermediate" ] && echo "directory intermediate already exists if you want to run the program please delete it" && exit
[ -d "output_files" ] && echo "directory output_files already exists if you want to run the program please delete it" && exit


IFS=',' read -r -a sizes <<< "$vec"

#obtaining each group name
var_temp=${principal_group_directory%*/}
princ_name=${var_temp##*/}

var_temp=${other_group_directory%*/}
other_name=${var_temp##*/}

#making the directories
mkdir -p intermediate
mkdir -p intermediate/dump_reference 
mkdir -p intermediate/mod_genome
mkdir -p intermediate/mod_genome/${princ_name}
mkdir -p intermediate/mod_genome/${other_name}
mkdir -p intermediate/sam_files
mkdir -p intermediate/ids_relaxed
mkdir -p intermediate/ids_conservative

mkdir -p intermediate/sam_files/${princ_name}
for size_kmer in "${sizes[@]}"
do
	mkdir -p intermediate/sam_files/${princ_name}/${size_kmer}
done
mkdir -p intermediate/sam_files/${other_name}
for size_kmer in "${sizes[@]}"
do
	mkdir -p intermediate/sam_files/${other_name}/${size_kmer}
done

mkdir -p intermediate/ids_relaxed/${princ_name}
for size_kmer in "${sizes[@]}"
do
	mkdir -p intermediate/ids_relaxed/${princ_name}/${size_kmer}
done
mkdir -p intermediate/ids_relaxed/${other_name}
for size_kmer in "${sizes[@]}"
do
	mkdir -p intermediate/ids_relaxed/${other_name}/${size_kmer}
done

mkdir -p intermediate/ids_conservative/${princ_name}
for size_kmer in "${sizes[@]}"
do
	mkdir -p intermediate/ids_conservative/${princ_name}/${size_kmer}
done
mkdir -p intermediate/ids_conservative/${other_name}
for size_kmer in "${sizes[@]}"
do
	mkdir -p intermediate/ids_conservative/${other_name}/${size_kmer}
done

mkdir -p intermediate/nums
mkdir -p intermediate/nums/${princ_name}
mkdir -p intermediate/nums/${other_name}
mkdir -p output_files

#printing the parameters used in the time report file
echo "Parameters:" >> output_files/time_report.txt
echo "Principal group directory: ${principal_group_directory}" >> output_files/time_report.txt
echo "Other group directory: ${other_group_directory}" >> output_files/time_report.txt
echo "Reference genome: ${reference_genome}" >> output_files/time_report.txt
echo "Sizes vector: ${vec}" >> output_files/time_report.txt
echo "Number of cores: ${num_cores}" >> output_files/time_report.txt
echo "Output directory: ${output_dir}" >> output_files/time_report.txt
echo "-x ${normal_process_princ}" >> output_files/time_report.txt
echo "-y ${normal_process_other}" >> output_files/time_report.txt
echo "-d ${delete_intermediate}" >> output_files/time_report.txt
echo ""  >> output_files/time_report.txt
echo "Times:" >> output_files/time_report.txt

#making the kmers files of the reference genome
start=`date +%s`
parallel -P ${num_cores} extrac_seq_perGene_write.py -i ${reference_genome} -o intermediate/dump_reference/{}_reference_genome.fasta -k {} -w 1 ::: ${sizes[@]}
dictionary_directory=intermediate/dump_reference/
end=`date +%s`
echo making kmer files execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

# echo "1"
# echo "princ ${normal_process_princ}"
# echo "other ${normal_process_other}"

#principal group making the alignments and counting the size of the genomes for the histogram
start=`date +%s`
find ${principal_group_directory} -name '*'.fasta | parallel -P ${num_cores} database_align.sh {} ${vec} ${dictionary_directory} ${princ_name}/ ${normal_process_princ}
end=`date +%s`
echo Principal group alignments execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#making the histogram of the sizes of the genomes
start=`date +%s`
hist_size.py --nam intermediate/nums/${princ_name}/cont_final.numfin --des output_files/${princ_name}_sizes_hist.jpg
#this will delete the numbers file as it's not needed anymore
rm intermediate/nums/${princ_name}/cont_final.numfin
end=`date +%s`
echo Concatenating and making the histogram execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

# echo "2"
# echo "princ ${normal_process_princ}"
# echo "other ${normal_process_other}"

#other group making the alignments and counting the size of the genomes for the histogram
start=`date +%s`
find ${other_group_directory} -name '*'.fasta | parallel -P ${num_cores} database_align.sh {} ${vec} ${dictionary_directory} ${other_name}/ ${normal_process_other}
end=`date +%s`
echo Other group alignments execution time was `expr $end - $start` seconds. >> output_files/time_report.txt


#makign the histogram of the sizes of the genomes
start=`date +%s`
hist_size.py --nam intermediate/nums/${other_name}/cont_final.numfin --des output_files/${other_name}_sizes_hist.jpg
#this will delete the numbers file as it's not needed anymore
rm intermediate/nums/${other_name}/cont_final.numfin
end=`date +%s`
echo Concatenating and making the histogram execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#counting each group genomes genomes
start=`date +%s`
num_principal_genomes=$(find ${principal_group_directory} -name '*'.fasta | wc -l)
num_other_genomes=$(find ${other_group_directory} -name '*'.fasta | wc -l)
end=`date +%s`
echo Counting genomes execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#executing the final part that is going to make the wig files
start=`date +%s`
parallel -P ${num_cores} two_groups_counts.sh {} ${reference_genome} ${num_principal_genomes} ${num_other_genomes} ${dictionary_directory} ${princ_name} ${other_name} ::: ${sizes[@]}
end=`date +%s`
echo Making wigs execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#deleting the intermediate folder
if [ ${delete_intermediate} = true ]
then
	rm -r intermediate/
else
	rm -r intermediate/dump_reference/
	rm -r intermediate/mod_genome/
	rm -r intermediate/nums/
	rm -r intermediate/sam_files/
fi

end_fin=`date +%s`
echo Total execution time was `expr $end_fin - $start_fin` seconds. >> output_files/time_report.txt


#moving the output_files directory only if the output directory isn't the current directory
if [ "$(pwd)/" != "${output_dir}" ]
then
	mv output_files/ ${output_dir}
fi