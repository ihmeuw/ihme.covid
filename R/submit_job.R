# TODO: Find best way to document defaults.
# TODO: How to explicitly allow multiple argument data types? Does R overload? How to document in Roxygen? (E.g., cores can be submitted as integer or character, and we can just convert to character when constructing command.)

#' @description  Submit a job to Slurm.
#'
#' \code{submit_job()} Runs a script with sbatch, accepting standard sbatch arguments in addition to an optional list of arguments to pass to the script.
#'
#' @param script_path [character] Full path to the script. Argument for `sbatch -s`.
#' @param job_name [character] Optional name to give job. Will be name of script if NULL.
#' @param mem [character] Memory to allocate. Should be valid argument format for `sbatch --mem`.
#' @param archiveTF [logical] To allow access to archive. Argument for `sbatch -C`.
#' @param threads [character] Cores to allocate. Argument for `sbatch -c`.
#' @param runtime [character] Minutes of runtime to allow. Argument for `sbatch -t`.
#' @param Partition [character] Partition to run on. Argument for `sbatch -p`.
#' @param Account [character] Account to attribute job to.
#' @param args_list [list()] Optional named list of arguments to pass to script, e.g. `list("--arg1" = arg1, "--arg2" = arg2)`.
#' @param SLURM_ERROR_PATH [character] Optional filepath to slurm error output. If not NULL, will send errors and output to same log file. Argument for `sbatch -o`.
#' @param R_IMAGE_PATH [character] Optional filepath to R image. Argument for `sbatch -i`.
#' @param r_shell [character] Optional filepath to image shell script. No associated flag for `sbatch`.
#' 
#' @return [character] `submission_return`, the return message from submitting `sbatch` `command` to `system(command, intern = T)`.
submit_job <- function(
    script_path,
    job_name = NULL,
    mem = "10G", # TODO: validate for G (or other options for --mem?)
    archiveTF = F,
    threads = "2",
    runtime = "20",
    Partition = "d.q",
    Account = "proj_covid",
    args_list = NULL,
    SLURM_ERROR_PATH = NULL,
    R_IMAGE_PATH = NULL,
    r_shell = NULL
) {
  
  # TODO: Validate input.
  
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
    # TODO: Only add if not NULL.
    # TODO: Allow users to pass -e and -o, so that output and errors can be separate if they wish.
    " -o ", file.path(SLURM_ERROR_PATH, paste0(job_name, ".o%A_%a")),
    # TODO: Only add if not NULL.
    # TODO: Does image require shell argument.
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
