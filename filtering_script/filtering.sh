#!/bin/bash

#This script is based on John Quensen's workflow (https://john-quensen.com/workshops/workshop-2/command-line-fungene-pipeline/)

#Set up your environment

export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
RDPToolsDir=/<path>/RDPTools/
hmmalign=hmmalign
usearch=./usearch8 #you specifically need to use USEARCH v.8 as this is the last version that will allow you to export non-chimeras

#Name some variables

gene=atoA ##this is the only thing you will have to modify prior to running the script
hmmfile=/<path to hmm file>/$gene.hmm
gene_ref_file=/<path to gene nucleotide reference file>/${gene}_ref.fasta
uchimefile=/<path to hmm seed file>/${gene}_nucl.seeds
outputdir=/<path to output directory>/

#Dereplicate the sequences, combine, add size info, and sort

java -Xmx4g -jar $RDPToolsDir/Clustering.jar derep -u -s -o /$outputdir/$gene/derep.fa /$outputdir/$gene/all_seqs.ids /$outputdir/$gene/all_seqs.samples /$outputdir/$gene/*.fasta

echo "Dereplication complete"

#Remove the spaces from fasta IDs so that uchime will run

cat /$outputdir/$gene/derep.fa | sed 's/ //g' > /$outputdir/$gene/derep_no_space.fa

#Run uchime using nucleotide seed sequences for each gene from the original database

$usearch -uchime_ref /$outputdir/$gene/derep_no_space.fa -db $uchimefile -nonchimeras /$outputdir/$gene/nc.fasta -strand plus

echo "Chimera filtering complete"

#Put the spaces back into the fasta IDs

cat /$outputdir/$gene/nc.fasta | sed 's/;/  ;/' > /$outputdir/$gene/nc_with_space.fasta

#Refresh the mappings

java -Xmx4g -jar $RDPToolsDir/Clustering.jar refresh-mappings /$outputdir/$gene/nc_with_space.fasta /$outputdir/$gene/all_seqs.ids /$outputdir/$gene/all_seqs.samples /$outputdir/$gene/filtered_all_seq.ids /$outputdir/$gene/filtered_all_seq.samples

echo "Mappings refreshed"

#Explode the sequences back into individual samples

mkdir /$outputdir/$gene/explode-mappings

java -Xmx4g -jar $RDPToolsDir/Clustering.jar explode-mappings -o /$outputdir/$gene/explode-mappings /$outputdir/$gene/filtered_all_seq.ids /$outputdir/$gene/filtered_all_seq.samples /$outputdir/$gene/nc_with_space.fasta

echo "Samples exploded"

#Copy the nucleotide sequences for each gene from the original database into the merged folder so that they are included in all subsequent analyses

cp $gene_ref_file /$outputdir/$gene/explode-mappings/

#Run framebot, using the proteins from the original database as references, and move the results into the fb_out directory

mkdir /$outputdir/$gene/fb_out
for f in $(ls /$outputdir/$gene/explode-mappings/*.fasta)
do
d=${f/explode-mappings\//}
d=${d/.fasta/}
java -Xmx4g -jar $RDPToolsDir/FrameBot.jar framebot -o $d ${gene_ref_file}.index $f
mv $d*.* /$outputdir/$gene/fb_out
done

#Copy the framebot protein output into the fb_corr_prot directory

mkdir /$outputdir/$gene/fb_corr_prot
cp /$outputdir/$gene/fb_out/*corr_prot.fasta /$outputdir/$gene/fb_corr_prot

echo "Framebot analysis complete"

#Align the corrected protein sequences using HMMER

mkdir /$outputdir/$gene/hmm_aligned
for f in $(ls /$outputdir/$gene/fb_corr_prot/*.fasta)
do
d=${f/fb_corr_prot\//}
echo $d
d=${d/_corr_prot/}
echo $d
d=${d/.fasta/}
echo $d
$hmmalign --allcol -o $d.stk $hmmfile $f
mv $d.stk /$outputdir/$gene/hmm_aligned
done

echo "HMMER alignment complete"

#Merge the alignments

mkdir /$outputdir/$gene/merged_alignment
java -Xmx4g -jar $RDPToolsDir/AlignmentTools.jar alignment-merger /$outputdir/$gene/hmm_aligned /$outputdir/$gene/merged_alignment/merged_alignment.fasta

echo "Alignments merged"

#Cluster, step 1, dereplicate

java -Xmx4g -jar $RDPToolsDir/Clustering.jar derep -m '#=GC RF' -o /$outputdir/$gene/merged_alignment/derep.fa /$outputdir/$gene/merged_alignment/all_seqs.ids /$outputdir/$gene/merged_alignment/all_seqs.samples /$outputdir/$gene/hmm_aligned/*.stk

echo "Alignments dereplicated"

#Cluster, step 2, make distance matrix

java -Xmx4g -jar $RDPToolsDir/Clustering.jar dmatrix --id-mapping /$outputdir/$gene/merged_alignment/all_seqs.ids -in /$outputdir/$gene/merged_alignment/derep.fa --outfile /$outputdir/$gene/merged_alignment/derep_matrix.bin --dist-cutoff 0.05

echo "Distance matrix calculated"

#Cluster, step 3, actually cluster

java -Xmx4g -jar $RDPToolsDir/Clustering.jar cluster --dist-file /$outputdir/$gene/merged_alignment/derep_matrix.bin --id-mapping /$outputdir/$gene/merged_alignment/all_seqs.ids --sample-mapping /$outputdir/$gene/merged_alignment/all_seqs.samples --method complete --outfile /$outputdir/$gene/merged_alignment/all_seq_complete.clust

echo "Clustering complete"
 
#Obtain the representative sequences

java -Xmx4g -jar $RDPToolsDir/Clustering.jar cluster-to-biom /$outputdir/$gene/merged_alignment/all_seq_complete.clust 0.05 > /$outputdir/$gene/merged_alignment/all_seq_complete.biom

java -Xmx4g -jar $RDPToolsDir/Clustering.jar rep-seqs -c -o /$outputdir/$gene/merged_alignment/ --id-mapping /$outputdir/$gene/merged_alignment/all_seqs.ids --one-rep-per-otu /$outputdir/$gene/merged_alignment/all_seq_complete.clust 0.05 /$outputdir/$gene/merged_alignment/merged_alignment.fasta

echo "Representative sequences obtained"


