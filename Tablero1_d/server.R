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
    if(input$anio == ""){
      graficar_producto_y_precio(complet, input$producto)}
    else{
      graficar_producto_y_precio(complet,  input$producto, input$anio)
    }  
  })
  
  
  output$grafico <- renderPlot({
    resultado()$grafico
  }, res = 100)
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_precios_cantidades_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      png(file, width = 2300, height = 1500, res = 300)  # Especifica el ancho y el alto de la imagen
      print(resultado()$grafico)
      dev.off()
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
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    mes_max <- resultado$mes_max
    distancia_max<-resultado$distancia_max
    cantidades_max<-resultado$cantidades_max
    precio_max<-resultado$precio_max
    
    #if(input$anio == ""){
    return(paste0("El mes más caro es ", mes_max,", siendo ", precio_max," pesos con ",cantidades_max," mil de toneladas ingresadas y ",distancia_max," kilómetros recorridos"))
    #} 
  })
}