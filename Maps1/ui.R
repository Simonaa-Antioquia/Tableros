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
  tags$div(
    style = "position: relative;  padding-bottom: 100px;",  # Añade un margen inferior
    tags$head(
      tags$title("Rutas de alimentos"),  # Añade esta línea
      tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),  # Importa la fuente Prompt
      tags$style(HTML("
      #grafico {
             display: block;
             margin: auto;
           }
      .selectize-dropdown {
      z-index: 10000 !important;
    }
      body {
        overflow-x: hidden;
      }
      .main-header {
        font-family: 'Prompt', sans-serif;
        font-size: 40px;
        color: #0D8D38;
      }
    .main-header_2 {
        font-family: 'Prompt', sans-serif;
        font-size: 20px;
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
  tags$h1("Rutas de los alimentos que ingresan a Medellín", class = "main-header"),
  tags$h1("Visualiza las rutas que transitan los alimentos que ingresan a Medellín.", class = "main-header_2"),
    div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(
      fluidRow(
        column(2,
               selectInput("anio", "Año", c("Todos los años" = "todo", sort(as.character(unique(abastecimiento_medellin$anio)))))),
        column(3,
               selectInput("mes", "Mes", c("Todos los meses" = "todo", "Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5, "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11, "Diciembre" = 12), selected="")),
        column(3,
               selectInput("producto", "Producto",c("Todos los productos" = "todo", sort(as.character(unique(abastecimiento_medellin$producto)))))),
        column(3,
               selectInput("importancia","Importancia de los municipios",c("No incluir" = "","Incluir")))
      ),
    fluidRow(
      column(7,  
             leafletOutput("plot"),
             #actionButton("descargar", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             #actionButton("github", "GitHub", icon = icon("github")),
             shiny::a("GitHub", href="https://github.com/Simonaa-Antioquia/Tableros/tree/26016cc3f1bdd2dd28b3cb0841c74042579620d3/Maps1", target="_blank",
                      class = "btn btn-default shiny-action-button", icon("github")),
             #actionButton("go", "Reporte", icon = icon("file-alt")),
             actionButton("reset", "Restrablecer",icon = icon("refresh"))
      ),
      column(5, 
           div(
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje2"),
                     style = "background-color: #005A45; color: #FFFFFF;")#,
             #wellPanel(textOutput("mensaje3"),
              #         style = "background-color: #094735; color: #FFFFFF;")
        ))
    ),
           tags$div(
             tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2", style = "margin-top: 1px;"),
             tags$p("Este mapa permite identificar las rutas de donde vienen los alimentos que abastecen la central mayorista y minorista de Medellín, permitiendo identificar la importancia de cada una para el abastecimiento total.", class = "sub-header2", style = "margin-top: 1px;"
             ),
             tags$p("La importancia de cada municipio se calculó en función del porcentaje del volumen total de productos que llegan a Medellín provenientes de cada municipio.", class = "sub-header2", style = "margin-top: 1px;"
             ),
             tags$p("Las distancias se calcularon utilizando OpenRouteService.", class = "sub-header2", style = "margin-top: 1px;"
             )
           
    )
  ),
   br(),
  br(),
  br(),
  br(),
  tags$div(
    tags$img(src = 'logo_2.png', style = "width: 100vw;"),
    style = "position: absolute; bottom: 0; width: 100%;"
  )
  )
)
