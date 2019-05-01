#!/bin/bash
while read P1

do
JOB=`msub - << EOJ


#MSUB -N samtools_${P1}
#MSUB -A b1042
#MSUB -m abe
#MSUB -M elizabeth.mallott@northwestern.edu
#MSUB -l nodes=1:ppn=4
#MSUB -l walltime=48:00:00
#MSUB -j oe
#MSUB -q genomicsguest

#Set up your environment

unset LD_LIBRARY_PATH
module load samtools/0.1.19

samtools view -S -F 4 -o /projects/b1057/samtools_output/${P1} /projects/b1057/bowtie2out/${P1}

EOJ
`

echo "JobID = ${JOB} for file ${P1} submitted on `date`"
done < params.txt
sleep 5
exit
