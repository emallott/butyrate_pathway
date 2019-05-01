#!/bin/bash

#MSUB -N xxxx_framebot
#MSUB -A b1042
#MSUB -m abe
#MSUB -M elizabeth.mallott@northwestern.edu
#MSUB -l nodes=1:ppn=2,mem=10gb
#MSUB -l walltime=48:00:00
#MSUB -j oe
#MSUB -q genomicsguest

#Set up your environment

unset LD_LIBRARY_PATH
module load java/jdk1.6.0_32

RDPToolsDir=/home/ekm9460/rdptools/2.0.2/

#Name some variables

gene=atoA ##this is the only thing you will have to modify prior to running the script
gene_ref_file=/projects/b1057/marius_databases/${gene}_ref.fasta

#Run framebot, using the proteins from the original database as references, and move the results into the fb_out directory

mkdir /projects/b1057/framebot/$gene/fb_out
for f in $(ls /projects/b1057/framebot/$gene/explode-mappings/*.fasta)
do
d=${f/explode-mappings\//}
d=${d/.fasta/}
java -Xmx8g -jar $RDPToolsDir/FrameBot.jar framebot -o $d ${gene_ref_file}.index $f
mv $d*.* /projects/b1057/framebot/$gene/fb_out
done

#Copy the framebot protein output into the fb_corr_prot directory

mkdir /projects/b1057/framebot/$gene/fb_corr_prot
cp /projects/b1057/framebot/$gene/fb_out/*corr_prot.fasta /projects/b1057/framebot/$gene/fb_corr_prot
