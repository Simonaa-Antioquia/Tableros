#Proyecto FAO
# Server
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 28/03/2024
#Fecha de ultima modificacion: 28/03/2024
# NETOS (FUNCIONES 5)
################################################################################
# Paquetes 
################################################################################
library(shiny); library(lubridate);library(shinythemes);library(shinyWidgets)
options(scipen = 999)
################################################################################

server <- function(input, output, session) {
  resultado <- reactive({
    tipo <- input$tipo
    producto_seleccionado <- input$producto_seleccionado
    
    if ((tipo == 2 || tipo == 4) && is.null(producto_seleccionado)) {
      validate(
        need(FALSE, "Debe seleccionar un producto.")
      )
    }
    
    if (is.null(producto_seleccionado)) {
      producto_seleccionado <- ""
    }
    
    neto_grafica(tipo, producto_seleccionado)
  })
  
  output$tiempo1 <- renderPlot({
    resultado()
  }, res = 150)  # Aumenta la resolución a 96 ppp
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_netos_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = resultado(), width = 13, height = 7, dpi = 200)
    }
  )
  
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado(), file)
    }
  )
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    fecha_min <- resultado$fecha_min
    min_ton <- resultado$min_ton
    paste0("Hubo mayor diferencia de entrada y salida de alimentos el ", fecha_min, " ingresando ", min_ton, " mil toneladas más de las que salieron.")
  })
}