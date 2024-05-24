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
  tags$h1("Disponibilidad Neta de alimentos en Antioquia", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(
      fluidRow(
        column(4,
               selectInput("tipo", "Seleccione el tipo de funcion:", 
                           choices = list("Netos generales anuales" = 1, 
                                          "Netos anuales por producto" = 2, 
                                          "Netos generales mensuales" = 3, 
                                          "Netos generales mensuales por producto" = 4))),
        column(4,
               conditionalPanel(
                 condition = "input.tipo == 2 || input.tipo ==4",
                 selectInput("producto_seleccionado", "Producto seleccionado:", choices = c(productos,  Ninguno =""), multiple = TRUE)
               ))
      )),
  fluidRow(
    column(9,
           div(
             plotly::plotlyOutput("grafico",height = "400px"),
             actionButton("descargar", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             #actionButton("github", "GitHub", icon = icon("github")),
             shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros.git", target="_blank",
                      class = "btn btn-default shiny-action-button", icon("github")),
             actionButton("go", "Reporte", icon = icon("file-alt")),
             actionButton("reset", "Restrablecer",icon = icon("refresh"))
             #,
             #tableOutput("vistaTabla") 
           )),
    
    column(3, 
           div(
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
            # wellPanel(textOutput("mensaje2"),
             #          style = "background-color: #005A45; color: #FFFFFF;"),
             #wellPanel(textOutput("mensaje3"),
              #         style = "background-color: #094735; color: #FFFFFF;")
           ))
  ),
    
    fluidRow(
      column(12,
             style = "margin-top: 2px;",
             tags$div(
               tags$p("Este gráfico muestra los valores netos de los alimentos disponibles en los principales centros de acopio de Medellín.", class = "sub-header2", style = "margin-top: 3px;"),
               tags$p("Se definen valores netos como: Productos que se producen en cualquiera de los municipios de Antioquia -  los productos que llegan a Medellín pero no se producen en Antiouia", class = "sub-header2", style = "margin-top: 3px;"),
               tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA)", class = "sub-header2", style = "margin-top: 3px;")
             )
      )
    ),

  fluidRow(
    tags$div(
      tags$img(src = 'logo.jpeg', style = "width: 100%; margin: 0;"),  
      style = "width: 100%; margin:0;"  
    )
  )
)
