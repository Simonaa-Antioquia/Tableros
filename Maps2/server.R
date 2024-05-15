# Definir la función de servidor
server <- function(input, output, session) {
  
  #resultado<-reactive({
  #  ruta()
  #})
  
  resultado<-reactive({
      # Comprobar si solo se ha seleccionado un producto
      if (input$producto != "" && input$anio == "" && input$mes == "" && input$ruta) {
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

