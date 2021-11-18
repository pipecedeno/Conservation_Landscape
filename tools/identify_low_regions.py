#!/usr/bin/python3

'''
This program will identify the regions that are low in a wig file, and will create a file with the start and finish of the
region, the mean of the region and the difference between the number given and the region mean, and it will print in terminal
how many regions are that have a difference in between some values.

What the program does is that using the number lower it checks regions that have a mean value lower than that
if this happens and it's lenght is bigger or equal to the lenght of the kmer used then it's saved as a region, 
and it is not good to report the regions that are smaller to the lenght of the kmer because does points wouldn't
have any biological meaning, because if it's a point mutation then the length of the low region would be of 20 because 
20 kmers will have that point mutation.

Inputs:
--file is the wig file in which the regions are going to be searched.
--lower is the number which the region should be lower to be considered.
--kmer size of the kmer used to produce the wig file.
--nclass is the number of divisions that the final table will have.
'''


import argparse
import statistics

parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-f", "--file",dest="file",required=True) #input file
parser.add_argument("-l", "--lower", dest="lower", required=True) #value the region needs to be lower than
parser.add_argument("-k", "--kmer", dest="kmer", required=True) #kmer size
parser.add_argument("-c", "--nclass", dest="nclass", required=True) #number of division of classes of the differences 
#that is going to be reported at the end
args = parser.parse_args()

list_val=[]

big_value=float(args.lower)

number_classes=int(args.nclass)

start=0
smaller=0
cont=1
file=open(args.file, "r")
output_file=open(args.file.replace(".wig","")+"_low_regions.txt", "w")
for line in file:
	line_split=line.rstrip("\n").split(" ")
	if(line_split[0]=="track" or line_split[0]=="variableStep"):
		continue

	val=float(line_split[1]) #the column 1 is used because that the place of he value in a wig file.
	position=int(line_split[0]) #the column of the position is 0, that is the first column of the wig
	if(val>big_value and start==0):
		start=1

	if(start==1 and val<big_value):
		if(smaller==0):
			list_val=[]
		list_val.append(val)
		if(len(list_val)==1):
			first=position
		smaller=1

	if(start==1 and val>big_value and smaller==1):
		if(len(list_val)>=int(args.kmer)):
			#to report mean value of the region
			#output_file.write(str(first)+"\t"+str(position)+"\t"+str(statistics.mean(list_val))+"\n")
			#to report difference of the mean value of the region
			#output_file.write(str(first)+"\t"+str(position)+"\t"+str(big_value-statistics.mean(list_val))+"\n")
			#This will write in the output_file the start and end of the region, the mean value and the difference to the value 
			#from which the differences are considered.
			output_file.write(str(first)+"\t"+str(position)+"\t"+str(statistics.mean(list_val))+"\t"+str(big_value-statistics.mean(list_val))+"\n")
			cont+=1
		smaller=0

file.close()
output_file.close()

#in this part the clasification of the regions detected is going to be done


vector=[]
cont=0
while (cont<=big_value):
	vector.append(round(cont,3))
	cont+=big_value/number_classes

vec_cont=[]
for i in range(len(vector)-1):
	vec_cont.append(0)


file=open(args.file.replace(".wig","")+"_low_regions.txt", "r")
for line in file:
	if("file_used:" in line):
		continue

	val=float(line.rstrip("\n").split("\t")[3])

	for i in range(len(vector)-1):
		if(vector[i]<val and vector[i+1]>val):
			vec_cont[i]+=1

file.close()

print("lower than\tbigger than\tnumber of regions in this class")
for i in range(len(vector)-1):
	print(vector[i],"\t",vector[i+1],"\t",vec_cont[i])

