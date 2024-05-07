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
      column(12,
             plotlyOutput("plot"),
             downloadButton("descargar", "Descargar gráfica"),
             downloadButton("descargarDatos", "Descargar datos")
      )
    ),
    tags$div(tags$p("Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.", class = "sub-header2"), style = "margin-top: 20px;"),
    
  ),
  tags$div(
    tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
    style = "position: absolute; bottom: 0; width: 100%;"
  ) 
)