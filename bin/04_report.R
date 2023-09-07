#!/usr/bin/env Rscript

require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)

name <- args[1]
rmd <- args[2]
res_other_fn <- args[3]
sites_tagged_context_fn <- args[4]

output = str_c(name, ".report.html")

res_other <- readRDS(res_other_fn)
sites_tagged_context <- readRDS(sites_tagged_context_fn)

rmarkdown::render(rmd, output_file=output)