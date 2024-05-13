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
library(glue);library(tidyverse); library(shiny); library(lubridate);library(shinythemes);library(shiny)
options(scipen = 999)
################################################################################
rm(list = ls())

source("008b_funciones_participacion_destino.R")
productos <- unique(IHH_anual_producto$producto)

ui <- fluidPage(
  tags$div(
    style = "position: relative; min-height: 100vh; padding-bottom: 100px;",  # Añade un margen inferior
    tags$head(
      tags$title("Índice concentración de los destinos de los alimentos"),  # Añade esta línea
      tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),  # Importa la fuente Prompt
      tags$style(HTML("
        body {
          overflow-x: hidden;
        }
        .main-header {
        font-family: 'Prompt', sans-serif;
        font-size: 40px;
        color: #0D8D38;
      }
      .sub-header {
        font-family: 'Prompt', sans-serif;
        font-size: 20px;
      }
      .sub-header2 {
        font-family: 'Prompt', sans-serif;
        font-size: 15px;
      }
    "))
  ),
  tags$h1("Índice concentración de los destinos de los alimentos (lugares a los que \"exporta\" Antioquia)", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),
  div(class = "scrollable-content",
      fluidRow(
        column(4,
               selectInput("tipo", "Seleccione el tipo:", 
                           choices = list("Anual" = 1, 
                                          "Anual por producto" = 2, 
                                          "Mensual" = 3, 
                                          "Mensual por producto" = 4))
        ),
        column(4,
               conditionalPanel(
                 condition = "input.tipo == 2 || input.tipo == 4",
                 selectInput("producto", "Seleccione los productos:", 
                             choices = c(NULL, unique(IHH_anual_producto$producto)), multiple = TRUE)
               )
        ),
        column(4,
               conditionalPanel(
                 condition = "input.tipo == 3 || input.tipo == 4",
                 selectInput("anio", "Seleccione el año:", 
                             choices = c("", unique(IHH_mensual_producto$year)))
               )
        )
      )
  ),
  div(
    fluidRow(
        column(10,
               plotlyOutput("grafico"),
               downloadButton("descargar", "Gráfica"),
               downloadButton("descargarDatos", "Datos"),
               actionButton("github", "GitHub", icon = icon("github")),
               actionButton("reset", "Restablecer", icon = icon("refresh"))
        ),
        column(2, 
               wellPanel(textOutput("mensaje1"),
                         style = "background-color: #0D8D38; color: #FFFFFF;"),
               wellPanel(textOutput("mensaje2"),
                         style = "background-color: #005A45; color: #FFFFFF;"),
               wellPanel(textOutput("mensaje3"),
                         style = "background-color: #094735; color: #FFFFFF;")
        )
    ),
    tags$div(tags$p("El índice de concentración de destinos de alimento busca ver qué tan variados son los destinos a los que los alimentos de origen 
                    antioqueño van, es decir que un índice cercano a 100 es que van a sólo un destino y cercano a 0 es que van a múltiples destinos.",
                    tags$br(),"Fuente: Calculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2"), style = "margin-top: 20px;")
    ),
    tags$div(
      tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
      style = "position: absolute; bottom: 0; width: 100%;"
      )
    )
  )
