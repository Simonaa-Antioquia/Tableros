#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/04/2024
#Fecha de ultima modificacion: 21/04/2024
################################################################################
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################
library(shiny);library(htmlwidgets);library(webshot);library(magick);library(shinyscreenshot);library(webshot2)
################################################################################
server <- function(input, output, session) {
  
  output$ubicacionInput <- renderUI({
    req(input$algo)
    if(input$algo == "Neto_sale") {
      selectInput("ubicacion", "Seleccione el destino:", choices = c("Todos las ciudades" ="todo", sort(lugar_sale)))
    } else if (input$algo == "Neto_entra"){
      selectInput("ubicacion", "Seleccione el origen:", choices = c("Todos los departamentos" ="todo",sort(lugar_entra)))
    }else if (input$algo == "Neto_entra_exter"){
      selectInput("ubicacion", "Seleccione el origen:", choices = c("Todos los departamentos" ="todo",sort(lugar_entra_exter)))
    }else{
      selectInput("ubicacion", "Seleccione el origen:", choices = c("Todos los departamentos" ="todo"))
    }
  })
  
  resultado <- reactive({
    req(input$algo, input$año, input$mes, input$ubicacion)
    if(input$año=="todo"&&input$mes=="todo"&&input$ubicacion=="todo"){
      pareto_graf(pareto = input$algo)
    }else if(input$año=="todo"&&input$mes=="todo"){
      pareto_graf(pareto = input$algo,sitio = input$ubicacion)
    }else if(input$año=="todo"){
      validate(
        need(input$año != "todo", "Debe seleccionar un año.")
      )
    }else if(input$año=="todo"&&input$ubicacion=="todo"){
      validate(
        need(input$año != "todo", "Debe seleccionar un año.")
      )
    }else if(input$mes=="todo"&&input$ubicacion=="todo"){
      pareto_graf(pareto = input$algo,año = input$año)
    }else if(input$ubicacion=="todo"){
      pareto_graf(pareto = input$algo,año = input$año, Mes = input$mes)
    }else if(input$mes=="todo"){
      pareto_graf(pareto = input$algo,año = input$año, sitio = input$ubicacion)
    }else {
      pareto_graf(pareto = input$algo,año = input$año, Mes = input$mes, sitio = input$ubicacion) 
    }
  })
  
  output$grafico <- plotly::renderPlotly({
    res<-resultado()
    if(nrow(res$datos)==0){
      validate(
        ("No hay datos disponibles")
      )
    }else{
      res$grafico
    }
    
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
#  output$descargar <- downloadHandler(
 #   filename = function() {
  #    paste("grafica_netos", Sys.Date(), ".png", sep="")
   # },
    #content = function(file) {
     # tempFile <- tempfile(fileext = ".html")
      #htmlwidgets::saveWidget(as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
      #webshot::webshot(tempFile, file = file, delay = 2)
    #}
  #)
  
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  observeEvent(input$reset, {
    updateSelectInput(session, "año", selected = "todo")
    updateSelectInput(session, "mes", selected = "todo")
    updateSelectInput(session, "ubicacion", selected = "todo")
  })
  
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
    res<-resultado()
    if(nrow(res$datos)==0){
      validate(
        ("No hay datos disponibles")
      )
    }else{res <- resultado()
    req(res)
    porcent_prod <- res$porcent_prod
    acumulado <- res$acumulado
    return(paste0("El ", porcent_prod, "% de los productos representan el ", acumulado,"% de lo que ",ifelse(input$algo=="Neto_sale", "sale","entra")))}
  })
  
  output$mensaje1 <- renderText({
    #resultado <- resultado()
    #volatil<-resultado$producto_vol
    return("Este gráfico muestra la importancia que tiene cada alimento en las entradas (locales o externas) y las salidas de los alimentos de Antioquia")
  })
  
  output$mensaje2 <- renderText({
    res<-resultado()
    if(nrow(res$datos)==0){
      validate(
        ("")
      )
    }else{res <- resultado()
    prod_neces<-res$prod_neces
    acumulado<-res$acumulado
    if(prod_neces==1){
      return("Solo se cuenta con un alimento")
    }else{
      return(paste0("Se necesitaron ",prod_neces," alimentos para llegar al ",acumulado,"%")) 
    }}
  })
  
 # output$mensaje3 <- renderText({
    #resultado <- resultado()
    #promedio_camb_an<-resultado$promedio_camb_an
  #  return("Poner mensaje")
  #})
  # Aqui tomamos screen 
  observeEvent(input$go, {
    screenshot()
  })
  
  observeEvent(input$descargar, {
    screenshot("#grafico", scale = 5)
  })
}