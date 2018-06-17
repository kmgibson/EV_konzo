#!/bin/bash
#SBATCH -N 1
#SBATCH -t 2-00:00:00
#SBATCH -p defq,gpu,short
#SBATCH --array=1-91
#SBATCH -o PS_hg38.%A_%a.out
#SBATCH -e PS_hg38.%A_%a.err

name=$(sed -n "$SLURM_ARRAY_TASK_ID"p ../samps.txt)

#--- Start the timer
t1=$(date +"%s")

echo $name
mkdir -p $name/bac

module load pathoscope
module load bowtie2


pathoscope.py MAP -numThreads $(nproc)\
 -outDir $name/bac \
 -indexDir ../refs \
 -targetIndexPrefixes ref_prok_rep_genomes.00_ti,ref_prok_rep_genomes.01_ti,ref_prok_rep_genomes.02_ti,ref_prok_rep_genomes.03_ti,ref_prok_rep_genomes.04_ti,ref_prok_rep_genomes.05_ti,ref_viruses_rep_genomes_ti,ref_viroids_rep_genomes_ti \
 -filterIndexPrefixes genome,phix174 \
 -1 $(ls $name/flexcleaned_1.fastq) \
 -2 $(ls $name/flexcleaned_2.fastq)
 
 echo "Completed running PathoMAP on bac for $name"


pathoscope.py ID \
 -outDir $name/bac \
 -thetaPrior 10000000 \
 -alignFile $name/bac/outalign.sam
 
 echo "Completed running PathoID on bac for $name"


#---Complete job
t2=$(date +"%s")
diff=$(($t2-$t1))
echo "[---$SN---] ($(date)) $(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
echo "[---$SN---] ($(date)) $SN COMPLETE."

