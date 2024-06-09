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
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot); library(shiny);library(htmlwidgets);library(webshot);library(magick);library(shinyscreenshot);library(webshot2)
options(scipen = 999)
################################################################################
server <- function(input, output, session) {
  
  ## The element vals will store all plots and tables
  
    resultado<-reactive({
    if(input$anio == "todo" && input$producto == "todo"){
      graficar_variable(base=input$base, variable=input$variable)
    } else if(input$producto == "todo"){
      graficar_variable(base=input$base, variable=input$variable,  fecha = input$anio)
    } else if(input$anio == "todo"){
      graficar_variable(base=input$base,variable=input$variable, input$producto)
    } else{
      graficar_variable(base=input$base,variable=input$variable, input$producto, input$anio)
    }
  })
  

  observeEvent(input$reset, {
    updateSelectInput(session, "producto", selected = "todo")
    updateSelectInput(session, "variable", selected = "precio_prom")
    updateSelectInput(session, "anio", selected = "todo")
  })
  
  
  output$grafico <- renderPlotly({
    plotly::ggplotly(resultado()$grafico)
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  

output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$datos, file)
    }
  )
  
  #observeEvent(input$github, {
  #  browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  #})
  
  # En el servidor
values <- reactiveValues(subtitulo = NULL)

  output$subtitulo <- renderText({
    resultado <- resultado()
    promedio <- formatC(resultado$promedio, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)
    fecha_max <- resultado$fecha_max
    fecha_min <- resultado$fecha_min
    values$subtitulo <-(paste0("El precio promedio",ifelse(input$producto=="todo"," de ''todos los productos''",paste0(" de ", input$producto)) ," fue de $", promedio,
                  ". La fecha con el precio más alto fue ", fecha_max, " y la más baja fue ", fecha_min))
    return(values$subtitulo)
  })
  
  grafico_plano <- reactive({
    res <- resultado()
    {
      res$grafico2  # Guarda solo el gráfico 'grafico_plano'
    }
  })
  
  values <- reactiveValues(mensaje1 = NULL)
  output$mensaje1 <- renderText({
    resultado <- resultado()
    values$mensaje1<-resultado$producto_vol
    return(values$mensaje1)
  })
  values <- reactiveValues(mensaje2 = NULL)
  output$mensaje2 <- renderText({
    resultado <- resultado()
    values$mensaje2<-resultado$promedio_camb
    return(values$mensaje2)
  })
  values <- reactiveValues(mensaje3 = NULL)
  output$mensaje3 <- renderText({
    resultado <- resultado()
    values$mensaje3<-resultado$promedio_camb_an
    return(values$mensaje3)
  })
  
  # Aqui tomamos screen 
  output$report <- downloadHandler(
    filename = 'informe.pdf',
    
    content = function(file) {
      # Ruta al archivo RMarkdown
      rmd_file <- "informe.Rmd"
      
      # Renderizar el archivo RMarkdown a PDF
      rmarkdown::render(rmd_file, output_file = file, params = list(
        datos = resultado()$datos,
        promedio = resultado()$promedio,
        fecha_max = resultado()$fecha_max,
        fecha_min = resultado()$fecha_min,
        plot = grafico_plano()+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)),# Accede al gráfico 'grafico_plano'
        subtitulo = values$subtitulo,
        mensaje1 = values$mensaje1,
        mensaje2 = values$mensaje2,
        mensaje3 = values$mensaje3,
        tipo = input$variable,
        anio = input$anio,
        base = input$base,
        alimento = input$producto
      ))
      
      
    },
    
    contentType = 'application/pdf'
  )
  
  observeEvent(input$descargar, {
    screenshot("#grafico", scale = 5)
  })

}
  
