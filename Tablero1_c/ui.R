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
library(glue);library(tidyverse);library(gridExtra);library(corrplot); library(shiny)
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
    tags$h1("Comportamiento de los precios en el tiempo", class = "main-header"),
    div(
      textOutput("subtitulo"),
      class = "sub-header2",
      style = "margin-bottom: 20px;"
    ),
    div(class = "scrollable-content",
        fluidRow(
          column(3,
                 selectInput("producto", "Seleccione producto:", c("Todos los productos" = "todo", as.character(names(which(table(data$producto) > 12)))))),
          column(3, 
                 selectInput("variable", "Seleccione la variable", c("Precio promedio" = "precio_prom", "Cambio porcentual" = "cambio_pct", "Cambio porcentual año anterior"="cambio_pct_anual"))),
          column(3, 
                 selectInput("anio", "Seleccione el año", c("Todos los años" = "todo", sort(unique(data$anio))))),
          column(3,
                 actionButton("reset", "Restablecer filtros"))
        )),
    div(
      fluidRow(
        column(10,
               plotlyOutput("grafico"),
               downloadButton("descargar", "Gráfica"),
               downloadButton("descargarDatos", "Datos"),
               actionButton("github", "GitHub", icon = icon("github"))
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
      tags$div(tags$p("Fuente: Calculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).",
                      tags$br(),"La información solo se muestra para los precios en el centro de acopio de Medellín.", class = "sub-header2"), style = "margin-top: 20px;")
    ),
    tags$div(
      tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
      style = "position: absolute; bottom: 0; width: 100%;"
    )
  )
)
