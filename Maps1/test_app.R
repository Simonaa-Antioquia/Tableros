library(shiny)
library(leaflet)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

ui <- fluidPage(
  leafletOutput("mymap"),
  p(),
  actionButton("recalc", "New points")
)



server <- function(input, output, session) {
  
  
  # resultado<-reactive({
  #   #Revisar si se incluye importancia o no
  #   if (input$importancia == ""){
  #     # Comprobar si solo se ha seleccionado un producto
  #     if (input$producto != "" && input$anio == "" && input$mes == "") {
  #       ruta(Producto = input$producto)
  #     } else if (input$mes != "" && input$anio == "") {
  #       validate(
  #         need(input$anio != "", "Debe seleccionar un año.")
  #       )
  #     } else if(input$anio == "" && input$producto == "" && input$mes == ""){
  #       ruta()
  #     } else if(input$producto == "" && input$mes == "" ){
  #       ruta(Año = input$anio)
  #     } else if(input$producto == ""){
  #       ruta(Año = input$anio, Mes = input$mes)
  #     } else if(input$mes == "" ){
  #       ruta(Año = input$anio, Producto = input$producto)
  #     } else if(input$anio == "" && input$mes == ""){
  #       ruta(Producto = input$producto)
  #     } else{
  #       ruta(Año = input$anio, Mes = input$mes,Producto = input$producto)
  #     }
  #   } else if (input$importancia == "Incluir"){
  #     # Comprobar si solo se ha seleccionado un producto
  #     if (input$producto != "" && input$anio == "" && input$mes == "") {
  #       ruta_importancia(Producto = input$producto)
  #     } else if (input$mes != "" && input$anio == "") {
  #       validate(
  #         need(input$anio != "", "Debe seleccionar un año.")
  #       )
  #     } else if(input$anio == "" && input$producto == "" && input$mes == ""){
  #       ruta_importancia()
  #     } else if(input$producto == "" && input$mes == "" ){
  #       ruta_importancia(Año = input$anio)
  #     } else if(input$producto == ""){
  #       ruta_importancia(Año = input$anio, Mes = input$mes)
  #     } else if(input$mes == "" ){
  #       ruta_importancia(Año = input$anio, Producto = input$producto)
  #     } else if(input$anio == "" && input$mes == ""){
  #       ruta_importancia(Producto = input$producto)
  #     } else{
  #       ruta_importancia(Año = input$anio, Mes = input$mes,Producto = input$producto)
  #     }
  #   }
  # })
  
  output$mymap <- renderLeaflet({
    df <- abastecimiento_medellin
    df <- df[!(duplicated(df[c("codigo_mpio_destino","codigo_mpio_origen")])),]
    
    ruta()$grafico
    
    #ruta()$grafico
    #resultado()$grafico
  })
  

  
}

shinyApp(ui, server)