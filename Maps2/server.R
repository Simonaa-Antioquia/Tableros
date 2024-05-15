# Definir la función de servidor
server <- function(input, output, session) {
  
  #resultado<-reactive({
  #  ruta()
  #})
  
  resultado<-reactive({
    #Comprobar si se selecciono como minimo una ruta para apagar
    if(is.null(input$ruta)) {
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
    } else {
        #r1 <- "r1" %in% input$ruta
        #r2 <- "r2" %in% input$ruta
        #r3 <- "r3" %in% input$ruta
        #r4 <- "r4" %in% input$ruta
        #r5 <- "r5" %in% input$ruta

        rutas <- unname(unlist(mget(input$varchoices, inherits = TRUE)))

        # Comprobar si solo se ha seleccionado un producto
        if (input$producto != "" && input$anio == "" && input$mes == "") {
          ruta(Producto = input$producto, Rutas = input$ruta)
        } else if (input$mes != "" && input$anio == "") {
          validate(
            need(input$anio != "", "Debe seleccionar un año.")
          )
        } else if(input$anio == "" && input$producto == "" && input$mes == ""){
          ruta(Rutas = input$ruta)
        } else if(input$producto == "" && input$mes == "" ){
          ruta(Año = input$anio, Rutas = input$ruta)
        } else if(input$producto == ""){
          ruta(Año = input$anio, Mes = input$mes, Rutas = input$ruta)
        } else if(input$mes == "" ){
          ruta(Año = input$anio, Producto = input$producto, Rutas = input$ruta)
        } else if(input$anio == "" && input$mes == ""){
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
    resultado()$grafico
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_cierre_rutas", Sys.Date(), ".png", sep="")
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
      write.csv(resultado()$datos, file)
    }
  )
}

