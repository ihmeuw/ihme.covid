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
#' @param sbatch_args_list [list()] Optional named list of arguments to pass to `sbatch`, e.g. `list("--arg1" = arg1, "--arg2" = arg2)`.
#' @param script_args_list [list()] Optional named list of arguments to pass to the script, e.g. `list("--arg1" = arg1, "--arg2" = arg2)`.
#' @param output_path [character] Optional filepath to slurm output. If NULL, will default to `file.path("/mnt/share/temp/slurmoutput", Sys.info()["user"], "errors")`. Will send errors and output to same log file if error_path is NULL. Argument for `sbatch -o`.
#' #' @param error_path [character] Optional filepath to slurm error output. Will send errors and output to same log file. If NULL, will send errors to same log file as output. Argument for `sbatch -e`.
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
    sbatch_args_list = NULL,
    script_args_list = NULL,
    output_path = NULL,
    image_path = NULL,
    shell_path = NULL
) {
  
  # TODO: Validate input.
  
  if (is.null(job_name)) {
    tmp <- unlist(strsplit(script_path, "[/.]"))
    job_name <- toupper(tmp[length(tmp) - 1])
  }
  
  if (is.null(output_path)) {
    output_path = file.path("/mnt/share/temp/slurmoutput", Sys.info()["user"], "errors")
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
    " -o ", file.path(output_path, paste0(job_name, ".o%A_%a")),
    ifelse(
      is.null(error_path),
      "",
      paste0(" -e ", file.path(output_path, paste0(job_name, ".e%A_%a")))
    )
  )
  
  for (arg_name in names(sbatch_args_list)) { # Append extra arguments for sbatch.
    command <- paste(command, arg_name, sbatch_args_list[arg_name])
  }
  
  command <- paste0(
    command,
    # TODO: Does image require shell argument.
    ifelse(is.null(shell_path), "", paste0(" ", shell_path)),
    " -s ", script_path,
    ifelse(is.null(image_path), "", paste0(command, " -i ", image_path))
  )
  
  for (arg_name in names(script_args_list)) { # Append extra arguments for script.
    command <- paste(command, arg_name, script_args_list[arg_name])
  }
  
  submission_return <- system(command, intern = T)
  message(paste("Cluster job submitted:", job_name, "; Submission return code:", submission_return))
  
  return(submission_return)
}
