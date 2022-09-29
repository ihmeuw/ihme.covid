
# NOTE: Set your working directory to the repo.
test_scripts_dir <- "tests/testthat/fixtures/sbatch_scripts"
script1 <- script_path <- file.path(test_scripts_dir, "test_script_1.R")
return_regex <- "Submitted batch job \\d{8}"

# Must run with just a valid script path.
# FIXME: Why is this test failing? Is it because the script path is relative to the repo root?
test_that(
  desc = "Must run with just a valid script path.",
  {
    result <- submit_job(script_path = script1)
    expect(
      ok = grepl(return_regex, result),
      failure_message = paste0(
        "Passing only script_path ", script1,
        " produced invalid submission return: ", result
      )
    )
  }
)

# Return must be valid.
test_that(
  desc = "Return must be 'Submitted batch job <job id>'.",
  {
    result <- submit_job(script_path = script1)
    expect(
      ok = grepl(return_regex, result),
      failure_message = paste0(
        "Passing only script_path ", script1,
        " produced invalid submission return: ", result
      )
    )
  }
)

# Inputs must be valid.
## script_path must be valid.
test_that(
  desc = "script_path must be valid.",
  {
    # script_path must be a string.
    script_path <- 10
    expect_error(
      object = submit_job(script_path = script_path),
      regexp = paste0("script_path must be a string. script_path: ", script_path)
    )

    # script_path must be a non-empty string.
    expect_error(
      object = submit_job(script_path = ""),
      regexp = "script_path is an empty string."
    )

    # script_path must be a valid filepath.
    script_path <- file.path("some_dir/we_should_never/make")
    expect_error(
      object = submit_job(script_path = script_path),
      regexp = paste0("script_path is not a valid or found filepath. script_path: ", script_path)
    )
  }
)

# Command must be valid.
test_that(
  desc = "Command must be valid.",
  {
    # Arguments are grouped with the commands/scripts to which they belong.
    ## sbatch args follow sbatch and precede shell_path.
    ## shell args follow shall_path and precede script_path.
    ## script args follow script_path.
    script_path <- script1
    job_name <- "test_job"
    mem <- "1G"
    archive <- T
    cores <- "2"
    runtime <- "1"
    partition <- "d.q"
    account <- "proj_covid"
    output_path <- "test_output_path"
    error_path <- output_path
    sbatch_args_list <- list("--test_sbatch_arg" = "test_sbatch_arg")
    shell_path <- "test_shell_path"
    image_path <- "test_image_path"
    shell_args_list <- list("--test_shell_arg" = "test_shell_arg")
    script_args_list <- list("--test_script_arg" = "test_script_arg")

    expect_message(
      object = tryCatch(
        suppressWarnings(
          submit_job(
            script_path = script_path,
            job_name = job_name,
            mem = mem,
            archive = archive,
            cores = cores,
            runtime = runtime,
            partition = partition,
            account = account,
            output_path = output_path,
            error_path = output_path,
            sbatch_args_list = sbatch_args_list,
            shell_path = shell_path,
            image_path = image_path,
            shell_args_list = shell_args_list,
            script_args_list = script_args_list,
            see_command = T
          )
        ),
        error = function(e){return(NULL)}
      ),
      regexp = paste0(
        "command: sbatch -J ", job_name, " --mem=", mem, " -C archive -c ", cores,
        " -t ", runtime, " -p ", partition, " -A ", account,
        " -o ", file.path(output_path, paste0(job_name, ".o%A_%a")), # TODO: could be less particular about the file type suffix.
        " -e ", file.path(output_path, paste0(job_name, ".e%A_%a")),
        " ", names(sbatch_args_list)[1], " ", sbatch_args_list[[names(sbatch_args_list)[1]]],
        " ", shell_path, " -i ", image_path,
        " ", names(shell_args_list)[1], " ", shell_args_list[[names(shell_args_list)[1]]],
        " -s ", script_path,
        " ", names(script_args_list)[1], " ", script_args_list[[names(script_args_list)[1]]]
      )
    )

    # # script_path is in the right place in command.
    # ## script_path is after a shell script with a -s flag.
    # expect_message(
    #   object = submit_job(script_path = script1, see_command = T),
    #   regexp = paste0("command: sbatch .*[.]sh .*-s ", script1)
    # )
    # ## script_path directly follows image_path when it is passed.
    # image_path = "/ihme/singularity-images/rstudio/ihme_rstudio_3631.img"
    # expect_message(
    #   object = submit_job(
    #     script_path = script1,
    #     image_path = image_path,
    #     see_command = T
    #   ),
    #   regexp = paste0("command: sbatch .* -i ", image_path, " -s ", script1)
    # )
    #
    # # image_path directly follows shell script when passed.
    # expect_message(
    #   object = submit_job(
    #     script_path = script1,
    #     image_path = image_path,
    #     see_command = T
    #   ),
    #   regexp = paste0("command: sbatch .*[.]sh -i ", image_path)
    # )
  }
)

## Required arguments are in command, especially when left out of function call.
## error_path is not in command when not passed.
## sbatch args are not in command when not passed.
## shell args are not in command when not passed.
## script args are not in command when not passed.
