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
  tags$title("Índice de vulnerabilidad del abastecimientos de alimentos de antioquia"),
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
        .main-header_2 {
        font-family: 'Prompt', sans-serif;
        font-size: 20px;
        color: #0D8D38;
      }
      .sub
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
    ")),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML")
  ),
  tags$h1("Índice de vulnerabilidad del abastecimiento de alimentos de Antioquia", class = "main-header"),
  tags$h1("Evaluación de la vulnerabilidad del abastecimiento por origen y distancia.", class = "main-header_2"),
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
                             choices = c("Todos los productos"= NULL, unique(indice_v_anual_producto$producto)), multiple = TRUE)
               )
        ),
        column(4,
               conditionalPanel(
                 condition = "input.tipo == 3 || input.tipo == 4",
                 selectInput("anio", "Seleccione el año:", 
                             choices = c("Todos los años" = "todo", unique(indice_v_mensual$anio)))
               )
        )
      )
  ),
  fluidRow(
    column(8,
           div(
             plotly::plotlyOutput("grafico",height = "400px"),
             downloadButton("descargar_", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros.git", target="_blank",
                      class = "btn btn-default shiny-action-button", icon("github")),
             actionButton("reset", "Restablecer", icon = icon("refresh")),
             downloadButton("report", "Generar informe")
           )),
    
    column(4, 
           div(
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;")
           ))
  ),
  
  
  fluidRow(
    column(12,
           style = "margin-top: 2px;",
           tags$div(
             tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", 
                    tags$br()," El cálculo del índice de vulnerabilidad combina dos medidas: el índice de Herfindahl-Hirschman, que evalúa la concentración de la producción de alimentos en diferentes municipios, y la distancia desde cada municipio hasta Medellín.", 
                    tags$p(HTML("El primer componente de este índice se calcula utilizando el índice de Herfindahl-Hirschman, que mide la concentración de productores siguiendo  H<sub>ti</sub> = &sum;<sub>i=1</sub><sup>N</sup>P<sub>itm</sub><sup>2</sup>,
                    donde P<sub>itm</sub> es la participación que tiene cada municipio (como productor) en el total de kilogramos que ingresan a Medellín en una fecha determinada. El segundo componente, denotado como  
                    D<sub>i</sub> , es la distancia ponderada por la participación entre Medellín y el municipio, que luego se reescala, obteniendo valores de 0 a 1, donde 0 es Medellín y 1 es el municipio más lejano del cual llegan alimentos a Medellín (incluso puede ser otro país). Finalmente, el índice 
                    de vulnerabilidad se obtiene siguiendo: V<sub>it</sub> = (H<sub>it</sub> + D<sub>i</sub>)/2."), class = "sub-header2", style = "margin-top: 3px;")
             ),
             )),
  
  fluidRow(
    tags$div(
      tags$img(src = 'logo_2.png', style = "width: 100%; margin: 0;"),  
      style = "width: 100%; margin:0;"  
    )
  ) 
))
