#!/bin/bash
#SBATCH --array 0-7 #ADJUST THIS TO THE NUMBER OF SAMPLES (EACH SAMPLE HAS A FORWARD READ FILE AND A REVERSE READ FILE)
#SBATCH --partition largemem
#SBATCH --time=24:00:00
#SBATCH --job-name=readQC
#SBATCH --mail-user=email@address.com #CHANGE EMAIL TO YOUR EMAIL
#SBATCH --mail-type=ALL
#SBATCH --ntasks 1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=12
#SBATCH --error=readQC_%A_%a.err
#SBATCH --output=readQC_%A_%a.out

#ACTIVATE THE MAMBA ENVIRONMENT
eval "$(mamba shell hook --shell bash)"
mamba activate readQC #CHANGE ENVIRONMENT NAME TO MATCH WHATEVER YOU NAMED YOUR PYTHON ENVIRONMENT

#PREPARE FILE NAMES AND PATHWAYS
readFOFN=aviti_reads.fofn #CHANGE THIS TO MATCH YOUR FILE OF FILE NAMES FOR THE SET OF READS YOU ARE WORKING WITH

pathToFastqs=path/to/fastq_files/ #CHANGE THIS PATH TO MATCH THE DIRECTORY WHERE READS ARE LOCATED + '/fastqc_pretrim'

i="$(($SLURM_ARRAY_TASK_ID*2))"
r1=$(python getLine.py $readFOFN $i)
r2=$(python getLine.py $readFOFN "$(($i+1))")
r1_len="$((${#r1}-9))"
r1_base=${r1:0:$r1_len}
r2_len="$((${#r2}-9))"
r2_base=${r2:0:$r2_len}

#PRE-TRIM FASTQC
fastqc -o $pathToFastqs/fastQC_pretrim -t 12 $r1 $r2

#TRIM ADAPTERS w/ FASTP
fastp -i $r1 -I $r2 -o $r1_base.trimmed.fastq.gz -O $r2_base.trimmed.fastq.gz -w 12 -q 20

#TRIM ADAPTERS W/TRIMMOMATIC (fastp preferred)
#java -Xmx12g -jar ~/miniforge3/envs/readQC/share/trimmomatic-0.41-0/trimmomatic.jar PE -threads 12 $r1 $r2 $r1_base.trimmed.fastq.gz $r1_base.trimmed.unpaired.fastq.gz $r2_base.trimmed.fastq.gz $r2_base.trimmed.unpaired.fastq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:50 #CHANGE ILLUMINA PARAMETERS AS NEEDED DEPENDING ON LIBRARY PREP

#POST-TRIM FASTQC
fastqc -o $pathToFastqs/fastQC_posttrim -t 12 $r1_base.trimmed.fastq.gz $r2_base.trimmed.fastq.gz