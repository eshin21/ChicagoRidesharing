# Feather data

Initially, we used the classic `saveRDS` and `readRDS` functions to perform data I/O. We've switched to `feather` now, with the exception of shapefiles since `feather` cannot handle those. 

Note that the `app` folder contains another copy of the `feather` folder so that all the necessary app elements are in one place, and so that `app.R` can read in accessory datasets for diagnostic purposes.

* Hadley Wickham (2019). feather: R Bindings to the Feather 'API'. R
  package version 0.3.5. https://CRAN.R-project.org/package=feather
