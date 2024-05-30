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
library(readxl);library(reshape2);library(ggplot2);library(gganimate);library(dplyr);
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel);library(stringr);library(shinyscreenshot);
library(shiny); library(plotly)
################################################################################-
server <- function(input, output, session) {
  resultado <- reactive({
    tipo <- input$tipo
    anio_seleccionado <- input$anio
    productos_seleccionados <- input$producto
    
    if (input$anio == "todo") {
      if (input$mes == "todo") {
        if (input$tipo == 1) {
          result <- diferencias_precios(input$tipo,"","")
        } else if (input$tipo == 0) {
          result <- diferencias_precios(input$tipo,"","",input$producto)
        }
      } else {
        if (input$tipo == 1) {
          result <- diferencias_precios(input$tipo,"",input$mes)
        } else if (input$tipo == 0) {
          result <- diferencias_precios(input$tipo,"",input$mes,input$producto)
        }
      }
    } else {
      if (input$mes == "todo") {
        if (input$tipo == 1) {
          result <- diferencias_precios(input$tipo,input$anio,"")
        } else if (input$tipo == 0) {
          result <- diferencias_precios(input$tipo,input$anio,"",input$producto)
        }
      } else {
        if (input$tipo == 1) {
          result <- diferencias_precios(input$tipo,input$anio,input$mes)
        } else if (input$tipo == 0) {
          result <- diferencias_precios(input$tipo,input$anio,input$mes,input$producto)
        }
      }
    }
  })
  
  output$plot <- plotly::renderPlotly({
    res <- resultado()
    if (is.character(res)) {
      validate("No hay datos disponibles")  # No hay gráfico para mostrar
    } else {
      plotly::ggplotly(res$grafico)
    }
  })
  
  output$vistaTabla <- renderTable({
    if (!is.null(resultado()$datos)) {
      head(resultado()$datos, 5)
    }
  })
  
  output$descargar <- downloadHandler(
    filename = function() {
      paste("grafica-", Sys.Date(), ".png", sep="")
    },
    content = function(file) {
      tempFile <- tempfile(fileext = ".html")
      htmlwidgets::saveWidget(as_widget(resultado()$grafico), tempFile, selfcontained = FALSE)
      webshot::webshot(tempFile, file = file, delay = 2)
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
  
  #observeEvent(input$github, {
  # browseURL("https://github.com/PlasaColombia-Antioquia/Tableros.git")
  #})
  
  output$subtitulo <- renderText({
    tryCatch({
      # Intenta ejecutar este código
      res <- resultado()  
      print(res)  
      precio_max <- res$precio_max
      precio_min <- res$precio_min
      ciudad_max <- res$ciudad_max
      ciudad_min <- res$ciudad_min
      
      return(paste0("El precio más bajo para el producto y periodo de tiempo se encontró en ",ciudad_min , ", con una diferencia de $", precio_min, " menos respecto al precio en Medellín. En contraste, el precio más alto se reportó en ", ciudad_max, ", superando el de Medellín en $", precio_max))
    }, error = function(e) {
      # Si ocurre un error, ejecuta este código
      return("No hay datos disponibles.")
    })
  })
  
  
  server <- function(input, output, session) {
    observeEvent(input$reset, {
      updateSelectInput(session, "tipo", selected = 1)
      updateSelectInput(session, "anio", selected = "todo")
      updateSelectInput(session, "mes", selected = "todo")
      updateSelectInput(session, "producto", selected = NULL)
    })
    }
  
  observeEvent(input$reset, {
    updateSelectInput(session, "tipo", selected = 1)
    updateSelectInput(session, "anio", selected = "todo")
    updateSelectInput(session, "mes", selected = "todo")
    updateSelectInput(session, "producto", selected = NULL)
  })
  
  values <- reactiveValues(mensaje1 = NULL)
  output$mensaje1 <- renderText({
    tryCatch({
      # Intenta ejecutar este código
      if (input$tipo != 1) {
        values$mensaje1<-(paste0("El producto seleccionado es: ", input$producto))
        return(values$mensaje1)
      } else {
        values$mensaje1<-("La visualización no se filtró por ningún producto específico.")
        return(values$mensaje1)
      }
    }, error = function(e) {
      # Si ocurre un error, ejecuta este código
      return("No hay datos disponibles.")
    })
  })
  
  
  output$mensaje2 <- renderText({
    tryCatch({
      # Intenta ejecutar este código
      if (input$tipo != 1) {
        return(paste0("El lugar más costoso para comprar ", input$producto, " es ", resultado()$ciudad_max, ". Es $", resultado()$precio_max, " más costoso que comprarlo en Medellín."))
      } else {
        return(paste0("El lugar más costoso para comprar alimentos es ", resultado()$ciudad_max, ". En promedio es $", resultado()$precio_max, " más costoso que comprarlos en Medellín."))
      }
    }, error = function(e) {
      # Si ocurre un error, ejecuta este código
      return("No hay datos disponibles.")
    })
  })
  
  
  output$mensaje3 <- renderText({
    tryCatch({
      # Intenta ejecutar este código
      if (input$tipo != 1) {
        return(paste0("El lugar más economico para comprar ", input$producto, " es ", resultado()$ciudad_min, ". Es $", resultado()$precio_min, " más barato que comprarlo en Medellín."))
      } else {
        return(paste0("El lugar más economico para comprar alimentos es ", resultado()$ciudad_min, ". En promedio es $", resultado()$precio_min, " más barato que comprarlos en Medellín."))
      }
    }, error = function(e) {
      # Si ocurre un error, ejecuta este código
      return("No hay datos disponibles.")
    })
  })  
  
  grafico_plano <- reactive({
    res <- resultado()
    {
      res$grafico2  # Guarda solo el gráfico 'grafico_plano'
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
        precio_max = resultado()$precio_max,
        precio_min = resultado()$precio_min,
        ciudad_max = resultado()$ciudad_max,
        ciudad_min = resultado()$ciudad_min,
        plot = grafico_plano(),
        subtitulo = values$subtitulo,
        mensaje1 = values$mensaje1,
        tipo = input$tipo,
        anio = input$anio,
        mes = input$mes,
        alimento = input$producto
      ))
      
      
    },
    
    contentType = 'application/pdf')
  
  observeEvent(input$descargar, {
    screenshot("#plot", scale = 5)
  })

}