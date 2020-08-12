#!/usr/bin/env Rscript

#command line arguments
library(optparse)   
option_list = list(
  make_option(c("-i", "--input"), 
              type='character', 
              default = NULL, 
              help='name of folder with files to add dummy variable to', 
              metavar = 'character'),
  make_option(c("-o", "--out"),
              type='character',
              default="_dummyadded",
              help='suffix for output file [default is %default]',
              metavar = 'character')
  );

opt_parser = OptionParser(option_list = option_list)    #creates instance of a parser opject
opt = parse_args(opt_parser)                            #parses command line options

# If no input arguments are provided display error message without the error call
if(is.null(opt$input)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (path to input folder)", call. = FALSE)
} 

# Retrieve filenames that are in that folder
my_files <- list.files(opt$input, full.names = TRUE) # get all the filepaths from the folder 

# Remove the filenames that are empty (so equal to file.size 0) because these files cannot be transformed into a dataframe 
# And there nothing to add dummy to: it causes errors in the script. 
my_files <- my_files[file.size(my_files) != 0]


#make dataframes of the files and save into a list 
df_list <- lapply(my_files, read.delim)


#columnnames of final dataframes
columnnames = c("#Query ID",	"#Subject", 	"#Subject accession",	"#Subject Taxonomy ID",	"#Identity percentage", "#Coverage",	"#evalue",	"#bitscore",	"#Source",	"#Taxonomy")

#load required packages
library(tibble)     #for adding columns
library(tools)      #for filepath without extension

#add dummy to every dataframe in df_list and output it to a new text file. Invisible() prevents NULL being returned.
invisible(lapply(1:length(df_list), function(a)  # for dataframe in range of dataframes 
  {df_list[[a]] <- add_column(df_list[[a]], subjectdummy = rep("dummy", nrow(df_list[[a]])), .after = 1)
  colnames(df_list[[a]]) <- columnnames
  outputfilename <- paste(file_path_sans_ext(my_files[a]), opt$out, sep = "")
  write.table(df_list[[a]], outputfilename, sep="\t", row.names = FALSE, quote = FALSE)
  }))
