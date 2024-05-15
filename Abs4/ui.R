#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 02/04/2024
#Fecha de ultima modificacion: 02/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
options(scipen = 999)
source("010b_Indices_saca_Antioquia_funcion.R")
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
      tags$title("Destino de la producción de alimentos de antioquia"),  # Añade esta línea
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
  tags$h1("Destino de la producción de alimentos de origen antioqueño", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(class = "scrollable-content",
      fluidRow(
        column(3,
               selectInput("anio", "Año", c("Todos los años" = "todo", sort(as.character(unique(proviene_antioquia$anio)))))),
        column(3,
               selectInput("mes", "Mes", c("Todos los meses" = "todo", "Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5,
                                           "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11,
                                           "Diciembre" = 12), selected="")),
        column(3,
               numericInput("municipios", "Número de municipios", value = 10, min = 1, max = 18)),
        column(3,
               selectInput("producto", "Producto",c("Todos los productos" = "todo", sort(as.character(unique(proviene_antioquia$producto))))))
      )),
  div(
    fluidRow(
      column(10,
             plotlyOutput("grafico",height = "400px"),
             actionButton("descargar", "Gráfica"),
             downloadButton("descargarDatos", "Datos"),
             actionButton("github", "GitHub", icon = icon("github")),
             actionButton("go", "Reporte"),
             actionButton("reset", "Restablecer", icon = icon("refresh"))
             #,
             #tableOutput("vistaTabla") 
      ),
      column(2, 
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje2"),
                       style = "background-color: #005A45; color: #FFFFFF;")#,
             #wellPanel(textOutput("mensaje3"),
              #         style = "background-color: #094735; color: #FFFFFF;")
      )
    ),
    tags$div(tags$p("Este gráfico muestra la importancia que tiene cada municipio como destino de los prodoctos de origen antioqueño",
                    tags$br(),"Fuente: Calculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2"), style = "margin-top: 20px;")
  ),
  tags$div(
    tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
    style = "position: absolute; bottom: 0; width: 100%;"
    )
  ) 
)