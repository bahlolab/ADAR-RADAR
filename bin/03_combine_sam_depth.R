#!/usr/bin/env Rscript

require(tidyverse)

args <- commandArgs(trailingOnly = TRUE)

name <- args[1]
siteStats_filt_fn <- args[2]
sam_depth_csv_fn <- args[3]
res_other_fn <- args[4]
DP_thresh <- as.integer(args[5])
altCount_thresh <- as.integer(args[6])
remove_chr <- as.logical(args[7])


siteStats_filt <- readRDS(siteStats_filt_fn)
# TODO - why are we filtering this way here? Does this need a strandedness swtich?
res_other <- readRDS(res_other_fn) %>% filter(basechange %in% 'A->G') 

# read depth for all samples (renamed from 'dt' in 03_samdepth.R)
sam_depth <-
  read_csv(sam_depth_csv_fn, col_types = 'cc') %>% 
  mutate(data = map(depthfile, 
                    read_tsv,
                    col_names = c('chromosome', 'pos', 'samDepth'),
                    col_types = 'cii')) %>%
  unnest(data) %>% 
  select(sample, chromosome, pos, samDepth) %>% 
  mutate(
    chromosome = `if`(remove_chr, str_remove(chromosome, '^chr'), chromosome),
    siteID = str_c(chromosome, pos, sep = "_"))
  
saveRDS(sam_depth, str_c(name, '.sam_depth_qQ20.rds'))

# renamed from dt_subset
sam_depth_subset <-
  sam_depth %>% 
  semi_join(res_other, 'sample') %>% 
  semi_join(siteStats_filt, 'siteID') %>% 
  filter(samDepth >= DP_thresh)

# renamed from y_subset
res_other_subset <- 
  res_other %>% 
  filter(
    flagINFO=='*',
    totalDP >= DP_thresh,
    altcount >= altCount_thresh,
    #basechange %in% c('A->G','T->C'), #toggle for unstranded data
    # basechange %in% c('A->G')
    ) %>% 
  semi_join(siteStats_filt, by = 'siteID') %>% 
  select(-flagINFO)

# rename from dp
sample_site_depth <- 
  left_join(sam_depth_subset,
            res_other_subset,
            by = c('sample' ,'siteID')) %>% 
  mutate(altcount= if_else(is.na(altcount), 0, altcount),
         altprop = if_else(is.na(altprop),  0, altprop)) %>% 
  group_by(siteID) %>%
  fill(strand, basechange, altbase, region, position, .direction = 'updown') %>% 
  ungroup() %>% 
  mutate(refcount = ifelse(altcount > 0,  (altcount * (1/altprop)) - altcount, samDepth)) %>% 
  mutate(totalDP  = ifelse(altcount == 0,   samDepth, totalDP)) %>% 
  mutate(totalDP = as.integer(round(totalDP,0))) %>% 
  select(1:altcount, refcount, totalDP, everything()) %>% 
  group_by(siteID) %>%
  mutate(sd_site = sd(altprop)) %>%
  ungroup()

sample_depth_error_flag <- 
  sample_site_depth %>%
  filter(samDepth != totalDP) %>%  
  filter(samDepth > 2 * totalDP) %>%
  count(sample, sort=T) 

# NB most samples are in this category
sample_site_depth <- 
  sample_site_depth %>%
  mutate(depth_flag = ifelse(sample %in% sample_depth_error_flag$sample, 1 , 0))

prev_count <- 
  sample_site_depth %>%
  # filter(depth_flag==0) %>%  # removes all samples
  filter(altcount > 0) %>% 
  count(siteID) %>% 
  select(siteID,n) %>%
  rename(nSamp_Ed = n)

sample_site_depth <- 
  sample_site_depth %>%
  left_join(prev_count, by = 'siteID')

saveRDS(
  sample_site_depth,
  str_c(name, '.sample_site_depth.rds')
)


