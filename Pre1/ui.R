#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 27/02/2024
#Fecha de ultima modificacion: 27/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot); library(shiny);library(shinyscreenshot);
options(scipen = 999)
source("001b_indices_precios_funciones.R")
################################################################################-

# Define la interfaz de usuario
ui <- fluidPage(
  #titlePanel("Precios en el tiempo"),
  tags$div(
    style = "position: relative; min-height: 100vh; padding-bottom: 100px;",  # Añade un margen inferior
    tags$head(
      tags$title("Comportamiento de los precios en el tiempo"),  # Añade esta línea
      tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),  # Importa la fuente Prompt
      tags$style(HTML("
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
    tags$h1("Comportamiento de los precios en el tiempo", class = "main-header"),
    div(
      textOutput("subtitulo"),
      class = "sub-header2",
      style = "margin-bottom: 20px;"
    ),
    div(class = "scrollable-content",
        fluidRow(
          column(4,
                 selectInput("producto", "Seleccione producto:", c("Todos los productos" = "todo", as.character(names(which(table(data$producto) > 12)))))),
          column(4, 
                 selectInput("variable", "Seleccione la variable", c("Precio promedio" = "precio_prom", "Cambio porcentual" = "cambio_pct", "Cambio porcentual año anterior"="cambio_pct_anual"))),
          column(4, 
                 selectInput("anio", "Seleccione el año", c("Todos los años" = "todo", sort(unique(data$anio)))))
        )),
    div(
      fluidRow(
        column(10,
               plotlyOutput("grafico"),
               actionButton("descargar", "Gráfica"),
               downloadButton("descargarDatos", "Datos"),
               actionButton("github", "GitHub", icon = icon("github")),
               actionButton("go", "Reporte"),
               actionButton("reset", "Restablecer", icon = icon("refresh"))
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
      tags$div(tags$p("La información solo se muestra para los precios en el centro de acopio de Medellín.",
                      tags$br(),"Fuente: Calculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2"), style = "margin-top: 20px;")
    ),
    tags$div(
      tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
      style = "position: absolute; bottom: 0; width: 100%;"
    )
  )
)
