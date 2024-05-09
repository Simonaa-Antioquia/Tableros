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
  
  output$grafico1 <- plotly::renderPlotly({
    resultado()$plot
  })
  
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$data)) {
      head(resultado()$data, 5)
    }
  })
  
  
  # Descargar grafica 
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_netos", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      tempFile <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(as_widget(resultado()$plot), tempFile, selfcontained = FALSE)
      webshot::webshot(tempFile, file = file, delay = 2)
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
      return(paste("La menor variedad de alimentos registrada fue en el año", anio_max_IHH, "donde se registró un índice máximo de", max_IHH ,"%"))
    } else if (tipo == 0) {
      return(paste("La menor variedad de alimentos registrada fue en el mes", mes_max_IHH,"del año", anio_max_IHH, "donde se registró un índice máximo de", max_IHH,"%"))
    }
    
  })
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  # Borrar filtros
  observeEvent(input$reset, {
    updateSelectInput(session, "tipo", selected = 1)
  })
  
  output$mensaje1 <- renderText({
    return("El índice de Herfindahl-Hirschman permite conocer el nivel de concentración de los alimentos en Antioquia, un mayor índice indica menos variedad de alimentos")
  })
  
  output$mensaje2 <- renderUI({
    withMathJax(paste0("La fórmula es: $$IHH = \\sum_{i=1}^{n} s_i^2$$ donde s es la participación del producto i en el total de alimentos y n es el número total de alimentos."))
  })
  
}