
# NOTE: Set your working directory to the repo.
test_scripts_dir = "tests/testthat/fixtures/sbatch_scripts"
return_regex = "Submitted batch job \\d{8}"

# Must run with just a valid script path.
script_path = file.path(test_scripts_dir, "test_script_1.R")
test_that(
  desc = "Must run with just a valid script path.",
  {
    result = submit_job(script_path = script_path)
    expect(
      ok = grepl(return_regex, result),
      failure_message = paste0(
        "Passing only script_path ", script_path,
        " produced invalid submission return: ", result
      )
    )
  }
)

# Return must be valid.
test_that(
  desc = "Return must be 'Submitted batch job <job id>'.",
  {
    result = submit_job(script_path = script_path)
    expect(
      ok = grepl(return_regex, result),
      failure_message = paste0(
        "Passing only script_path ", script_path,
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
  }
)
## script_path must be a non-empty string.
## script_path must be a valid filepath.

# Command must be valid.
## script_path is in command.
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
## image_path is in command when passed.
## shell args are in command when passed.
## script args are in command when passed.
## command output when see_command set to true.