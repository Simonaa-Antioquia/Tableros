# Proyecto FAO
# Visualizacion de DATOS 2  - abastecimeinto en Medellin 
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 20/03/2024
#Fecha de ultima modificacion: 23/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(shiny); library(shinydashboard)
options(scipen = 999)
################################################################################-
# Definir la función de servidor
server <- function(input, output, session) {
  

  
  resultado<-reactive({
    if (is.null(input$municipios) || is.na(input$municipios) || input$municipios == 0) {
      return(NULL)
    }
    # Comprobar si solo se ha seleccionado un producto
    if (input$producto != "" && input$anio == "" && input$mes == "") {
      importancia(Producto = input$producto)
    } else if (input$mes != "" && input$anio == "") {
      validate(
        need(input$anio != "", "Debe seleccionar un año.")
      )
    } else if(input$anio == "" && input$producto == "" && input$mes == ""){
      importancia(municipios = input$municipios)
    } else if(input$producto == "" && input$mes == "" ){
      importancia(Año = input$anio, municipios = input$municipios)
    } else if(input$producto == ""){
      importancia(Año = input$anio, Mes = input$mes ,municipios = input$municipios)
    } else if(input$mes == "" ){
      importancia(Año = input$anio, municipios = input$municipios, Producto = input$producto)
    } else if(input$anio == "" && input$mes == ""){
      importancia(Producto = input$producto)
    } else{
      importancia(Año = input$anio, Mes = input$mes ,municipios = input$municipios, Producto = input$producto)
    }
  })
  


  output$grafico <- plotly::renderPlotly({
    res <- resultado()
    if (is.character(res) || length(res) == 0 || is.null(input$municipios) || input$municipios < 1) {
      return(NULL)  # No hay gráfico para mostrar
    } else {
      res$grafico  # Devuelve el gráfico Plotly
    }
  })

  
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_principales_municipios_traen_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Forzar la ejecución de la función reactiva
      res <- resultado()
      
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = res$grafico, width = 13, height = 7, dpi = 200)
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
    resultado <- resultado()
    lugar_max <- resultado$lugar_max
    porcentaje_max<-resultado$porcentaje_max
   
    if (is.na(input$municipios) || is.null(input$municipios )){
      return("Por favor ingrese el numero de municipios que quiere graficar")
    } else {
      return(paste0(lugar_max, "es el municipio con mayor importancia en el abastecimeinto de Antioquia, aporta ",porcentaje_max,"%"))
    }
  })
  
 
 observeEvent(input$reset, {
      updateSelectInput(session, "municipios", selected = 10)
      updateSelectInput(session, "anio", selected = "")
      updateSelectInput(session, "mes", selected = "")
      updateSelectInput(session, "producto", selected = NULL)
    })
 
 output$mensaje1 <- renderText({
    if (is.na(input$municipios)) {
       return("")
     } else   {
       return(paste0("El municipio mas importante en el abastecimiento es: ", resultado()$lugar_max))
     }
 })
 
  
}


