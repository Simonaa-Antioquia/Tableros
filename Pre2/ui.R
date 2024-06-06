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
library(corrplot); library(shiny)
options(scipen = 999)
source("001b_indices_precios_funciones.R")
################################################################################-

# Define la interfaz de usuario
ui <- fluidPage(
  tags$div(
    style = "position: relative; min-height: 100vh; padding-bottom: 100px;",  # Añade un margen inferior
    tags$head(
      tags$title("Cantidades y precios por mes"),  # Añade esta línea
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
  tags$h1("Relación entre volúmenes y precios de los alimentos", class = "main-header"),
  tags$h1("Evolución del precio promedio por Kg en relación al volumen de ingreso a las centrales de abasto de Medellín", class = "main-header_2"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),
  div(class = "scrollable-content",
      fluidRow(
        column(6,
               selectInput("producto", "Seleccione producto:", c("Todos los productos" = "total", as.character(productos_filtrados)))),
        column(6,
               selectInput("anio", "Seleccione un año:", c("Todos los años"="todos", sort(unique(complet$anio)))))
      )),
  div(
    fluidRow(
      column(9,
             plotlyOutput("grafico",height = "300px"),
             actionButton("descargar", "Gráfica", icon = icon("download")),
             downloadButton("descargarDatos", "Datos"),
             #actionButton("github", "GitHub", icon = icon("github")),
             shiny::a("GitHub", href="https://github.com/PlasaColombia-Antioquia/Tableros/tree/8d5220f3bec2898e21495993520e1d8637e6b5d4/Pre2", target="_blank",
                      class = "btn btn-default shiny-action-button", icon("github")),
             downloadButton("report", "Generar informe"),
             actionButton("reset", "Restablecer", icon = icon("refresh"))
             #,
             #tableOutput("vistaTabla") 
      ),
      column(3, 
             wellPanel(textOutput("mensaje2"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             #wellPanel(textOutput("mensaje1"),
              #         style = "background-color: #005A45; color: #FFFFFF;"),
             #wellPanel(textOutput("mensaje3"),
              #         style = "background-color: #094735; color: #FFFFFF;")
      )
    ),
    tags$div(tags$p("Fuente: Cálculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).",
                    tags$br(),"Para los productos fríjol verde, tomate, aguacate, banano, guayaba, mandarina, naranja, piña, arracacha, papa negra y yuca, los precios reportados corresponden a la variedad predominante en el mercado al momento de la recolección de la información.",
                    tags$br(),"De acuerdo con el SIPSA, el valor reportado corresponde al precio mayorista por kilogramo de producto de primera calidad en la Central Mayorista de Antioquia.",
                    tags$br(),"La información solo se muestra precios promedio en el centro de acopio de Medellín.", class = "sub-header2"), style = "margin-top: 20px;")
  ),
  tags$div(
    tags$img(src = 'logo_2.png', style = "width: 100vw;"),
    style = "position: absolute; bottom: 0; width: 100%;"
  )
)
)
