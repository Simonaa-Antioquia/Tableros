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
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel);library(stringr);
library(shiny); library(plotly)
################################################################################-
server <- function(input, output, session) {
  resultado <- reactive({
    tipo <- input$tipo
    anio_seleccionado <- input$anio
    productos_seleccionados <- input$producto
    
    
    if (input$anio == "") {
      if (input$mes == "") {
        if (input$tipo == 1) {
          result <- diferencias_precios(input$tipo,"","")
        } else if (input$tipo == 0) {
          result <- diferencias_precios(input$tipo,"","",input$producto)
        }
      } else {
        if (input$tipo == 1) {
          result <- diferencias_precios(input$tipo,"",input$mes)
        } else if (input$tipo == 0) {
          result <- diferencias_precios(input$tipo,"",input$mes,input$producto)
        }
      }
    } else {
      if (input$mes == "") {
        if (input$tipo == 1) {
          result <- diferencias_precios(input$tipo,input$anio,"")
        } else if (input$tipo == 0) {
          result <- diferencias_precios(input$tipo,input$anio,"",input$producto)
        }
      } else {
        if (input$tipo == 1) {
          result <- diferencias_precios(input$tipo,input$anio,input$mes)
        } else if (input$tipo == 0) {
          result <- diferencias_precios(input$tipo,input$anio,input$mes,input$producto)
        }
      }
    }
  })
  
  output$plot <- renderPlotly({
    ggplotly(resultado()$grafico)
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
      webshot::webshot(tempFile, file = file, delay = 2)
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
    res <- resultado()  
    print(res)  
    precio_max <- res$precio_max
    precio_min <- res$precio_min
    ciudad_max <- res$ciudad_max
    ciudad_min <- res$ciudad_min
    
    return(paste("El menor precio reportado para el periodo y producto seleccionado es", precio_min,"y se reporto en", ciudad_min, "frente al mayor precio reportado en", ciudad_max, "y fue de",precio_max,"pesos")) 
  })
}
