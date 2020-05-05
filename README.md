# Installation

For now just install to a temporary directory. This should always work.
```
tmpinstall <- system("mktemp -d", intern = TRUE)
.libPaths(c(tmpinstall, .libPaths()))
devtools::install_github("ihmeuw/ihme.covid", upgrade = "never")
```

# Functions to use

* `ihme.covid::get_script_dir()`

Returns the directory your R script is in or NULL (if it fails).

This should work in files that are `source`d **or** called with `Rscript`
```
# source my_functions.R that lives in the same directory as this script
this_dir <- ihme.covid::get_script_dir()
source(file.path(this_dir, "my_functions.R"))
```

* `print_debug`

Convenience function for printing values in the namespace.

If your code looks like this ...
```
infile_path <- "/path/to/file.csv"
age_bins <- 5
outfile = "/path/to/output.csv"


ihme.covid::print_debug(infile_path, age_bins, outfile)
```

it will print this...
```
infile_path: /path/to/file.csv
age_bins: 5
outfile: /path/to/output.csv
```

* `get_output_dir`

Wraps common logic associated with getting the next output directory.

Normal use will be to provide a `root` where data is saved and a date which is probably `"today"` but can be ANY `YYYY_MM_DD` date you wish.

```
# returns the next release for *today*
get_output_dir(
  root = "/ihme/covid-19/temperature"
  date = "today")

# returns the next release for 2020_05_01
get_output_dir(
  root = "/ihme/covid-19/temperature"
  date = "2020_05_01")
```

* `get_latest_output_date_index`

From `hospitalization_sim_functions.r`

```
# returns 2, as there are 2 releases on this date and the newest is 2
ihme.covid::get_latest_output_date_index("/ihme/covid-19/snapshot-data", "2020_05_02")
# returns 0, as there are no releases on this date
ihme.covid::get_latest_output_date_index("/ihme/covid-19/snapshot-data", "1999_09_09")
```
