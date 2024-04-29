#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 02/04/2024
#Fecha de ultima modificacion: 02/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot)
library(sf)
options(scipen = 999)
################################################################################-
# Cargar el shapefile
shapefile <- st_read("MGN_DPTO_POLITICO.shp")%>%
  janitor::clean_names()%>%filter(dpto_ccdgo!=88)%>%mutate(dpto_ccdgo=as.numeric(dpto_ccdgo))
  
antioquia<-read.csv("base_indices_antioquia_cadena.csv")
antioquia$depto_origen[antioquia$depto_origen=="QUINDÍO"]<-"QUINDIO"

ant_en_col<-function(Año = NULL, Mes = NULL, Producto = NULL){
  
  df<-antioquia
  
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
  
  if (!is.null(Año) && !is.null(Mes) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio,depto_origen,producto,mes, .keep_all = TRUE) %>%
      select(anio,depto_origen, mes, producto, porcentaje_dpto_mes_producto)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_mes_producto)
    
  } else if (!is.null(Año) && !is.null(Mes)) {
    
    df<- df  %>%
      distinct(anio,depto_origen,mes, .keep_all = TRUE) %>%
      select(anio,depto_origen, mes, porcentaje_dpto_mes)  
    columna_porcentaje <- "porcentaje_dpto_mes"
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_mes)
    
    
  } else if (!is.null(Año) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio,depto_origen,producto, .keep_all = TRUE) %>%
      select(anio,depto_origen, producto, porcentaje_dpto_anio_producto)  
    columna_porcentaje <- "porcentaje_dpto_anio_producto"
    df <- df %>% rename( columna_porcentaje =porcentaje_dpto_anio_producto)
    
  } else if (!is.null(Año)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(anio,depto_origen, .keep_all = TRUE) %>%
      select(anio,depto_origen, porcentaje_dpto_anio)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_anio)
    
  }else if (!is.null(Producto)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(depto_origen,producto, .keep_all = TRUE) %>%
      select(depto_origen,producto, porcentaje_dpto_prod)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_prod)
    
  } else {
    
    df<- df  %>%
      distinct(depto_origen, .keep_all = TRUE) %>%
      select(depto_origen, porcentaje_dpto)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto)
    
  }
  df<-df%>%filter(depto_origen !="ANTIOQUIA")
  mapa<-shapefile%>%left_join(df, by = c("dpto_cnmbr"="depto_origen"))
  
  # Crear un título dinámico
  #titulo <- paste("Porcentaje que se envía a Antioquia", ifelse(is.null(Año), "", paste("en el año", Año)),
  #                ifelse(is.null(Mes), "", paste("para el mes", Mes)), 
  #                ifelse(is.null(Producto), "", paste("-", Producto)))
  
  p <-ggplot() +
    geom_sf(data = mapa, aes(fill = columna_porcentaje*100)) +
    scale_fill_gradient(low = "#0D8D38", high = "#F2E203", na.value = "white", name = "Porcentaje") +
    labs(title = " ") +
    theme_minimal() +
    theme(
      plot.background = element_blank(),  # Hace que el fondo sea transparente
      panel.background = element_blank(),  # Hace que el fondo del panel sea transparente
      panel.grid = element_blank(),  # Elimina las líneas de la cuadrícula
      axis.line = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank()
    )
  porcentaje_max <- round(max(df$columna_porcentaje) * 100, 1)
  dpto_max <- df$depto_origen[which.max(df$columna_porcentaje)]
  dpto_max <- tolower(dpto_max)
  words <- strsplit(dpto_max, " ")[[1]]
  words <- paste(toupper(substring(words, 1, 1)), substring(words, 2), sep = "")
  dpto_max <- paste(words, collapse = " ")
  
  return(list(
    grafico = p,
    datos = df,
    porcentaje_max = porcentaje_max,
    dpto_max = dpto_max
  ))
}

#ant_en_col()
#ant_en_col(Año=2023)
#ant_en_col(Año=2023, Mes=1)
#ant_en_col(Año=2023, Mes=1, Producto = "arroz")
#ant_en_col(Año=2023, Producto = "arroz")
#ant_en_col(Producto = "cebolla junca")




