library(shiny)
bpURL<- "https://bikepedinator.pythonanywhere.com/metadata"
bpinfo<- httr::GET(bpURL)
bpParsed<- fromJSON(rawToChar(bpinfo$content))

ui<- fluidPage(
  titlePanel("Bicycle and Pedestrian Data in North Carolina"),
  
  tabsetPanel(
  tabPanel("About", markdown("This data comes from 163 sensors placed along greenways around North Carolina. My colleague has graciously made this publicly available to anyone without a key at https://bikepedinator.pythonanywhere.com/. This project is sponsered by NCDOT. The purpose of this app is to allow users to graphically explore the data for a site of interest and then download it. Please note that if data does not exist you may get an ERROR")),
  tabPanel("Data Download",
           sidebarLayout(
             sidebarPanel(
               selectInput(inputId = "StationName", "Site", bpParsed$StationName), #Which Site do you want? 
               dateInput(inputId = "StartDate", "Start Date",min = "2017-01-01"), #Beginning of counts
               dateInput(inputId = "EndDate", "End Date", min = "2017-01-01") #End of counts
             ),
             mainPanel(
               downloadButton("downloadData", "Download"),
               tableOutput("table")
             )
           )),
  tabPanel("Plot Data",
           sidebarLayout(
             sidebarPanel(
               selectInput(inputId = "StationName_P", "Site", bpParsed$StationName), #Which Site do you want? 
               dateInput(inputId = "StartDate_P", "Start Date",min = "2017-01-01"), #Beginning of counts
               dateInput(inputId = "EndDate_P", "End Date", min = "2017-01-01"), #End of counts
               actionButton("newplot","New Plot")
             ),
             mainPanel(
                plotOutput("plot")
             )
           ))
  
  ),
  sidebarLayout(
    sidebarPanel(
      
    ),
    mainPanel(
      
    )
  )
)