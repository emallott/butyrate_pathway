#!/bin/bash
while read P1

do
	JOB=`msub - << EOJ

#MSUB -N xander
#MSUB -A b1042
#MSUB -m abe
#MSUB -M elizabeth.mallott@northwestern.edu
#MSUB -l nodes=1:ppn=1,mem=24gb
#MSUB -l walltime=10:00:00
#MSUB -j oe
#MSUB -q genomicsguest

/home/ekm9460/rdptools/2.0.2/Xander_assembler/bin/run_xander_skel.sh /home/ekm9460/${P1} "build find search" "4hbt abfD abfH atoA atoD bcd bhbd buk but cro etfA etfB gcdA gcdB gctA gctB hgCoAdA hgCoAdB hgCoAdC kamA kamD kamE kce kdd pyrG recA rplB thl"

EOJ
`

echo "JobID = ${JOB} for file ${P1} submitted on `date`"
done < params.txt
sleep 5
exit

