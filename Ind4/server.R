#Proyecto FAO
#INDICE DE VULNERABILIDAD 
# SERVER
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 14/03/2024
#Fecha de ultima modificacion: 21/02/2024
################################################################################
# Paquetes 
################################################################################
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse); library(shiny); library(lubridate);library(shinythemes);library(shinyWidgets)
library(htmlwidgets);library(shiny);library(webshot);library(magick);

options(scipen = 999)
################################################################################

server <- function(input, output, session) {
  resultado <- reactive({
    tipo <- input$tipo
    anio_seleccionado <- input$anio
    productos_seleccionados <- input$producto
    
    if ((tipo == 2 || tipo == 4) && is.null(productos_seleccionados)) {
      validate(
        need(FALSE, "Debe seleccionar un producto.")
      )
    }
    
    if (is.null(productos_seleccionados)) {
      productos_seleccionados <- ""
    }
    if (tipo == 2) {
      grafica_indice(tipo, "", productos_seleccionados)
    } else if (tipo == 3) {
      if (is.null(anio_seleccionado)){
        grafica_indice(tipo)
      } else {
        grafica_indice(tipo, anio_seleccionado)
      }
    } else if (tipo == 4) {
      if (is.null(anio_seleccionado)){
        anio_seleccionado  <- ""
      }
      grafica_indice(tipo, anio_seleccionado, productos_seleccionados)
    } else {
      if (is.null(anio_seleccionado)){
        anio_seleccionado  <- ""
      }
      grafica_indice(tipo, anio_seleccionado, productos_seleccionados)
    }
  })
  
  # RENDER PLOTLY
  output$grafico <- plotly::renderPlotly({
    resultado()$grafico
  })
  # RENDER GRAFICO PLANO
  grafico_plano <- reactive({
    res<-resultado()
    if(nrow(res$datos)==0){
      validate(
        ("No hay datos disponibles")
      )
    }else{
      res$grafico_plano
    }
  }) 
  
  # HEAD DE LOS DATOS
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  # DESCARGAMOS LA GRAFICA
  output$descargar_ <- downloadHandler(
    filename = function() {
      paste("IND4_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Forzar la ejecución de la función reactiva
      res <- resultado()
      
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = res$grafico_plano, width = 13, height = 7, dpi = 200)
    }
  )
  
  #DESCARGA DE DATOS
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$datos, file)
    }
  )
  
# BOTON DE RESET
  observeEvent(input$reset, {
    updateSelectInput(session, "tipo", selected = 1)
  })
  
  
  
  # SUBTITULO
  
  values <- reactiveValues(subtitulo = NULL, mensaje1 = NULL)
  

output$subtitulo <- renderText({
    if ((input$tipo == 2 || input$tipo == 4) && is.null(input$producto)) {
      return("Debe seleccionar un producto.")
    }
    resultado <- grafica_indice(input$tipo, input$anio, input$producto)
    tipo <- input$tipo
    max_vulnerabilidad <- round(resultado$max_vulnerabilidad, digits = 1)
    fecha_max_vulnerabilidad <- resultado$fecha_max_vulnerabilidad
    producto_max_vulnerabilidad <- resultado$producto_max_vulnerabilidad
    
    fecha_max_vulnerabilidad <- as.character(fecha_max_vulnerabilidad)
    componentes <- strsplit(fecha_max_vulnerabilidad, "-")[[1]]
    anio <- componentes[1]
    mes <- componentes[2]
    dia <- componentes[3]
    nombres_meses <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                       "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")
    mes <- nombres_meses[as.integer(mes)]
    
    if (tipo == 2) {
      values$subtitulo <-(paste("En el ", fecha_max_vulnerabilidad, " se registró el índice de vulnerabilidad más alto, con un valor de " , max_vulnerabilidad, " para el producto ",producto_max_vulnerabilidad ))
      } else if (tipo == 3) {
        values$subtitulo <- (paste("En  ", mes, " del ", anio, " se registró el índice de vulnerabilidad más alto, con un valor de " , max_vulnerabilidad ))
    } else if (tipo == 4) {
      values$subtitulo <- (paste("En",mes, "del", anio, " se registró el índice de vulnerabilidad más alto, con un valor de " , max_vulnerabilidad, " para el producto ",producto_max_vulnerabilidad))
      } else {
        values$subtitulo <- (paste("En el ", fecha_max_vulnerabilidad, " se registró el índice de vulnerabilidad más alto, con un valor de " , max_vulnerabilidad))
      } 
    return(values$subtitulo)
  })

  output$mensaje1 <- renderText({
    values$mensaje1 <- ("El índice mide la vulnerabilidad del abastecimiento de alimentos, basándose en la cantidad de lugares de procedencia y su distancia a Medellín. Menos lugares y mayor distancia implican mayor vulnerabilidad.")
    values$mensaje1
    })
  
  
  # GENERAMOS INFORME 
  output$report <- downloadHandler(
    filename = 'informe.pdf',
    
    content = function(file) {
      # Ruta al archivo RMarkdown
      rmd_file <- "informe.Rmd"
      
      # Renderizar el archivo RMarkdown a PDF
      rmarkdown::render(rmd_file, output_file = file, params = list(
        tipo = input$tipo,
        producto= input$producto,
        anio = input$anio,
        plot = grafico_plano(),
        subtitulo = values$subtitulo,
        mensaje1 = values$mensaje1
        
      ))  
    },
    contentType = 'application/pdf'
  )     
  
  
}
