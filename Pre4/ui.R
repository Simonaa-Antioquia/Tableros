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
library(reshape2);library(sf);library(shiny);library(leaflet);library(htmlwidgets)
library(webshot)

################################################################################-
source("001h_precios_diferencias_mapa_funciones.R")

producto_counts <- as.data.frame(table(data$producto))

# Filtrar los productos que aparecen más de 12 veces
productos_filtrados <- producto_counts[producto_counts$Freq > 11, "Var1"]

# Definir la interfaz de usuario
ui <- fluidPage(
  tags$div(
    style = "position: relative; min-height: 100vh; padding-bottom: 100px;",  # Añade un margen inferior
    tags$head(
      tags$title("Mapa comparación de precios"),  # Añade esta línea
      tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Prompt&display=swap"),  # Importa la fuente Prompt
      tags$style(HTML("
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
        column(4,
               selectInput("anio", "Año", c("Todos los años" = "todo", sort(as.character(unique(data$year)))))),
        column(4,
               selectInput("mes", "Mes", c("Todos los meses" = "todo", "Enero" = 1, "Febrero" = 2, "Marzo" = 3, "Abril" = 4, "Mayo" = 5, "Junio" = 6, "Julio" = 7, "Agosto" = 8, "Septiembre" = 9, "Octubre" = 10, "Noviembre" = 11, "Diciembre" = 12), selected="")),
        column(4,
               selectInput("producto", "Producto", c("Todos los productos" = "todo", sort(as.character(unique(productos_filtrados))))))
      )),
  div(
    fluidRow(
      column(10,
             leafletOutput("grafico"),
             downloadButton("descargar", "Gráfica"),
             downloadButton("descargarDatos", "Datos"),
             actionButton("github", "GitHub", icon = icon("github")),
             actionButton("reset", "Restablecer", icon = icon("refresh"))#,
             #tableOutput("vistaTabla") 
      ),
      column(2, 
             wellPanel(textOutput("mensaje1"),
                       style = "background-color: #0D8D38; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje2"),
                       style = "background-color: #005A45; color: #FFFFFF;"),
             wellPanel(textOutput("mensaje3"),
                       style = "background-color: #094735; color: #FFFFFF;")
      )
    ),
    tags$div(tags$p("La comparación es entre ciudades pero para facilidad visual se toman como todo el departamento.",
                    tags$br(),"Fuente: Calculos propios a partir de datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA).", class = "sub-header2"), style = "margin-top: 20px;")
  ),
  tags$div(
    tags$img(src = 'logo.jpeg', style = "width: 100vw;"),
    style = "position: absolute; bottom: 0; width: 100%;"
  )
  )
)