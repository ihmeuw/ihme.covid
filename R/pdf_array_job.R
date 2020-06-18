#' Submit an array job to plot PDFs, then bind back together.
#'
#' @param jobs_file .csv that has one row for each job you want to run, with arguments for plots as columns.
#' @param r_script Full path to the R script that has your plotting code.
#' @param final_out_dir Path to directory to save final file. Needs to be to a path on the cluster. 
#' @param write_file_name Final file name to write. Defaults to "all_jobs.pdf". 
#' @param rshell R-shell to use. Defaults to LBD shell. 
#' @param fthread fthreads for cluster jobs. Defaults to 5. 
#' @param fmem fmem for cluster jobs. Defaults to 10G. 
#' @param h_rt h_rt for cluster jobs. Defaults to 2 hours. 
#' @param queue Queue for cluster jobs. Options are 'all.q', 'i.q', 'long.q', or 'd.q'. Defaults to 'all.q'. 
#' @param project Cluster project. Defaults to 'proj_covid'. 
#' @param job_name Cluster job name. Defaults to 'pdf_array'. 
#' @param output Path to write cluster output messages to. Defaults to "/share/temp/sgeoutput/USERNAME/output"
#' @param errors Path to write cluster error messages to. Defaults to "/share/temp/sgeoutput/USERNAME/errors"
#' @param remove_temp_files Remove temporary files after jobs have completed? Defaults to TRUE.
pdf_array_job <- function(jobs_file, r_script, final_out_dir, 
                          write_file_name="all_jobs.pdf",
                          rshell="/share/singularity-images/lbd/shells/singR.sh -e s", 
                          fthread=5, fmem='10G', h_rt="00:02:00:00", queue="all.q",
                          project="proj_covid", job_name="pdf_array", output=NULL, errors=NULL, 
                          remove_temp_files=TRUE){
  # Global variables 
  user = Sys.info()[['user']]
  uuid = uuid::UUIDgenerate()
  
  # Set up output/error logging
  if (is.null(output)) output=paste0("/share/temp/sgeoutput/", user, "/output")
  output = paste0(output, "/", uuid)
  dir.create(output, recursive=TRUE)
  if (is.null(errors)) errors=paste0("/share/temp/sgeoutput/", user, "/errors")
  errors = paste0(errors, "/", uuid)
  dir.create(errors, recursive=TRUE)
  
  # Make temp output directory
  temp_out_dir=paste0('/ihme/scratch/projects/covid/pdf_temp/', user, "/", uuid)
  if (!dir.exists(temp_out_dir)) dir.create(temp_out_dir, recursive=TRUE)
  
  # Escape spaces in job_name
  job_name = gsub(" ", "_", job_name)
  
  jobs = data.table::fread(jobs_file)
  command <- paste0(
    "qsub", 
    " -l fthread=", fthread, ",fmem=", fmem, ",h_rt=", h_rt, 
    " -t 1:", nrow(jobs), 
    " -q ", queue, 
    " -P ", project, 
    " -N ", job_name, 
    " -now no",
    " -o ", output, 
    " -e ", errors,
    " ", rshell, 
    " ", r_script, 
    " --jobs-file ", jobs_file, 
    " --temp-out-dir ", temp_out_dir
  )
  print("Running array jobs command:")
  print(command)
  system(command)
  
  # Once jobs have finished, bind them back together
  bind_job_name = paste0("bind_", job_name)
  command <- paste0(
    "qsub", 
    " -l fthread=", fthread, ",fmem=", fmem, ",h_rt=", h_rt, ",archive=TRUE",
    " -q ", queue, 
    " -P ", project, 
    " -N ", bind_job_name, 
    " -now no",
    " -hold_jid ", job_name,
    " -cwd",
    " -o ", output, 
    " -e ", errors,
    " ", rshell, " R/bind_pdf.r", 
    " --temp-out-dir ", temp_out_dir, 
    " --final-out-dir ", final_out_dir, 
    " --write-file-name ", write_file_name
  )
  print("Running PDF binding command:")
  print(command)
  system(command)
  
  # Remove temporary directories and their contents.
  # All have been created within this function with a UUID
  # or explicitly passed as an argument, 
  # so should be safe to delete.
  temp_file_dirs = c(temp_out_dir, errors, outputs)
  if(remove_temp_files){
    for(dir in temp_file_dirs){
      command <- paste0(
        "qsub",
        " -l fthread=2,fmem=10G,h_rt=00:00:45:00,archive=TRUE",
        " -q ", queue,
        " -P ", project,
        " -N clean_temp_files_", i
        " -now no",
        " -hold_jid ", bind_job_name,
        " -b yes", 
        " rm -r ", dir[i]
      )
      system(command)
    }
  }
}
