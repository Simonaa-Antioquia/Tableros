#Proyecto FAO
#INDICE Herfindahl–Hirschman - shiny 2 - De donde viene la comida (municipios)
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 14/03/2024
#Fecha de ultima modificacion: 21/02/2024
################################################################################
# Paquetes 
################################################################################
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse); library(shiny); library(lubridate);library(shinythemes)
options(scipen = 999)
################################################################################
server <- function(input, output, session) {
  
  resultado <- reactive({
    tipo <- input$tipo
    anio_seleccionado <- input$anio
    productos_seleccionados <- input$producto
    
    if (is.null(productos_seleccionados)) {
      productos_seleccionados <- ""
    }
    if (tipo == 2) {
      grafica_indice_mun(tipo, "", productos_seleccionados)
    } else if (tipo == 3) {
      if (is.null(anio_seleccionado)){
        grafica_indice_mun(tipo)
      } else {
        grafica_indice_mun(tipo, anio_seleccionado)
      }
    } else if (tipo == 4) {
      if (is.null(anio_seleccionado)){
        anio_seleccionado  <- ""
      }
      grafica_indice_mun(tipo, anio_seleccionado, productos_seleccionados)
    } else {
      if (is.null(anio_seleccionado)){
        anio_seleccionado  <- ""
      }
      grafica_indice_mun(tipo, anio_seleccionado, productos_seleccionados)
    }
  })
  
  output$grafico <- renderPlot({
    resultado()$grafico
  }, res = 96)
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_indice_importancia_mpios", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      png(file,width = 10, height = 7, units = "in", res = 300)
      print(resultado()$grafico)
      dev.off()
    }
  )
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos_importancia_mpios", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$datos, file)
    }
  )
  
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- grafica_indice_mun(input$tipo, input$anio, input$producto)
    tipo <- input$tipo
    max_IHH <- resultado$max_vulnerabilidad
    fecha_max_vulnerabilidad <- resultado$fecha_max_vulnerabilidad
    producto_max_vulnerabilidad <- resultado$producto_max_vulnerabilidad
    
    if (tipo == 2) {
      return(paste("La mayor indice es en", fecha_max_vulnerabilidad, "para el producto", producto_max_vulnerabilidad, "y es de", max_IHH))
    } else if (tipo == 3) {
      return(paste("La maxima vulnerabilidad mensual, fue en", fecha_max_vulnerabilidad, "y es de", max_IHH))
    } else if (tipo == 4) {
      return(paste("La mayor vulnerabilidad fue en",fecha_max_vulnerabilidad, "para el prodcuto",producto_max_vulnerabilidad,"y fue de",max_IHH))
    } else {
      return(paste("El año con mayor indice de vulnerabilidad fue",fecha_max_vulnerabilidad, "y fue de",max_IHH))
    }
  })
}