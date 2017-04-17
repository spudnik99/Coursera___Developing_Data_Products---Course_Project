30#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


library(shiny)
library(leaflet)
library(RCurl)

#the_data<-read.csv("h:/shinyapp/MexPopLatElev.csv")
gitcsv <- getURL("https://raw.githubusercontent.com/spudnik99/DevelopingDataProducts_Coursera/master/MexPopLatElev.csv")
the_data <- read.csv(text = gitcsv,header = TRUE)

totalpop<-sum(the_data$Municipality_Population)
difcolor<-(the_data$In_the_tropics+2)*2

pal <- colorNumeric(
  palette = "Reds",
  domain = the_data$In_the_tropics*8)
#pal <- setNames(pal, c(0, 1))

shinyServer(function(input, output) {
  
  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically
  #     re-executed when inputs change
  #  2) Its output type is a plot
 
  
  output$mymap <- renderLeaflet({
    elev_lower<-input$rangeE[1]
    elev_upper<-input$rangeE[2]
    pop_lower<-input$rangeP[1]
    pop_upper<-input$rangeP[2]
    
    filtered_data<-subset(the_data, (Average_Elevation>=elev_lower)&(Average_Elevation<=elev_upper)&(Municipality_Population>=pop_lower)&(Municipality_Population<=pop_upper))
    lats<-  filtered_data$Average_Latitude
    lngs<-  filtered_data$Average_Longitude
    popups<-filtered_data$Municipality
    pop<-   filtered_data$Municipality_Population    
    difcolor<-(filtered_data$In_the_tropics+2)*2
    
  leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addCircles(lng=lngs, lat=lats, radius=sqrt(pop)*30,popup=popups, color = pal(difcolor), weight=1)
    
        
   
    
  })
  output$values <- renderTable({
    elev_lower<-input$rangeE[1]
    elev_upper<-input$rangeE[2]
    pop_lower<-input$rangeP[1]
    pop_upper<-input$rangeP[2]
    #totalpop<-sum(the_data$Municipality_Population)
    filtered2_data<-subset(the_data, (Average_Elevation>=elev_lower)&(Average_Elevation<=elev_upper)&(Municipality_Population>=pop_lower)&(Municipality_Population<=pop_upper))
    selected_pop<-sum(filtered2_data$Municipality_Population)
    weighted_elevation<-sum(filtered2_data$Average_Elevation*filtered2_data$Municipality_Population)/selected_pop
    
    filtered2_data_t<-subset(the_data, (Average_Elevation>=elev_lower)&(Average_Elevation<=elev_upper)&(Municipality_Population>=pop_lower)&(Municipality_Population<=pop_upper)&(In_the_tropics==1))
    selected_pop_t<-sum(filtered2_data_t$Municipality_Population)
    weighted_elevation_t<-sum(filtered2_data_t$Average_Elevation*filtered2_data_t$Municipality_Population)/selected_pop_t
        
    data.frame(
      Measure = c("Selected population",
                  "Selected population, in tropics",
               "Total population",
               "Percent of total population selected",
               "Percent of total population selected, in the tropics",
               "Average elevation (m) weighted by population",
               "Average elevation (m) weighted by population, in the tropics"),
      Value = as.character(c(format(selected_pop,scientific = FALSE,big.mark = ","),
                             format(selected_pop_t,scientific = FALSE,big.mark = ","),
                             format(totalpop,scientific = FALSE,big.mark = ","),
                             100*selected_pop/totalpop,
                            100*selected_pop_t/totalpop,
                            format(weighted_elevation,scientific = FALSE,big.mark = ","),
                                   format(weighted_elevation_t,scientific = FALSE,big.mark = ","))), 
      stringsAsFactors=FALSE) 
  })
  
})