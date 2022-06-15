library(shiny)
library(tidyverse)
library(tigris)
library(ggmap)
library(gpclib)
library(maptools)
library(magrittr)
library(leaflet)
library(sp)
library(geosphere)
library(htmltools)
#faster data
library(feather)
# random colors for diagnostics (to make sure one-to-one lines are actually being drawn)
library(circlize)
library(lubridate)
library(shinyWidgets)
library(shinydashboard)
library(shinyjs)
library(rgeos)
library(leaflet.extras)
library(shinycssloaders)
library(dashboardthemes)
library(shinyalert)
# #############
gpclibPermit()

# read data
valday <- read_feather("feather/valday_small.feather")
shapefile_race <- readRDS("RDA/shapefile_race.Rda")
shapefile_income <- readRDS("RDA/shapefile_income.Rda")
shapefile_chicago <- readRDS("RDA/chicagoBound.Rda")

#make sunset date to filter data
# sunset on Valentine's Day 2019 was at 5:22 CST
## which is 11:22 PM UTC
sunset <- lubridate::as_datetime("2019-02-14 23:22:00")

# create options for user selections
racenames <- c("Other", "Black", "White", "Hawaiian or Pacific Islander",
               "Asian", "Native American")
incomenames <- c("Median household income ($)", "Per capita income ($)",
                 "Median earnings for workers ($)", "Percent under poverty level (%)")

# clean up environment - this indicator is used for the sunset feature
if(exists("hasRun")){
  rm("hasRun")
}


# define ui with slider and animation control for time
ui <- dashboardPage(
  # Application title
  dashboardHeader(title="Chicago Rideshare and Demographics", 
                  titleWidth=400),
  dashboardSidebar(
    sliderInput(inputId = "time", label = "Time", 
                min = min(valday$trip_start_timestamp), 
                max = max(valday$trip_start_timestamp),
                value = min(valday$trip_start_timestamp),
                step=60*5, # set to increment by 300 seconds, adjust appropriately
                animate = animationOptions(
                  interval = 10, loop = FALSE)),
    
    # option for showing demographic variables
    selectInput(inputId ="showdemo", label="Demographic variables", 
                choices=c("None", "Race", "Income measures"), selected = "None"),
    
    sidebarMenu(
      menuItem("Map", tabName = "map"),
      menuItem("About", tabName = "about")
    ),
    
    
    useShinyjs(), # Include shinyjs in the UI
    useShinyalert()
    
  ),
  
  dashboardBody(
    # options for types of visualization (see README)
    
    tabItems(
      tabItem("map",
              column(width = 1,
                     shiny::actionButton(inputId = "clear", 
                                         label = "Clear the board")),
              column(width = 2, offset = 1,
                     shiny::actionButton(inputId = "blink", 
                                         label = "Point mode")),
              column(width = 1,
                     shiny::actionButton(inputId = "showall", 
                                         label = "Show all")),           
              
              leafletOutput("demographic_map", height="85vh")
      ),
      
      tabItem("about",
              fluidPage(
                includeMarkdown("about.md")
              )
      )
    ),
    
    
    
    shinyDashboardThemes(
      theme = "grey_dark"
    ),
  )
  
)


server <- function(input, output, session){
  
  
  shinyalert("Welcome", "Welcome to the Chicago Rideshare App (beta)! \n\n
            \tThis application visualizes a random sample of 500 rideshare trips undertaken on Valentine's Day 2019 in Chicago. Over the course of the day, the application plots the paths of each trip, giving an idea of the userbase of private rideshare services like Uber and Lyft. \n 
             \t The user can overlay census demographic data such as racial and economic distributions to observe correlations between rideshare usage and demographic patterns. \n
          \t Press \"play\" to see the rides drawn over time. When the timeline hits sunset, the map changes to dark mode, so users can see the difference in ridership patterns during the day and night. \n\n 
          \t For the demographic data, the recommended sequence is to click the \"Show all\" overlay and then select demographic variables. Note that you need to de-select a previously chosen value before choosing to overlay another.", type = "info", closeOnEsc = TRUE, closeOnClickOutside = TRUE)
  
  # helper function: change the points available for drawing based on timeslider
  points <- reactive({
    valday_filtered <- valday %>% 
      filter(trip_start_timestamp <= input$time)  %>%
      filter(trip_start_timestamp == max(trip_start_timestamp))
  })
  
  #draw base map
  
  output$demographic_map <- renderLeaflet({
    
    leaflet(options=leafletOptions(preferCanvas = TRUE, 
                                   zoomControl=FALSE)) %>%
      htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
    }") %>%
      setView(lat = 41.9,
              lng = -87.7, zoom = 10) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(data=shapefile_chicago,
                  weight=1.5, color="black",
                  fillOpacity = 0, group="border")
    
  })
  
  
  #reactive map based on slider's time output
  #change the points available for drawing based on timeslider
  observeEvent(input$time, {
    req(!input$blink)
    valday_current <<- points()
    
    
    if(input$time < sunset){
      for(i in 1:nrow(valday_current)){
        addlines <- leafletProxy("demographic_map") %>%
          addPolylines(data=valday_current, 
                       lng=as.numeric(valday_current[i,c(15,18)]),
                       lat =as.numeric(valday_current[i,c(14, 17)]), 
                       weight=0.8,
                       color = "#3895D3",
                       group="daytime")
        
      }
      addlines 
    }  
    # change to dark mode when sunset hits
    else if(input$time >= sunset){
      
      if(!exists("hasRun")){
        print("night mode on")
        leafletProxy("demographic_map") %>%
          clearTiles() %>%
          hideGroup("border") %>%
          addProviderTiles(providers$CartoDB.DarkMatter) 
        hasRun <<- TRUE
      }
      else if(exists("hasRun")){
        # leafletProxy("demographic_map") %>%
        # addProviderTiles(providers$CartoDB.DarkMatter)
        for(i in 1:nrow(valday_current)){
          addlines <- leafletProxy("demographic_map") %>%
            addPolylines(data=valday_current,
                         lng=as.numeric(valday_current[i,c(15,18)]),
                         lat =as.numeric(valday_current[i,c(14, 17)]),
                         weight=1,
                         color = "yellow",
                         group="evening")
        }
        addlines
      }
    }
    # add chicago city border
    leafletProxy("demographic_map") %>%
      addLayersControl(
        overlayGroups = c("daytime", "evening")
      ) %>%
      addPolygons(data=shapefile_chicago,
                  weight=2, color="black",
                  fillOpacity = 0)
  })
  # if "clear all" button is clicked, do that
  observeEvent(input$clear, {
    leafletProxy("demographic_map") %>%
      clearShapes() %>%
      clearMarkers() %>%
      clearPopups() %>%
      clearControls() 
  })
  
  #show demographics option
  observeEvent(input$showdemo,{
    
    if(input$showdemo == "Race"){
      # clear previous
      leafletProxy("demographic_map") %>%
        clearControls() 
      # cycle through possible races and prepare all layers for all races
      for(i in 1:6){
        # grab the columns for each race's proportion - columns 16-21
        racevar <- names(shapefile_race@data)[15+i]
        racedata <- shapefile_race@data[[racevar]]
        
        # make label
        racegroup <- racenames[i]
        
        # make palette
        palette <- leaflet::colorNumeric(
          palette="Spectral",
          domain = racedata,
          reverse = TRUE
        )
        # draw map
        # give each race its own map group
        ## to selectively show/hide
        leafletProxy("demographic_map") %>%
          hideGroup(racenames) %>%
          addPolygons(data=shapefile_race,
                      fillColor=~palette(racedata),
                      stroke=FALSE,
                      group = racegroup) #critical for layer control
        
      }
      # add layer control
      leafletProxy("demographic_map") %>%
        hideGroup(racenames) %>%
        addLayersControl(
          overlayGroups = racenames,
          options = layersControlOptions(collapsed = FALSE,
                                         position="bottomleft")) 
      
    }
    
    # same process as above but for income
    if(input$showdemo=="Income measures"){
      
      leafletProxy("demographic_map") %>%
        clearControls() %>%
        hideGroup(racenames) 
      
      for(i in 1:4){
        
        incomevar <- names(shapefile_income@data)[15+i]
        incomedata <- shapefile_income@data[[incomevar]]
        incomegroup <- incomenames[i]
        
        palette <- leaflet::colorNumeric(
          palette="Spectral",
          domain = incomedata,
          reverse = TRUE
        )
        
        leafletProxy("demographic_map") %>%
          hideGroup(incomenames) %>%
          addPolygons(data=shapefile_income,
                      fillColor=~palette(incomedata),
                      stroke=FALSE,
                      group = incomegroup) 
        
      }
      
      leafletProxy("demographic_map") %>%
        # hideGroup(incomenames) %>%
        addLayersControl(
          overlayGroups = incomenames,
          options = layersControlOptions(collapsed = FALSE,
                                         position="bottomleft")) 
      
    }
  })
  
  # make reactive legends for race/income
  # show layer for selected value of race or income
  # we already built the layers above
  observeEvent(input$demographic_map_groups,{
    
    demographic_map <- leafletProxy("demographic_map") %>%
      clearControls()
    
    if("Other" %in% input$demographic_map_groups){
      
      racedata <- shapefile_race@data[["Some.other.race"]]
      
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = racedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = racedata,
          position = "bottomright",
          title = "Proportion of persons of other race")
      
    }
    
    else if("Black" %in% input$demographic_map_groups){
      
      racedata <- shapefile_race@data[["Black.or.African.American"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = racedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = racedata,
          position = "bottomright",
          title = paste0("Proportion of Black persons"))
      
    }
    
    else if("White" %in% input$demographic_map_groups){
      
      racedata <- shapefile_race@data[["White"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = racedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = racedata,
          position = "bottomright",
          title = paste0("Proportion of White persons"))
      demographic_map
      
    }
    
    else if("Hawaiian or Pacific Islander" %in% input$demographic_map_groups){
      
      racedata <- shapefile_race@data[["Native.Hawaiian.and.Other.Pacific.Islander"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = racedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = racedata,
          position = "bottomright",
          title = paste0("Proportion of Hawaiians or Pacific Islanders"))
      
    }
    
    else if("Asian" %in% input$demographic_map_groups){
      
      racedata <- shapefile_race@data[["Asian.alone"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = racedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = racedata,
          position = "bottomright",
          title = paste0("Proportion of Asian persons"))
      
    }
    
    else if("Native American" %in% input$demographic_map_groups){
      racedata <- shapefile_race@data[["American.Indian.and.Alaska.Native"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = racedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = racedata,
          position = "bottomright",
          title = paste0("Proportion of Native American persons"))
      
    }
    
    else if("Median household income ($)" %in% input$demographic_map_groups){
      incomedata <- shapefile_income@data[["Median.household.income"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = incomedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = incomedata,
          position = "bottomright",
          title = paste0("Median household income ($)"))
    }
    
    else if("Per capita income ($)" %in% input$demographic_map_groups){
      incomedata <- shapefile_income@data[["Per.capita.income"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = incomedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = incomedata,
          position = "bottomright",
          title = paste0("Per capita income ($)"))
    }
    
    else if("Median earnings for workers ($)" %in% input$demographic_map_groups){
      incomedata <- shapefile_income@data[["Median.earnings.for.workers"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = incomedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = incomedata,
          position = "bottomright",
          title = paste0("Median earnings for workers ($)"))
    }
    else if("Percent under poverty level (%)" %in% input$demographic_map_groups){
      incomedata <- shapefile_income@data[["Pct.under.poverty.level"]] 
      palette <- leaflet::colorNumeric(
        palette="Spectral",
        domain = incomedata,
        reverse = TRUE
      )
      
      demographic_map <- demographic_map %>%
        addLegend(
          pal = palette,
          values = incomedata,
          position = "bottomright",
          title = paste0("Percent under poverty level (%)"))
    }
    
    
  })
  
  # point mode
  observeEvent(input$blink,{
    leafletProxy("demographic_map") %>%
      clearShapes() %>%
      clearMarkers() %>%
      clearPopups() %>%
      clearControls() %>%
      clearTiles() %>%
      addProviderTiles(provider="CartoDB.DarkMatter") %>%
      addLegend(
        colors=c("yellow", "#42a5f5"),
        labels=c("pickup", "dropoff"),
        position = "bottomright",
        title = paste0("Pickup/dropoff")
      )
  }) 
  # point mode dependent on time
  observeEvent(input$time, {
    # require point mode to be selected
    req(input$blink)
    
    currentData <<- points()
    # draw points based on time
    for(i in 1:nrow(currentData)){
      
      leafletProxy("demographic_map",
                   deferUntilFlush = FALSE) %>% 
        addCircleMarkers(data=currentData, 
                         lng=currentData[i,]$pickup_centroid_longitude,
                         lat = currentData[i,]$pickup_centroid_latitude,
                         color="yellow", stroke=FALSE) %>%
        addCircleMarkers(data=currentData, 
                         lng=currentData[i,]$dropoff_centroid_longitude,
                         lat = currentData[i,]$dropoff_centroid_latitude,
                         color="#42a5f5", stroke=FALSE)
      # shinyjs::delay(200, clearMarkers(leafletProxy("demographic_map")))
    }
  }) 
  
  # show all feature 
  observeEvent(input$showall, {
    leafletProxy("demographic_map") %>%
      clearShapes() %>%
      clearMarkers() %>%
      clearPopups() %>%
      clearControls() %>%
      clearTiles() %>%
      addProviderTiles(provider="CartoDB.Positron") 
    
    for(i in 1:nrow(valday)){
      
      # color based on sunset
      if(valday[i,]$trip_start_timestamp < sunset){
        leafletProxy("demographic_map") %>%
          addPolylines(data=valday, 
                       lng=as.numeric(valday[i,c(15,18)]),
                       lat =as.numeric(valday[i,c(14, 17)]), 
                       weight=0.8,
                       color = "red",
                       group="daytime")
      }
      
      else{
        leafletProxy("demographic_map") %>%
          addPolylines(data=valday, 
                       lng=as.numeric(valday[i,c(15,18)]),
                       lat =as.numeric(valday[i,c(14, 17)]), 
                       weight=1.5,
                       color = "#42a5f5",
                       group="evening")
      }
      
    }
    # add legend and chicago border
    leafletProxy("demographic_map") %>%
      addLayersControl(
        overlayGroups = c("daytime", "evening")
      ) %>%
      addLegend(
        colors=c("red", "#42a5f5"),
        labels=c("daytime", "evening"),
        position = "bottomright",
        title = paste0("Time of day")
      ) %>%
      addPolygons(data=shapefile_chicago,
                  weight=2, color="black",
                  fillOpacity = 0)
    
  })
}

shinyApp(ui, server) 