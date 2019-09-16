# minion-pipeline-tooling

Tools for managing and automating analysis of MinION nanopore longreads
Relates to [B19006-555](https://docs.google.com/spreadsheets/d/14XQJgJ_Fk2FqaAuyZOWalApxIOcrkr5V0KlYvKmkl6Q/edit?ts=5ca74201#gid=420939240) and this [MSc project proposal](https://docs.google.com/document/d/1eZRCKmotnMgoF08aTI3XvSKGO5fuuFFwqTTYFTFagEI/edit)

## Project goals

### Assemble test / reference data

- resulting from metabarcoding samples
- following base calling, i.e. FASTQ
- cover multiple test cases (e.g. 3 total)
- can be deposited (under embargo?) on the SRA

### Assess clustering algorithms

- which tools to use?
- parameter exploration of divergence levels
- tools collected in a docker container
- clustering pipelines scripted in this repo
- clustering pipelines wrapped in galaxy XML

### Assess consensus building

- map cluster against marker template (e.g. COI)
- compute consensus with modal base per site
- compute consensus with IUPAC ambiguity code
- assess BLAST hist
- consensus building code in docker container
- consensus building scripts in this repo
- consensus building scripts wrapped in galaxy XML
