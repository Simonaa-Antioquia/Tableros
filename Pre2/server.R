#Proyecto FAO
#Procesamiento datos SIPSA
# Server
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 27/02/2024
#Fecha de ultima modificacion: 27/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(corrplot); library(shiny)
library(htmlwidgets);library(webshot);library(magick);library(shinyscreenshot);library(webshot2)
options(scipen = 999)
################################################################################-

server <- function(input, output, session) {
  
  
  resultado<-reactive({
    if(input$anio == "todos"){
      graficar_producto_y_precio(complet, input$producto)}
    else{
      graficar_producto_y_precio(complet,  input$producto, input$anio)
    }  
  })
  
  
  output$grafico <- renderPlotly({
    res<-resultado()
    if (nrow(res$datos)<1){
      validate(
        "No hay datos disponibles"
      )
    } else {
      res$grafico 
    }
  })
  
  observeEvent(input$reset, {
    updateSelectInput(session, "producto", selected = "total")
    updateSelectInput(session, "anio", selected = "todos")
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  #output$descargar <- downloadHandler(
    #filename = function() {
     # paste("grafica-", Sys.Date(), ".png", sep="")
    #},
    #content = function(file) {
      #tempFile <- tempfile(fileext = ".html")
     # htmlwidgets::saveWidget(as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
    #  webshot::webshot(tempFile, file = file, delay = 2, vwidth = 800, vheight = 500, zoom = 2)
   # }
  #)
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
  
  grafico_plano <- reactive({
    res <- resultado()
    {
      res$grafico2  # Guarda solo el gráfico 'grafico_plano'
    }
  })
  
  # En el servidor
  values <- reactiveValues(subtitulo = NULL)
  output$subtitulo <- renderText({
    resultado <- resultado()
    mes_max <- resultado$mes_max
    distancia_max<-resultado$distancia_max
    cantidades_max<-resultado$cantidades_max
    precio_max<-resultado$precio_max
    
    if(nrow(resultado$datos) < 1){
      validate("No hay datos disponibles")
    }else{
      values$subtitulo<-(paste0("Para el producto y periodo de tiempo analizado, ", mes_max," destacó como el mes más costoso, con un precio promedio de $", precio_max," y un volumen total de ingreso de ",cantidades_max," mil toneladas."))
      return(values$subtitulo)
    } 
  })
  
  output$mensaje1 <- renderText({
    #resultado <- resultado()
    #volatil<-resultado$producto_vol
    return("Promedio de precios y cantidades de productos en Medellín para cada mes del año")
  })
  values <- reactiveValues(mensaje2 = NULL)
  output$mensaje2 <- renderText({
    resultado <- resultado()
    values$mensaje2<-resultado$mensaje2
    return(values$mensaje2)
  })
  
  values <- reactiveValues(mensaje3 = NULL)
  output$mensaje3 <- renderText({
    resultado <- resultado()
    values$mensaje3<-resultado$mensaje3
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
        mes_max = resultado()$mes_max,
        distancia_max=resultado()$distancia_max,
        cantidades_max=resultado()$cantidades_max,
        precio_max=resultado()$precio_max,
        plot = grafico_plano(),#+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)),# Accede al gráfico 'grafico_plano'
        subtitulo = values$subtitulo,
        mensaje2 = values$mensaje2,
        mensaje3 = values$mensaje3,
        anio = input$anio,
        alimento = input$producto
      ))
      
      
    },
    
    contentType = 'application/pdf'
  )
  
  observeEvent(input$descargar, {
    screenshot("#grafico", scale = 5)
  })
  
}