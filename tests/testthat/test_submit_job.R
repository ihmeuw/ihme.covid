
# NOTE: Set your working directory to the repo.
test_scripts_dir = "tests/testthat/fixtures/sbatch_scripts"
script1 = script_path = file.path(test_scripts_dir, "test_script_1.R")
return_regex = "Submitted batch job \\d{8}"

# Must run with just a valid script path.
test_that(
  desc = "Must run with just a valid script path.",
  {
    result = submit_job(script_path = script1)
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
    result = submit_job(script_path = script1)
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
    script_path = 10
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
    script_path = file.path("some_dir/we_should_never/make")
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
    
    # script_path is in the right place in command.
    ## script_path is after a shell script with a -s flag.
    expect_message(
      object = submit_job(script_path = script1, see_command = T),
      regexp = paste0("command: sbatch .*[.]sh .*-s ", script1)
    )
    ## script_path directly follows image_path when it is passed.
    image_path = "/ihme/singularity-images/rstudio/ihme_rstudio_3631.img"
    expect_message(
      object = submit_job(
        script_path = script1,
        image_path = image_path,
        see_command = T
      ),
      regexp = paste0("command: sbatch .* -i ", image_path, " -s ", script1)
    )
    
    # image_path directly follows shell script when passed.
    expect_message(
      object = submit_job(
        script_path = script1,
        image_path = image_path,
        see_command = T
      ),
      regexp = paste0("command: sbatch .*[.]sh -i ", image_path)
    )
  }
)

## job_name is in command (set and passed).
## mem is in command.
## archive is in command.
## cores is in command.
## runtime is in command.
## partition is in command.
## account is in command.
## output_path is in command.
## error_path is in command when passed.
## sbatch args are in command when passed.
## shell_path is in command.
## shell args are in command when passed.
## script args are in command when passed.
## command output when see_command set to true.