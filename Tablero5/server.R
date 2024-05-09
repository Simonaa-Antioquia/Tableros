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
  
  output$grafico <- plotly::renderPlotly({
    res <- resultado()
      res$grafico  # Devuelve el gráfico Plotly
  }) 
  
# Descargar grafica 

  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_netos", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      tempFile <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
      webshot::webshot(tempFile, file = file, delay = 2)
    }
  )  
  

  
# Datos
  
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos_netos", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$datos, file)
    }
  )
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    fecha_min <- resultado$fecha_min
    min_ton <- resultado$min_ton
    paste0("Hubo mayor diferencia de entrada y salida de alimentos el ", fecha_min, " ingresando ", min_ton, " mil toneladas más de las que salieron.")
  })
  
  # Borrar filtros
  observeEvent(input$reset, {
    updateSelectInput(session, "tipo", selected = 1)
  })
  
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  output$mensaje1 <- renderText({
      return("Neto es igual a la cantidad de kilogramos que salen me Antioquia menos los que Ingresan")
  })
  
  #output$mensaje2 <- renderText({
  #    if (input$tipo != 1) {
  #      return(paste0("El lugar más costoso para comprar ", input$producto, " es ", resultado()$ciudad_max, ". Es $", resultado()$precio_max, " más costoso que comprarlo en Medellín."))
  #    } else {
  #      return(paste0("El lugar más costoso para comprar alimentos es ", resultado()$ciudad_max, ". En promedio es $", resultado()$precio_max, " más costoso que comprarlos en Medellín."))
  #    }
  #  
  #  })
  
  
  
}