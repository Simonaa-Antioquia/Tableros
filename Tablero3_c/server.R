#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 03/04/2024
#Fecha de ultima modificacion: 03/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
options(scipen = 999)
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot)
library(sf) 
################################################################################-
# Definir la función de servidor
server <- function(input, output, session) {
  
  resultado<-reactive({
    if (input$producto != "" && input$anio == "" && input$mes == "") {
      ant_en_col(Producto = input$producto)
    } else if (input$mes != "" && input$anio == "") {
      validate(
        need(input$anio != "", "Debe seleccionar un año.")
      )
    } else if(input$anio == "" && input$producto == "" && input$mes == ""){
      ant_en_col()
    } else if(input$producto == "" && input$mes == "" ){
      ant_en_col(Año = input$anio)
    } else if(input$producto == ""){
      ant_en_col(Año = input$anio, Mes = input$mes)
    } else if(input$mes == "" ){
      ant_en_col(Año = input$anio, Producto = input$producto)
    } else if(input$anio == "" && input$mes == ""){
      ant_en_col(Producto = input$producto)
    } else{
      ant_en_col(Año = input$anio, Mes = input$mes ,Producto = input$producto)
    }
  })
  
  output$grafico <- renderPlot({
    resultado()$grafico
  }, res = 100)
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_porcentaje_envia_a_antioquia_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Forzar la ejecución de la función reactiva
      res <- resultado()
      
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = res$grafico, width = 7, height = 7, dpi = 400)
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
    porcentaje_max <- resultado$porcentaje_max
    dpto_max <- resultado$dpto_max
    
    #if(input$anio == ""){
    return(paste0(dpto_max," envía el ", porcentaje_max, "% de lo que saca, siendo Antioquia su principal socio comercial"))
    #} 
  })
}