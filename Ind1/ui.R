#Proyecto FAO
#INDICE Herfindahl–Hirschman - Abastecimiento shiny abasteciemiento
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 14/03/2024
#Fecha de ultima modificacion: 14/03/2024
################################################################################
# Paquetes 
################################################################################
library(shiny); library(lubridate);library(shinythemes);library(plotly);
library(shinydashboard)
options(scipen = 999)
################################################################################
rm(list = ls())
source("006b_HHindex_abastecimiento_funciones.R")

ui <- fluidPage(
  tags$head(
    tags$title("índice de concentración alimentaria"),
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
    ")),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML")
  ),
  tags$h1("Índice de diversidad de alimentos", class = "main-header"),
  tags$h1("Análisis de varidad de los alimentos que ingresan a las pricipales centrales de abasto de Antioquia.", class = "main-header_2"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),
  div(
    fluidRow(
      column(6,
             selectInput("tipo", "Seleccione el tipo:", 
                         choices = list("Anual" = 1, 
                                        "Mensual" = 0))
      ),
      column(4,
             conditionalPanel(
               condition = "input.tipo == 0 ",
               selectInput("anio", "Seleccione el año:", 
                           choices = c("", unique(IHH_anual$year))))
      )
    )
  ),
  
  fluidRow(
    column(9,
           div(
             plotly::plotlyOutput("grafico1",height = "400px"),
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
             wellPanel(uiOutput("mensaje2"),
                       style = "background-color: #005A45; color: #FFFFFF;")#,
             #wellPanel(textOutput("mensaje3"),
            #           style = "background-color: #094735; color: #FFFFFF;")
           ))
  ),
  
  fluidRow(
    column(12,
           style = "margin-top: 2px;",
           tags$div(
             tags$p("Este gráfico se calcula con base en el índice de Herfindahl-Hirschman", class = "sub-header2", style = "margin-top: 3px;"),
             tags$p("Un mayor índice indica menor variedad de alimentos disponibles en los principales centros de abastecimiento", class = "sub-header2", style = "margin-top: 3px;"),
             tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA)", class = "sub-header2", style = "margin-top: 3px;"),
             tags$div(style = "text-align: left;", 
                      tags$p("La fórmula del índice de Herfindahl-Hirschman es:", class = "sub-header2", style = "margin-top: 3px;"),
                      tags$script(HTML('MathJax.Hub.Queue(["Typeset", MathJax.Hub, "mathjax-output"])')),
                      tags$div(id = "mathjax-output", HTML("$$IHH = \\sum_{i=1}^{n} s_i^2$$"))
             ),
             tags$p("Donde Si es la participación que tiene cada producto en el volumen total de alimentos que ingresan a las principales centrales de abasto de Antioquia", class = "sub-header2", style = "margin-top: 3px;"),
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