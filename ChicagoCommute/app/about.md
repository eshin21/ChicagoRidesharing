# Visualizing Chicago Rideshare and Demographics Data
*By Enoch Shin and Felix Stetsenko, Fall 2019*



### About the Application

This application visualizes a sample of 500 rideshare trips undertaken on Valentine's Day 2019 (February 14) in the City of Chicago. Over the course of the day, the application plots the paths of each sampled trip, giving a general idea of the userbase of private rideshare services like Uber and Lyft.

In addition, the user can overlay census tract-level demographic data such as racial and economic distributions to observe correlations between rideshare usage and demographic patterns.

Note that the demographic overlays should be selected **before** activating the timelapse feature in the sidebar, which plots the trips over the course of the day.


### Motivation 

  This project was partly inspired by a [2018 article in the Atlantic](https://www.theatlantic.com/business/archive/2018/03/chicago-segregation-poverty/556649/), detailing the extreme “Tale of Two Cities” that characterizes the Chicago of today [(Semuels 2018)](https://www.theatlantic.com/business/archive/2018/03/chicago-segregation-poverty/556649/). 
  
  While portions of the city are booming -- corporations like McDonalds and GE Healthcare have recently moved their headquarters to the loop, Chicago’s downtown area -- and overall unemployment is at a near all-time low -- 4.1% -- neighborhoods across the southern and western portions of the city are struggling.  Crime and gun violence is a plague across portions of the city; access to jobs, mass transit, and good schools is limited: this sharp divide exists along racial lines, as seen by income and poverty statistics by race, compiled from the U.S. Census Bureau’s 2017 American Community Survey 5-year estimates [(Bureau n.d.)](https://www.census.gov/programs-surveys/acs).

### Question

  Can Chicago’s segregation be visualized through other means?  Does it extend to, say, commuting and transportation patterns? We stumbled across the City of Chicago’s Open Data Portal, which offers a wealth of information pertaining to city demographics, public safety statistics, 311 service requests, locations of towed vehicles, and -- what would become relevant for our project -- [Transportation Network Provider (TNP) pickup and dropoff data (Levy 2019)](https://data.cityofchicago.org/Transportation/Transportation-Network-Providers-Trips/m6dm-c72p).
	  
  All TNP (ridesharing services, Uber, Lyft, etc.) are required to share data with Chicago.  We imagine that this data is useful for government officials to understand, say, where public transit is inadequate or perhaps where additional infrastructure (Uber/Lyft dropoff/pickup zones) is needed.

**Our question in practice for this project became the following: if we plot ridesharing trips (using the pickup and dropoff census tract locations) and combine it with data on income and poverty metrics by race, will we find any revealing patterns?**

 
