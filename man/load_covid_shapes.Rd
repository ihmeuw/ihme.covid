% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_covid_shapes.R
\name{load_covid_shapes}
\alias{load_covid_shapes}
\title{Load COVID-19 shapes from standard model-inputs}
\usage{
load_covid_shapes(
  location_set_id,
  location_set_version_id,
  version = "best",
  shp_path = NULL
)
}
\arguments{
\item{location_set_id}{integer representing location_set_id of the hierarchy}

\item{location_set_version_id}{integer representing location_set_version_id of the hierarchy}

\item{version}{character version. Defaults to "best"}

\item{shp_path}{path to shapefile to load. Used for testing and overwrites all other arguments.}
}
\description{
Load COVID-19 shapes and standardize column names to harmonize with standard location hierarchy names.
}
