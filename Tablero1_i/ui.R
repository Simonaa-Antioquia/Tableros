#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/02/2024
#Fecha de ultima modificacion: 25/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(reshape2);library(sf);library(shiny)
################################################################################-
source("001h_precios_diferencias_mapa_funciones.R")

producto_counts <- as.data.frame(table(data$producto))

# Filtrar los productos que aparecen más de 12 veces
productos_filtrados <- producto_counts[producto_counts$Freq > 11, "Var1"]

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
      #plot img {
        display: block;
        margin: auto;
        width: 50%;
        height: auto;
      }
    "))
  ),
  tags$h1("Comparación de precios", class = "main-header"),
  div(
    textOutput("subtitulo"),
    class = "sub-header2",
    style = "margin-bottom: 20px;"
  ),  
  div(class = "scrollable-content",
      fluidRow(
        column(3,
               selectInput("anio", "Año", c("Todos los años" = "", sort(as.character(unique(data$year)))))),
        column(3,
               selectInput("mes", "Mes", c("Todos los meses" = "", 1:12), selected = "")),
        column(3,
               selectInput("producto", "Producto", c("Todos los productos" = "", sort(as.character(unique(productos_filtrados))))))
      )),
  div(
    fluidRow(
      column(12,
             plotOutput("grafico",height = "300px"),
             downloadButton("descargar", "Descargar gráfica"),
             downloadButton("descargarDatos", "Descargar datos")
             #,
             #tableOutput("vistaTabla") 
      )
    ),
    tags$div(tags$p("Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.Este es un párrafo de texto que aparecerá debajo del panel.", class = "sub-header2"), style = "margin-top: 20px;")
  ),
  tags$div(
    tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
    style = "position: absolute; bottom: 0; width: 100%;"
  ) 
)