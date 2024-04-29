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

server <- function(input, output, session) {
  
  resultado<-reactive({
    # Comprobar si solo se ha seleccionado un producto
    if (input$producto != "" && input$anio == "" && input$mes == "") {
      mapa_dif(Producto = input$producto) #Producto en los 10 Anios
    } else if (input$producto != "" && input$anio != "" && input$mes == "") {
      mapa_dif(Anio = input$anio, Producto = input$producto) #Producto en determinado Anio
    } else if(input$producto == "" && input$anio == "" && input$mes == ""){
      mapa_dif()#Todos los Anios
    } else if(input$producto == "" && input$anio != "" && input$mes == ""){
      mapa_dif(Anio = input$anio)#Ano en específico
    } else if(input$producto == "" && input$anio != "" && input$mes != ""){
      mapa_dif(Anio = input$anio, Mes = input$mes)#Anio y mes específico
    } else if(input$producto != "" && input$anio == "" && input$mes != ""){
      mapa_dif(Mes = input$mes , Producto = input$producto)#mes en todos los Anios por producto
    } else if(input$producto == "" && input$anio == "" && input$mes != ""){
      mapa_dif(Mes = input$mes) #Mes en específico
    } else{
      mapa_dif(Anio = input$anio, Mes = input$mes ,Producto = input$producto)#Anio, mes y producto específico
    } 
  })
  
  output$grafico <- renderPlot({
    data <- resultado()
    validate(
      need(nrow(data$datos) > 0, "No hay datos disponibles")
    )
    data$grafico
  }, res = 100)
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_precios_diferencias_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Forzar la ejecución de la función reactiva
      res <- resultado()
      
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = res$grafico, width = 7, height = 7, dpi = 400)
    }
  )
  
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write_csv(resultado()$datos, file)
    }
  )
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    precio_max <- resultado$precio_max
    precio_min <- resultado$precio_min
    ciudad_max <- resultado$ciudad_max
    ciudad_min <- resultado$ciudad_min
    
    return(paste0(ciudad_max," es $", precio_max, " costosa que Medellín, mientras que ", ciudad_min," es $", precio_min," más barata."))
  })
}