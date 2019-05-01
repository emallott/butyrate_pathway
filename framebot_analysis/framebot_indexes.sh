#!/bin/bash
while read P1

do
	JOB=`msub - << EOJ


#MSUB -N framebot_indexes
#MSUB -A b1042
#MSUB -m abe
#MSUB -M elizabeth.mallott@northwestern.edu
#MSUB -l nodes=1:ppn=4
#MSUB -l walltime=12:00:00
#MSUB -j oe
#MSUB -q genomicsguest

unset LD_LIBRARY_PATH
module load java/jdk1.6.0_32

java -Xmx4g -jar /home/ekm9460/rdptools/2.0.2/FrameBot.jar index /projects/b1057/reference_databases/${P1} /projects/b1057/reference_databases/${P1}.index

EOJ
`

echo "JobID = ${JOB} for file ${P1} submitted on `date`"
done < params.txt
sleep 5
exit

