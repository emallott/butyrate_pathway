#!/bin/bash -login

##load modules

module load java
module load python
module load uchime
module load hmmer

#### start of configuration

###### Adjust values for these parameters ####
#       SEQFILE, SAMPLE_SHORTNAME
#       WORKDIR, REF_DIR, JAR_DIR, UCHIME, HMMALIGN
#       FILTER_SIZE, MAX_JVM_HEAP, K_SIZE
#       THREADS
#####################

## THIS SECTION MUST BE MODIFIED FOR YOUR FILE SYSTEM. MUST BE ABSOLUTE PATH
## SEQFILE can use wildcards to point to multiple files (fasta, fataq or gz format), as long as there are no spaces in the names
SEQFILE=/projects/p30050/gut_metagenomes/sample.trimmed.fastq.gz
WORKDIR=/projects/p30050/Xander
REF_DIR=/home/ekm9460/rdptools/2.0.2/Xander_assembler
JAR_DIR=/home/ekm9460/rdptools/2.0.2
UCHIME=/software/uchime/4.2.40/uchime
HMMALIGN=/software/hmmer/3.1b2/bin/hmmalign

## THIS SECTION NEED TO BE MODIFIED, SAMPLE_SHORTNAME WILL BE THE PREFIX OF CONTIG ID
SAMPLE_SHORTNAME=sample

## THIS SECTION MUST BE MODIFIED BASED ON THE INPUT DATASETS
## De Bruijn Graph Build Parameters
K_SIZE=45  # kmer size, should be multiple of 3, a kmer size of 42 was used for kal
FILTER_SIZE=35 # memory = 2**FILTER_SIZE, 38 = 32 GB, 37 = 16 GB, 36 = 8 GB, 35 = 4 GB, increase FILTER_SIZE if the bloom filter predicted false positive rate is greater than 1%
MAX_JVM_HEAP=24G # memory for java program, must be larger than the corresponding memory of the FILTER_SIZE
MIN_COUNT=2  # minimum kmer abundance in SEQFILE to be included in the final de Bruijn graph structure

## number of threads to use for find starting kmer step and kmer coverage mapping step
THREADS=1

## Contig Search Parameters
PRUNE=20 # prune the search if the score does not improve after n_nodes (default 20, set to -1 to disable pruning)
PATHS=1 # number of paths to search for each starting kmer, default 1 returns the shortest path
LIMIT_IN_SECS=100 # number of seconds a search allowed for each kmer, recommend 100 secs if PATHS is 1, need to increase if PATHS is large 

## Contig Merge Parameters
MIN_BITS=50  # mimimum assembled contigs bit score, 30 was used for kal
MIN_LENGTH=150  # minimum assembled protein contigs, 90 was used for kal

## Contig Clustering Parameters
DIST_CUTOFF=0.01  # cluster at aa distance 

NAME=${SAMPLE_SHORTNAME}_k${K_SIZE}

#### end of configuration

