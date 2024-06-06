# Definir la función de servidor
server <- function(input, output, session) {
  
  #resultado<-reactive({
  #  ruta()
  #})
  
  resultado<-reactive({
    #Revisar si se incluye importancia o no
    if (input$importancia == ""){
      # Comprobar si solo se ha seleccionado un producto
      if (input$producto != "todo" && input$anio == "todo" && input$mes == "todo") {
        ruta(Producto = input$producto)
      } else if (input$mes != "todo" && input$anio == "todo") {
        validate(
          need(input$anio != "todo", "Debe seleccionar un año.")
        )
      } else if(input$anio == "todo" && input$producto == "todo" && input$mes == "todo"){
        ruta()
      } else if(input$producto == "todo" && input$mes == "todo" ){
        ruta(Año = input$anio)
      } else if(input$producto == "todo"){
        ruta(Año = input$anio, Mes = input$mes)
      } else if(input$mes == "todo" ){
        ruta(Año = input$anio, Producto = input$producto)
      } else if(input$anio == "todo" && input$mes == "todo"){
        ruta(Producto = input$producto)
      } else{
        ruta(Año = input$anio, Mes = input$mes,Producto = input$producto)
      }
    } else if (input$importancia == "Incluir"){
      # Comprobar si solo se ha seleccionado un producto
      if (input$producto != "todo" && input$anio == "todo" && input$mes == "todo") {
        ruta_importancia(Producto = input$producto)
      } else if (input$mes != "todo" && input$anio == "todo") {
        validate(
          need(input$anio != "todo", "Debe seleccionar un año.")
        )
      } else if(input$anio == "todo" && input$producto == "todo" && input$mes == "todo"){
        ruta_importancia()
      } else if(input$producto == "todo" && input$mes == "todo" ){
        ruta_importancia(Año = input$anio)
      } else if(input$producto == "todo"){
        ruta_importancia(Año = input$anio, Mes = input$mes)
      } else if(input$mes == "todo" ){
        ruta_importancia(Año = input$anio, Producto = input$producto)
      } else if(input$anio == "todo" && input$mes == "todo"){
        ruta_importancia(Producto = input$producto)
      } else{
        ruta_importancia(Año = input$anio, Mes = input$mes,Producto = input$producto)
      }
    }
  })
  
  output$plot <- renderLeaflet({
    #df <- abastecimiento_medellin
    #df <- df[!(duplicated(df[c("codigo_mpio_destino","codigo_mpio_origen")])),]
    
    #ruta()$grafico
    
    #ruta()$grafico
    res <- resultado()
    if (nrow(res$datos) == 0) {
      validate("No hay datos disponibles")
    } else {
      res$grafico
    }
    #resultado()$grafico
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica-", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      tempFile <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
      webshot::webshot(tempFile, file = file, delay = 2)
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
  
  #observeEvent(input$github, {
  #  browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  #})
  
  # En el servidor
  output$subtitulo <- renderText({
    res<-resultado()
    if(nrow(res$datos)==0){
      return("No hay datos disponibles")
    }
  })
  
 
 observeEvent(input$reset, {
      updateSelectInput(session, "municipios", selected = 10)
      updateSelectInput(session, "anio", selected = "")
      updateSelectInput(session, "mes", selected = "")
      updateSelectInput(session, "producto", selected = NULL)
    })
 
 output$mensaje1 <- renderText({
   res <- resultado()
    if (nrow(res$datos) == 0) {
      validate("No hay datos disponibles")
    } else {
     values$mensaje1 <- return(paste0("Durante el periodo seleccionado y para el producto específico, se recorrieron en promedio ", resultado()$av_km," kilómetros."))
    }
    return(values$mensaje1)
})

 output$mensaje2 <- renderText({
   res <- resultado()
    if (nrow(res$datos) == 0) {
      validate("No hay datos disponibles")
    } else {
      values$mensaje2 <- return(paste0("Durante el periodo seleccionado y para el producto específico, se recorrieron la distancia mínima recorrida fue ", resultado()$min_km," kilómetros y máxima ", resultado()$max_km," kilómetros."))
    }
    return(values$mensaje2)
})       
 
 # Aqui tomamos screen 
 observeEvent(input$go, {
   screenshot()
 })
 
 observeEvent(input$descargar, {
   screenshot("#grafico", scale = 5)
 }) 
}

