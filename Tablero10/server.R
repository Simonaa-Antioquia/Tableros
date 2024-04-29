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
    if (input$producto != "" && input$anio == "" && input$mes == "") {
      importancia(Producto = input$producto)
    } else if (input$mes != "" && input$anio == "") {
      validate(
        need(input$anio != "", "Debe seleccionar un año.")
      )
    } else if(input$anio == "" && input$producto == "" && input$mes == ""){
      importancia(municipios = input$municipios)
    } else if(input$producto == "" && input$mes == "" ){
      importancia(Año = input$anio, municipios = input$municipios)
    } else if(input$producto == ""){
      importancia(Año = input$anio, Mes = input$mes ,municipios = input$municipios)
    } else if(input$mes == "" ){
      importancia(Año = input$anio, municipios = input$municipios, Producto = input$producto)
    } else if(input$anio == "" && input$mes == ""){
      importancia(Producto = input$producto)
    } else{
      importancia(Año = input$anio, Mes = input$mes ,municipios = input$municipios, Producto = input$producto)
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
      paste("grafica_principales_municipios_reciben_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Forzar la ejecución de la función reactiva
      res <- resultado()
      
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = res$grafico, width = 13, height = 7, dpi = 200)
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
    lugar_max <- resultado$lugar_max
    porcentaje_max<-resultado$porcentaje_max
    #if(input$anio == ""){
    return(paste0("El principal municipio a donde va la comida de Antioquia es ", lugar_max, " con un ", porcentaje_max,"%"))
    #}
  })
}

