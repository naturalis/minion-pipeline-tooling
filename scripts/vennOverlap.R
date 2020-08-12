#!/usr/bin/env Rscript

library(optparse)
library(stringr) 
library(tools)
library(RColorBrewer)
suppressPackageStartupMessages(library(VennDiagram))
library(gridExtra)
library(ggplot2)


option_list = list(
  make_option(c('-i', '--input'), 
              type = 'character', 
              default = NULL, 
              help = 'name of folder with files to make venn diagram with', 
              metavar = 'character'),
  make_option(c('-o', '--outfile'),
              type = 'character',
              default = 'Venn_Diagram_',
              help = 'name for prefix output file [default is %default]',
              metavar = 'character'),
  make_option(c('-s', '--sizefilter'),
              type = 'character',
              default = NULL,
              help = 'Filter out cluster size equal to and lower input (integers only).',
              metavar = 'character'),
  make_option(c('-t', '--taxonlevel'),
              type ='character',
              default = 'NULL',
              help = 'taxonomic level to make venn diagram for \n\t\t(all, kingdom, phylum, class, order, family, genus, species)',
              metavar = 'character'))

opt_parser = OptionParser(option_list = option_list)    #creates instance of a parser opject
opt = parse_args(opt_parser)                            #parses command line options

# Check if required inputs are given
if(is.null(opt$input)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (path to input folder)", call. = FALSE)
} else if (is.null(opt$taxonlevel)){
  print_help(opt_parser)
  stop("Specify taxonomic level to make venn diagram for (all, kingdom, phylum, class, order, family, genus, species)", 
       call. = FALSE)} 

# FUNCTIONS
# function to get data and rename files and columns
getData <- function(){
  # make dataframes of the files and save into a list 
  df_list <- lapply(my_files, read.delim)
  #change names of df_list to the filenames (basename without extensions)
  names(df_list) <- basename(file_path_sans_ext(my_files))
  # remove X. from column names
  df_list <- lapply(df_list, function(x){ 
    setNames(x, sub("^X.", "", names(x)))})}

# function to filter on size
filteronsize <- function(size){
  df_list <- lapply(1:length(df_list), function(x){
    df_list[[x]]$X.Query <- as.character(df_list[[x]]$X.Query)  #column value has to be coverted to factor in order for the pattern matching to work properly.
    sizefilter <- paste('size=', size, '$', sep ="")
    df_list[[x]] <- df_list[[x]] %>% dplyr::filter(!str_detect(X.Query, sizefilter)) 
  })}

# function: make list with each taxon from each dataframe
makelist <- function(tax){
  emptylist <- list()
  sapply(df_list, function(df){
    emptylist <- df[, tax]})}

# function: exexute makelist function, convert to characters and remove 'no identification' entries.
preplist <- function(taxa) {
  preplist <- makelist(tax = taxa)
  preplist <- lapply(preplist, as.character, simplify = TRUE)
  preplist <- lapply(preplist, remove.noid)}  

getCol <- function(){
  if (length(df_list) >= 3) {
    myCol <- brewer.pal(length(df_list), "Pastel2")
  } else {
    myCol <- c('#FF0000', '#1100FF')}
  return(myCol)}

## Function finding intersect, union, and differences between nameslists
Intersect <- function (x) {  
  if (length(x) == 1) {
    unlist(x)
  } else if (length(x) == 2) {
    intersect(x[[1]], x[[2]])
  } else if (length(x) > 2){
    intersect(x[[1]], Intersect(x[-1]))
  }
}

Union <- function (x) {  
  if (length(x) == 1) {
    unlist(x)
  } else if (length(x) == 2) {
    union(x[[1]], x[[2]])
  } else if (length(x) > 2) {
    union(x[[1]], Union(x[-1]))
  }
}
Setdiff <- function (x, y) {
  xx <- Intersect(x)
  yy <- Union(y)
  setdiff(xx, yy)
}

# function: go trough the list(s) and remove all the no identification entries
remove.noid <- function(vector) {vector[vector != "no identification"]}

# make plot 
venns <- function(i){
  invisible(venn <- venn.diagram(
    # data
    x = final_list[[i]],
    filename = NULL,
    category.names = names(df_list),
    force.unique = TRUE, #doesn't count double entries
    output= TRUE,
    cat.pos = c(-35, 35, 0),
    
    #output
    imagetype= "png" ,
    height = 500 , 
    width = 700 , 
    resolution = 150,
    compression = "lzw",
    
    # Circles
    lwd = 2,
    lty = 'blank',
    fill = myCol,
    
    # Numbers
    cex = 1,
    fontface = "bold",
    fontfamily = "sans",
    
    # Set title and subtitle
    main = taxa[i],
    main.cex = 1.3,
    sub = paste('overlap between unique identifications at', taxa[i], 'level,', subtitle, sep = ' '),
    sub.cex = 1,
    
    # Set names
    cat.cex = 1.1,
    cat.default.pos = "outer",
    cat.fontfamily = "sans",
  ))
  # legend
  lg <- legendGrob(labels = names(df_list), pch=rep(19, length(names(df_list))),
                   gp=gpar(col=myCol, fontsize = 8, fontfamily = 'sans' ),
                   byrow=TRUE, vgap = 0.5)
  # make g tree from venn
  g <- gTree(children = gList(venn))
  
  #combine venn and legend into one page
  myplot <- gridExtra::grid.arrange(g, bottom=lg)}


# combine names final_list for the combinations possible in venn diagram
overlaplist <- function(i){
  combs <- unlist(lapply(1:length(final_list[[i]]), 
                         function(j) combn(names(final_list[[i]]), j, simplify = FALSE)),
                  recursive = FALSE)
  names(combs) <- sapply(combs, function(i) paste0(i, collapse = " - "))
  elements <- lapply(combs, function(x){ 
    Setdiff(final_list[[i]][x], final_list[[i]][setdiff(names(final_list[[i]]), x)])
  })
  n.elements <- sapply(elements, length)
  sink(paste(opt$outfile, 'overlap_', taxa[i], '.txt', sep =""))
  lapply(1:length(elements), function(x) {
    cat(names(elements)[[x]], ' (', n.elements[[x]], '):\n')
    cat(elements[[x]], sep = ", ")
    cat("\n\n")
  })
  sink()
}


# EXECUTION:
my_files <- list.files(opt$input, full.names = TRUE) # get all the filepaths from the folder 

# retrieve filenames that are in that folder, if not 2 or 3 files issue warning
if(length(my_files) < 2 | length(my_files) > 3){
  print_help(opt_parser)
  stop("File folder must contain either two or three files to make a venn diagram.", call = FALSE)}


df_list <- getData()


# filter on size and set subtitle
if(!is.null(opt$size)){ 
  opt$size <- as.integer(opt$size)
  subtitle <- paste('excluding cluster sizes up to', opt$size)
  for (s in 1:opt$size){ 
    df_list <- filteronsize(opt$size)}
} else
  subtitle <- 'not filtered on cluster size'


# if a venn diagram is wanted for all taxa, make a list of all taxa, if only for one taxa, have only that one.  
if (opt$taxonlevel == 'all'){
  taxa <- c("kingdom", "phylum", "class", "order", "family", "genus", "species")
  outname <- 'all'
} else {taxa <- opt$taxonlevel; outname <- opt$taxonlevel}


# executefunctions to get all the cleaned lists
final_list <- lapply(taxa, preplist)


# change names of list to all taxa if neccesary
if (length(final_list) ==7){names(final_list) = taxa}


# get colors for venn diagram
myCol <- getCol()


# open pdf file for output vennss
pdf(paste(opt$outfile, outname, '.pdf', sep = ""))


# invisble to supress output
invisible(lapply(1:length(final_list), function(i){ 
  venns(i)
  overlaplist(i)}))