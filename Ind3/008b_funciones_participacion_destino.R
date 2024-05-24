  #Proyecto FAO
  #INDICE Herfindahl–Hirschman - Exportaciones 1 - Hacia donde va la comida que se produce en Antioquia
  # Funciones
  ################################################################################
  #Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
  #Fecha de creacion: 29/04/2024
  #Fecha de ultima modificacion:29/04/2024
  ################################################################################
  # Paquetes 
  library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
  library(glue);library(tidyverse);library(DT);library(tools)
  library(plotly)
  options(scipen = 999)
  ################################################################################
  rm(list = ls())

  # Cargamos las bases de datos generadas en 008a_HHINDEX_participacion_destino
  IHH_anual_total <- readRDS("base_indice_anual_total_destino.rds")
  IHH_anual_total$year <-as.numeric(IHH_anual_total$year)
  IHH_anual_producto <- readRDS("base_indice_anual_producto_desti.rds")%>%
    mutate(producto=tools::toTitleCase(tolower(producto)))
  IHH_anual_producto$year <- as.numeric(IHH_anual_producto$year)
  IHH_mensual_producto <- readRDS("base_indice_mensual_producto_destino.rds")%>%
    mutate(producto=tools::toTitleCase(tolower(producto)))
  IHH_mensual_total <- readRDS("base_indice_mensual_total_destino.rds")
  
# Funcion 

col_palette <- c("#1A4922", "#2E7730", "#0D8D38", "#85A728", "#AEBF22", "#F2E203", "#F1B709", "#F39F06", "#BE7E11",
                 "#08384D", "#094B5C", "#00596C", "#006A75", "#007A71", "#00909C", "#0088BB", "#007CC3", "#456ABB")


grafica_indice <- function(tipo, anio_seleccionado = "", productos_seleccionados = "") {
  if (tipo == 1 ) {
    df <- IHH_anual_total
    df <- df %>%
      select("year", "IHH")
  } else if (tipo == 2) {
    df <- IHH_anual_producto
    df <- df %>%
      select("year","producto", "IHH")
    
  } else if (tipo == 3) {
    df <- IHH_mensual_total
    df <- df %>%
      select("mes_y_ano","year","month","IHH")
    if (anio_seleccionado != ""){
      df <- df %>%
        filter(anio_seleccionado == year)
    }
  } else if (tipo == 4) {
    df <- IHH_mensual_producto
    df <- df %>%
      select("year","month","mes_y_ano","producto", "IHH")
    if (anio_seleccionado != ""){
      df <- df %>%
        filter(anio_seleccionado == year)
    }
  }
  if (tipo %in% c(1, 2)) {
    df <- rename(df, fecha = year) 
  }else if (tipo %in% c(3, 4)){
    df <- rename(df, fecha = mes_y_ano)
    df$fecha <-  as.Date(df$fecha)
  }
  df<-df%>%mutate(IHH=round(IHH*100))
  # Filtrar los productos seleccionados solo para las opciones 2 y 4
  if (tipo %in% c(1)) {
    # Comprueba si df$fecha está vacío o contiene valores no numéricos
      p<-ggplot(df, aes(x = fecha, y = IHH)) +
        geom_line(color = "#2E7730") +
        labs(x = "Año", y = "Importancia Municipios destino") +
        scale_x_continuous(breaks = seq(min(df$fecha), max(df$fecha))) +
        scale_color_manual(values = col_palette) +
        theme_minimal()  
  }else if (tipo %in% c(2)){
    df <- df[df$producto %in% productos_seleccionados, ]
    p<-ggplot(df, aes(x = fecha, y = IHH, color = producto)) +
      geom_line() +
      scale_color_manual(values = col_palette) +
      labs(x = "Año", y = "Importancia Municipios destino") +
      scale_x_continuous(breaks = seq(min(df$fecha), max(df$fecha))) +
      theme_minimal() 
  } else if (tipo%in%(3)) { 
    
   p<- ggplot(df, aes(x = fecha, y = IHH)) +
      geom_line(color = "#2E7730") +
      labs(x = "Año", y = "Indice de Vulnerabilidad") +
      theme_minimal()  +
      scale_color_manual(values = col_palette) +
      theme(text = element_text(family = "Prompt", size = 16)) 
    
  } else if (tipo%in%(4)){
    df <- df[df$producto %in% productos_seleccionados, ]
    p<-ggplot(df, aes(x = fecha, y = IHH, color = producto)) +
      geom_line() +
      labs(x = "Año", y = "Importancia Municipios destino") +
      theme_minimal()  +
      scale_color_manual(values = col_palette) +
      theme(text = element_text(family = "Prompt", size = 16))
  }
  
  # Calcular el valor máximo del índice de vulnerabilidad
  indice_max_vulnerabilidad <- which.max(df$IHH)
  max_vulnerabilidad <- round(df$IHH[indice_max_vulnerabilidad], 3)
  fecha_max_vulnerabilidad <- df$fecha[indice_max_vulnerabilidad]
  producto_max_vulnerabilidad <- ifelse("producto" %in% names(df), df$producto[indice_max_vulnerabilidad], NA)
  
  p<-plotly::ggplotly(p)
  
  # Devolver el gráfico, los datos y los valores máximos
  return(list(
    grafico = p,
    datos = df,
    max_vulnerabilidad = max_vulnerabilidad,
    fecha_max_vulnerabilidad = fecha_max_vulnerabilidad,
    producto_max_vulnerabilidad = producto_max_vulnerabilidad
  ))
} 


#grafica_indice(1)
#grafica_indice(2,"",c("Arroz","Carne De Cerdo"))
#grafica_indice(3,2013)
#grafica_indice(4,"",c("Arroz","Carne De Cerdo"))
#grafica_indice(4,"2015",c("Arroz","Carne De Cerdo"))








