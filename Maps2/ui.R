#Proyecto FAO
#Shiny de mapa de rutas
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
source("004b_cierre_rutas.R")
################################################################################-

# Cargar los paquetes necesarios
library(shiny)
library(dplyr)
library(ggplot2)
library(leaflet)

# Definir la interfaz de usuario

ui <- fluidPage(
  tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),
  tags$head(tags$title("Riesgo cierre de rutas"),  # Añade esta línea
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
  tags$h1("Impacto del cierre de vías de acceso en el abastecimiento de Medellín", class = "main-header"),
  tags$h1("Analiza cómo los cierres viales afectan el suministro de alimentos en Medellín", class = "main-header_2"),  
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(
      fluidRow(
        column(2,
               selectInput("anio", "Año", c("Todos los años" = "", sort(as.character(unique(abastecimiento_medellin$anio)))))),
        column(2,
               selectInput("mes", "Mes", c("Todos los meses" = "", sort(as.numeric(unique(abastecimiento_medellin$mes)))))),
        column(2,
               selectInput("producto", "Producto",c("Todos los productos" = "", sort(as.character(unique(abastecimiento_medellin$producto)))))),
        column(6,
                checkboxGroupInput("ruta", "Rutas a cerrar:",
                                 c("Antioquia" = 99,
                                   "Norte" = 1,
                                   "Nororiente" = 2,
                                   "Suroccidente" = 3,
                                   "Suroriente" = 4,
                                   "Noroccidente" = 5,
                                   "Sur" = 6,
                                   "Choco" = 7), inline = TRUE))
      )),
    fluidRow(
      column(9,  
             leafletOutput("plot", width = "100%", height = "500px"),
             actionButton("descargar", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             #actionButton("github", "GitHub", icon = icon("github")),
             shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros.git", target="_blank",
                      class = "btn btn-default shiny-action-button", icon("github")),
             actionButton("go", "Reporte", icon = icon("file-alt")),
             actionButton("reset", "Restrablecer",icon = icon("refresh"))
      ),
      column(3, 
           div(
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje2"),
                     style = "background-color: #005A45; color: #FFFFFF;")#,
             #wellPanel(textOutput("mensaje3"),
              #         style = "background-color: #094735; color: #FFFFFF;")
        ))
    ),
    fluidRow(
    column(12,
           style = "margin-top: 2px;",
           tags$div(
             tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA)", class = "sub-header2", style = "margin-top: 3px;"),
             tags$p("Este mapa muestra la importancia de las diferentes rutas de acceso al departamento de Atioquia, permitiendo visualizar el impacto que tendría el cierre de una o unas de ellas en el abastecimiento.", class = "sub-header2", style = "margin-top: 3px;")
    )
  ),
    fluidRow(
      tags$div(
        tags$img(src = 'logo_2.png', style = "width: 100%; margin: 0;"),  
        style = "position: fixed; bottom: 0; width: 100%; margin:0;"  
      )
  )
)
