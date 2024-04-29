#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/04/2024
#Fecha de ultima modificacion: 21/04/2024
################################################################################
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################
library(shiny)
################################################################################
server <- function(input, output, session) {
  
  resultado<-reactive({
    if(input$año==""&&input$mes==""&&input$depto==""){
      salen_prod()
    }else if(input$año==""&&input$mes==""){
      salen_prod(depto = input$depto)
    }else if(input$año==""){
      validate(
        need(input$año != "", "Debe seleccionar un año.")
      )
    }else if(input$año==""&&input$depto==""){
      validate(
        need(input$año != "", "Debe seleccionar un año.")
      )
    }else if(input$mes==""&&input$depto==""){
      salen_prod(año = input$año)
    }else if(input$depto==""){
      salen_prod(año = input$año, Mes = input$mes)
    }else if(input$mes==""){
      salen_prod(año = input$año, depto = input$depto)
    }else {
      salen_prod(año = input$año, Mes = input$mes, depto = input$depto) 
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
      paste("grafica_productos_salen_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Forzar la ejecución de la función reactiva
      res <- resultado()
      
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = res$grafico, width = 13, height = 7, dpi = 200)
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
    producto_max <- resultado$producto_max
    porcentaje_max<-resultado$porcentaje_max
    #if(input$anio == ""){
    return(paste0("El producto que más sale de Antioquia es ", producto_max, " con un ", porcentaje_max,"%."))
    #}
  })
}


