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
  tags$div(
    class = "scrollable-content",
    tags$h1("Análisis de precios de alimentos por ciudad", class = "main-header"),
    tags$h1("Descubre las diferencias de precios de alimentos en ciudades, comparadas con Medellín", class = "main-header_2"),
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
               selectInput("anio", "Año", c("Todos los años" = "todo", sort(as.character(unique(data_comparacion_anual_producto$year)))))),
        column(3,
               selectInput("mes", "Mes", c("Todos los meses" = "todo", "Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5, "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11, "Diciembre" = 12), selected = "")),
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
               #actionButton("github", "GitHub", icon = icon("github")),
               shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros.git", target="_blank",
                        class = "btn btn-default shiny-action-button", icon("github")),
               downloadButton("report", "Generar informe"),
               actionButton("reset", "Restrablecer",icon = icon("refresh"))
        ),
        column(4, 
               wellPanel(textOutput("mensaje1"),
                         style = "background-color: #0D8D38; color: #FFFFFF;"),
               #wellPanel(textOutput("mensaje2"),
                #         style = "background-color: #005A45; color: #FFFFFF;"),
               #wellPanel(textOutput("mensaje3"),
                #         style = "background-color: #094735; color: #FFFFFF;")
        )
      ), 
      fluidRow(
        column(12,
               style = "margin-top: 2px;",
               tags$div(
                 tags$p("Este gráfico muestra la diferencia promedio de precios entre varias ciudades comparadas con Medellín.",
                        tags$br(),"El tamaño del círculo refleja cuánto cambia el precio dentro de cada ciudad.",
                        tags$br(),"Desviación estándar: Mide qué tan parejos están los precios de los productos comparados con el promedio. Si los precios cambian mucho, la desviación estándar será alta, si no cambian mucho, será baja. Permite ver si los productos tienen un precio más o menos estable.",
                        tags$br(),"Para los productos fríjol verde, tomate, aguacate, banano, guayaba, mandarina, naranja, piña, arracacha, papa negra y yuca, los precios reportados corresponden a la variedad predominante en el mercado al momento de la recolección de la información.",
                        tags$br(),"De acuerdo con el SIPSA, el valor reportado corresponde al precio mayorista por kilogramo de producto de primera calidad en la Central Mayorista de Antioquia.",
                        tags$br(),"Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2", style = "margin-top: 3px;")
               )
        )
        
      )
    ),
    fluidRow(
      tags$div(
        tags$img(src = 'logo.png', style = "width: 100vw; margin: 0;"),
        style = "width: 100%; margin:0;"  
      )
    )
  )
)