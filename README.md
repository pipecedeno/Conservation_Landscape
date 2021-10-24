# CovDif
## master_flow

## Software requirements:
Linux based operating System.

## Prerequisites:
* python 3.8 This can be installed from here: https://www.python.org/
Or more information could be found here: https://docs.python-guide.org/starting/install3/linux/
* matplotlib 3.3.2 This can be installed from here https://matplotlib.org/stable/users/installing.html
* biopython 1.78 This can be installed from here: https://biopython.org/wiki/Download
* razers 3.5.8 (seqan 2.4.0) Can be installed from: https://github.com/seqan/seqan/tree/master/apps/razers3

## How to Download this Repository
Use the following command in the desired directory:  

```bash
git clone https://github.com/pipecedeno/Conservation_Landscape.git
```
When you download the repository make sure to give execution permission to the bash and python files. This can be done with the following commands if you are located in the programs directory in your computer:

```bash
chmod +x *.sh
chmod +x *.py
```

## Add to path
This step is completely necessary for the program to work.

This intructions were obtaine from https://gist.github.com/nex3/c395b2f8fd4b02068be37c961301caa7

1.- Open the .bashrc file in your home directory (for example, /home/your-user-name/.bashrc) in a text editor.
2.- Add export PATH=$PATH:your-dir to the last line of the file, where your-dir is the directory you want to add.
3.- Save the .bashrc file.
4.- Restart your terminal.

And to test if the path was added after restarting the terminal you can use echo $PATH, to see if the directory is there.

## Program usage
The program has 2 options: two_groups and many_groups.

### two_groups usage

Example:

```bash
cov_dif.sh two_groups -c virus_genome_directory/ -n non_virus_directory/ -r reference_genome/reference.fasta -s 20,21,22 -p 10
```

Options:  
-h Displays help message.  
-c The directory of the group of interest.  
-n The other group directory.  
-r The file of the reference genome (.fasta file).  
-s (Optional) If given it’s the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23. If not given the sizes for default are going to be from 20 to 25.  
-p (Optional) Is the number of cores/threads that are going to be used, if not given 1 is going to be used.  
-o Is the place where the directory with the output files is going to be saved 
-x Do not fill the gaps of kmers with N in the groups of interest.
-y Do not fill the gaps of kmers with N in the other group.

### many_groups usage

Example:

```bash
cov_dif.sh many_groups -m genomes_directory/ -r reference_genome/reference.fasta -s 21,22 -p 4
```
Options:  
-h Displays help message.  
 -m The directory that contains only the directory of each group that is going to be used.  
-r The file of the reference genome (fasta file).  
-s (Optional) If given it’s the sizes in which the program will use, the sizes must be separated by commas. Example: 20,21,23. If not given the sizes for default are going to be from 20 to 25.  
-p (Optional) Is the number of cores/threads that are going to be used, if not given 1 is going to be used.  
-o Is the place where the directory with the output files is going to be saved, if you want it to be saved in your current director you can use ".".  

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
http://genomeview.org/manual/Wig2tdf

