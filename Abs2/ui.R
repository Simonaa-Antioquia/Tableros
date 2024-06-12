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
      tags$title("Importancia_Antioquia"),  # Añade esta línea
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
    "))
  ),
  tags$h1("Antioquia y su importancia en la recepción de alimentos", class = "main-header"),
  tags$h1("Descubre la importancia de Antioquia como receptor de alimentos desde otros departamentos del país.", class = "main-header_2"),
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
      column(9,
             leafletOutput("grafico",  height = "500px"),
             downloadButton("descargar_", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros/tree/8d5220f3bec2898e21495993520e1d8637e6b5d4/Abs2", target="_blank",
                      class = "btn btn-default shiny-action-button", icon("github")),
             actionButton("reset", "Restablecer", icon = icon("refresh")),
             downloadButton("report", "Generar informe")
        
      ),
      column(3, 
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;")
      )
    ),
    tags$div(tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).",
                    tags$br(),"Esta visualización muestra el porcentaje de alimentos enviados a Antioquia desde cada departamento, incluyendo productos de origen local. Permite apreciar la importancia de Antioquia como receptor de alimentos provenientes de otros territorios del país.",
                    tags$br(),"Los departamentos en color gris indican la ausencia de reportes de ingresos de productos provenientes de esas áreas en las principales centrales de abasto.", class = "sub-header2"), style = "margin-top: 20px;")
),
  br(),
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
