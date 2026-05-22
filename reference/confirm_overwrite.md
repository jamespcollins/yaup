# Confirm before overwriting existing output file with changed data

Description

## Usage

``` r
confirm_overwrite(
  data,
  target,
  force_in_batch = TRUE,
  compress = "none",
  pass_data = FALSE,
  archive = NULL,
  rds_dir = ".csv_overwrites",
  use_here = TRUE
)
```

## Arguments

- data:

  Current working data.

- target:

  Target file path. Should end in .rds or .csv.

- force_in_batch:

  If called via an R CMD BATCH job, whether to force overwrite and
  archive. Default TRUE.

- compress:

  Pass-through parameter to readr::write_rds.

- pass_data:

  If successful, return the supplied data for further action. Default
  true.

- archive:

  If user chooses to overwrite file, rename existing file as archival
  copy. Default NULL prompts for action.

- rds_dir:

  The directory to store RDS representations of CSVs.

- use_here:

  Use here::here() to reference to project.

## Value

returns

## Examples

``` r
if (FALSE) { # \dontrun{
# Example title
} # }
```
