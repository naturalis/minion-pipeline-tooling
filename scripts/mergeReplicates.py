#!/usr/bin/python

import argparse
import os
import re

parser = argparse.ArgumentParser(description='')
parser.add_argument('-i', '--input_folder', metavar='', dest='input', type=str,
                    help='input folder with replicates', default='', required=True)

args = parser.parse_args()

myFolder = args.input
files = os.listdir(myFolder)


def merge():
    for filename in files:
        prefix = re.match("(.*?)_[ABC]_*", filename).group(1)
        print(prefix)
        with open(os.path.join("/home/arjen/Downloads/Illumina_reads/replicates/ABCmerged",
                               "merged_" + prefix + ".fastq"), 'a') as outfile:
            with open(os.path.join(myFolder,
                                   filename)) as infile:
                outfile.write(infile.read())

def main():
	merge()

if __name__ == "__main__":
	main()

