#------------------------------------------------------
# AUTHOR: Emily Linebarger 
# PURPOSE: Example script for submitting PDF array jobs 
# LAST UPDATED: June 16, 2020 
#------------------------------------------------------
rm(list=ls())

# You will need to be in the root of the 'ihme.covid' repository. 
repo_root = "~/repos/covid19/ihme.covid/"
setwd(repo_root)

# Source array job function 
source('R/pdf_array_job.R')

# Install other libraries 
library(data.table)
library(ggplot2) 
library(datasets)

# Say you want to make a scatter plot of temperature in 2015 for all 50 states in the US. 
# We want to create a list of jobs that has the arguments for each page 
# in our PDF deck. In this case, each page is just uniquely identified by location_id, 
# so that's the only column we need. 

source("/ihme/cc_resources/libraries/current/r/get_location_metadata.R")
hierarchy = get_location_metadata(location_set_id=111)

us_states = hierarchy[parent_id==102]

# Now, write this list of jobs somewhere the cluster can see them. 
jobs = us_states[, .(location_id)]
write.csv(jobs, "~/jobs.csv", row.names=F)

# Source the pdf_array_job function. 
pdf_array_job(jobs_file='~/jobs.csv', 
              r_script='~/repos/covid19/ihme.covid/templates/make_single_pdf_page.R', 
              final_out_dir='~/scratch', 
              write_file_name='temp_all_us_states.pdf')


