#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/02/2024
#Fecha de ultima modificacion: 25/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(reshape2);library(sf);library(shiny);library(htmlwidgets);library(shinyscreenshot)
library(webshot);library(magick);library(webshot2)
################################################################################-

server <- function(input, output, session) {
  
  resultado<-reactive({
    # Comprobar si solo se ha seleccionado un producto
    if (input$producto != "todo" && input$anio == "todo" && input$mes == "todo") {
      mapa_dif(Producto = input$producto) #Producto en los 10 Anios
    } else if (input$producto != "todo" && input$anio != "todo" && input$mes == "todo") {
      mapa_dif(Anio = input$anio, Producto = input$producto) #Producto en determinado Anio
    } else if(input$producto == "todo" && input$anio == "todo" && input$mes == "todo"){
      mapa_dif()#Todos los Anios
    } else if(input$producto == "todo" && input$anio != "todo" && input$mes == "todo"){
      mapa_dif(Anio = input$anio)#Ano en específico
    } else if(input$producto == "todo" && input$anio != "todo" && input$mes != "todo"){
      mapa_dif(Anio = input$anio, Mes = input$mes)#Anio y mes específico
    } else if(input$producto != "todo" && input$anio == "todo" && input$mes != "todo"){
      mapa_dif(Mes = input$mes , Producto = input$producto)#mes en todos los Anios por producto
    } else if(input$producto == "todo" && input$anio == "todo" && input$mes != "todo"){
      mapa_dif(Mes = input$mes) #Mes en específico
    } else{
      mapa_dif(Anio = input$anio, Mes = input$mes ,Producto = input$producto)#Anio, mes y producto específico
    } 
  })
  
  observeEvent(input$reset, {
    updateSelectInput(session, "producto", selected = "todo")
    updateSelectInput(session, "mes", selected = "todo")
    updateSelectInput(session, "anio", selected = "todo")
  })
  
  output$grafico <- renderLeaflet({
    res<-resultado()
    if(nrow(res$datos)==0){
      validate("No hay datos disponibles")
    }else{
      res$grafico
    }
  })
  


  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write_csv(resultado()$datos, file)
    }
  )
  
  observeEvent(input$github, {
    browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  })
  
  # En el servidor
  output$subtitulo <- renderText({
    resultado <- resultado()
    if(nrow(resultado$datos)==0){
      validate("No hay datos disponibles")
    }else{
    precio_max <- resultado$precio_max
    precio_min <- resultado$precio_min
    ciudad_max <- resultado$ciudad_max
    ciudad_min <- resultado$ciudad_min
    
    return(paste0(ciudad_max," es $", precio_max, " costosa que Medellín, mientras que ", ciudad_min," es $", precio_min," más barata."))
    }
    })
  
  output$mensaje1 <- renderText({
    resultado <- resultado()
    if(nrow(resultado$datos)==0){
      validate("No hay datos disponibles")
    }else{if (input$producto != "todo") {
      return(paste0("El lugar más costoso para comprar ", input$producto, " es ", resultado()$ciudad_max, ". Es $", resultado()$precio_max, " más costoso que comprarlo en Medellín."))
    } else {
      return(paste0("El lugar más costoso para comprar alimentos es ", resultado()$ciudad_max, ". En promedio es $", resultado()$precio_max, " más costoso que comprarlos en Medellín."))
    }}
  })
  
  output$mensaje2 <- renderText({
    resultado <- resultado()
    if(nrow(resultado$datos)==0){
      validate("No hay datos disponibles")
    }else{if (input$producto != "todo") {
      return(paste0("El lugar más economico para comprar ", input$producto, " es ", resultado()$ciudad_min, ". Es $", resultado()$precio_min, " más barato que comprarlo en Medellín."))
    } else {
      return(paste0("El lugar más economico para comprar alimentos es ", resultado()$ciudad_min, ". En promedio es $", resultado()$precio_min, " más barato que comprarlos en Medellín."))
    }}
  })
  
  output$mensaje3 <- renderText({
    return("Poner mensaje")
  })
  
  # Aqui tomamos screen 
  observeEvent(input$go, {
    screenshot()
  })
  
  output$descargar <- downloadHandler(
   filename = function() {
    paste("grafica-", Sys.Date(), ".png", sep="")
  },
  content = function(file) {
   tempFile <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget((resultado()$grafico), tempFile, selfcontained = FALSE)
  webshot::webshot(tempFile, file = file, delay = 2, vwidth = 800, vheight = 800)
  }
  )
  #observeEvent(input$descargar, {
   # screenshot("#grafico", scale = 10)
  #})
}