% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/barber_smooth.R
\name{barber_smooth}
\alias{barber_smooth}
\title{Kernel smooth as average of X neighbors}
\usage{
barber_smooth(vec, n_neighbors, times)
}
\arguments{
\item{vec}{Vector of positive values}

\item{n_neighbors}{Integer of number of nieghbors to smooth with}

\item{times}{Integer number of times to run the smoother}
}
\description{
Substitute in linear extension of first neighbor using average diff of nearest 3 
for first and last date
}
