#Proyecto FAO
#INDICE Herfindahl–Hirschman - shiny 2 - De donde viene la comida (municipios)
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 14/03/2024
#Fecha de ultima modificacion: 21/02/2024
# Tablero 7
################################################################################
# Paquetes 
################################################################################
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse); library(shiny); library(lubridate);library(shinythemes);library(plotly);
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
  
  
  
  output$grafico <- plotly::renderPlotly({
    resultado()$grafico
  })
  
  
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  # Descargar grafica 
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_indice_municipios", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      tempFile <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
      webshot::webshot(tempFile, file = file, delay = 2)
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
    if ((input$tipo == 2 || input$tipo == 4) && is.null(input$producto)) {
      return("Debe seleccionar un producto.")
    }
    
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

observeEvent(input$github, {
  browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
})  

# Borrar filtros
observeEvent(input$reset, {
  updateSelectInput(session, "tipo", selected = 1)
})

output$mensaje1 <- renderText({
  return("El índice de Herfindahl-Hirschman permite conocer el nivel de concentración de los alimentos en Antioquia, un mayor índice indica menos variedad de alimentos")
})

output$mensaje2 <- renderUI({
  withMathJax(paste0("La fórmula es: $$IHH = \\sum_{i=1}^{n} s_i^2$$ donde s es la participación del producto i en el total de alimentos y n es el número total de alimentos."))
})
  
}