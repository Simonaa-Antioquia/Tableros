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

# Definir la interfaz de usuario
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
  tags$h1("Netos", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(class = "scrollable-content",
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
  div(
    fluidRow(
      column(12,
             plotOutput("tiempo1"),
             downloadButton("descargar", "Descargar gráfica"),
             downloadButton("descargarDatos", "Descargar datos")
      )
    ),
    tags$div(tags$p("Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.", class = "sub-header2"), style = "margin-top: 20px;")
  )
)
