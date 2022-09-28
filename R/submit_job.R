# TODO: Find best way to document defaults.
# TODO: How to explicitly allow multiple argument data types? Does R overload? How to document in Roxygen? (E.g., cores can be submitted as integer or character, and we can just convert to character when constructing command.)

#' @description  Submit a job to Slurm. See `sbatch` documentation: https://slurm.schedmd.com/sbatch.html
#'
#' \code{submit_job()} Runs a script with sbatch, accepting standard sbatch arguments in addition to an optional list of arguments to pass to the script.
#'
#' @param script_path [character] Path to the script to launch. Argument for `sbatch -s`.
#' @param job_name [character] Optional name to give job. Will be name of script if NULL.
#' @param mem [character] Memory to allocate. Should be valid argument format for `sbatch --mem`.
#' @param archive [logical] To allow access to archive. Argument for `sbatch -C`.
#' @param cores [character] Cores to allocate. Argument for `sbatch -c`.
#' @param runtime [character] Minutes of runtime to allow. Argument for `sbatch -t`.
#' @param partition [character] Partition to run on. Argument for `sbatch -p`.
#' @param account [character] Account to attribute job to. Argument for `sbatch -A`.
#' @param args_list [list()] Optional named list of arguments to pass (to the script or to sbatch), e.g. `list("--arg1" = arg1, "--arg2" = arg2)`.
#' @param error_path [character] Optional filepath to slurm error output. Will send errors and output to same log file. If NULL, will default to `file.path("/mnt/share/temp/slurmoutput", Sys.info()["user"], "errors")`. Argument for `sbatch -o`.
#' @param image_path [character] Optional filepath to image. Argument for `sbatch -i`.
#' @param shell_path [character] Optional filepath to image shell script. No associated flag for `sbatch`.
#' 
#' @return [character] `submission_return`, the return message from submitting `sbatch` `command` to `system(command, intern = T)`.
#' 
submit_job <- function(
    script_path,
    job_name = NULL,
    mem = "10G", # TODO: validate for G (or other options for --mem?)
    archive = F,
    cores = "2",
    runtime = "20",
    partition = "d.q",
    account = "proj_covid",
    args_list = NULL,
    error_path = NULL,
    image_path = NULL,
    shell_path = NULL
) {
  
  # TODO: Validate input.
  
  if (is.null(job_name)) {
    tmp <- unlist(strsplit(script_path, "[/.]"))
    job_name <- toupper(tmp[length(tmp) - 1])
  }
  
  if (is.null(error_path)) {
    error_path = file.path("/mnt/share/temp/slurmoutput", Sys.info()["user"], "errors")
  }
  
  if (is.null(shell_path)) {
    shell_path = "/ihme/singularity-images/rstudio/shells/execRscript.sh"
  }
  
  command <- paste0(
    "sbatch",
    " -J ", job_name,
    " --mem=", mem,
    ifelse(archive, " -C archive", ""),
    " -c ", cores,
    " -t ", runtime,
    " -p ", partition,
    " -A ", account,
    # TODO: Only add if not NULL.
    # TODO: Allow users to pass -e and -o, so that output and errors can be separate if they wish.
    " -o ", file.path(error_path, paste0(job_name, ".o%A_%a")),
    # TODO: Only add if not NULL.
    # TODO: Does image require shell argument.
    " ", shell_path,
    " -s ", script_path
  )
  
  if (!is.null(image_path)) {
    command <- paste0(command, " -i ", image_path)
  }
  
  for (arg_name in names(args_list)) { # append extra arguments
    command <- paste(command, arg_name, args_list[arg_name])
  }
  
  submission_return <- system(command, intern = T)
  message(paste("Cluster job submitted:", job_name, "; Submission return code:", submission_return))
  
  return(submission_return)
}
