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
      tags$title("Precios en el tiempo"),  # Añade esta línea
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
    tags$h1("Comportamiento de los precios en el tiempo", class = "main-header"),
    tags$h1("Análisis histórico de precios de alimentos en las centrales de abasto de Medellín", class = "main-header_2"),
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
                 selectInput("variable", "Seleccione la variable", c("Precio promedio" = "precio_prom", "Cambio porcentual" = "cambio_pct", "Cambio porcentual intranual"="cambio_pct_anual"))),
          column(4, 
                 selectInput("anio", "Seleccione el año", c("Todos los años" = "todo", sort(unique(data$anio)))))
        )),
    div(
      fluidRow(
        column(9,
               plotlyOutput("grafico"),
               actionButton("descargar", "Gráfica", icon = icon("download")),
               downloadButton("descargarDatos", "Datos"),
               #actionButton("github", "GitHub", icon = icon("github")),
               shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros.git", target="_blank",
                        class = "btn btn-default shiny-action-button", icon("github")),
               downloadButton("report", "Generar informe"),
               actionButton("reset", "Restablecer", icon = icon("refresh"))
        ),
        column(3, 
               #wellPanel(textOutput("mensaje1"),
                #         style = "background-color: #0D8D38; color: #FFFFFF;"),
               wellPanel(textOutput("mensaje2"),
                         style = "background-color: #0D8D38; color: #FFFFFF;"),
               wellPanel(textOutput("mensaje3"),
                         style = "background-color:#005A45; color: #FFFFFF;")
        )
      ),
      tags$div(tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).",
                      tags$br(),"La información solo se muestra para los precios en el centro de acopio de Medellín.",
                      tags$br(),"Para los productos fríjol verde, tomate, aguacate, banano, guayaba, mandarina, naranja, piña, arracacha, papa negra y yuca, los precios reportados corresponden a la variedad predominante en el mercado al momento de la recolección de la información.",
                      tags$br(),"De acuerdo con el SIPSA, el valor reportado corresponde al precio mayorista por kilogramo de producto de primera calidad en la Central Mayorista de Antioquia.",
                      class = "sub-header2"), style = "margin-top: 20px;")
    ),
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
