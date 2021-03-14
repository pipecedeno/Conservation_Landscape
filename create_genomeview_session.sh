#!/bin/bash

#This program is for creating the session files so it woulb de easier to open all the files created by
#the flow in GenomeView

while getopts ":hr:f:s:" option
do
case "${option}"
in
h)
	echo "Usage: create_genomeview_session.sh [options]"
	echo "	-h Display this message"
	echo "	-r Reference genome file"
	echo "	-f Directory where the wig files are located"
	echo "	-s Name of the session file that is going to be made (Use the .gvs termination in the name)"
	exit 0
	;;
r) reference_genome=${OPTARG};;
f) files_directory=${OPTARG};;
s) session_name=${OPTARG};;
:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
\? )
	echo "Invalid Option: -$OPTARG" 1>&2
    echo "Please try using -h to get information of the usage of this program."
    exit 1
    ;;
esac
done

if [ -z "$files_directory" ]
then 
	echo "-f option is empty"
	exit
else
	files_directory=$(realpath ${files_directory})"/"
	echo "${files_directory}"
fi

if [ -z "$reference_genome" ]
then 
	echo "-r option is empty"
	exit
fi

if [ -z "$session_name" ]
then 
	echo "-s option is empty"
	exit
fi

find ${files_directory} -name '*'.wig | parallel -P 1 java -jar wig2tdf.jar {}

echo "##GenomeView session       ##" >> ${files_directory}${session_name}
echo "##Do not remove header lines##" >> ${files_directory}${session_name}

echo "DATA:$(realpath ${reference_genome})" >> ${files_directory}${session_name}

FILES=$(find ${files_directory} -name '*'.tdf)

for file in $FILES
do
	echo "DATA:$(realpath ${file})" >> ${files_directory}${session_name}
done
