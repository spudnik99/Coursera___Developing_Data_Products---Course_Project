library(shiny)
library(leaflet)
library(RCurl)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Mexico: Population & Elevation Explorer"),
  navbarPage("Navbar!",
             tabPanel("App",  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("rangeP",
                  "Population:",
                  min = 0,
                  max = 2000000,
                   value = c(300000,2000000)),
       sliderInput("rangeE",
                   "Elevation (m):",
                   min = -2,
                   max = 3000,
                   value = c(-2,3000))
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      leafletOutput("mymap"),
      tableOutput("values")
    )
  )
),
tabPanel("Documentation",mainPanel(includeMarkdown("https://raw.github.com/spudnik99/DevelopingDataProducts_Coursera/master/README.md"))))
)
)