#!/usr/bin/python

import csv
import argparse

parser = argparse.ArgumentParser(description='')
parser.add_argument('-i', '--input_file', metavar='', dest='input', type=str,
                    help='input data in tsv format', default='', required=True)
parser.add_argument('-o', '--output_file', metavar='output file', dest='output', type=str,
                    help='results file in tsv', required=True)

args = parser.parse_args()


def write():
    with open(args.input, mode='r') as rfile, open(args.output, mode='w') as wfile:
        csvreader = csv.reader(rfile, delimiter = '\t')
        next(csvreader, None)
        wfile.write('SampleID' + '\t' + 'FwdBarcode' + '\t' + 'FwdPrimer' + '\t' + 'RevBarcode' + '\t' + 'RevPrimer' + '\n')
        for line in csvreader:
            SampleID = line[1]
            FwdBarcode = line[4]
            FwdPrimer = line[5]
            RevBarcode = line[11]   # must be in reverse complement
            RevPrimer = line[12]  # must be in reverse complement
            wfile.write(SampleID + '\t' + FwdBarcode + '\t' + FwdPrimer + '\t' + RevBarcode + '\t' + RevPrimer + '\n')

def main():
	write()

if __name__ == "__main__":
	main()

