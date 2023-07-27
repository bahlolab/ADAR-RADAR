#!/usr/bin/env Rscript

require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)

sample <- args[1]
jacusa_table_fn <- args[2]
dbSNP_loci_fn <- args[3]

jacusa_table <- read_tsv(
  jacusa_table_fn,
  col_types = cols(position = col_integer()))

dbSNP_loci <- read_tsv(
  dbSNP_loci_fn, 
  col_names = c('region', 'position'),
  col_types = cols(position = col_integer()))

res <- anti_join(jacusa_table, dbSNP_loci, by = c('region', 'position'))

write_tsv(res, str_c(sample, '.jacusa_table.dbSNP_filt.tsv.gz'))
