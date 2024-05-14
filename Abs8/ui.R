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

source("012b_pareto_productos_funcion.R")

ui <- fluidPage(
  tags$head(
    tags$title("Acumulado productos"),  
    tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),
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
  tags$h1("Acumulado de los principales productos", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(
    fluidRow(
      column(3,
             selectInput("algo", "Seleccione la variable:", 
                         choices = list("Entradas" = "Neto_entra", 
                                        "Salidas" = "Neto_sale", 
                                        "Entradas locales" = "Neto_entra_local", 
                                        "Entradas externas" = "Neto_entra_exter"))),
      column(3,
             selectInput("año", "Selecciones el año:", c("Todos los años" = "todo", sort(unique(acum_total_anio$anio))))),
      column(3,
             selectInput("mes", "Selecciones el mes:", c("Todos los meses" = "todo", "Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5,
                                                         "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11,
                                                         "Diciembre" = 12), selected="")),
      column(3,
             uiOutput("ubicacionInput"))
    )),
  fluidRow(
    column(9,
           div(
             plotly::plotlyOutput("grafico",height = "400px"),
             actionButton("descargar", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             actionButton("github", "GitHub", icon = icon("github")),
             actionButton("go", "Reporte", icon = icon("file-alt")),
             actionButton("reset", "Restrablecer",icon = icon("refresh"))
             #,
             #tableOutput("vistaTabla") 
           )),
    
    column(3, 
           div(
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje2"),
                       style = "background-color: #005A45; color: #FFFFFF;"),
             #wellPanel(textOutput("mensaje3"),
              #         style = "background-color: #094735; color: #FFFFFF;")
           ))
  ),
  
  fluidRow(
    column(12,
           style = "margin-top: 2px;",
           tags$div(tags$p("Se muestran los alimentos que reunen aproximadamente el 85% del acumulado",
                           tags$br(),"Fuente: Calculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2"), style = "margin-top: 20px;")
    )
  ),
  
  fluidRow(
    tags$div(
      tags$img(src = 'logo.jpeg', style = "width: 100%; margin: 0;"),  
      style = "width: 100%; margin:0;"  
    )
  )
)