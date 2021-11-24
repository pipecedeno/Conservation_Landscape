#!/bin/bash

######
# Date: 17/Nov/2021
# Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
# version: 1.1
# 1.1: added an option to delete or not the intermediate directory.

# Program Description:
# This program can be used to compare the conservation of 2 or more groups of genomes based on a reference
# genome and it will create a directory with wig files which are text files that can be used by different 
# visualization tools to see a graph of the conservation.
# This program is used for selecting which of the 2 flows is going to be used (if it's going to use two groups 
# or more) and it checks that the inputs are the correct for the flow selected

# Usage:
#     -h                      Display this help message.
#     two_groups [options]
#     many_groups [options]

# Usage of option two_groups: 
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

# Usage of option many_groups: 
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


print_all_usage(){
	echo "Usage:"
    	echo "    -h                      Display this help message."
    	echo "    two_groups [options]"
    	echo "    many_groups [options]"
    	echo ""
    	print_two_usage
    	echo ""
    	print_many_usage
    	echo ""
}

print_two_usage() {
		echo "Usage of option two_groups: "
		echo "	-h Display this message."
		echo "	-c The group of interest directory."
		echo "	-n The other group directory."
		echo "	-r The reference_genome fasta file."
		echo "	-s (Optional) If given it is the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23."
		echo "		If not given the sizes are going to be from 20 to 25."
		echo "	-p (Optional) Is the number of cores/threads that is gonna be used, if not given 1 is going to be used."
		echo "	-o Is the place where the directory with the output files is going to be saved"
		echo "	-x Do not fill the gaps of kmers with N in the groups of interest."
		echo "	-y Do not fill the gaps of kmers with N in the other group."
		echo "	-d If this flag is used the intermediate folder won't be deleted"
}

print_many_usage() {
		echo "Usage of option many_groups: "
		echo "	-m The directory that contains the directory of each group that is going to be used."
		echo "	-r The reference genome fasta file."
		echo "	-s (Optional) If given it is the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23."
		echo "		If not given the sizes are going to be from 20 to 25."
		echo "	-p Is the number of cores/threads that is gonna be used, if not given 1 is going to be used."
		echo "	-o Is the place where the directory with the output files is going to be saved"
		echo "	-d If this flag is used the intermediate folder won't be deleted"
}

while getopts ":h" opt; do
  case ${opt} in
    h )
	  	print_all_usage
	    exit 0
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     echo "Please try using -h to get information of the usage of this program."
     exit 1
     ;;
  esac
done
		

two_groups_flag=0
many_groups_flag=0

subcommand=$1; shift

case "$subcommand" in
  # Parse options to the two_groups sub command
  two_groups)
  two_groups_flag=1  # Remove 'two_groups' from the argument list

  #added flags to fill the gaps or not of the conservative track
  normal_process_princ='false'
  normal_process_other='false'

  #flag to know if intermediate should be deleted or not
  delete_intermediate='true'

  # Process options
  while getopts ":hc:n:r:s:p:o:xyd" option
  do
	case "${option}"
	in
	h)
		print_two_usage
		exit 0
		;;
	c) princ_group_dir=${OPTARG};;
	n) other_group_dir=${OPTARG};;
	r) reference_genome=${OPTARG};;
	s) vec=${OPTARG};;
	p) num_cores=${OPTARG};;
	o) output_dir=${OPTARG};;
	x) normal_process_princ='true';;
	y) normal_process_other='true';;
	d) delete_intermediate='false';;
	:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
	\? )
     echo "Invalid Option: -$OPTARG" 1>&2
     echo "Please try using -h to get information of the usage of this program."
     exit 1
	esac
	done
    ;;
  many_groups)
	many_groups_flag=1  # Remove 'many_groups' from the argument list

	#flag to know if intermediate should be deleted or not
  delete_intermediate='true'

	# Process options
	while getopts ":hm:r:s:p:o:d" option
	do
	case "${option}"
	in
	h)
		print_many_usage
		exit 0
		;;
	m) groups_directory=${OPTARG};;
	r) reference_genome=${OPTARG};;
	s) vec=${OPTARG};;
	p) num_cores=${OPTARG};;
	o) output_dir=${OPTARG};;
	d) delete_intermediate='false';;
	:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
	\? )
     echo "Invalid Option: -$OPTARG" 1>&2
     echo "Please try using -h to get information of the usage of this program."
     exit 1
	esac
	done
	;;
esac

if [ "$two_groups_flag" -eq "0" ] && [ "$many_groups_flag" -eq "0" ]
then
	echo "No option was given, please try using -h to get information of the usage of this program."
	exit
fi

#Selecting which of the two flows is going to be executed
if [ "$two_groups_flag" -eq "1" ]
then
	echo "two groups flow selected."

	if [ -z "$princ_group_dir" ]
	then 
		echo "-c option is empty"
		exit
	else
		temp=$(realpath ${princ_group_dir})
		princ_group_dir=${temp}"/"
	fi

	if [ -z "$other_group_dir" ]
	then 
		echo "-n option is empty"
		exit
	else
		temp=$(realpath ${other_group_dir})
		other_group_dir=${temp}"/"
	fi

	if [ -z "$reference_genome" ]
	then 
		echo "-r option is empty"
		exit
	else
		reference_genome=$(realpath ${reference_genome})
	fi

	if [ -z "$num_cores" ]
	then 
		echo "no selected number of cores so 1 is going to be used by default"
		num_cores=1
	fi

	if [ -z "$vec" ]
	then 
		echo "no size selected, default sizes are going to be used"
		vec=20,21,22,23,24,25
	fi

	if [ -z "$output_dir" ]
	then
		echo "-o option is empty"
		exit
	else
		output_dir=$(realpath ${output_dir})"/"
	fi

	two_groups_flow.sh -c ${princ_group_dir} -n ${other_group_dir} -r ${reference_genome} -s ${vec} -p ${num_cores} -o ${output_dir} -x ${normal_process_princ} -y ${normal_process_other} -d ${delete_intermediate}
fi

if [ "$many_groups_flag" -eq "1" ]
then
	echo "many groups flow is going to be used."
	if [ -z "$groups_directory" ]
	then 
		echo "-m option is empty"
		exit
	else
		temp=$(realpath ${groups_directory})
		groups_directory=${temp}"/"
	fi

	if [ -z "$reference_genome" ]
	then 
		echo "-r option is empty"
		exit
	else
		reference_genome=$(realpath ${reference_genome})
	fi

	if [ -z "$num_cores" ]
	then 
		echo "no selected number of cores so 1 is going to be used by default"
		num_cores=1
	fi

	if [ -z "$vec" ]
	then 
		echo "no size selected, default sizes are going to be used"
		vec=20,21,22,23,24,25
	fi

	if [ -z "$output_dir" ]
	then
		echo "-o option is empty"
		exit
	else
		output_dir=$(realpath ${output_dir})"/"
	fi

	many_groups_flow.sh -m ${groups_directory} -r ${reference_genome} -s ${vec} -p ${num_cores} -o ${output_dir} -d ${delete_intermediate}
fi