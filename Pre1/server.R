#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 27/02/2024
#Fecha de ultima modificacion: 27/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot); library(shiny);library(htmlwidgets);library(webshot);library(magick);library(shinyscreenshot)
options(scipen = 999)
################################################################################
server <- function(input, output, session) {
  
  ## The element vals will store all plots and tables
  vals <- reactiveValues(plt1=NULL)  
  
  resultado<-reactive({
    if(input$anio == "todo" && input$producto == "todo"){
      graficar_variable(data, variable=input$variable)
    } else if(input$producto == "todo"){
      graficar_variable(data, variable=input$variable,  fecha = input$anio)
    } else if(input$anio == "todo"){
      graficar_variable(data,variable=input$variable, input$producto)
    } else{
      graficar_variable(data,variable=input$variable, input$producto, input$anio)
    }
  })
  
  #Cambiar la imagen cada que cambian los filtros
  observe({
    vals$plt1 <- plotly::ggplotly(resultado()$grafico)
  })
  
  observeEvent(input$reset, {
    updateSelectInput(session, "producto", selected = "todo")
    updateSelectInput(session, "variable", selected = "precio_prom")
    updateSelectInput(session, "anio", selected = "todo")
  })
  
  
  output$grafico <- renderPlotly({
    plotly::ggplotly(resultado()$grafico)
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  

output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$datos, file)
    }
  )
  
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    promedio <- formatC(resultado$promedio, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)
    fecha_max <- resultado$fecha_max
    fecha_min <- resultado$fecha_min
    return(paste0("El precio promedio",ifelse(input$producto==""," por kg",paste0(" del kg de ", input$producto)) ," fue de $", promedio,
                  ". El mes con el precio más alto fue ", fecha_max, " y el más bajo fue ", fecha_min))
  })
  
  
  output$mensaje1 <- renderText({
    resultado <- resultado()
    volatil<-resultado$producto_vol
    return(volatil)
  })
  
  output$mensaje2 <- renderText({
    resultado <- resultado()
    promedio_camb<-resultado$promedio_camb
    return(promedio_camb)
  })
  
  output$mensaje3 <- renderText({
    resultado <- resultado()
    promedio_camb_an<-resultado$promedio_camb_an
    return(promedio_camb_an)
  })
  
  observeEvent(input$go, {
    screenshot()
  })
  
  output$export = downloadHandler(
    filename = function() {"plot.png"},
    content = function(file) {
      temp_file <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(vals$plt1, file = temp_file, selfcontained = FALSE)
      webshot::webshot(url = temp_file, file = file)
    }
  )
  
}
  
