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
    if((nrow(res$datos)==0 )){
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
  
  #observeEvent(input$github, {
  #  browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  #})
  
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
  values <- reactiveValues(mensaje1 = NULL)
  output$mensaje1 <- renderText({
    resultado <- resultado()
    if(nrow(resultado$datos)==0){
      validate("No hay datos disponibles")
    }else{if (input$producto != "todo") {
      values$mensaje1<-(paste0("El lugar más costoso para comprar ", input$producto, " fue ", resultado()$ciudad_max, ", con una diferencia superior de $", format(resultado()$precio_max, big.mark = ","), " con respecto al precio de Medellín para el mismo periodo de tiempo."))
      return(values$mensaje1)
    } else {
      values$mensaje1<-(paste0("El lugar más costoso para comprar alimentos fue ", resultado()$ciudad_max, ", con una diferencia superior de $", format(resultado()$precio_max, big.mark = ","), " con respecto al precio de Medellín para el mismo periodo de tiempo."))
      return(values$mensaje1)
    }}
  })
  values <- reactiveValues(mensaje2 = NULL)
  output$mensaje2 <- renderText({
    resultado <- resultado()
    if(nrow(resultado$datos)==0){
      validate("No hay datos disponibles")
    }else{if (input$producto != "todo") {
      values$mensaje2<-(paste0(resultado()$ciudad_min, " ofreció el precio más bajo para ", input$producto, ", siendo $", format(resultado()$precio_min, big.mark = ","), " más económico que en Medellín durante el mismo período de tiempo."))
      return(values$mensaje2)
    } else {
      values$mensaje2<-(paste0(resultado()$ciudad_min, " ofreció el precio más bajo paracomprar alimentos, siendo $", format(resultado()$precio_min, big.mark = ","), " más económico que en Medellín durante el mismo período de tiempo."))
      return(values$mensaje2)
    }}
  })
  
  values <- reactiveValues(mensaje3 = NULL)
  output$mensaje3 <- renderText({
    resultado <- resultado()
    if(nrow(resultado$datos)==0){
      validate("No hay datos disponibles")
    }else{if (input$producto != "todo") {
      values$mensaje3<-( paste0("El precio promedio de ", input$producto, 
                                " en Medellín para el periodo de tiempo seleccionado fue: $", 
                                format(resultado()$precio_medellin, big.mark = ","), " pesos."))
      return(values$mensaje3)
    } else {
      values$mensaje3<-(paste0("El precio promedio en Medellín para el periodo de tiempo seleccionado fue: $", format(resultado()$precio_medellin, big.mark = ","), " pesos."))
      return(values$mensaje3)
    }}
  })
  
  

  grafico_plano <- reactive({
    res <- resultado()
    if((nrow(res$datos)==0 )){
      return(NULL)
    } else {
      return(res$grafico2)
    }
  })
    

  
  # Aqui tomamos screen 
  output$report <- downloadHandler(
    filename = 'informe.pdf',
    
    content = function(file) {
      # Ruta al archivo RMarkdown
      rmd_file <- "informe.Rmd"
      
      # Renderizar el archivo RMarkdown a PDF
      rmarkdown::render(rmd_file, output_file = file, params = list(
        datos = resultado()$datos,
        ciudad_min = resultado()$ciudad_min,
        precio_min = resultado()$precio_min,
        precio_max = resultado()$precio_max,
        ciudad_max = resultado()$ciudad_max,
        plot = grafico_plano(),#+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)),# Accede al gráfico 'grafico_plano'
        mensaje1 = values$mensaje1,
        mensaje2 = values$mensaje2,
        mensaje3 = values$mensaje3,
        anio = input$anio,
        mes = input$mes,
        alimento = input$producto
      ))
      
      
    },
    
    contentType = 'application/pdf'
  )
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica_precios_diferencias_", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      # Forzar la ejecución de la función reactiva
      res <- resultado()
      
      # Usa ggsave para guardar el gráfico
      ggplot2::ggsave(filename = file, plot = res$grafico2, width = 7, height = 7, dpi = 400)
    }
  )
}