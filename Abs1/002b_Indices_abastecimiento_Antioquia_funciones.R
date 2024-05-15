#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 24/02/2024
#Fecha de ultima modificacion: 24/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(tools);library(plotly)
options(scipen = 999)
################################################################################-

abastecimiento_medellin<-readRDS("base_indices_abastecimiento.rds")%>%
  mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month"))

abastecimiento_medellin_interno<-readRDS("base_indices_abastecimiento_interno.rds")%>%
  mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month"))

abastecimiento_medellin_externo<-readRDS("base_indices_abastecimiento_externo.rds")%>%
  mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month"))


# Funcion Numero 2

importancia <- function(tipo, Año = NULL, Mes = NULL, municipios = 10, Producto = NULL) {
  if(tipo==1){
    df <- abastecimiento_medellin
  }else if(tipo==2){
    df <- abastecimiento_medellin_interno
  }else {
    df <- abastecimiento_medellin_externo 
  }
  
  
  if (is.null(municipios) || length(municipios) == 0) {
    return(NULL)
  }
  
  
  # Año seleccionado
  if (!is.null(Año)) {
    df <- df %>% dplyr::filter(anio == Año)
  }
  
  # Mes seleccionado, si se proporciona
  if (!is.null(Mes)) {
    df <- df %>% dplyr::filter(mes == Mes)
  }
  
  # Si se especifica un producto
  if (!is.null(Producto)) {
    df <- df %>% dplyr::filter(producto == Producto)
  }
  
  # Determinar la columna de porcentaje
  if (!is.null(Año) && !is.null(Mes) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio, mpio_origen,producto,mes, .keep_all = TRUE) %>%
      select(anio, mpio_origen, mes, producto, mes_municipio_producto_porcentaje)  
    df <- df %>% rename( columna_porcentaje = mes_municipio_producto_porcentaje)
    
  } else if (!is.null(Año) && !is.null(Mes)) {
    
    df<- df  %>%
      distinct(anio, mpio_origen,mes, .keep_all = TRUE) %>%
      select(anio, mpio_origen, mes, mes_municipio_porcentaje)  
    columna_porcentaje <- "mes_municipio_porcentaje"
    df <- df %>% rename( columna_porcentaje = mes_municipio_porcentaje)
    
    
  } else if (!is.null(Año) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio, mpio_origen,producto, .keep_all = TRUE) %>%
      select(anio, mpio_origen, producto, año_municipio_producto_porcentaje)  
    columna_porcentaje <- "año_municipio_producto_porcentaje"
    df <- df %>% rename( columna_porcentaje =año_municipio_producto_porcentaje)
    
  } else if (!is.null(Año)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(anio, mpio_origen, .keep_all = TRUE) %>%
      select(anio, mpio_origen, año_municipio_porcentaje)  
    df <- df %>% rename( columna_porcentaje = año_municipio_porcentaje)
    
  }else if (!is.null(Producto)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct( mpio_origen,producto, .keep_all = TRUE) %>%
      select( mpio_origen,producto, municipio_producto_porcentaje)  
    df <- df %>% rename( columna_porcentaje = municipio_producto_porcentaje)
    
  } else {
    
    df<- df  %>%
      distinct( mpio_origen, .keep_all = TRUE) %>%
      select( mpio_origen, municipio_porcentaje)  
    df <- df %>% rename( columna_porcentaje = municipio_porcentaje)
    
  }
  
  
  municipios <- min(municipios, 18)
  
  df <- df  %>% 
    arrange(desc(all_of(columna_porcentaje))) %>% 
    mutate( mpio_origen = factor( mpio_origen, levels =  mpio_origen)) %>% 
    head(municipios)
  
  # Grafica  
  # Crear un título dinámico
  #titulo <- paste("Importancia de los", length(unique(df$ mpio_origen)), "municipios principales", ifelse(is.null(Año), "", paste("en el año", Año)), 
  #                ifelse(is.null(Mes), "", paste("en el mes de", Mes)), 
  #                ifelse(is.null(Producto), "", paste("-", Producto)))
  
  # Definir los colores de inicio y fin
  #start_color <- "#6B0077"
  #end_color <- "#ACE1C2"
  
  # Crear una función de interpolación de colores
  #color_func <- colorRampPalette(c(start_color, end_color))
  
  # Generar una paleta de N colores
  #N <- municipios
  #col_palette <- color_func(N)
  col_palette <- c("#1A4922", "#2E7730", "#0D8D38", "#85A728", "#AEBF22", "#F2E203", "#F1B709", "#F39F06", "#BE7E11",
                   "#08384D", "#094B5C", "#00596C", "#006A75", "#007A71", "#00909C", "#0088BB", "#007CC3", "#456ABB")
  
  df$tooltip_text <- paste0("Ciudad de origen: ", df$mpio_origen, "<br>Porcentaje: ", round(df$columna_porcentaje*100),"%")
  
  p <- ggplot(df, aes(x =  forcats::fct_reorder(mpio_origen, as.numeric(all_of(columna_porcentaje))), y = as.numeric(all_of(columna_porcentaje)), fill =  mpio_origen, text = tooltip_text)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = scales::percent(as.numeric(all_of(columna_porcentaje)), accuracy = 1)), hjust = 0.1) +
    coord_flip() +
    labs(x = " ", y = "Porcentaje", title = " ") +
    scale_fill_manual(values = col_palette) +  # Agregar la paleta de colores
    theme_minimal() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.position = "none")#,axis.text.x = element_blank())
  
  p <- plotly::ggplotly(p, tooltip = "text")
  
  
  porcentaje_max<-round(max(df$columna_porcentaje)*100)
  lugar_max<-df$mpio_origen[which.max(df$columna_porcentaje)]
  
  return(
    list(
      grafico = p,
      datos = df,
      porcentaje_max=porcentaje_max,
      lugar_max=lugar_max
    )
  )
}


#importancia(1,2023)
#importancia(2,2023,1)
#importancia(3,2023,1,15,"lechuga batavia")
#importancia(1,Año = 2023, Producto = "lechuga batavia")
#importancia(2,municipios = 8,Producto = "carne de cerdo")
#importancia(3)


