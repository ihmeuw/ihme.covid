# Installation

For now just install to a temporary directory. This should always work.
```
tmpinstall <- system("mktemp -d --tmpdir=/tmp", intern = TRUE)
.libPaths(c(tmpinstall, .libPaths()))
devtools::install_github("ihmeuw/ihme.covid", upgrade = "never")
loadNamespace("ihme.covid")
```

# Usage

By default all functions are exported. That means you have two options

1. Namespace everything e.g., `ihme.covid::get_latest_output_date_index("/ihme/covid-19/snapshot-data", "2020_05_02")`
1. Use `library(ihme.covid)` and then call the function normally e.g., `get_latest_output_date_index("/ihme/covid-19/snapshot-data", "2020_05_02")`

# Functions to use

## `ihme.covid::get_script_dir()`

Returns the directory your R script is in or NULL (if it fails).

This should work in files that are `source`d **or** called with `Rscript`
```
# source my_functions.R that lives in the same directory as this script
this_dir <- ihme.covid::get_script_dir()
source(file.path(this_dir, "my_functions.R"))
```

## `print_debug`

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

## `get_output_dir`

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

## `get_latest_output_date_index`

From `hospitalization_sim_functions.r`

```
# returns 2, as there are 2 releases on this date and the newest is 2
ihme.covid::get_latest_output_date_index("/ihme/covid-19/snapshot-data", "2020_05_02")
# returns 0, as there are no releases on this date
ihme.covid::get_latest_output_date_index("/ihme/covid-19/snapshot-data", "1999_09_09")
```

## `sort_hierarchy`

Sort your existing location hierarchy by name, respecting the hierarchy.

In other words, "Italy" comes before "United States of America", and "Alabama" comes immediately after "United States of America" (because it's the first state alphabetically)

This will also **prepend** an arbitrary list of locations (by `location_id`) if you like.

```
# REQUIRES the following columns: location_id, location_name, path_to_top_parent
sorted <- ihme.covid::sort_hierarchy(dt)

# Same requirements as above. This time, list "Spokane County" and "Italy" before anything else
sorted <- ihme.covid::sort_hierarchy(dt, prepend = c(3539, 86))
```

## `error_on_missing_locations`

Errors if your data is missing 1 or more values relative to the location hierarchy.

Add a line like this to your code:
```
ihme.covid::error_on_missing_locations(shape@data$loc_id, hierarchy = hierarchy)
```

and get an error message if your data is missing locations in the hierarchy!

```
Error in ihme.covid::error_on_missing_locations(shape@data$loc_id, hierarchy = hierarchy) :
  shape@data$loc_id missing values for location_id(s): 24,367,369,413,416
```

## `load_covid_shapes`

Loads the covid shapefile and normalizes column names to be consistent with `get_location_metadata()`s output

```
world <- ihme.covid::load_covid_shapes(location_set_id = lsid, location_set_version_id = lsvid)
zwe <- world[world$location_id == 198, ]
```

This is meant to be easier and less error-prone than remembering alternative column names as shapefiles are limited to 10 characters for each column name.

## `barber_smooth`

Smooth a vector of positive numbers. Returns a **`matrix`** of equal dimensions to the input vector.

Add a line like this to your code:
```
ihme.covid::barber_smooth(vec = x, n_neighbors = 1, times = 1)
```

and get an error message if your vector has non-positive numbers
