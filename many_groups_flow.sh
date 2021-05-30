#!/bin/bash

#This program controls all the commands and programs that should be executed in a particular order to 
#complete this flow

while getopts "m:r:s:p:o:" option
do
case "${option}"
in
m) groups_directory=${OPTARG};;
r) reference_genome=${OPTARG};;
s) vec=${OPTARG};;
p) num_cores=${OPTARG};;
o) output_dir=${OPTARG};;
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
mkdir -p intermediate/bowtie_db

#A directory for each group is made in bowtie_db directory
for group in "${groups_vec[@]}"
do
	mkdir -p intermediate/bowtie_db/${group}
done

#this directories are new for version2
mkdir -p intermediate/sam_files
for group in "${groups_vec[@]}"
do
	for size_kmer in "${sizes[@]}"
	do
		mkdir -p intermediate/sam_files/${group}/${size_kmer}
	done
done

#this directories are for version3
mkdir -p intermediate/ids_perfect_match
for group in "${groups_vec[@]}"
do
	for size_kmer in "${sizes[@]}"
	do
		mkdir -p intermediate/ids_perfect_match/${group}/${size_kmer}
	done
done

mkdir -p intermediate/ids_perfect_match
for group in "${groups_vec[@]}"
do
	for size_kmer in "${sizes[@]}"
	do
		mkdir -p intermediate/ids_perfect_match/${group}/${size_kmer}
	done
done

mkdir -p intermediate/ids_not_perfect_match
for group in "${groups_vec[@]}"
do
	for size_kmer in "${sizes[@]}"
	do
		mkdir -p intermediate/ids_not_perfect_match/${group}/${size_kmer}
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
echo "Sixes vector: ${vec}" >> output_files/time_report.txt
echo "Number of cores: ${num_cores}" >> output_files/time_report.txt
echo "Output directory: ${output_dir}" >> output_files/time_report.txt
echo ""  >> output_files/time_report.txt
echo "Times:" >> output_files/time_report.txt

#making the kmers files of the reference genome
start=`date +%s`
parallel -P ${num_cores} extrac_seq_perGene_write.py -i ${reference_genome} -o intermediate/dump_reference/{}_reference_genome.fasta.dump -k {} -w 1 ::: ${sizes[@]}
dictionary_directory=intermediate/dump_reference/
end=`date +%s`
echo making kmer files execution time was `expr $end - $start` seconds. >> output_files/time_report.txt


#Here the databases, the alignments and the counts of the sizes of the genomes of each group is going to be made
for directory in $(find ${groups_directory} -type d)
do
	var_temp=${directory##*/}
	if [ -n "$var_temp" ]
	then
		start=`date +%s`
		find ${directory} -name '*'.fasta | parallel -P ${num_cores} database_align.sh {} ${vec} ${dictionary_directory} ${var_temp}/ 
		end=`date +%s`
		echo ${var_temp} databases execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

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

#executing the final part that is going to make the bedgraph files
start=`date +%s`
parallel -P ${num_cores} many_groups_counts.sh {} ${reference_genome} ${counts} ${dictionary_directory} ${groups_directory} ::: ${sizes[@]}
end=`date +%s`
echo Making bedgraphs execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#deleting the intermediate folder
rm -r intermediate/

end_fin=`date +%s`
echo Total execution time was `expr $end_fin - $start_fin` seconds. >> output_files/time_report.txt

#moving the output_files directory
if [ "$(pwd)/" != "${output_dir}" ]
then
	mv output_files/ ${output_dir}
fi