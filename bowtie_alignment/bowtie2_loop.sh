#!/bin/bash
while read P1

do
JOB=`msub - << EOJ


#MSUB -N bowtie2_${P1}
#MSUB -A b1042
#MSUB -m abe
#MSUB -M elizabeth.mallott@northwestern.edu
#MSUB -l nodes=1:ppn=4
#MSUB -l walltime=48:00:00
#MSUB -j oe
#MSUB -q genomicsguest

#Set up your environment

unset LD_LIBRARY_PATH
module load bowtie2

bowtie2 -x All_nucl_new_derep -U /projects/p30050/gut_metagenomes/${P1}_trimmed.fastq --very-sensitive -p 4 -S /projects/b1057/bowtie2out/${P1}.sam

EOJ
`

echo "JobID = ${JOB} for file ${P1} submitted on `date`"
done < params.txt
sleep 5
exit
