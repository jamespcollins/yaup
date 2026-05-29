# Write to a log file

Writes a timestamped message to a log file.

## Usage

``` r
write_log(message, log_obj, type = "INFO")
```

## Arguments

- message:

  Message to log.

- log_obj:

  `log` object created with
  [`open_log()`](http://jpcollins.me/yaup/reference/open_log.md).

- type:

  Log message type. Valid values are `INFO`, `WARN`, and `ERROR`.

## Value

Echos log message to console.
