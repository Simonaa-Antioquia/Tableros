#Proyecto FAO
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 28/03/2024
#Fecha de ultima modificacion: 28/03/2024
################################################################################
# Paquetes 
################################################################################
library(shiny); library(lubridate);library(shinythemes);library(shinyWidgets)
options(scipen = 999)
################################################################################
rm(list = ls())

source("005b_netos_funciones.R")
productos <- unique(data_anual_producto$producto)


ui <- fluidPage(
  tags$head(
    tags$title("Netos"),  
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
  tags$h1("Balance de Alimentos: Productos de origen local vs. externo", class = "main-header"),
  tags$h1("Compara volúmenes de alimentos locales y externos que ingresan a las principales centrales de abasto de Medellín.", class = "main-header_2"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(
      fluidRow(
        column(4,
               selectInput("tipo", "Seleccione el tipo de funcion:", 
                           choices = list("Balances generales anuales" = 1, 
                                          "Balances anuales por producto" = 2, 
                                          "Balances generales mensuales" = 3, 
                                          "Balances generales mensuales por producto" = 4))),
        column(4,
               conditionalPanel(
                 condition = "input.tipo == 2 || input.tipo ==4",
                 selectInput("producto_seleccionado", "Producto seleccionado:", choices = c(productos,  Ninguno =""), multiple = TRUE)
               ))
      )),
  fluidRow(
    column(12,
           div(
             plotly::plotlyOutput("grafico",height = "400px"),
             downloadButton("descargar_", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros.git", target="_blank",
                      class = "btn btn-default shiny-action-button", icon("github")),
             actionButton("reset", "Restablecer", icon = icon("refresh")),
             downloadButton("report", "Generar informe")
           )),
 
  ),
    
    fluidRow(
      column(12,
             style = "margin-top: 2px;",
             tags$div(
               tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2", style = "margin-top: 3px;"),
               tags$p(HTML("El balance de alimentos se define como la diferencia en volumen entre los alimentos que ingresan a las principales centrales de abasto de Medellín con origen en Antioquia y el total de alimentos reportados en las centrales. La fórmula para calcular el balance de alimentos es <i>N<sub>it</sub> = P<sub>a</sub> - D<sub>a</sub></i>, donde <i>N<sub>it</sub> es el balance de alimentos, P<sub>a</sub> es el volumen de alimentos que se originan en Antioquia y D<sub>a</sub></i> es el volumen total de alimentos que llegan al centro de acopio de Medellín."), class = "sub-header2", style = "margin-top: 3px;"),
               tags$p("Un balance negativo es sinónimo de dependencia hacia otros departamentos del país.", class = "sub-header2", style = "margin-top: 3px;")
               )
      )
    ),

  fluidRow(
    tags$div(
      tags$img(src = 'logo_2.png', style = "width: 100%; margin: 0;"),  
      style = "width: 100%; margin:0;"  
    )
  )
)
