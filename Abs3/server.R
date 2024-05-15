

# Definir la función de servidor
server <- function(input, output, session) {
  
  resultado<-reactive({
    # Comprobar si solo se ha seleccionado un producto
    if (input$producto != "todo" && input$anio == "todo" && input$mes == "todo") {
      col_en_ant(Producto = input$producto)
    } else if (input$mes != "todo" && input$anio == "todo") {
      validate(
        need(input$anio != "todo", "Debe seleccionar un año.")
      )
    } else if(input$anio == "todo" && input$producto == "todo" && input$mes == "todo"){
      col_en_ant()
    } else if(input$producto == "todo" && input$mes == "todo" ){
      col_en_ant(Año = input$anio)
    } else if(input$producto == "todo"){
      col_en_ant(Año = input$anio, Mes = input$mes)
    } else if(input$mes == "todo" ){
      col_en_ant(Año = input$anio, Producto = input$producto)
    } else if(input$anio == "todo" && input$mes == "todo"){
      col_en_ant(Producto = input$producto)
    } else{
      col_en_ant(Año = input$anio, Mes = input$mes ,Producto = input$producto)
    }  
  })
  
  observeEvent(input$reset, {
    updateSelectInput(session, "producto", selected = "todo")
    updateSelectInput(session, "mes", selected = "todo")
    updateSelectInput(session, "anio", selected = "todo")
  })
  
  output$grafico <- renderLeaflet({
    res <- resultado()
    if (is.data.frame(res) || is.list(res)) {
      if (nrow(res$datos) == 0) {
        print("No hay datos disponibles")
        leaflet()  # Devuelve un mapa de Leaflet vacío
      } else {
        res$grafico %>%
          setView(lng = -75.5, lat = 3.9, zoom = 5) 
      }
    } else {
      print("No hay datos disponibles")
      leaflet()  # Devuelve un mapa de Leaflet vacío
    }
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  #output$descargar <- downloadHandler(
   # filename = function() {
    #  paste("grafica-", Sys.Date(), ".png", sep="")
    #},
    #content = function(file) {
     # tempFile <- tempfile(fileext = ".html")
      #htmlwidgets::saveWidget(plotly::as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
      #webshot::webshot(tempFile, file = file, delay = 2, vwidth = 800, vheight = 800)
    #}
  #)
  
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
  
  output$subtitulo <- renderText({
    res <- resultado()
    if (is.data.frame(res) || is.list(res)) {
      if(nrow(res$datos) == 0) {
        return("No hay datos disponibles")
      }else{
        porcentaje_max <- res$porcentaje_max
        dpto_max <- res$dpto_max
        
        return(paste0(dpto_max," recibe el ", porcentaje_max, "% de lo que ingresa de Antioquia, siendo el departamento que más recibe de este."))
      }
    } else {
      return("No hay datos disponibles")
    }
  })
  
  output$mensaje1 <- renderText({
    #resultado <- resultado()
    #volatil<-resultado$producto_vol
    return("Cada porcentaje es lo que cada departamento recibe de Antioquia del total de productos que ingresan a este.")
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

