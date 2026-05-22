# Read a CSV path but from intermediate RDS store.

Description

## Usage

``` r
read_csv_from_intermediate(path, rds_dir = ".csv_overwrites")
```

## Arguments

- path:

  CSV path to read

- rds_dir:

  The directory to store RDS representations of CSVs.

## Value

Returns data read from RDS store.
