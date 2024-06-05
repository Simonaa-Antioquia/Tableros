#Proyecto FAO
# Server
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 28/03/2024
#Fecha de ultima modificacion: 28/03/2024
# NETOS (FUNCIONES 5)
################################################################################
# Paquetes 
################################################################################
library(shiny); library(lubridate);library(shinythemes);library(shinyWidgets)
library(htmlwidgets);library(webshot);library(magick);library(shinyscreenshot);library(webshot2)
options(scipen = 999)
################################################################################

server <- function(input, output, session) {
  
  resultado <- reactive({
    tipo <- input$tipo
    producto_seleccionado <- input$producto_seleccionado
    
    if ((tipo == 2 || tipo == 4) && is.null(producto_seleccionado)) {
      validate(
        need(FALSE, "Debe seleccionar un producto.")
      )
    }
    
    if (is.null(producto_seleccionado)) {
      producto_seleccionado <- ""
    }
    
    neto_grafica(tipo, producto_seleccionado)
  })
  
  
# Grafico plorly  
  output$grafico <- plotly::renderPlotly({
    res <- resultado()
      res$grafico  
  }) 
  
# Grafico plano 
  
  
grafico_plano <- reactive({
    res<-resultado()
    if(nrow(res$datos)==0){
      validate(
        ("No hay datos disponibles")
      )
    }else{
      res$grafico_plano
    }
})  
  

# Descargar el grafico 
output$descargar_ <- downloadHandler(
  filename = function() {
    paste("grafica_productos_ingresan_", Sys.Date(), ".png", sep="")
  },
  content = function(file) {
    # Forzar la ejecución de la función reactiva
    res <- resultado()
    
    # Usa ggsave para guardar el gráfico
    ggplot2::ggsave(filename = file, plot = res$grafico_plano, width = 13, height = 7, dpi = 200)
  }
)
  

# Descargar datos
  
  output$descargarDatos <- downloadHandler(
    filename = function() {
      paste("datos_netos", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(resultado()$datos, file)
    }
  )
  
# En el servidor
  values <- reactiveValues(subtitulo = NULL)
  
  output$subtitulo <- renderText({
    resultado <- resultado()
    fecha_min <- resultado$fecha_min
    min_ton <- resultado$min_ton
    # FECHA
    fecha_min <- as.character(fecha_min)
    componentes <- strsplit(fecha_min, "-")[[1]]
    anio <- componentes[1]
    mes <- componentes[2]
    dia <- componentes[3]
    nombres_meses <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                       "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")
    mes <- nombres_meses[as.integer(mes)]  
  if (input$tipo == 1 | input$tipo==2){
    values$subtitulo <- paste0("Hubo mayor diferencia en volumen de entradas y el volumen de salidas de alimentos en el año ",anio, " ingresando ", min_ton, " mil toneladas más de las que salieron.")
  } else if (input$tipo == 3 | input$tipo == 4){
    values$subtitulo <- paste0("Hubo mayor diferencia en volumen de entradas y el volumen de salidas de alimentos en el ",mes, " del ",anio, " ingresando ", min_ton, " mil toneladas más de las que salieron.") 
  }
  return(values$subtitulo)
    })
  
  
  
  
# Borrar filtros
  observeEvent(input$reset, {
    updateSelectInput(session, "tipo", selected = 1)
  })
  
  # Generamos el Informe
  output$report <- downloadHandler(
    filename = 'informe.pdf',
    
    content = function(file) {
      # Ruta al archivo RMarkdown
      rmd_file <- "informe.Rmd"
      
      # Renderizar el archivo RMarkdown a PDF
      rmarkdown::render(rmd_file, output_file = file, params = list(
        tipo = input$tipo,
        producto = input$producto_seleccionado,
        subtitulo = values$subtitulo,
        plot = grafico_plano()
      ))  
    },
    contentType = 'application/pdf'
  )  

}