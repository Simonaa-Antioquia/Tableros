# Definir la función de servidor
server <- function(input, output, session) {
  
  #resultado<-reactive({
  #  ruta()
  #})
  
  resultado<-reactive({
    #Comprobar si se selecciono como minimo una ruta para apagar
    if(is.null(input$ruta)) {
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
    } else {
        #r1 <- "r1" %in% input$ruta
        #r2 <- "r2" %in% input$ruta
        #r3 <- "r3" %in% input$ruta
        #r4 <- "r4" %in% input$ruta
        #r5 <- "r5" %in% input$ruta

        #rutas <- unname(unlist(mget(input$varchoices, inherits = TRUE)))

        # Comprobar si solo se ha seleccionado un producto
        if (input$producto != "todo" && input$anio == "todo" && input$mes == "todo") {
          ruta(Producto = input$producto, Rutas = input$ruta)
        } else if (input$mes != "todo" && input$anio == "todo") {
          validate(
            need(input$anio != "todo", "Debe seleccionar un año.")
          )
        } else if(input$anio == "todo" && input$producto == "todo" && input$mes == "todo"){
          ruta(Rutas = input$ruta)
        } else if(input$producto == "todo" && input$mes == "todo" ){
          ruta(Año = input$anio, Rutas = input$ruta)
        } else if(input$producto == "todo"){
          ruta(Año = input$anio, Mes = input$mes, Rutas = input$ruta)
        } else if(input$mes == "todo" ){
          ruta(Año = input$anio, Producto = input$producto, Rutas = input$ruta)
        } else if(input$anio == "todo" && input$mes == "todo"){
          ruta(Producto = input$producto, Rutas = input$ruta)
        } else{
          ruta(Año = input$anio, Mes = input$mes,Producto = input$producto, Rutas = input$ruta)
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
      validate("No hay datos disponibles"
      )
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
  
 observeEvent(input$reset, {
      updateSelectInput(session, "municipios", selected = 10)
      updateSelectInput(session, "anio", selected = "")
      updateSelectInput(session, "mes", selected = "")
      updateSelectInput(session, "producto", selected = NULL)
    })

 output$mensaje1 <- renderText({
   res <- resultado()
    if (nrow(res$datos) == 0) {
      validate("No hay datos disponibles"
      )
    } else {
      values$mensaje1 <- return(paste0("La ruta ",resultado()$ruta_imp," es la más importante para el abastecimiento de Antioquia, representando el ",resultado()$por_ruta,"% del total del volumen de ingreso a las principales centrales de abasto."))
    }
   return(values$mensaje1)
 })
 
output$mensaje2 <- renderText({
  res <- resultado()
    if (nrow(res$datos) == 0) {
      validate("No hay datos disponibles"
      )
    } else {
      values$mensaje2 <- return(paste0("Un hipotético cierre de las rutas seleccionadas podría reducir el abastecimiento de alimentos en un ",resultado()$por_perdido,"%, al dejar de ingresar ",resultado()$ton_perdido," toneladas a las principales centrales de abasto de Medellín."))
    }
   return(values$mensaje2)
 })

output$mensaje3 <- renderText({
  res <- resultado()
    if (nrow(res$datos) == 0) {
      validate("No hay datos disponibles"
      )
    } else {
      values$mensaje3 <-  return(paste0("Las rutas del abastecimiento de Antioquia por orden de importancia en el periodo y para el producto seleccionado son: ",resultado()$rutas_ordenadas,"."))
    }
   return(values$mensaje3)
 })
 
 # Aqui tomamos screen 
 observeEvent(input$go, {
   screenshot()
 })
 
 observeEvent(input$descargar, {
   screenshot("#grafico", scale = 5)
 }) 
}
