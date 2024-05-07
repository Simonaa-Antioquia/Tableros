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
  
  
  output$grafico <- renderPlot({
    resultado()$grafico
  })#, res = 100)
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_tendencia_precios_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Forzar la ejecución de la función reactiva
      res <- resultado()
      
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = res$grafico, width = 13, height = 7, dpi = 300)
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