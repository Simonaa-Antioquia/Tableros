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
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(tools)
library(sf)
options(scipen = 999)
################################################################################-

# Cargar el shapefile
shapefile <- st_read("MGN_DPTO_POLITICO.shp")%>%
  janitor::clean_names()%>%filter(dpto_ccdgo!=88)%>%mutate(dpto_ccdgo=as.numeric(dpto_ccdgo))

antioquia<-read.csv("base_indices_cadena_antioquia.csv")
#antioquia$depto_origen[antioquia$depto_origen=="BOGOTÁ, D. C."]<-"BOGOTÁ, D.C."

col_en_ant<-function(Año = NULL, Mes = NULL, Producto = NULL){
  
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
      distinct(anio,codigo_depto_destino,producto,mes, .keep_all = TRUE) %>%
      select(anio,codigo_depto_destino, mes, producto, porcentaje_dpto_mes_producto)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_mes_producto)
    
  } else if (!is.null(Año) && !is.null(Mes)) {
    
    df<- df  %>%
      distinct(anio,codigo_depto_destino,mes, .keep_all = TRUE) %>%
      select(anio,codigo_depto_destino, mes, porcentaje_dpto_mes)  
    columna_porcentaje <- "porcentaje_dpto_mes"
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_mes)
    
    
  } else if (!is.null(Año) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio,codigo_depto_destino,producto, .keep_all = TRUE) %>%
      select(anio,codigo_depto_destino, producto, porcentaje_dpto_anio_producto)  
    columna_porcentaje <- "porcentaje_dpto_anio_producto"
    df <- df %>% rename( columna_porcentaje =porcentaje_dpto_anio_producto)
    
  } else if (!is.null(Año)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(anio,codigo_depto_destino, .keep_all = TRUE) %>%
      select(anio,codigo_depto_destino, porcentaje_dpto_anio)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_anio)
    
  }else if (!is.null(Producto)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(codigo_depto_destino,producto, .keep_all = TRUE) %>%
      select(codigo_depto_destino,producto, porcentaje_dpto_prod)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_prod)
    
  } else {
    
    df<- df  %>%
      distinct(codigo_depto_destino, .keep_all = TRUE) %>%
      select(codigo_depto_destino, porcentaje_dpto)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto)
    
  }
  df<-df%>%filter(codigo_depto_destino !=5)
  mapa<-shapefile%>%left_join(df, by = c("dpto_ccdgo"="codigo_depto_destino"))
  
  # Crear un título dinámico
  #titulo <- paste("Porcentaje que llega de Antioquia del total", ifelse(is.null(Año), "", paste("en el año", Año)),
  #                ifelse(is.null(Mes), "", paste("para el mes", Mes)), 
  #                ifelse(is.null(Producto), "", paste("-", Producto)))
  
  p<-ggplot() +
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
      
      porcentaje_max<-round(max(df$columna_porcentaje)*100,1)
      # Encontrar el índice del valor máximo ignorando los NA
      indice_max <- which(mapa$columna_porcentaje == max(mapa$columna_porcentaje, na.rm = TRUE))
      # Convertir a formato de título
      dpto_max <- tools::toTitleCase(tolower(mapa$dpto_cnmbr[indice_max]))
      return(list(
        grafico=p,
        datos=df,
        porcentaje_max=porcentaje_max,
        dpto_max=dpto_max
      ))
}

#col_en_ant()
#col_en_ant(Año=2023)
#col_en_ant(Año=2023, Mes=1)
#col_en_ant(Año=2023, Mes=1, Producto = "arroz")
#col_en_ant(Año=2023, Producto = "arroz")
#col_en_ant(Producto = "arroz")
