# RDA data

Initially, we used the classic `saveRDS` and `readRDS` functions to perform data I/O. We've switched to `feather` now, with the exception of shapefiles since `feather` cannot handle those. 

**Thus, this folder contains shapefiles and some old RDA files in the `OLD` folder.**

Note that the `app` folder contains another copy of the `RDA` folder so that all the necessary app elements are in one place.
