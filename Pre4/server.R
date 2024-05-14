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
library(reshape2);library(sf);library(shiny);library(htmlwidgets);library(mapview);library(shinyscreenshot);
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
    #resultado <- resultado()
    #volatil<-resultado$producto_vol
    return("Poner mensaje")
  })
  
  output$mensaje2 <- renderText({
    #resultado <- resultado()
    #promedio_camb<-resultado$promedio_camb
    return("Poner mensaje")
  })
  
  output$mensaje3 <- renderText({
    #resultado <- resultado()
    #promedio_camb_an<-resultado$promedio_camb_an
    return("Poner mensaje")
  })
  
  # Aqui tomamos screen 
  observeEvent(input$go, {
    screenshot()
  })
  
  observeEvent(input$descargar, {
    screenshot("#grafico", scale = 5)
  })
}