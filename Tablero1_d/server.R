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
    res$grafico
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
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica-", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      tempFile <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
      webshot::webshot(tempFile, file = file, delay = 2, vwidth = 800, vheight = 500, zoom = 2)
    }
  )
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$datos, file)
    }
  )
  
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    mes_max <- resultado$mes_max
    distancia_max<-resultado$distancia_max
    cantidades_max<-resultado$cantidades_max
    precio_max<-resultado$precio_max
    
    output$mensaje1 <- renderText({
      #resultado <- resultado()
      #volatil<-resultado$producto_vol
      return("Poner mensaje")
    })
    
    output$mensaje2 <- renderText({
      #resultado <- resultado()
      #promedio_camb<-resultado$promedio_camb
      return("Poner mensaje")
    })
    
    output$mensaje3 <- renderText({
      #resultado <- resultado()
      #promedio_camb_an<-resultado$promedio_camb_an
      return("Poner mensaje")
    })
    #if(input$anio == ""){
    return(paste0("El mes más caro es ", mes_max,", siendo $", precio_max," con ",cantidades_max," mil de toneladas ingresadas y ",distancia_max," kilómetros recorridos"))
    #} 
  })
}