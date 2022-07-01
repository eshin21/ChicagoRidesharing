# STAT231F19-GroupA: Chicago Rideshare and Demographics Data
Group project repo for Enoch Shin and Felix Stetsenko

[Presentation](https://docs.google.com/presentation/d/14YcaReYEkX2YKXQhY-JxTTYR2Pbggy3KdCO9XLtfE8M/edit?usp=sharing)

[Shinyapps.io App](https://enochshin.shinyapps.io/ChicagoRideshare/)


# Motivation 

  This project was partly inspired by a [2018 article in the Atlantic](https://www.theatlantic.com/business/archive/2018/03/chicago-segregation-poverty/556649/), detailing the extreme “Tale of Two Cities” that characterizes the Chicago of today [(Semuels 2018)](https://www.theatlantic.com/business/archive/2018/03/chicago-segregation-poverty/556649/). 
  
  While portions of the city are booming -- corporations like McDonalds and GE Healthcare have recently moved their headquarters to the loop, Chicago’s downtown area -- and overall unemployment is at a near all-time low -- 4.1% -- neighborhoods across the southern and western portions of the city are struggling.  Crime and gun violence is a plague across portions of the city; access to jobs, mass transit, and good schools is limited: this sharp divide exists along racial lines, as seen by income and poverty statistics by race, compiled from the U.S. Census Bureau’s 2017 American Community Survey 5-year estimates [(Bureau n.d.)](https://www.census.gov/programs-surveys/acs).

# Question

  Can Chicago’s segregation be visualized through other means?  Does it extend to, say, commuting and transportation patterns? We stumbled across the City of Chicago’s Open Data Portal, which offers a wealth of information pertaining to city demographics, public safety statistics, 311 service requests, locations of towed vehicles, and -- what would become relevant for our project -- [Transportation Network Provider (TNP) pickup and dropoff data (Levy 2019)](https://data.cityofchicago.org/Transportation/Transportation-Network-Providers-Trips/m6dm-c72p).
	  
  All TNP (ridesharing services, Uber, Lyft, etc.) are required to share data with Chicago.  We imagine that this data is useful for government officials to understand, say, where public transit is inadequate or perhaps where additional infrastructure (Uber/Lyft dropoff/pickup zones) is needed.

**Our question in practice for this project became the following: if we plot ridesharing trips (using the pickup and dropoff census tract locations) and combine it with data on income and poverty metrics by race, will we find any revealing patterns?**

# Navigating the repository

  All relevant files for this project are organized under the `ChicagoCommute` directory. See the `FinalReport` file for details about our conclusions and our sources.
  There are READMEs that detail the steps for each component of the project. See the [app README here](https://github.com/eshin21/ChicagoRidesharing/blob/master/ChicagoCommute/app/README.md) for technical details about our Shiny application. 
