#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 03/04/2024
#Fecha de ultima modificacion: 03/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot)
library(sf)
################################################################################-
options(scipen = 999)
source("003b_Indices_envian_antioquia_cadena_funciones.R")
################################################################################-

# Cargar los paquetes necesarios
library(shiny)
library(dplyr)
library(ggplot2)

# Definir la interfaz de usuario

ui <- fluidPage(
  tags$div(
    style = "position: relative; min-height: 100vh; padding-bottom: 100px;",  # Añade un margen inferior
    tags$head(
      tags$title("Importancia de Antioquia para lo que envian otros departamento"),  # Añade esta línea
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
  tags$h1("¿Qué tan importante es Antioquia para lo que envian otros departamento?", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),
  div(class = "scrollable-content",
      fluidRow(
        column(4,
               selectInput("anio", "Año", c("Todos los años" = "todo", sort(as.character(unique(antioquia$anio)))))),
        column(4,
               selectInput("mes", "Mes", c("Todos los meses" = "todo", "Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5, "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11, "Diciembre" = 12), selected="")),
        column(4,
               selectInput("producto", "Producto",c("Todos los productos" = "todo", sort(as.character(unique(antioquia$producto))))))
      )),
  div(
    fluidRow(
      column(10,
             leafletOutput("grafico", width = "500px", height = "500px"),
             downloadButton("descargar", "Gráfica"),
             downloadButton("descargarDatos", "Datos"),
             actionButton("github", "GitHub", icon = icon("github")),
             actionButton("reset", "Restablecer", icon = icon("refresh"))
             #,
             #tableOutput("vistaTabla") 
      ),
      column(2, 
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje2"),
                       style = "background-color: #005A45; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje3"),
                       style = "background-color: #094735; color: #FFFFFF;")
      )
    ),
    tags$div(tags$p("Cada porcentaje es lo que cada departamento envía a Antioquia, incluido lo que se queda en Antioquia.",
                    tags$br(),"Fuente: Calculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2"), style = "margin-top: 20px;")
  ),
  tags$div(
    tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
    style = "position: absolute; bottom: 0; width: 100%;"
    )
  )
)