#!/bin/bash
while read P1

do
	JOB=`msub - << EOJ


#MSUB -N trim
#MSUB -A b1042
#MSUB -m abe
#MSUB -M elizabeth.mallott@northwestern.edu
#MSUB -l nodes=1:ppn=4
#MSUB -l walltime=06:00:00
#MSUB -j oe
#MSUB -q genomicsguest

unset LD_LIBRARY_PATH
module load java

java -jar /home/ekm9460/trimmomatic/0.33/trimmomatic-0.33.jar SE -threads 4 -phred33 /projects/p30050/gut_metagenomes/${P1}.fastq.gz /projects/p30050/gut_metagenomes_trimmed/${P1}.trimmed.fastq.gz ILLUMINACLIP:/home/ekm9460/TruSeq3-SE.fa:2:30:10 AVGQUAL:20 MINLEN:70

EOJ
`

echo "JobID = ${JOB} for file ${P1} submitted on `date`"
done < params.txt
sleep 5
exit

