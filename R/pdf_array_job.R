#' Submit an array job to plot PDFs, then bind back together.
#'
#' @param jobs_file .csv that has one row for each job you want to run, with arguments for plots as columns.
#' @param r_script Full path to the R script that has your plotting code.
#' @param final_out_dir Path to directory to save final file. Needs to be to a path on the cluster. 
#' @param write_file_name Final file name to write. Defaults to "all_jobs.pdf". 
#' @param rshell R-shell to use. Defaults to SciComp shell. 
#' @param fthread fthreads for cluster jobs. Defaults to 5. 
#' @param fmem fmem for cluster jobs. Defaults to 10G. 
#' @param h_rt h_rt for cluster jobs. Defaults to 2 hours. 
#' @param queue Queue for cluster jobs. Options are 'all.q', 'i.q', 'long.q', or 'd.q'. Defaults to 'all.q'. 
#' @param project Cluster project. Defaults to 'proj_covid'. 
#' @param job_name Cluster job name. Defaults to 'pdf_array'. 
#' @param output Path to write cluster output messages to. Defaults to "/ihme/temp/slurmoutput/USERNAME/output"
#' @param errors Path to write cluster error messages to. Defaults to "/ihme/temp/slurmoutput/USERNAME/errors"
#' @param remove_temp_files Remove temporary files after jobs have completed? Defaults to TRUE.
#' @param args Additional arguments to pass to array job launch script. 
pdf_array_job <- function(jobs_file, r_script, final_out_dir, 
                          write_file_name="all_jobs.pdf",
                          rshell="/ihme/singularity-images/rstudio/shells/execRscript.sh -s", 
                          fthread=5, fmem='10G', h_rt="02:00:00", queue="all.q",
                          project="proj_covid", job_name="pdf_array", output=NULL, errors=NULL, 
                          remove_temp_files=TRUE, args=NULL){
  # Global variables 
  user = Sys.info()[['user']]
  uuid = uuid::UUIDgenerate()
  
  # Set up output/error logging
  if (is.null(output)) output=paste0("/ihme/temp/slurmoutput/", user, "/output")
  output = paste0(output, "/", uuid)
  if (!dir.exists(output)) dir.create(output, recursive=TRUE)
  if (is.null(errors)) errors=paste0("/ihme/temp/slurmoutput/", user, "/errors")
  errors = paste0(errors, "/", uuid)
  if (!dir.exists(errors)) dir.create(errors, recursive=TRUE)
  
  # Make temp output directory
  temp_out_dir=paste0('/ihme/scratch/projects/covid/pdf_temp/', user, "/", uuid)
  if (!dir.exists(temp_out_dir)) dir.create(temp_out_dir, recursive=TRUE)
  
  # Escape spaces in job_name
  job_name = gsub(" ", "_", job_name)
  
  jobs = data.table::fread(jobs_file)
  command <- paste0(
    "sbatch", 
    " --mem ", fmem,
    " -c ", fthread, 
    " -t ", h_rt, 
    " --array=1-", nrow(jobs), 
    " -p ", queue, 
    " -A ", project, 
    " -J ", job_name, 
    " -o ", output, "/%x.o%j",
    " -e ", errors, "/%x.e%j",
    " ", rshell, 
    " ", r_script,
    " --jobs-file ", jobs_file, 
    " --temp-out-dir ", temp_out_dir
  )
  if (!is.null(args)){
    stopifnot(typeof(args)=='list')
    for (arg in names(args)){
      command = paste0(command, " --", arg, " ", args[[arg]])
    }
  }
  print("Running array jobs command:")
  print(command)
  job_id = system(command, intern = TRUE)
  job_id = gsub("[[:alpha:]]| ", "", job_id)
  
  # Once jobs have finished, bind them back together
  bind_job_name = paste0("bind_", job_name)
  bind_script = system.file("bind_pdf.R", package="ihme.covid", lib.loc="/ihme/covid-19/.r-packages/current", mustWork=TRUE)
  command <- paste0(
    "sbatch", 
    " --mem ", fmem,
    " -c ", fthread, 
    " -t ", h_rt, 
    " -p ", queue, 
    " -A ", project, 
    " -J ", bind_job_name, 
    " -o ", output, "/%x.o%j",
    " -e ", errors, "/%x.e%j",
    " --dependency ", job_id,
    " ", rshell, 
    " ", bind_script, 
    " --temp-out-dir ", temp_out_dir, 
    " --final-out-dir ", final_out_dir, 
    " --write-file-name ", write_file_name
  )
  print("Running PDF binding command:")
  print(command)
  job_id = system(command, intern = TRUE)
  job_id = gsub("[[:alpha:]]| ", "", job_id)
  
  # Remove temporary directories and their contents.
  # All have been created within this function with a UUID,
  # so should be safe to delete.
  temp_file_dirs = c(temp_out_dir, errors, output)
  if(remove_temp_files==TRUE){
    for(i in 1:length(temp_file_dirs)){
      command <- paste0(
        "sbatch",
        " --mem 10G -c 2 -t 00:45:00 -C archive",
        " -p ", queue,
        " -A ", project,
        " -J clean_temp_files_", i,
        " --dependency ", job_id,
        " --wrap", 
        " 'rm -r ", temp_file_dirs[i], "'"
      )
      system(command)
    }
  }
}
