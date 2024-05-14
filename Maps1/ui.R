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
  div(class = "scrollable-content",
      fluidRow(
        column(4,
               selectInput("anio", "Año", c("Todos los años" = "", sort(as.character(unique(abastecimiento_medellin$anio)))))),
        column(4,
               selectInput("mes", "Mes", c("Todos los meses" = "", sort(as.numeric(unique(abastecimiento_medellin$mes)))))),
        column(4,
               selectInput("producto", "Producto",c("Todos los productos" = "", sort(as.character(unique(abastecimiento_medellin$producto)))))),
        column(4,
               selectInput("importancia","Importancia de los municipios",c("No incluir" = "","Incluir")))
      )),
  div(
    fluidRow(
      column(12,  
             leafletOutput("plot", width = "75%", height = "100px"),
             #downloadButton("descargar", "Descargar gráfica"),
             #downloadButton("descargarDatos", "Descargar datos")
             #,
             #tableOutput("vistaTabla") 
      )
    ),
    tags$div(tags$p("Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.", class = "sub-header2"), style = "margin-top: 20px;")
  ),
  tags$div(
    tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
    style = "position: absolute; bottom: 0; width: 100%;"
  ) 
)
