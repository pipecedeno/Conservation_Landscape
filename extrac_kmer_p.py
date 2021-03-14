'''
This program is for obtaining the kmers of a fasta file and make a output file where the header
of each kmer is it's position in the genome file.
--file is the file from the kmers are going to be extracted
--output is the name of the output file
--kmer is the size of the kmer that is going to be saved in the output file
--window is the space between each kmer that is gonna be saved
'''
import argparse
parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-f", "--file", dest="file", required=True) #file
parser.add_argument("-o", "--output", dest="output", required=True) #name of the output file
parser.add_argument("-k", "--kmer", dest="kmer", required=True) #Kmer size
parser.add_argument("-w", "--window", dest="window", required=True) #window
args = parser.parse_args()

size=int(args.kmer)
window=int(args.window)

cont=1
kmer_string=""

resp=open(args.output, "w")

file=open(args.file, "r")
for line in file:
	kmer_temp=line.rstrip("\n")

	if(kmer_temp[0]==">"):
		continue

	kmer_string+=kmer_temp

	while(len(kmer_string)>size):
		resp.write(">"+str(cont)+"\n"+kmer_string[0:size]+"\n")
		kmer_string=kmer_string[window:]
		cont+=window

file.close()
resp.close()
