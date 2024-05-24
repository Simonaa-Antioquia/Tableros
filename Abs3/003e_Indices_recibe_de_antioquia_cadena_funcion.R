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
library(sf);library(plotly)
options(scipen = 999)
################################################################################-

# Cargar el shapefile
shapefile <- st_read("MGN_DPTO_POLITICO.shp")%>%
  janitor::clean_names()%>%filter(dpto_ccdgo!=88)%>%mutate(dpto_ccdgo=as.numeric(dpto_ccdgo))

antioquia<-readRDS("base_indices_cadena_antioquia.rds")
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
      distinct(anio,mpio_destino,mpio_destino,codigo_depto_destino,producto,mes, .keep_all = TRUE) %>%
      select(anio,mpio_destino,codigo_depto_destino, mes, producto, porcentaje_dpto_mes_producto)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_mes_producto)
    
  } else if (!is.null(Año) && !is.null(Mes)) {
    
    df<- df  %>%
      distinct(anio,mpio_destino,codigo_depto_destino,mes, .keep_all = TRUE) %>%
      select(anio,mpio_destino,codigo_depto_destino, mes, porcentaje_dpto_mes)  
    columna_porcentaje <- "porcentaje_dpto_mes"
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_mes)
    
    
  } else if (!is.null(Año) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio,mpio_destino,codigo_depto_destino,producto, .keep_all = TRUE) %>%
      select(anio,mpio_destino,codigo_depto_destino, producto, porcentaje_dpto_anio_producto)  
    columna_porcentaje <- "porcentaje_dpto_anio_producto"
    df <- df %>% rename( columna_porcentaje =porcentaje_dpto_anio_producto)
    
  } else if (!is.null(Año)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(anio,mpio_destino,codigo_depto_destino, .keep_all = TRUE) %>%
      select(anio,mpio_destino,codigo_depto_destino, porcentaje_dpto_anio)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_anio)
    
  }else if (!is.null(Producto)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(mpio_destino,codigo_depto_destino,producto, .keep_all = TRUE) %>%
      select(mpio_destino,codigo_depto_destino,producto, porcentaje_dpto_prod)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_prod)
    
  } else {
    
    df<- df  %>%
      distinct(mpio_destino,codigo_depto_destino, .keep_all = TRUE) %>%
      select(mpio_destino,codigo_depto_destino, porcentaje_dpto)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto)
    
  }
  df<-df#%>%filter(codigo_depto_destino !=5)
  if (nrow(df) == 0) {
    print("No hay datos disponibles")
  } else {mapa<-shapefile%>%left_join(df, by = c("dpto_ccdgo"="codigo_depto_destino"))%>%
    mutate(columna_porcentaje=columna_porcentaje*100)
  
  # Crear un título dinámico
  #titulo <- paste("Porcentaje que llega de Antioquia del total", ifelse(is.null(Año), "", paste("en el año", Año)),
  #                ifelse(is.null(Mes), "", paste("para el mes", Mes)), 
  #                ifelse(is.null(Producto), "", paste("-", Producto)))
  
  mapa <- mapa %>% #filter(!is.na(columna_porcentaje))%>% 
    arrange(columna_porcentaje)%>%mutate(columna_porcentaje2=columna_porcentaje*-1)
  
  min_val <- min(abs(na.omit(mapa$columna_porcentaje)))
  max_val <- max(abs(na.omit(mapa$columna_porcentaje)))
  
  valores_sin_na <- na.omit(mapa$columna_porcentaje)
  my_palette_sin_na <- colorNumeric(palette = c("#F2E203", "#1A4922"), domain = valores_sin_na)
  
  # Crear una paleta de colores personalizada
  my_palette <- colorNumeric(palette = colorRampPalette(c("#F2E203", "#1A4922"))(length(unique(mapa$columna_porcentaje))), domain = c(min_val,max_val),  na.color = "#C5C7C6")
  
  # Crear el mapa interactivo
  p <- leaflet(mapa) %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addPolygons(fillColor = ~my_palette(columna_porcentaje),
                fillOpacity = 0.8, 
                color = "#D5D5D5", 
                weight = 1,
                popup = ~ifelse(is.na(columna_porcentaje),"",paste0("<strong>Departamento: </strong>", tools::toTitleCase(tolower(mapa$dpto_cnmbr)), 
                                "<br><strong>Diferencia del precio: </strong>", round(columna_porcentaje),"%")),
                highlightOptions = highlightOptions(color = "white", 
                                                    weight = 2,
                                                    bringToFront = FALSE)) %>%
    addLegend(pal = my_palette_sin_na, values = ~valores_sin_na, opacity = 0.7, title = "Porcentaje")#, na.label = "")
    
  mapa2<-mapa%>%filter(mpio_destino!="Medellín")
  porcentaje_max<-round(max(mapa2$columna_porcentaje))
      porcentaje_max_1 <- round(max(df$columna_porcentaje[which(df$mpio_destino=="Medellín")]) * 100) 
      # Encontrar el índice del valor máximo ignorando los NA
      indice_max <- which(mapa2$columna_porcentaje == max(mapa2$columna_porcentaje, na.rm = TRUE))
      # Convertir a formato de título
      dpto_max <- tools::toTitleCase(tolower(mapa2$dpto_cnmbr[indice_max]))
      return(list(
        grafico=p,
        datos=df,
        porcentaje_max=porcentaje_max,
        dpto_max=dpto_max,
        porcentaje_max_1=porcentaje_max_1
      ))
  }
}

#col_en_ant()
#col_en_ant(Año=2013)
#col_en_ant(Año=2023, Mes=1)
#col_en_ant(Año=2013, Mes=1, Producto = "tomates otros")
#col_en_ant(Año=2023, Producto = "arroz")
#col_en_ant(Producto = "arroz")
