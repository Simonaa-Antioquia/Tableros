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
    res <- resultado()
    if (is.character(res)) {
      return(NULL)  # No hay gráfico para mostrar
    } else {
      plotly::ggplotly(res$grafico)
    }
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
  
  output$subtitulo <- renderText({
    tryCatch({
      # Intenta ejecutar este código
      res <- resultado()  
      print(res)  
      precio_max <- res$precio_max
      precio_min <- res$precio_min
      ciudad_max <- res$ciudad_max
      ciudad_min <- res$ciudad_min
      
      return(paste("El menor precio reportado para el período y producto seleccionado es $", precio_min, "por debajo del precio de Medellín y se reportó en", ciudad_min, ". El mayor precio reportado fue en", ciudad_max, "y fue de $", precio_max, "pesos más que el precio de Medellín"))
    }, error = function(e) {
      # Si ocurre un error, ejecuta este código
      return("No hay datos disponibles.")
    })
  })
  
  
  server <- function(input, output, session) {
    observeEvent(input$reset, {
      updateSelectInput(session, "tipo", selected = 1)
      updateSelectInput(session, "anio", selected = "")
      updateSelectInput(session, "mes", selected = "")
      updateSelectInput(session, "producto", selected = NULL)
    })
    }
  
  observeEvent(input$reset, {
    updateSelectInput(session, "tipo", selected = 1)
    updateSelectInput(session, "anio", selected = "")
    updateSelectInput(session, "mes", selected = "")
    updateSelectInput(session, "producto", selected = NULL)
  })
  
  output$mensaje1 <- renderText({
    tryCatch({
      # Intenta ejecutar este código
      if (input$tipo != 1) {
        return(paste0("El producto seleccionado es: ", input$producto))
      } else {
        return("En esta opción no se filtro por ningun producto")
      }
    }, error = function(e) {
      # Si ocurre un error, ejecuta este código
      return("No hay datos disponibles.")
    })
  })
  
  
  output$mensaje2 <- renderText({
    tryCatch({
      # Intenta ejecutar este código
      if (input$tipo != 1) {
        return(paste0("El lugar más costoso para comprar ", input$producto, " es ", resultado()$ciudad_max, ". Es $", resultado()$precio_max, " más costoso que comprarlo en Medellín."))
      } else {
        return(paste0("El lugar más costoso para comprar alimentos es ", resultado()$ciudad_max, ". En promedio es $", resultado()$precio_max, " más costoso que comprarlos en Medellín."))
      }
    }, error = function(e) {
      # Si ocurre un error, ejecuta este código
      return("No hay datos disponibles.")
    })
  })
  
  
  output$mensaje3 <- renderText({
    tryCatch({
      # Intenta ejecutar este código
      if (input$tipo != 1) {
        return(paste0("El lugar más economico para comprar ", input$producto, " es ", resultado()$ciudad_min, ". Es $", resultado()$precio_min, "más barato que comprarlo en Medellín."))
      } else {
        return(paste0("El lugar más economico para comprar alimentos es ", resultado()$ciudad_min, ". En promedio es $", resultado()$precio_min, " más barato que comprarlos en Medellín."))
      }
    }, error = function(e) {
      # Si ocurre un error, ejecuta este código
      return("No hay datos disponibles.")
    })
  })  
  

}