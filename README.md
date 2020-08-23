[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3992310.svg)](https://doi.org/10.5281/zenodo.3992310)


# minion-pipeline-tooling

Tools for managing and automating analysis of MinION nanopore longreads
Relates to [B19006-555](https://docs.google.com/spreadsheets/d/14XQJgJ_Fk2FqaAuyZOWalApxIOcrkr5V0KlYvKmkl6Q/edit?ts=5ca74201#gid=420939240) and this [MSc project proposal](https://docs.google.com/document/d/1eZRCKmotnMgoF08aTI3XvSKGO5fuuFFwqTTYFTFagEI/edit)

## Minion pipeline and Saba/St. Eustatius environmental analysis with Illumina.
### This repository contains:

- Project report (available in docs)
- Scripts
  - R (scripts and markdowns)
  - Python
- Pipeline
- File with commands used
- Links to drive folders
- Other relevant files
- Presentations 

The project report will reference to files in this repository, which serves as an appendix.

## Project goals

### Collect documentation

- relevant literature
- student project

### Assemble test / reference data

- resulting from metabarcoding samples
- following base calling, i.e. FASTQ
- cover multiple test cases (Arjen has data also run in Illumina)
- can be deposited (under embargo?) on the SRA

### Develop demultiplexing

- shoehorn custom adaptors into demultiplexing tool
- attempt to sort

### Assess clustering algorithms

- which tools to use? (Guppy? Rutger + Elza evaluate)
- parameter exploration of divergence levels
- tools collected in a docker container
- clustering pipelines scripted in this repo
- clustering pipelines wrapped in galaxy XML

### Assess consensus building

- map cluster against marker template (e.g. COI)
- compute consensus with modal base per site
- compute consensus with IUPAC ambiguity code
- assess BLAST hits
- consensus building code in docker container
- consensus building scripts in this repo
- consensus building scripts wrapped in galaxy XML

### Other resources

- [Dutch Caribbean sampling trip project folder](https://drive.google.com/drive/folders/0AJciDEav_vtMUk9PVA)
- [sample metadata sheet](https://docs.google.com/spreadsheets/d/1q1Q3AW5qvXCaXK5MO9jRTS8BdWyp5GQz9toH6hs0VhU/edit?ts=5e96c68e#gid=1654989386)
- [research proposal by Heleen Bouwer](https://drive.google.com/file/d/1YLrRx86EswGZK3411CPPQ86vAI4Q16Wf/view?usp=sharing)
