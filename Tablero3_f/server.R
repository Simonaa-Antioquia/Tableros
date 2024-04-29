

# Definir la función de servidor
server <- function(input, output, session) {
  
  resultado<-reactive({
    # Comprobar si solo se ha seleccionado un producto
    if (input$producto != "" && input$anio == "" && input$mes == "") {
      col_en_ant(Producto = input$producto)
    } else if (input$mes != "" && input$anio == "") {
      validate(
        need(input$anio != "", "Debe seleccionar un año.")
      )
    } else if(input$anio == "" && input$producto == "" && input$mes == ""){
      col_en_ant()
    } else if(input$producto == "" && input$mes == "" ){
      col_en_ant(Año = input$anio)
    } else if(input$producto == ""){
      col_en_ant(Año = input$anio, Mes = input$mes)
    } else if(input$mes == "" ){
      col_en_ant(Año = input$anio, Producto = input$producto)
    } else if(input$anio == "" && input$mes == ""){
      col_en_ant(Producto = input$producto)
    } else{
      col_en_ant(Año = input$anio, Mes = input$mes ,Producto = input$producto)
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
      paste("grafica_porcentaje_recibe_de_antioquia_", Sys.Date(), ".png", sep="")
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
  
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    porcentaje_max <- resultado$porcentaje_max
    dpto_max <- resultado$dpto_max
    
    #if(input$anio == ""){
    return(paste0(dpto_max," recibe el ", porcentaje_max, "% de lo que ingresa de Antioquia, siendo el departamento que más recibe de este."))
    #} 
  })
}

