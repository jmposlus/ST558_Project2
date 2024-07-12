library(shiny)
library(jsonlite)
library(tidyverse)
library(dplyr)
library(ggplot2)

#Need the meta data
bpURL<- "https://bikepedinator.pythonanywhere.com/metadata"
bpinfo<- httr::GET(bpURL)
bpParsed<- fromJSON(rawToChar(bpinfo$content))

#Need the function to query the API based on user input
getSiteData<- function(siteID){
  bpdURL<- paste("https://bikepedinator.pythonanywhere.com/data/",siteID,sep = "")
  bpdinfo<- httr::GET(bpdURL)
  bpdParsed<- as_tibble(fromJSON(rawToChar(bpdinfo$content)))
  return(bpdParsed)
}

#And I need the correct ID for the API query from the list
getID<- function(name, dat){
  ID<- dat %>% filter(StationName == name)
  return(ID[2])
}

shinyServer(function(input, output, session){
  #Let's go ahead and get out subset data from the data tab
  #Should be able to use this code twice for the plot tab
result<- reactive({
  ID<- getID(input$StationName, bpParsed) #Get ID
  sitedata<- getSiteData(ID) #Get Data
  sitedata$Date<- as.Date(sitedata$Date) #My colleague stored the dates as characters
  sitedata<- sitedata %>% filter(Date<= input$EndDate) %>% filter(Date >= input$StartDate) #Filter based on user input
})

output$table<- renderTable({result()})
output$downloadData<- downloadHandler(
  filename = function(){
    paste("BikePedDownload",Sys.Date(),".csv",sep = "")
  },
  content = function(file){
    write.csv(result(), file, row.names = F)
  }
)
  
  #Sub-setting the Data all over again
  for_plot<- reactive({
    ID2<- getID(input$StationName_P, bpParsed)
    sitedata2<- getSiteData(ID2)
    sitedata2$Date<- as.Date(sitedata2$Date)
    sitedata2<- sitedata2 %>% filter(Date <= input$EndDate_P) %>% filter(Date >= input$StartDate_P)
  })
  #Actually plotting now
  output$plot<- renderPlot({
    input$newplot
    ggplot(data = for_plot(), aes(x = Date, y = Count)) + geom_line()
  })
})