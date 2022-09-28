
# Return must be valid.
## Return type must be (?).
## A valid test script must return a job id.

# Inputs must be valid.
## script_path must be a string.
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