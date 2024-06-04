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
  tags$h1("¿Cómo afecta cerrar una ruta de ingreso a Antioquia?", class = "main-header"),
  div(
      fluidRow(
        column(2,
               selectInput("anio", "Año", c("Todos los años" = "", sort(as.character(unique(abastecimiento_medellin$anio)))))),
        column(2,
               selectInput("mes", "Mes", c("Todos los meses" = "", sort(as.numeric(unique(abastecimiento_medellin$mes)))))),
        column(2,
               selectInput("producto", "Producto",c("Todos los productos" = "", sort(as.character(unique(abastecimiento_medellin$producto)))))),
        column(5,
                #checkboxGroupInput("ruta", "Rutas a cerrar:",
                #                 c("Ruta 1" = 1,
                #                   "Ruta 2" = 2,
                #                   "Ruta 3" = 3,
                #                   "Ruta 4" = 4,
                #                   "Ruta 5" = 5,
                #                   "Ruta 6" = 6), inline = TRUE)
              uiOutput("checkbox")
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
             tags$p("Este mapa permite la importancia de las diferentes rutas de acceso al departmento, visualizando el impacto de cerrar una sobre el abastecimiento.", class = "sub-header2", style = "margin-top: 3px;"),
             tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA)", class = "sub-header2", style = "margin-top: 3px;")
           )
    )
  ),
    fluidRow(
      tags$div(
        tags$img(src = 'logo.jpeg', style = "width: 100%; margin: 0;"),  
        style = "position: fixed; bottom: 0; width: 100%; margin:0;"  
      )
  )
)
