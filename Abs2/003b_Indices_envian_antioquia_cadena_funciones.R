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
  
antioquia<-readRDS("base_indices_antioquia_cadena.rds")
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
      select(anio,depto_origen, mes, producto, porcentaje_dpto_mes_producto,total_kilogramos_mes_destino_prod)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_mes_producto, total_ton = total_kilogramos_mes_destino_prod)
    
  } else if (!is.null(Año) && !is.null(Mes)) {
    
    df<- df  %>%
      distinct(anio,depto_origen,mes, .keep_all = TRUE) %>%
      select(anio,depto_origen, mes, porcentaje_dpto_mes,total_kilogramos_mes_destino)  
    columna_porcentaje <- "porcentaje_dpto_mes"
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_mes, total_ton = total_kilogramos_mes_destino)
    
    
  } else if (!is.null(Año) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio,depto_origen,producto, .keep_all = TRUE) %>%
      select(anio,depto_origen, producto, porcentaje_dpto_anio_producto,total_kilogramos_ano_destino_prod)  
    columna_porcentaje <- "porcentaje_dpto_anio_producto"
    df <- df %>% rename( columna_porcentaje =porcentaje_dpto_anio_producto, total_ton = total_kilogramos_ano_destino_prod)
    
  } else if (!is.null(Año)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(anio,depto_origen, .keep_all = TRUE) %>%
      select(anio,depto_origen, porcentaje_dpto_anio,total_kilogramos_ano_destino)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_anio, total_ton = total_kilogramos_ano_destino)
    
  }else if (!is.null(Producto)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(depto_origen,producto, .keep_all = TRUE) %>%
      select(depto_origen,producto, porcentaje_dpto_prod,total_kilogramos_destino_prod)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto_prod, total_ton = total_kilogramos_destino_prod)
    
  } else {
    
    df<- df  %>%
      distinct(depto_origen, .keep_all = TRUE) %>%
      select(depto_origen, porcentaje_dpto,total_kilogramos_destino)  
    df <- df %>% rename( columna_porcentaje = porcentaje_dpto, total_ton = total_kilogramos_destino)
    
  }
  
  if(nrow(df)==0){
    p<-  validate("No hay datos disponibles")
    p_plano <- NULL
  } else {
  
  df<-df%>%mutate(represent_ant=total_ton/sum(total_ton, na.rm = TRUE))
  mapa<-shapefile%>%dplyr::left_join(df, by = c("dpto_cnmbr"="depto_origen"))%>%
    mutate(columna_porcentaje=columna_porcentaje*100)

    # Filtrar para eliminar las filas con valores NA en "comp"
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
                popup = ~paste0("<strong>Departamento: </strong>", dpto_cnmbr, 
                                "<br><strong>Porcentaje enviado a Antioquia:</strong>", round(columna_porcentaje, digits = 1),"%",
                                "<br><strong>Toneladas: </strong>", formatC((total_ton), format = "f", big.mark = ".",decimal.mark = ",", digits = 1), 
                                "<br><strong>Porcentaje que representa para Antioquia:</strong>", round(represent_ant*100, digits = 1),"%"),
                highlightOptions = highlightOptions(color = "white", 
                                                    weight = 2,
                                                    bringToFront = FALSE)) %>%
    addLegend(pal = my_palette_sin_na, values = ~valores_sin_na, opacity = 0.7, title = "Porcentaje")#, na.label = "")
  
}
  df_sin_antioquia <- df[df$depto_origen != "ANTIOQUIA",]
  
  # Calcula el porcentaje máximo y el departamento correspondiente
  porcentaje_max <- round(max(df_sin_antioquia$columna_porcentaje) * 100, digits = 1)
  dpto_max <- df_sin_antioquia$depto_origen[which.max(df_sin_antioquia$columna_porcentaje)]
  porcentaje_max_1 <- round(max(df$columna_porcentaje[which(df$depto_origen=="ANTIOQUIA")]) * 100, digits = 1) 
  #dpto_max_1 <- df$depto_origen[which.max(df$columna_porcenta)]
  #dpto_max_1 <- tolower(dpto_max_1)
  #words <- strsplit(dpto_max_1, " ")[[1]]
  #words <- paste(toupper(substring(words, 1, 1)), substring(words, 2), sep = "")
  #dpto_max_1 <- paste(words, collapse = " ")
  dpto_max <- tolower(dpto_max)
  words <- strsplit(dpto_max, " ")[[1]]
  words <- paste(toupper(substring(words, 1, 1)), substring(words, 2), sep = "")
  dpto_max <- paste(words, collapse = " ")
  
  
  
  p_plano <-ggplot() +
    geom_sf(data = mapa, aes(fill = columna_porcentaje)) +
    scale_fill_gradient(low = "#F2E203", high = "#0D8D38", na.value = "#C5C7C6", name = "Porcentaje") +
    labs(title = " ") +
    theme_minimal() +
    theme(
      plot.background = element_blank(),  # Hace que el fondo sea transparente
      panel.background = element_blank(),  # Hace que el fondo del panel sea transparente
      panel.grid = element_blank(),  # Elimina las líneas de la cuadrícula
      axis.line = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank())
  
  return(list(
    grafico = p,
    grafico_plano = p_plano, 
    datos = df,
    porcentaje_max = round(porcentaje_max,digits = 1),
    dpto_max = dpto_max,
    porcentaje_max_1=round(porcentaje_max_1,digits = 1)
    #dpto_max_1=dpto_max_1
  ))
}

#ant_en_col()
#ant_en_col(Año=2023)
#ant_en_col(Año=2023, Mes=1)
#ant_en_col(Año=2023, Mes=1, Producto = "arroz")
#ant_en_col(Año=2023, Producto = "arroz")
#ant_en_col(Producto = "cebolla junca")




