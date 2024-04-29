#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/02/2024
#Fecha de ultima modificacion: 25/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readxl);library(reshape2);library(ggplot2);library(gganimate);library(dplyr);
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel);
  library(magick); library(gifski)
################################################################################-

server <- function(input, output, session) {
  
  output$producto <- renderUI({
    if (input$tipo == "Producto") {
      selectInput("producto", "Seleccione producto:",  choices = unique(data$producto))
    }
  })
  
  resultado <- reactive({
    diferencias_precios(input$tipo, input$anio, input$mes, input$producto)
  })
  
  output$plot <- renderImage({
    # Use the result from resultado()
    res <- resultado()
    
    # Return a list containing the filename
    list(src = res$gif_path,
         contentType = 'image/gif'
    )}, deleteFile = TRUE)
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_principales_municipios_reciben_", Sys.Date(), ".gif", sep="")
    },
    content = function(file) {
      # Copy the GIF file to the download location
      file.copy(resultado()$gif_path, file)
    }
  )
  
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write_csv(resultado()$datos, file)
    }
  )
  
  output$subtitulo <- renderText({
    res <- resultado()
    precio_max <- res$precio_max
    precio_min <- res$precio_min
    ciudad_max <- res$ciudad_max
    ciudad_min <- res$ciudad_min
    
    return(paste0(ciudad_max," es $", precio_max, " costosa que Medellín, mientras que ", ciudad_min," es $", precio_min," más barata."))
  })
}