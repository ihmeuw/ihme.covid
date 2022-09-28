# TODO: write docstring
submit_job <- function(
    script_path, # full path to the script
    job_name = NULL, # Will be name of script if NULL.
    mem = "10G", # memory
    archiveTF = F, # Expects T/F
    threads = "2", # threads (uge: fthread)
    runtime = "20", # runtime, min
    Partition = "d.q", # partition (uge: queue)
    Account = "proj_covid", # account (uge: project)
    args_list = NULL, # optional list() of arguments, e.g. `list("--arg1" = arg1, "--arg2" = arg2)`
    SLURM_ERROR_PATH = NULL,
    R_IMAGE_PATH = NULL,
    r_shell = NULL
) {
  
  if (is.null(job_name)) {
    tmp <- unlist(strsplit(script_path, "[/.]"))
    job_name <- toupper(tmp[length(tmp) - 1])
  }
  
  if (is.null(SLURM_ERROR_PATH)) {
    SLURM_ERROR_PATH = file.path("/mnt/share/temp/slurmoutput", Sys.info()["user"], "errors")
  }
  
  if (is.null(r_shell)) {
    r_shell = "/ihme/singularity-images/rstudio/shells/execRscript.sh"
  }
  
  command <- paste0(
    "sbatch",
    " -J ", job_name,
    " --mem=", mem,
    ifelse(archiveTF, " -C archive", ""),
    " -c ", threads,
    " -t ", runtime,
    " -p ", Partition,
    " -A ", Account,
    " -o ", file.path(SLURM_ERROR_PATH, paste0(job_name, ".o%A_%a")),
    " ", r_shell,
    " -s ", script_path
  )
  
  if (!is.null(R_IMAGE_PATH)) {
    command <- paste0(command, " -i ", R_IMAGE_PATH)
  }
  
  for (arg_name in names(args_list)) { # append extra arguments
    command <- paste(command, arg_name, args_list[arg_name])
  }
  
  submission_return <- system(command, intern = T)
  message(paste("Cluster job submitted:", job_name, "; Submission return code:", submission_return))
  
  return(submission_return)
}
