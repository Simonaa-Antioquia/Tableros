#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/04/2024
#Fecha de ultima modificacion: 21/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################

server <- function(input, output, session) {
  
  resultado<-reactive({
    if(input$año=="todo"&&input$mes!="todo"&&input$depto=="todo"){
      validate(
        need(input$anio != "todo", "Debe seleccionar un año.")
      )
    }else if(input$año=="todo"&&input$mes=="todo"&&input$depto=="todo"){
      entran_prod()
    }else if(input$año=="todo"&&input$mes=="todo"){
      entran_prod(depto = input$depto)
    }else if(input$año=="todo"){
      print("Seleccione un año")
    }else if(input$año=="todo"&&input$depto=="todo"){
      print("Seleccione un año")
    }else if(input$mes=="todo"&&input$depto=="todo"){
      entran_prod(año = input$año)
    }else if(input$depto=="todo"){
      entran_prod(año = input$año, Mes = input$mes)
    }else if(input$mes=="todo"){
      entran_prod(año = input$año, depto = input$depto)
    }else {
      entran_prod(año = input$año, Mes = input$mes, depto = input$depto) 
    } 
  })
  
  output$grafico <- renderHighchart({
    res<-resultado()
    if(nrow(res$datos)==0){
      validate(
        ("Debe seleccionar un año.")
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
  
  observeEvent(input$reset, {
    updateSelectInput(session, "año", selected = "todo")
    updateSelectInput(session, "mes", selected = "todo")
    updateSelectInput(session, "depto", selected = "todo")
  })
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    producto_max <- resultado$producto_max
    porcentaje_max<-resultado$porcentaje_max
    #if(input$anio == ""){
    return(paste0("El producto que más ingresa a Medellín es ", producto_max, " con un ", porcentaje_max,"%."))
    #}
  })
  
  output$mensaje1 <- renderText({
    #resultado <- resultado()
    #volatil<-resultado$producto_vol
    return("Este gráfico muestra la importancia que tiene cada alimento en los alimentos que ingresan a los centros de acopio de Medellín.")
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
  
  # Aqui tomamos screen 
  observeEvent(input$go, {
    screenshot()
  })
  
  observeEvent(input$descargar, {
    screenshot("#grafico", scale = 5)
  })
}
