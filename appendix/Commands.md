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

database for lambda reads: chrL.fa
database for BOLD: /home/arjen/COI_db/BOLD/bold_all_sequences_taxonomy_species_only_nodups.fa
database for Genbank: /home/arjen/COI_db/Genbank/CO1/CO1.fa

    blastn -query input.fasta -db database.fa -task megablast -num_threads 12 -max_hsps 1 -out out.blasated -outfmt "6 qseqid stitle sacc staxid pident qcovs evalue bitscore" -max_target_seqs 100 -perc_identity 70 -qcov_hsp_perc 70

## 8. Pycharm Command NanoPlot
Command for making quality plots, readlength plots, and get statistics.

    NanoPlot --fastq input.fastq
## 9. Terimnal Command NanoLyse
Command to filter out lambda CS DNA from reads

    NanoLyse --reference /home/arjen/lambda_reads/lambda_genome/chrL.fa input.fastq > output_no_lambda.fastq

## 10. Terminal Command makeBarcodeFile.py (Script available under minion-pipeline-tooling/scripts)
Command organizes the file in which primers, tags, and tails are listed into a file that is supplied to minibar

    python ~/Documents/PycharmProjects/makeBarcodeFile.py -i File_1_Primers_tags_tails_Minion_pool.tsv -o File_2_tagsprimers.txt
 
## 11. Terminal command minibar
Command to demultiplex nanopore reads on custom primers and tags
-p is the percent idendity with which the primers have to match (-e for ma
-l is the number of bases from ends of read that mininbar searches in for primer

    python3 minibar.py primerstags.txt input.fasta -p 0.8 -l 90
   
## 12. Terminal Command cutadapt
Commands to remove primers and everything before/after primers

commands are for a files within a folder that end with fastq. 
Round1:

    # while in folder with fastq files:
    for file in *.fastq
    do 
        cutadapt --front GCYCCYGAYATRGCYTTYCC --revcomp --action trim --match-read-wildcards --error-rate 0.2 --overlap 10 --untrimmed-output untrimmed/${file}.untrimmed --output trimmed/trimmed.${file} $file
    done
    
    # move to folder with trimmed files
    mv trimmed
    
Round 2:

    for file in *.fastq
    do 
        –adapter TGRTTYTTYGGNCAYCCHGA –action trim –untrimmed-output untrimmed/untrimmedround2.fasta --overlap 10  -m 400 -M 440 -o trimmed.$file $file
    done

## 13. Terminal Command UCHIME chimera check
Command checks for chimeras denovo, that is: it compares abundance of reads to construct a self made database of non chimera reads.
This command is for all files in a directory that contain .fastq

    for file in *.fastq
    do 
        vsearch --uchime_denovo $file --chimeras $file.chimeras --nonchimeras $file.nonchimeras --sizeout
    done
    
    
## 14. Terminal Command VSEARCH
Command for clustering sequences with vsearch
command is for clustering round per file in folder 

id = percentage at which to cluster
iddef = pairwise identity defintion used in --id (0 = CD HIT, see vsearch manual for other definitinos)
gapopen/gapext = gap open and gap extension penalty for external and terminal gaps

for Minion

    for file in *
    do 
        vsearch --cluster_fast $file --id 0.97 --iddef 0  --gapopen 60I/4E --gapext 4I/2E --clusterout_id --sizein --relabel_keep --clusterout_sort --sizeout --sizeorder --centroids $file.centroids97 --consout $file.cons97 --msaout $file.msa97 --log $file.log97 
    done
   
for Illumina

    vsearch --cluster_fast combined.fasta --id 0.98 --iddef 0 --centroids combined.centroids98.fasta --clusterout_id --sizein --consout combined.cons98.fasta  --clusterout_sort --sizeout --sizeorder --msaout combined.msa98 --log combined.log98 --otutabout otu.about
    
for Illumina (default --gapopen and --gapext penalty)

    for file in *
    do 
        vsearch --cluster_fast $file --id 0.98 --iddef 0 --clusterout_id --sizein --relabel_keep --clusterout_sort --sizeout --sizeorder --centroids $file.centroids98 --consout $file.cons98 --msaout $file.msa98 --log $file.log98 
    done

## 15. Terminal Command add_taxonomy
Command to add taxnonomy to blast output (BOLD only, this edited script does not require a json file for genbank taxonomy)
Will save output in directory you are currently in.

    python2 /home/arjen/blast_tools/galaxy-tool-BLAST/blastn_add_taxonomy_lite_edited.py -i input.blasted

## 16.Terminal Command addDummy.R (script available under minion-pipeline-tooling/scripts)
Command adds dummy to all blast files in folder to which taxonomy was edited

    addDummy.R -i taxonomyadded.input
    
## 17. Terminal Command lca.py (script in naturlis github > galaxy-tool-lca)
Command executes lca analysis on blast output with taxonomy added and 10 columns

    lca.py -i taxonomy.fasta.dummyadded -o lca.output -b 8 -id 70 -cov 70 -t best_hitrange -tid 98 -tcov 99 -fh "environmental" -flh "unknown"

## 18. Terminal Command barplots (script available in minion-pipeline-tooling/scripts/barplots.R)
Command that makes barkplots from the lcas at different clustering percentages.
The input must be a folder with LCAs

    barplots.R -i ~/lca/all/forbarplot -o barplot.output -t all --log10 TRUE

## 19. Terminal Command venn diagram (script available in minion-pipeline-tooling/scripts/vennOverlap.R)
Command calls script that makes a venn diagram of overlapping reads between 2 or 3 methods, and outputs lists with the identifications

     vennOverlap.R -i /home/arjen/unclusteredboth/presentation_venn/cons80-unclu-centroids97 -t all -o output
    
## 20. Terminal command merge replicates (script available in minion-pipeline-tooling/scripts/mergeReplicates.py)
Command calls script that merged the replicates in a folder (if utilize _A_ _B_ _C_ format to indicate replicate)

    python mergeReplicates.py -i input.folder
    
## 21. Terminal command add samplename to headers in fasta file
Commands to make a new directory in which the files will end up, and then prepend sample name to fasta header

    mkdir changedheader

    for FILE in *.fasta; do  awk '/^>/{sub(">","&"FILENAME":");sub(/\.fasta/,x)}1' $FILE > changedheader/changed_${FILE}; done

## 22. Terminal command combine contents of file

    cat *.fasta > out.fasta
    

    
## additional commands
From fastq to fasta:

    sed -n '1~4s/^@/>/p;2~4p' in.fastq > out.fasta
    

    
