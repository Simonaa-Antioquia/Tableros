#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/04/2024
#Fecha de ultima modificacion: 21/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-

source("011b_porcentaje_productos_entran_funciones.R")

library(shiny)

# Define la interfaz de usuario
ui <- fluidPage(
  tags$head(
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
  tags$h1("Productos que ingresan a Antioquia", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(class = "scrollable-content",
      fluidRow(
        column(4,
               selectInput("año", "Selecciones el año:", c("Todos los años" = "", sort(unique(entran$anio))))),
        column(4,
               selectInput("mes", "Selecciones el mes:", c("Todos los meses" = "", sort(unique(entran$mes))))),
        column(4,
               selectInput("depto", "Selecciones el departamento", c("Total nacional" = "", sort(unique(entran$depto_origen)))))
      )),
  div(
    fluidRow(
      column(12,
             plotOutput("grafico"),
             downloadButton("descargar", "Descargar gráfica"),
             downloadButton("descargarDatos", "Descargar datos")
             #,
             #tableOutput("vistaTabla") 
      )
    ),
    tags$div(tags$p("Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.", class = "sub-header2"), style = "margin-top: 20px;")
  )
)