# Chicago Rideshare and Demographics Application

*Purpose: An application that visualizes n=500 transportation network provider rides on Valentine's Day 2019 in Chicago, IL, with layers for race and income census data.*

[Shinyapps.io App](https://enochshin.shinyapps.io/ChicagoRideshare/)



## Tips and Features:

### Sidebar

`Time`:

* Press "play" to see the rides drawn live over time. When the timeline hits sunset, the map changes to dark mode. This allows for users to see the difference in ridership patterns during the day and night.

* Experimental feature: because of the computational intensity of drawing the polygons representing the trips, the timeline is laggy. 


`Demographic variables`:

* Allows user to overlay race and income variables over the map. The recommended sequence is to click the `Show all` overlay and then select demographic variables.

* Give this a bit of time to load. After that, you can toggle the different levels/values for the race and income variable using the legend popup.

* Note that you need to de-select a previously chosen value before choosing to overlay another. For example, if I chose to overlay white Chicagoans on the map, I'd have to de-select that option to change races.



### Buttons

`Clear the board`: 

* Self-explanatory. Note that this will clear *everything* on the board.

`Point mode`:

* Experimental feature.

* Simply drawing the paths as lines does not show us the *directionality* of the trips. Therefore, this feature enables the user to see the pickups and dropoffs, though the sheer quantity of data does make it hard to make conclusions.

`Show all`: 

* Shows all the ride paths, faceted by time of day (red = ride taken during day, blue = night). 

* After clicking this, hover over the layer icon on the right and choose whether you want to filter the rides by time of day. **Note:** you cannot go back and filter rides by time of day after you've selected demographic variables to overlay.


## Dependencies


The application relies on a couple datasets and shapefiles:

`app/feather` includes the tabular data:

* Data frame for the sampled *n* = 500 rides on Valentine's Day.

`app/RDA` includes the shapefiles:

* Shapefiles for income and race distributions

* Shapefile for City of Chicago boundaries 

*
