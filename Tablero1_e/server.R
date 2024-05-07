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
  
  output$plot <- plotly::renderPlotly({
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
  
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  # En el servidor

  output$subtitulo <- renderText({
    res <- resultado()  
    print(res)  
    precio_max <- res$precio_max
    precio_min <- res$precio_min
    ciudad_max <- res$ciudad_max
    ciudad_min <- res$ciudad_min
    
    return(paste("El menor precio reportado para el periodo y producto seleccionado es", precio_min," pesos por debajo del precio de Medellin y se reporto en", ciudad_min,". El mayor precio reportado fue en", ciudad_max, "y fue de",precio_max,"pesos mas que el precio de Medellín")) 
  })
  
  output$mensaje1 <- renderText({
    if (input$tipo != 1) {
      paste0("El producto seleccionado es: ", input$producto)
    } else {
      "En esta opción no se filtro por ningun producto"
    }
  })
  
  output$mensaje2 <- renderText({
    if (input$tipo != 1) {
      paste0("El lugar más costoso para comprar ", input$producto, " es ", resultado()$ciudad_max, ". Es ", resultado()$precio_max, " más costoso que comprarlo en Medellín.")
    } else {
      paste0("El lugar más costoso para comprar alimentos es ", resultado()$ciudad_max, ". En promedio es ", resultado()$precio_max, " más costoso que comprarlos en Medellín.")
    }
  })
  
  output$mensaje3 <- renderText({
    if (input$tipo !=1) {
      paste0("El lugar más economico para comprar ", input$producto, " es ", resultado()$ciudad_min, ". Es ", resultado()$precio_min, " pesos más barato que comprarlo en Medellín.")
    } else {
      paste0("El lugar más economico para comprar alimentos es ", resultado()$ciudad_min, ". En promedio es ", resultado()$precio_min, " más barato que comprarlos en Medellín.")
    }
  })
}