# Conservation_Landscape
## master_flow

## Software requirements:
Linux based operating System.

## Prerequisites:
* python 3.8 This can be installed from here: https://www.python.org/
Or more information could be found here: https://docs.python-guide.org/starting/install3/linux/
* matplotlib 3.3.2 This can be installed from here https://matplotlib.org/stable/users/installing.html
* biopython 1.78 This can be installed from here: https://biopython.org/wiki/Download
* bowtie2 2.4.2 This can be installed from here: https://sourceforge.net/projects/bowtie-bio/

## How to Download this Repository

## Add to path
This step is completely necessary for the program to work.

And it can be done using the following command:

```bash
export PATH=$PATH:(full path of the directory)
```

And the full path of the directory could be obtained using pwd.

## Program usage
The program has 2 options: two_groups and many_groups.

### two_groups usage

Example:

```bash
master_flow.sh two_groups -c virus_genome_directory/ -n non_virus_directory/ -r reference_genome/reference.fasta -s 20,21,22 -p 10
```

Options:
-h Displays help message.
-c The directory of the group of interest.
-n The other group directory.
-r The file of the reference genome (.fasta file).
-s (Optional) If given it’s the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23. If not given the sizes for default are going to be from 20 to 25. 
-p (Optional) Is the number of cores/threads that are going to be used, if not given 1 is going to be used.
-o Is the place where the directory with the output files is going to be saved

### many_groups usage

Example:

```bash
master_flow.sh many_groups -m genomes_directory/ -r reference_genome/reference.fasta -s 21,22 -p 4
```
Options:
-h Displays help message.
 -m The directory that contains only the directory of each group that is going to be used.
-r The file of the reference genome (fasta file).
-s (Optional) If given it’s the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23. If not given the sizes for default are going to be from 20 to 25.
-p (Optional) Is the number of cores/threads that are going to be used, if not given 1 is going to be used.
-o Is the place where the directory with the output files is going to be saved

Note: master_flow.sh -h will display a help message with the information of the 2 flows. 
And it’s important that in the directories of the fasta files of each group all the fasta files have the “.fasta” termination.

## create_genomeview_session

### Prerequisites:
java 7+ It can be installed using this instructions: https://phoenixnap.com/kb/how-to-install-java-ubuntu
Or using this ones:
https://openjdk.java.net/install/

### Usage
Example: 

```bash
create_genomeview_session.sh -r reference_genome.fasta -f output_files/ -s test_session.gvs 
```

Options:
-h Display this message
-r Reference genome file
-f Directory where the wig files are located
-s Name of the session file that is going to be made (Use the .gvs termination in the name)

Note: the session file and the .tdf files that are needed for genomeview will be saved in the same directory where the wig files are located.

This program uses the java programs necessary to pass the wig file to the .tdf that the genomeview needs to load the information. And the information of the software can be found here:
The url of the genomeview is currently working, but it will added when it's available.

