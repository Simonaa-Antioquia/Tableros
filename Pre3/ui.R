#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/02/2024
#Fecha de ultima modificacion: 25/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readxl);library(reshape2);library(ggplot2);library(gganimate);library(dplyr);
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel);library(stringr);library(shinyscreenshot);
################################################################################-

source("001f_precios_diferencias_municipios_funciones.R")

ui <- fluidPage(
  tags$head(
    tags$title("Diferencia de precios entre ciudades"),  # Añade esta línea
    tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),  # Importa la fuente Prompt
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
  tags$div(
    class = "scrollable-content",
    tags$h1("Diferencia de precios entre ciudades", class = "main-header"),
    div(
      textOutput("subtitulo"),
      class = "sub-header2",
      style = "margin-bottom: 20px;"
    ),
    div(
      fluidRow(
        column(3,
               selectInput("tipo", "Función:", 
                           choices = list("General" = 1, 
                                          "Producto" = 0 ))),
        column(3,
               selectInput("anio", "Año", c("Todos los años" = "", sort(as.character(unique(data_comparacion_anual_producto$year)))))),
        column(3,
               selectInput("mes", "Mes", c("Todos los meses" = "", "Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5, "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11, "Diciembre" = 12), selected = "")),
        column(3,
               conditionalPanel(
                 condition = "input.tipo == 0 ",
                 selectInput("producto", "Seleccione los productos:", 
                             choices = c(NULL, unique(data_comparacion_producto$producto)))
               )
        )
      )
    ),
    div(
      fluidRow(
        column(8,
               plotly::plotlyOutput("plot", height = "400px"),
               actionButton("descargar", "Gráfica", icon = icon("download")),
               downloadButton("descargarDatos", "Datos"),
               actionButton("github", "GitHub", icon = icon("github")),
               actionButton("go", "Reporte", icon = icon("file-alt")),
               actionButton("reset", "Restrablecer",icon = icon("refresh"))
        ),
        column(4, 
               wellPanel(textOutput("mensaje1"),
                         style = "background-color: #0D8D38; color: #FFFFFF;"),
               wellPanel(textOutput("mensaje2"),
                         style = "background-color: #005A45; color: #FFFFFF;"),
               wellPanel(textOutput("mensaje3"),
                         style = "background-color: #094735; color: #FFFFFF;")
        )
      ), 
      fluidRow(
        column(12,
               style = "margin-top: 2px;",
               tags$div(
                 tags$p("Este gráfico muestra la diferencia de precios promedio entre las diferentes ciudades y Medellín", class = "sub-header2", style = "margin-top: 3px;"),
                 tags$p("El tamaño de cada una de las bolas depende de la variación del precio dentro de cada ciudad", class = "sub-header2", style = "margin-top: 3px;"),
                 tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA)", class = "sub-header2", style = "margin-top: 3px;")
               )
        )
        
      )
    ),
    fluidRow(
      tags$div(
        tags$img(src = 'logo.jpeg', style = "width: 100vw; margin: 0;"),
        style = "width: 100%; margin:0;"  
      )
    )
  )
)