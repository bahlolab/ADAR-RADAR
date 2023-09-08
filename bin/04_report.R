#!/usr/bin/env Rscript

require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)

name <- args[1]
res_other_fn <- args[2]
sites_tagged_context_fn <- args[3]
sites_stats_filt_fn <- args[4]
sample_site_depth_fn <- args[5]

output = str_c(name, ".report.html")

res_other <- readRDS(res_other_fn)
sites_tagged_context <- readRDS(sites_tagged_context_fn)
sites_stats_filt <- readRDS(sites_stats_filt_fn)
sample_site_depth <- readRDS(sample_site_depth_fn)

rmarkdown::render('04_report.Rmd', output_file=output)