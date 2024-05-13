#Proyecto FAO
#INDICE DE VULNERABILIDAD 
# UI
# FUNCION 9
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 14/03/2024
#Fecha de ultima modificacion: 21/02/2024
################################################################################
# Paquetes 
################################################################################
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse); library(shiny); library(lubridate);library(shinythemes);library(shinyWidgets)
library(htmlwidgets)

options(scipen = 999)
################################################################################
rm(list = ls())

source("009b_funciones_Indice_Vulnerabilidad.R")
productos <- unique(indice_v_anual_producto$producto)
#webshot::install_phantomjs()


ui <- fluidPage(
  tags$title("Indice de vulnerabilidad del abastecimientos de alimentos de antioquia"),
  tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),
  tags$head(
    tags$style(HTML("
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
      .sub-header3 {
        font-family: 'Prompt', sans-serif;
        font-size: 15px;
      }
      .center {
        display: flex;
        justify-content: center;
      }
      .scrollable-content {
        overflow-y: auto;
        overflow-x: hidden;
        height: auto;
      }
    "))
  ),
  tags$h1("Indice de vulnerabilidad del abastecimientos de alimentos de antioquia", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),
  div(
      fluidRow(
        column(4,
               selectInput("tipo", "Seleccione el tipo:", 
                           choices = list("Índice de vulnerabilidad anual" = 1, 
                                          "Índice de vulnerabilidad anual por producto" = 2, 
                                          "Índice de vulnerabilidad mensual" = 3, 
                                          "Índice de vulnerabilidad mensual por producto" = 4))
        ),
        column(4,
               conditionalPanel(
                 condition = "input.tipo == 2 || input.tipo == 4",
                 selectInput("producto", "Seleccione los productos:", 
                             choices = c(NULL, unique(indice_v_anual_producto$producto)), multiple = TRUE)
               )
        ),
        column(4,
               conditionalPanel(
                 condition = "input.tipo == 3 || input.tipo == 4",
                 selectInput("anio", "Seleccione el año:", 
                             choices = c("", unique(indice_v_mensual$anio)))
               )
        )
      )
  ),
  fluidRow(
    column(8,
           div(
             plotly::plotlyOutput("grafico",height = "400px"),
             downloadButton("descargar", "Gráfica"),
             downloadButton("descargarDatos", "Datos"),
             actionButton("github", "GitHub", icon = icon("github")),
             actionButton("reset", "Restrablecer",icon = icon("refresh"))
             #,
             #tableOutput("vistaTabla") 
           )),
    
    column(4, 
           div(
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             wellPanel(uiOutput("mensaje2"),
                       style = "background-color: #005A45; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje3"),
                       style = "background-color: #094735; color: #FFFFFF;")
           ))
  ),
  
  
  fluidRow(
    column(12,
           style = "margin-top: 2px;",
           tags$div(
             tags$p("El índice de vulnerabilidad se calcula teniendo en cuenta el número de municipios en los que se produce un alimento y la distancia desde este municipio a Medellín", class = "sub-header2", style = "margin-top: 3px;"),
             tags$p("Un mayor índice indica mayor vulnerabilidad", class = "sub-header2", style = "margin-top: 3px;"),
             tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA)", class = "sub-header2", style = "margin-top: 3px;")
           )
    )),
  
  fluidRow(
    tags$div(
      tags$img(src = 'logo.jpeg', style = "width: 100%; margin: 0;"),  
      style = "width: 100%; margin:0;"  
    )
  ) 
)