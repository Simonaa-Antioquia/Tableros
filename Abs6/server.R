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
    if(input$año=="todo"&&input$mes=="todo"&&input$depto=="todo"){
      salen_prod()
    }else if(input$año=="todo"&&input$mes=="todo"){
      salen_prod(depto = input$depto)
    }else if(input$año=="todo"){
      validate(
        need(input$año != "todo", "Debe seleccionar un año.")
      )
    }else if(input$año=="todo"&&input$depto=="todo"){
      validate(
        need(input$año != "todo", "Debe seleccionar un año.")
      )
    }else if(input$mes=="todo"&&input$depto=="todo"){
      salen_prod(año = input$año)
    }else if(input$depto=="todo"){
      salen_prod(año = input$año, Mes = input$mes)
    }else if(input$mes=="todo"){
      salen_prod(año = input$año, depto = input$depto)
    }else {
      salen_prod(año = input$año, Mes = input$mes, depto = input$depto) 
    }
  })
  
  output$grafico <- renderHighchart({
    res<-resultado()
    if(nrow(res$datos)==0){
      validate(
        ("No hay datos disponibles")
      )
    }else{
      res$grafico
    }
    
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafico-", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Guardar el gráfico en un archivo temporal HTML
      tempFile <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(resultado()$grafico, file = tempFile, selfcontained = FALSE)
      
      # Usar webshot en el archivo HTML
      webshot::webshot(url = tempFile, file = file, delay = 3)
    }
  )
  
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  observeEvent(input$reset, {
    updateSelectInput(session, "año", selected = "todo")
    updateSelectInput(session, "mes", selected = "todo")
    updateSelectInput(session, "depto", selected = "todo")
  })
  
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
      res<-resultado()
      if(nrow(res$datos)==0){
        validate(
          ("No hay datos disponibles.")
        )
      }else{
    resultado <- resultado()
    producto_max <- resultado$producto_max
    porcentaje_max<-resultado$porcentaje_max
    #if(input$anio == ""){
    return(paste0("El producto que más sale de Antioquia es ", producto_max, " con un ", porcentaje_max,"%."))
    }
  })
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
}