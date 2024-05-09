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
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(ggrepel);library(leaflet)
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
  df<-df#%>%filter(depto_origen !="ANTIOQUIA")
  mapa<-shapefile%>%dplyr::left_join(df, by = c("dpto_cnmbr"="depto_origen"))%>%
    mutate(columna_porcentaje=columna_porcentaje*100)
  
  # Crear un título dinámico
  #titulo <- paste("Porcentaje que se envía a Antioquia", ifelse(is.null(Año), "", paste("en el año", Año)),
  #                ifelse(is.null(Mes), "", paste("para el mes", Mes)), 
  #                ifelse(is.null(Producto), "", paste("-", Producto)))
  
  # Filtrar para eliminar las filas con valores NA en "comp"
  mapa <- mapa %>% #filter(!is.na(columna_porcentaje))%>% 
    arrange(columna_porcentaje)%>%mutate(columna_porcentaje2=columna_porcentaje*-1)
  
  min_val <- min(abs(na.omit(mapa$columna_porcentaje)))
  max_val <- max(abs(na.omit(mapa$columna_porcentaje)))
  
  valores_sin_na <- na.omit(mapa$columna_porcentaje)
  my_palette_sin_na <- colorNumeric(palette = c("#F2E203", "#1A4922"), domain = valores_sin_na)
  
  # Crear una paleta de colores personalizada
  my_palette <- colorNumeric(palette = colorRampPalette(c("#F2E203", "#1A4922"))(length(unique(mapa$columna_porcentaje))), domain = c(min_val,max_val),  na.color = "#D5D5D5")
  
  # Crear el mapa interactivo
  p <- leaflet(mapa) %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addPolygons(fillColor = ~my_palette(columna_porcentaje),
                fillOpacity = 0.8, 
                color = "#D5D5D5", 
                weight = 1,
                popup = ~paste0("<strong>Departamento: </strong>", dpto_cnmbr, 
                                "<br><strong>Diferencia del precio: </strong>", round(columna_porcentaje),"%"),
                highlightOptions = highlightOptions(color = "white", 
                                                    weight = 2,
                                                    bringToFront = TRUE)) %>%
    addLegend(pal = my_palette_sin_na, values = ~valores_sin_na, opacity = 0.7, title = "Porcentaje")#, na.label = "")
  
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




