# Commands in bash

## 1. Terminal Command FLASH merger
This command merged the R1 and R2 files with min overlap of 50 and max 400, with max errorrate. 

While in folder with R1 and R2 files:

    mkdir merged
    for i in $(ls *_R1.fastq | grep -Poh ".*_L001_" | sed 's/1$//')
        do  ~/Downloads/FLASH-1.2.11-Linux-x86_64/flash -m 50 -M 400 -x 0.2 -O -c ${i}R1.fastq ${i}R2.fastq > merged/$i\merged.fastq
    done
    
## 2. Terminal Command Guppy
This is the command for basecalling with Guppy GPU. The chunksize and runner are the best for performance on the Dell XPS 15 laptop

    sudo guppy_basecaller -i /home/arjen/Documents/Fast5filesMinION/Fast5_pass/ -s /home/arjen/Documents/test5  -c dna_r9.4.1_450bps_hac.cfg --device auto --chunks_per_runner 2500 --chunk_size 2500

## 3. Terminal Command Bonito
This is the command for basecalling with bonito. This version does not produce quality scores.

    bonito basecaller dna_r9.4.1 /home/arjen/Downloads/fast5 > basecalls.fasta

## 4. Terminal Command Rerio
The Rerio basecaller is an additional model within the guppy program.

    guppy_basecaller -i /home/arjen/Downloads/fast5 -s basecalled_fast5s \ -d ./rerio/basecall_models/ \   -c res_dna_r941_min_flipflop_v001.cfg --device auto --chunks_per_runner 2000 --chunk_size 2000

## 5. Terminal Command Makeblastdb
Command for making custom blast database out of fasta sequences

     makeblastdb -dbtype nucl -in /home/arjen/lambda_reads/lambda_genome/chrL.fa -input_type fasta -title lambdagenome -out /home/arjen/lambda_reads/lambda_genome/lambdagenomedb
     
## 6. PyCharm Command Nanofilt 
Command to filter on 1500-4000 reads (in PyCharm terminal)

 NanoFilt -l 1500 --maxlength 4000 file.fastq > output.fastq

## 7. Terminal command Blast 
Command for assignming taxonomy to sequences using blastn

   blastn -query input.fasta -db database.fa -task megablast -num_threads 12 -max_hsps 1 -out out.blasated -outfmt "6 qseqid stitle sacc staxid pident qcovs evalue bitscore" -max_target_seqs 100 -perc_identity 70 -qcov_hsp_perc 70

## 8. 

