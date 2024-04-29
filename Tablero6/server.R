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

server <- function(input, output, session) {
  resultado <- reactive({
    # Si el input del año está vacío, déjalo vacío, de lo contrario, usa el año seleccionado
    anio <- if (is.null(input$anio) || input$anio == "") NULL else input$anio
    tipo <- input$tipo
    
    # Llama a la función plot_data con los parámetros seleccionados
    plot_data(tipo, anio)
  })
  
  output$grafico1 <- renderPlot({
    # Devuelve el gráfico
    resultado()$plot
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$data)) {
      head(resultado()$data, 5)
    }
  })
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_indice_variedad_abastecimeinto_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Ajusta el tamaño de la imagen y la resolución para que coincidan con la proporción de aspecto del gráfico
      png(file, width = 10, height = 7, units = "in", res = 300)
      print(resultado()$plot)
      dev.off()
    }
  )
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$data, file)
    }
  )
  
  output$subtitulo <- renderText({
    tipo <- input$tipo
    anio <- ifelse(is.null(input$anio) || input$anio == "", NA, input$anio)
    data_resultado <- resultado()
    
    max_IHH <- data_resultado$max_IHH
    mes_max_IHH <- data_resultado$mes_max_IHH
    anio_max_IHH <- data_resultado$anio_max_IHH
    
    if (tipo == 1) {
      return(paste("El mayor indice anual es", max_IHH , "en el año", anio_max_IHH))
    } else if (tipo == 0) {
      return(paste("El mayor indice mensual es", max_IHH, "en el mes", mes_max_IHH, "del año", anio_max_IHH))
    }
  })
  
}