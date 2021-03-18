#!/bin/bash

while getopts ":hr:f:s:d:g:e:" option
do
case "${option}"
in
h)
	echo "Usage: tables_low_region.sh [options]"
	echo "	-h Display this message."
	echo "	-r This is the file of the regions that was created with identify_low_regions.py."
	echo "	-f The wig file of the first group that is going to be used."
	echo "	-s The wig file of the second group that is going to be used."
	echo "	-d The value the difference should be bigger to create the contingency table."
	echo "	-g The number of genomes in the first group (the one indicated by -f)"
	echo "		This option can be a number or the directory of the first group so the program counts the genomes."
	echo "	-e The number of genomes in the second group (the one indicated by -s)"
	echo "		This option can be a number or the directory of the second group so the program counts the genomes."
	exit 0
	;;
r) regions_file=${OPTARG};;
f) first_wig=${OPTARG};;
s) second_wig=${OPTARG};;
d) difference=${OPTARG};;
g) genome1=${OPTARG};;
e) genome2=${OPTARG};;
:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
\? )
	echo "Invalid Option: -$OPTARG" 1>&2
    echo "Please try using -h to get information of the usage of this program."
    exit 1
    ;;
esac
done

if [ -z "$regions_file" ]
then 
	echo "-r option is empty"
	exit
fi

if [ -z "$first_wig" ]
then 
	echo "-f option is empty"
	exit
fi

if [ -z "$second_wig" ]
then 
	echo "-s option is empty"
	exit
fi

if [ -z "$difference" ]
then 
	echo "-d option is empty"
	exit
fi

if [ -z "$genome1" ]
then 
	echo "-g option is empty"
	exit
else
	if [ -d "$genome1" ]
	then
		num_genome1=$( ls ${genome1} | wc -l)
	else
		num_genome1=${genome1}
	fi
fi

if [ -z "$genome2" ]
then 
	echo "-e option is empty"
	exit
else
	if [ -d "$genome2" ]
	then
		num_genome2=$( ls ${genome2} | wc -l)
	else
		num_genome2=${genome2}
	fi
fi

tables_low_region.py -r ${regions_file} -f ${first_wig} -s ${second_wig} -d ${difference} -g ${num_genome1} -e ${num_genome2}
