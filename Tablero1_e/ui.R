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
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel);library(stringr)
################################################################################-

source("001f_precios_diferencias_municipios_funciones.R")


ui <- fluidPage(
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
    "))
  ),
  tags$h1("Diferencia de precios entre departamentos", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),
  div(class = "scrollable-content",
      fluidRow(
        column(3,
               selectInput("tipo", "Función:", 
                           choices = list("General" = 1, 
                                          "Producto" = 0 ))
        ),
        column(3,
               selectInput("anio", "Año", c("Todos los años" = "", sort(as.character(unique(data_comparacion_anual_producto$year)))))),
        column(3,
               selectInput("mes", "Mes", c("Todos los meses" = "", 1:12), selected = "")), 
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
             plotly::plotlyOutput("plot", height = "300px"),
             downloadButton("descargar", "Gráfica"),
             downloadButton("descargarDatos", "Datos"),
             actionButton("github", "GitHub", icon = icon("github"))
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
        style = "margin-top: 10px;",
        tags$div(
          tags$strong("Notas:", class = "sub-header3"),
          tags$p("Este grafico muestra la diferencia de precios promedio entre las diferentes ciudades y Medellín", class = "sub-header3", style = "margin-top: 1px;"),
          tags$p("El tamaño de cada una de las bolas depende de la desviacion estandar del precio a nivel departamento", class = "sub-header3", style = "margin-top: 1px;")
        )
      )
    
  ),
  fluidRow(
  tags$div(
    tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
    style = "position: fixed; bottom: 0; width: 100%;"
  ))
  
)