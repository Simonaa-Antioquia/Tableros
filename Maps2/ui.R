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
source("004b_cierre_rutas.R")
################################################################################-

# Cargar los paquetes necesarios
library(shiny)
library(dplyr)
library(ggplot2)
library(leaflet)

# Definir la interfaz de usuario

ui <- fluidPage(
  tags$div(
    style = "position: relative; min-height: 100vh; padding-bottom: 100px;",  # Añade un margen inferior
  tags$head(
    tags$title("Riesgo cierre de rutas"),  # Añade esta línea
    tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),
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
  tags$h1("Impacto del cierre de vías de acceso en el abastecimiento de Medellín", class = "main-header"),
  tags$h1("Analiza cómo los cierres viales afectan el suministro de alimentos en Medellín", class = "main-header_2"),  
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(
      fluidRow(
        column(2,
               selectInput("anio", "Año", c("Todos los años" = "todo", sort(as.character(unique(abastecimiento_medellin$anio)))))),
        column(3,
               selectInput("mes", "Mes", c("Todos los meses" = "todo", "Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5, "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11, "Diciembre" = 12), selected="")),
        column(2,
               selectInput("producto", "Producto",c("Todos los productos" = "todo", sort(as.character(unique(abastecimiento_medellin$producto)))))),
        column(5,
                checkboxGroupInput(
                  inputId = "ruta",
                  label = "Rutas a cerrar:",
                  choiceNames = list(
                    tags$span("Antioquia", style = "color: #0D8D38;font-weight: bold"),
                    tags$span("Norte", style = "color: red;"), 
                    tags$span("Nororiente", style = "color: blue;"), 
                    tags$span("Suroccidente", style = "font-weight: bold;"),
                    tags$span("Suroriente", style = "color: red;"),
                    tags$span("Noroccidente", style = "color: red;"), 
                    tags$span("Sur", style = "color: blue;"), 
                    tags$span("Choco", style = "font-weight: bold;")
                  ),
                  choiceValues = c(99,1,2,3,4,5,6,7),
                           #      c(tags$span("Antioquia" = 99, style = "color: red;"),
                           #        "Norte" = 1,
                           #        "Nororiente" = 2,
                           #        "Suroccidente" = 3,
                           #        "Suroriente" = 4,
                           #        "Noroccidente" = 5,
                           #        "Sur" = 6,
                           #        "Choco" = 7),
                  inline = TRUE))
      ),
    fluidRow(
      column(7,  
             leafletOutput("plot"),
             actionButton("descargar", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             #actionButton("github", "GitHub", icon = icon("github")),
             shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros.git", target="_blank",
                      class = "btn btn-default shiny-action-button", icon("github")),
             actionButton("go", "Reporte", icon = icon("file-alt")),
             actionButton("reset", "Restrablecer",icon = icon("refresh"))
      ),
      column(5, 
           div(
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje2"),
                     style = "background-color: #005A45; color: #FFFFFF;")#,
             #wellPanel(textOutput("mensaje3"),
              #         style = "background-color: #094735; color: #FFFFFF;")
        ))
    ),
           tags$div(
             tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA)", class = "sub-header2", style = "margin-top: 3px;"),
             tags$p("Este mapa muestra la importancia de las diferentes rutas de acceso al departamento de Atioquia, permitiendo visualizar el impacto que tendría el cierre de una o unas de ellas en el abastecimiento.", class = "sub-header2", style = "margin-top: 3px;")
             )
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
