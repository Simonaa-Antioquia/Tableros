#Proyecto FAO
#Procesamiento datos SIPSA
# Server
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 02/04/2024
#Fecha de ultima modificacion: 02/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
options(scipen = 999)
################################################################################-

# Definir la función de servidor
server <- function(input, output, session) {
  
  resultado<-reactive({
    # Comprobar si solo se ha seleccionado un producto
    if (input$producto != "todo" && input$anio == "todo" && input$mes == "todo") {
      importancia(Producto = input$producto,municipios = input$municipios)
    } else if (input$mes != "todo" && input$anio == "todo") {
      validate(
        need(input$anio != "todo", "Debe seleccionar un año.")
      )
    } else if(input$anio == "todo" && input$producto == "todo" && input$mes == "todo"){
      importancia(municipios = input$municipios)
    } else if(input$producto == "todo" && input$mes == "todo" ){
      importancia(Año = input$anio, municipios = input$municipios)
    } else if(input$producto == "todo"){
      importancia(Año = input$anio, Mes = input$mes ,municipios = input$municipios)
    } else if(input$mes == "todo" ){
      importancia(Año = input$anio, municipios = input$municipios, Producto = input$producto)
    } else if(input$anio == "todo" && input$mes == "todo"){
      importancia(Producto = input$producto,municipios = input$municipios)
    } else{
      importancia(Año = input$anio, Mes = input$mes ,municipios = input$municipios, Producto = input$producto)
    }
  })
  
  output$grafico <- plotly::renderPlotly({
    res <- resultado()
    if (nrow(res$datos)==0) {
      validate(
        ("No hay datos disponibles")
      )
    } else {
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
  
  observeEvent(input$reset, {
    updateSelectInput(session, "municipios", selected = 10)
    updateSelectInput(session, "anio", selected = "todo")
    updateSelectInput(session, "mes", selected = "todo")
    updateSelectInput(session, "producto", selected = "todo")
  })
  
  output$subtitulo <- renderText({
    resultado <- resultado()
    if (nrow(resultado$datos) == 0) {
      validate("No hay datos disponibles")
    } else {
    lugar_max <- resultado$lugar_max
    porcentaje_max<-resultado$porcentaje_max
    #if(input$anio == ""){
    return(paste0("El principal municipio a donde va la comida de Antioquia es ", lugar_max, " con un ", porcentaje_max,"%"))
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

