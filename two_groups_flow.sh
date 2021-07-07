#!/bin/bash

#This program controls all the commands and programs that should be executed in a particular order to 
#complete this flow

while getopts "c:n:r:s:p:o:" option
do
case "${option}"
in
c) principal_group_directory=${OPTARG};;
n) other_group_directory=${OPTARG};;
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

#obtaining each group name
var_temp=${principal_group_directory%*/}
princ_name=${var_temp##*/}

var_temp=${other_group_directory%*/}
other_name=${var_temp##*/}

#making the directories
mkdir -p intermediate
mkdir -p intermediate/dump_reference 
mkdir -p intermediate/bowtie_db
mkdir -p intermediate/bowtie_db/${princ_name}
mkdir -p intermediate/bowtie_db/${other_name}
mkdir -p intermediate/sam_files

#This directories are new for version2 that is a directory for each group and for each size
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

mkdir -p intermediate/nums
mkdir -p intermediate/nums/${princ_name}
mkdir -p intermediate/nums/${other_name}
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

#principal group creating databases, making the alignments and counting the size of the genomes for the histogram
start=`date +%s`
find ${principal_group_directory} -name '*'.fasta | parallel -P ${num_cores} database_align.sh {} ${vec} ${dictionary_directory} ${princ_name}/
end=`date +%s`
echo Principal group databases execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#makign the histogram of the sizes of the genomes
start=`date +%s`
hist_size.py --nam intermediate/nums/${princ_name}/cont_final.numfin --des output_files/${princ_name}_sizes_hist.jpg
#this will delete the numbers file as it's not needed anymore
rm intermediate/nums/${princ_name}/cont_final.numfin
end=`date +%s`
echo Concatenating and making the histogram execution time was `expr $end - $start` seconds. >> output_files/time_report.txt

#other group creating databases, making the alignments and counting the size of the genomes for the histogram
start=`date +%s`
find ${other_group_directory} -name '*'.fasta | parallel -P ${num_cores} database_align.sh {} ${vec} ${dictionary_directory} ${other_name}/
end=`date +%s`
echo Other group databases execution time was `expr $end - $start` seconds. >> output_files/time_report.txt


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
rm -r intermediate/

end_fin=`date +%s`
echo Total execution time was `expr $end_fin - $start_fin` seconds. >> output_files/time_report.txt


#moving the output_files directory only if the output directory isn't the current directory
if [ "$(pwd)/" != "${output_dir}" ]
then
	mv output_files/ ${output_dir}
fi