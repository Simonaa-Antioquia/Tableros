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
source("004a_rutas_abastecimiento.R")
################################################################################-

# Cargar los paquetes necesarios
library(shiny)
library(dplyr)
library(ggplot2)
library(leaflet)

# Definir la interfaz de usuario

ui <- fluidPage(
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
    "))
  ),
  tags$h1("¿Qué rutas toman los alimentos que llegan a Antioquia?", class = "main-header"),
  div(
      fluidRow(
        column(2,
               selectInput("anio", "Año", c("Todos los años" = "", sort(as.character(unique(abastecimiento_medellin$anio)))))),
        column(2,
               selectInput("mes", "Mes", c("Todos los meses" = "", sort(as.numeric(unique(abastecimiento_medellin$mes)))))),
        column(3,
               selectInput("producto", "Producto",c("Todos los productos" = "", sort(as.character(unique(abastecimiento_medellin$producto)))))),
        column(4,
               selectInput("importancia","Importancia de los municipios",c("No incluir" = "","Incluir")))
      )),
    fluidRow(
      column(7,  
             leafletOutput("plot", width = "100%", height = "250px"),
             actionButton("descargar", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             actionButton("github", "GitHub", icon = icon("github")),
             actionButton("go", "Reporte", icon = icon("file-alt")),
             actionButton("reset", "Restrablecer",icon = icon("refresh"))
      ),
      column(5, 
           div(
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;")#,
             #wellPanel(textOutput("mensaje2"),
              #       style = "background-color: #005A45; color: #FFFFFF;")#,
             #wellPanel(textOutput("mensaje3"),
              #         style = "background-color: #094735; color: #FFFFFF;")
        ))
    ),
    fluidRow(
    column(12,
           style = "margin-top: 2px;",
           tags$div(
             tags$p("Este mapa permite identificar las rutas de donde vienen los alimentos que abastecen la central mayorista y minorista de Medellín, permitiendo identificar la importancia de cada una para el abastecimiento total.", class = "sub-header2", style = "margin-top: 3px;"),
             tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA)", class = "sub-header2", style = "margin-top: 3px;")
           )
    )
  ),
    fluidRow(
    tags$div(
      tags$img(src = 'logo.jpeg', style = "width: 100%; margin: 0;"),  
      style = "width: 100%; margin:0;"  
    )
  )
)
