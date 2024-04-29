# Proyecto FAO
# Visualizacion de DATOS 2  - abastecimeinto en Medellin 
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 20/03/2024
#Fecha de ultima modificacion: 23/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(shiny); library(shinydashboard)
options(scipen = 999)
################################################################################-

# Corremos el codigo "002_Indices_abastecimiento_Antioquia.R"
source("002b_Indices_abastecimiento_Antioquia_funciones.R")


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
  tags$h1("Importancia de los municipios que abastecen a Antioquia", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(class = "scrollable-content",
      fluidRow(
        column(3,
               selectInput("anio", "Año", c("Todos los años" = "", as.character(unique(abastecimiento_medellin$anio))))),
        column(3,
               selectInput("mes", "Mes", c("Todos los meses" = "", as.character(unique(abastecimiento_medellin$mes))))),
        column(3,
               numericInput("municipios", "Número de municipios", value = 10, min = 1, max = 50)),
        column(3,
               selectInput("producto", "Producto",c("Todos los productos" = "", as.character(unique(abastecimiento_medellin$producto)))))
      )),
  div(
    fluidRow(
      column(12,
             plotOutput("grafico"),
             downloadButton("descargar", "Descargar gráfica"),
             downloadButton("descargarDatos", "Descargar datos")
             #,
             #tableOutput("vistaTabla") 
      )
    ),
    tags$div(tags$p("Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.", class = "sub-header2"), style = "margin-top: 20px;")
  )
)