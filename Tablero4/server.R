# Definir la función de servidor
server <- function(input, output, session) {
  
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
    resultado()$grafico
  )}
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_rutas_abastecimiento", Sys.Date(), ".png", sep="")
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

