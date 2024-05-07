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
library(glue);library(tidyverse);library(gridExtra);library(corrplot); library(shiny)
options(scipen = 999)
################################################################################
server <- function(input, output, session) {
  
  resultado<-reactive({
    if(input$anio == "" && input$producto == ""){
      graficar_variables(data)
    } else if(input$producto == ""){
      graficar_variables(data,  fecha = input$anio)
    } else if(input$anio == ""){
      graficar_variables(data, input$producto)
    } else{
      graficar_variables(data, input$producto, input$anio)
    }
  })
  
  
  output$grafico <- renderPlotly({
    plotly::ggplotly(resultado()$grafico)
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica-", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      tempFile <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
      webshot::webshot(tempFile, file = file, delay = 2, vwidth = 480, vheight = 480)
    }
  )
  
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$datos, file)
    }
  )
  
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
    paste0("El producto seleccionado es: ", input$producto)
  })
  
  output$mensaje2 <- renderText({
    paste0("El año seleccionado es: ", input$anio)
  })
  
  output$mensaje3 <- renderText({
    paste0("El promedio de precios para ", input$producto, " en el año ", input$anio, " es: $", resultado()$promedio)
  })
}