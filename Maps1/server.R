# Definir la función de servidor
server <- function(input, output, session) {
  
  #resultado<-reactive({
  #  ruta()
  #})
  
  resultado<-reactive({
    #Revisar si se incluye importancia o no
    if (input$importancia == ""){
      # Comprobar si solo se ha seleccionado un producto
      if (input$producto != "" && input$anio == "" && input$mes == "") {
        ruta(Producto = input$producto)
      } else if (input$mes != "" && input$anio == "") {
        validate(
          need(input$anio != "", "Debe seleccionar un año.")
        )
      } else if(input$anio == "" && input$producto == "" && input$mes == ""){
        ruta()
      } else if(input$producto == "" && input$mes == "" ){
        ruta(Año = input$anio)
      } else if(input$producto == ""){
        ruta(Año = input$anio, Mes = input$mes)
      } else if(input$mes == "" ){
        ruta(Año = input$anio, Producto = input$producto)
      } else if(input$anio == "" && input$mes == ""){
        ruta(Producto = input$producto)
      } else{
        ruta(Año = input$anio, Mes = input$mes,Producto = input$producto)
      }
    } else if (input$importancia == "Incluir"){
      # Comprobar si solo se ha seleccionado un producto
      if (input$producto != "" && input$anio == "" && input$mes == "") {
        ruta_importancia(Producto = input$producto)
      } else if (input$mes != "" && input$anio == "") {
        validate(
          need(input$anio != "", "Debe seleccionar un año.")
        )
      } else if(input$anio == "" && input$producto == "" && input$mes == ""){
        ruta_importancia()
      } else if(input$producto == "" && input$mes == "" ){
        ruta_importancia(Año = input$anio)
      } else if(input$producto == ""){
        ruta_importancia(Año = input$anio, Mes = input$mes)
      } else if(input$mes == "" ){
        ruta_importancia(Año = input$anio, Producto = input$producto)
      } else if(input$anio == "" && input$mes == ""){
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
    resultado()$grafico
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
  
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  # En el servidor
  output$subtitulo <- renderText({
    res<-resultado()
    if(nrow(res$datos)==0){
      return("No hay datos disponibles")
    }else{
      resultado <- resultado()
    lugar_max <- resultado$lugar_max
    porcentaje_max<-resultado$porcentaje_max
   
    if (is.na(input$municipios) || is.null(input$municipios )){
      return("Por favor ingrese el numero de municipios que quiere graficar")
    } else {
      return(paste0(lugar_max, "es el municipio con mayor importancia en el abastecimeinto de Antioquia, aporta ",porcentaje_max,"%"))
    }}
  })
  
 
 observeEvent(input$reset, {
      updateSelectInput(session, "municipios", selected = 10)
      updateSelectInput(session, "anio", selected = "")
      updateSelectInput(session, "mes", selected = "")
      updateSelectInput(session, "producto", selected = NULL)
    })
 
 output$mensaje1 <- renderText({
    return(paste0("Los alimentos recorren en promedio ", resultado()$av_km, " kilómetros, con un máximo de ", resultado()$max_km, " kilómetros."))
 })

 output$mensaje2 <- renderText({
    return(paste0("Los alimentos recorren en promedio ", resultado()$av_km, " kilómetros, con un máximo de ", resultado()$max_km, " kilómetros."))
 })       
 
 # Aqui tomamos screen 
 observeEvent(input$go, {
   screenshot()
 })
 
 observeEvent(input$descargar, {
   screenshot("#grafico", scale = 5)
 }) 
}

