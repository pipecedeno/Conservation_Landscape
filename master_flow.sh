#!/bin/bash

#This program is for selecting which of the 2 flows is going to be used and it checks that the inputs
#are the correct for the flow selected

while getopts ":h" opt; do
  case ${opt} in
    h )
    	echo "Usage:"
    	echo "    -h                      Display this help message."
    	echo "    two_groups [options]"
    	echo "    many_groups [options]"
    	echo ""
    	echo "Usage of option two_groups: "
		echo "	-h Display this message."
		echo "	-c The group of interest directory."
		echo "	-n The other group directory."
		echo "	-r The reference_genome fasta file."
		echo "	-s (Optional) If given it is the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23."
		echo "		If not given the sizes are going to be from 20 to 25."
		echo "	-p (Optional) Is the number of cores/threads that is gonna be used, if not given 1 is going to be used."
	    echo "	-o Is the place where the directory with the output files is going to be saved"
	    echo ""
	    echo "Usage of option many_groups: "
		echo "	-m The directory that contains the directory of each group that is going to be used."
		echo "	-r The reference genome fasta file."
		echo "	-s (Optional) If given it is the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23."
		echo "		If not given the sizes are going to be from 20 to 25."
		echo "	-p Is the number of cores/threads that is gonna be used, if not given 1 is going to be used."
	    echo "	-o Is the place where the directory with the output files is going to be saved"
	    echo ""
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

    # Process options
    while getopts ":hc:n:r:s:p:o:" option
    do
	case "${option}"
	in
	h)
		echo "Usage of option two_groups: "
		echo "	-h Display this message."
		echo "	-c The group of interest directory."
		echo "	-n The other group directory."
		echo "	-r The reference_genome fasta file."
		echo "	-s (Optional) If given it is the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23."
		echo "		If not given the sizes are going to be from 20 to 25."
		echo "	-p (Optional) Is the number of cores/threads that is gonna be used, if not given 1 is going to be used."
		echo "	-o Is the place where the directory with the output files is going to be saved"
		exit 0
		;;
	c) princ_group_dir=${OPTARG};;
	n) other_group_dir=${OPTARG};;
	r) reference_genome=${OPTARG};;
	s) vec=${OPTARG};;
	p) num_cores=${OPTARG};;
	o) output_dir=${OPTARG};;
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

	# Process options
	while getopts ":hm:r:s:p:o:" option
	do
	case "${option}"
	in
	h)
		echo "Usage of option many_groups: "
		echo "	-m The directory that contains the directory of each group that is going to be used."
		echo "	-r The reference genome fasta file."
		echo "	-s (Optional) If given it is the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23."
		echo "		If not given the sizes are going to be from 20 to 25."
		echo "	-p Is the number of cores/threads that is gonna be used, if not given 1 is going to be used."
		echo "	-o Is the place where the directory with the output files is going to be saved"
		exit 0
		;;
	m) groups_directory=${OPTARG};;
	r) reference_genome=${OPTARG};;
	s) vec=${OPTARG};;
	p) num_cores=${OPTARG};;
	o) output_dir=${OPTARG};;
	:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
	\? )
     echo "Invalid Option: -$OPTARG" 1>&2
     echo "Please try using -h to get information of the usage of this program."
     exit 1
	esac
	done
	;;
esac
#echo "two_groups_flag: ${two_groups_flag}"
#echo "many_groups_flag: ${many_groups_flag}"

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
		#if [ "${princ_group_dir: -1}" != "/" ]
		#then
			#princ_group_dir+="/"
		#fi
		temp=$(realpath ${princ_group_dir})
		princ_group_dir=${temp}"/"
	fi

	if [ -z "$other_group_dir" ]
	then 
		echo "-n option is empty"
		exit
	else
		#if [ "${other_group_dir: -1}" != "/" ]
		#then
			#other_group_dir+="/"
		#fi
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

	two_groups_flow.sh -c ${princ_group_dir} -n ${other_group_dir} -r ${reference_genome} -s ${vec} -p ${num_cores} -o ${output_dir}
fi

if [ "$many_groups_flag" -eq "1" ]
then
	echo "many groups flow is going to be used."
	if [ -z "$groups_directory" ]
	then 
		echo "-m option is empty"
		exit
	else
		#if [ "${groups_directory: -1}" != "/" ]
		#then
		#	groups_directory+="/"
		#fi
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

	many_groups_flow.sh -m ${groups_directory} -r ${reference_genome} -s ${vec} -p ${num_cores} -o ${output_dir}
fi