#!/usr/bin/env Rscript

#command line arguments
library(optparse)   
option_list = list(
  make_option(c('-i', '--input'), 
              type='character', 
              default = NULL, 
              help='name of folder with files to add dummy variable to', 
              metavar = 'character'),
  make_option(c('-o', '--out'),
              type='character',
              default='_plot',
              help='name for output file [default is suffix %default]',
              metavar = 'character'),
  make_option(c('-s', '--sizefilter'),
              type='character',
              default = NULL,
              help = 'option for filtering on size of cluster (integers only). Will filter out clusters up to and included that size (default is no filtering)',
              metavar = 'character'),
  make_option(c('-t', '--taxonlevel'),
              type ='character',
              default = 'all',
              help = 'taxonomic level to make venn diagram for (all, kingdom, phylum, class, order, family, genus, species)',
              metavar = 'character'),
  make_option(c('-l', '--log10'),
              type = 'logical',
              default = 'false',
              help = 'have the y axis in scale of logarhitm 10 [TRUE|FALSE] (default is false)',
              metavar = 'logical'))

opt_parser = OptionParser(option_list = option_list)    #creates instance of a parser opject
opt = parse_args(opt_parser)                            #parses command line options

#if no input arguments are provided display error message without the error call
if(is.null(opt$input)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (path to input folder)", call. = FALSE)
} 

#retrieve filenames that are in that folder
my_files <- list.files(opt$input, full.names = TRUE) # get all the filepaths from the folder 

#make dataframes of the files and save into a list 
df_list <- lapply(my_files, read.delim)

#load required packages
#library(dplyr) #load required packages for filtering data
library(stringr) # load required packages for str_detect formula

#function to filter on size)

filteronsize <- function(size){
  df_list <- lapply(1:length(df_list), function(x){
    df_list[[x]]$X.Query <- as.character(df_list[[x]]$X.Query)  #column value has to be coverted to factor in order for the pattern matching to work properly.
    sizefilter <- paste('size=', size, '$', sep ="")
    df_list[[x]] <- df_list[[x]] %>% dplyr::filter(!str_detect(X.Query, sizefilter)) 
  })}

# if a argument is filled in for size execute this function
if(!is.null(opt$size)){ 
  opt$size <- as.integer(opt$size)
  for (s in 1:opt$size){ 
    df_list <- filteronsize(as.character(s))}
}

library(tools)
names(df_list) <- c("centroids 80", "centroids 85", "centroids 90", "centroids 95", "centroids 97",
                    "consensus 80", "consensus 85", "consensus 90", "consensus 95", "consensus 97",
                    "Illumina centroid 97", "Illumina consensus 97")

df_list <- lapply(df_list, function(x) 
  setNames(x, sub("^X.", "", names(x)))) # remove X. from column names

desiredtaxa = c("kingdom", "phylum", "class", "order", "family", "genus", "species")

Method  = c() 
Taxa = c()
UniqueCount = c()
AbsoluteCount = c()

#count everything
invisible(lapply(1:length(df_list), function(y) # for dataframe in range of dataframes  
  lapply(desiredtaxa, function(x) # for every taxa AbsoluteCount that we want to extract
  {saveAbsoluteCount = sum(!grepl("no identification", df_list[[y]][,x]))#sum all the occurences that ar not 'no id' in dataframeY of column x and save it to AbsoluteCount
  saveUniqueCount = length(unique(df_list[[y]][,x]))
  Method <<- append(Method, names(df_list)[y]) 
  Taxa <<- append(Taxa, x)
  AbsoluteCount <<- append(AbsoluteCount, saveAbsoluteCount)
  UniqueCount <<- append(UniqueCount, saveUniqueCount ) 
  })))

#make dataframes from all the counts
df_absolutecount <- data.frame(Method, Taxa, AbsoluteCount)
df_uniquecount <- data.frame(Method, Taxa, UniqueCount)


#make dataframes with names
list_df <- list(df_absolutecount=df_absolutecount, df_uniquecount=df_uniquecount)

#make facotrs and characters
invisible(lapply(1:length(list_df), function(x) {
  list_df[[x]]$Taxa <<- as.character(list_df[[x]]$Taxa)
  list_df[[x]]$Taxa <<- factor(list_df[[x]]$Taxa, levels=desiredtaxa)
}))

y_names <- c('Absolute Counts', 'Unique Counts')

invisible(lapply(1:length(list_df), function(x){
  list_df[[x]]$Method <<- factor(
    list_df[[x]]$Method, levels = c("centroids 80", "consensus 80", 
                                    "centroids 85", "consensus 85", 
                                    "centroids 90", "consensus 90",
                                    "centroids 95", "consensus 95",
                                    "centroids 97", "consensus 97",
                                    "Illumina centroid 97", "Illumina consensus 97"))}))


if (opt$taxonlevel != 'all') {
  suppressPackageStartupMessages(library(dplyr))
  list_df <- lapply(1:length(list_df), function(x) {filter(list_df[[x]], Taxa == 'species')})
}

library(ggplot2)

#col <- c("wheat1", "lightgoldenrod1",
 #       "tomato1", "tomato4", 
  #       "darkolivegreen3", "darkolivegreen4", 
   #      "lightblue", "lightblue4", 
    #     "plum2", "purple",
     #    "snow3", "snow4")
#plot function
doGroupedBarPlot <- function(data, y_name) {
  p <- ggplot(data, aes(x=Taxa, y=data[,3])) + 
    geom_bar(stat = "identity", aes(fill = Method), position = "dodge") 
  if (opt$log10 == TRUE){
    p <- p + scale_y_log10() + ylab(paste(y_name, " (log10)"))}
    else {
      p <- p + ylab(y_name)}
  print(p)
  ggsave("Mybarplot", p, device = "png", width = 7, height = 7) + theme(test = element_text(size = 20))
}

#execute plot function
plots <-mapply(doGroupedBarPlot, list_df, y_names)
