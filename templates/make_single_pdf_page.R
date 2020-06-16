#------------------------------------------------------
# AUTHOR: Emily Linebarger 
# PURPOSE: Make single PDF page
# LAST UPDATED: June 16, 2020 
#------------------------------------------------------
require(data.table)
#------------------------------------------------------------------------------------
# HOW TO ADAPT FOR YOUR CODE: 
# You will only need to update the main function to call your data, 
# source in the libraries you need, 
# add any arguments you need for this specific plot (must be a column in your jobs file) 
# and update the plotting code. 
#------------------------------------------------------------------------------------

# Make each plot
main <- function(jobs, job_id, temp_out_dir) {
  # MY LIBRARIES 
  require(ggplot2) 
  
  # MY PLOT ARGUMENTS 
  LOCATION_ID = jobs$location_id[job_id]
  
  # MY DATA 
  data = fread('/ihme/covid-19/temperature/latest/NOAA_NCEP/temp_pwtemp_NCEP2015.csv')
  data = data[location_id==LOCATION_ID]
  
  # MY PLOT 
  p = ggplot(data, aes(x=date, y=wmean)) + 
    geom_point() + 
    theme_bw() + 
    labs(title=paste0("2015 temperature data for location_id: ", LOCATION_ID))
  ggsave(paste0(temp_out_dir, "/", job_id, ".png"), p) # <-- please leave as a .png! 
} 

#-----------------------------------------------------
# THIS SECTION AUTOMATICALLY HANDLED BY SUBMIT SCRIPT 
#-----------------------------------------------------
# Parse arguments from "pdf_array_job" call 
parser <- argparse::ArgumentParser()
parser$add_argument("--jobs-file", required=TRUE, help="File that includes ")
parser$add_argument("--temp-out-dir", required=TRUE, help="Temporary directory to save files in")
args <- parser$parse_args()

jobs_file = args$job_file
temp_out_dir = args$temp_out_dir

# Read in your jobs file. Each job is indexed by "SGE_TASK_ID", which will 
# correspond to a row in your dataframe. 
jobs = fread('~/jobs.csv')
job_id = Sys.getenv("SGE_TASK_ID")
job_id = as.integer(job_id)

main(jobs, job_id, temp_out_dir)