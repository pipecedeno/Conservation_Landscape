
Test Data Example

The program of cov_dif.sh has two different flows:
-two_groups
-many_groups 
So here are two examples of commands, one for each flow.

Example for two_groups

For this example the following command was executed:

cov_dif.sh two_groups -c genomes/gh/ -n genomes/l/ -r reference_genome/covid_reference.fasta -s 20 -p 1 -o test_twogroups

The option two_groups is used to specify this flow.
-c is used to indicate the directory of the clade gh of covid, which in this case has only 3 genomes.
-n is used to indicate the directory of the clade l of covid, and in this case there are only 4 genomes in that directory.
-r is for the reference genome file.
-s indicates that only the size 20 of the kmer is going to be processed instead of the default of 20 to 25.
-p this option is used to indicate that only a core is going to be used, as in this case only a few genomes are ging to be processed.
-o indicates the output directory that is going to be created to store the information.

This command is going to take less than 30 seconds to execute and the output is going to be the same that is in the folder of test_output/test_twogroups. In this directory there is going to be the wig files and some images of the histograms of the sizes of the genomes of each group.
The wig files are going to be 3 differents, the gh_ wigs, that show the conservation of the gh clade genomes against the reference genome, the l_ wigs, that show the conservation of the l genomes against the refrerence genome, and the diff_ wig, which have the difference of conservation between gh and l, so if a value is bigger than 1 is that those kmers are only present in the gh clade, and if there's a value of -1 those kmers are specific of the l clade.
Also in the direcotory there's an image called "twogroups_example_15900_21900.png", which is a photo from the genome browser igv which shows how this wig files can be visualized, and using any browser more information can be used to get a better understanding of the information as annotation can be uploaded too.

Example for many_groups

For this example the following command was executed:

cov_dif.sh many_groups -m genomes/ -r reference_genome/covid_reference.fasta -s 20 -p 1 -o test_manygroups

The options used in this command are the following.
-m indicates the directory were the directory of each group is saved. This directory is importan that it follows a structure were the directory given to the program only has inside the amount of groups that are going to be processed (each being a directory) and in the directory of each group there are only the .fasta files.
-r is for the reference genome file.
-s indicates that only the size 20 of the kmer is going to be processed instead of the default of 20 to 25.
-p this option is used to indicate that only a core is going to be used, as in this case only a few genomes are ging to be processed.
-o indicates the output directory that is going to be created to store the information.

In the output directory of the program there is going to be 3 files for each group that was in the input directory and the diff tracks.
And as in the two_group example an image of the visualization was added.


In the two flows also a file called time_report.txt is added were it has the inputs given to the program, which is importantif the programs needs to be runned again with the same inputs.
