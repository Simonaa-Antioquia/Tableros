#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 24/02/2024
#Fecha de ultima modificacion: 24/02/2024
################################################################################-
setwd("C:/Users/tusig/OneDrive - Universidad EAFIT/FAO/01_Analisis_Empirico/")
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(leaflet)
options(scipen = 999)
################################################################################-

## Cargamos la base de datos de origen destino 

abastecimiento_rutas <- readRDS("rutas_abastecimiendo_medellin.rds")

ruta <- function(Año = NULL,Mes = NULL,Producto = NULL) {
  df <- abastecimiento_medellin
  
  if (!is.null(Año)) {
    df <- df %>% dplyr::filter(anio == Año)
  }
  
  if (!is.null(Mes)) {
    df <- df %>% dplyr::filter(mes == Mes)
  }
  
  if (!is.null(Producto)) {
    df <- df %>% dplyr::filter(producto == Producto)
  }
  
  df <- df[!(duplicated(df[c("codigo_mpio_destino","codigo_mpio_origen")])),]
  
  map <- leaflet() %>%
    addTiles()
  
  for(i in 1:nrow(df)) {
    dir <- matrix(unlist(df[i,18][[1]]), ncol = 2)
    map <- map %>% addPolylines(data = dir, color = "#0D8D38", stroke = 0.05, opacity = 0.8)
  }
  
  return(list(
    grafico=map,
    datos=df
  ))
}

ruta_importancia <- function(opcion1,Año = NULL, Mes = NULL,Producto = NULL) {
  df <- abastecimiento_medellin
  
  if (Año != "" & Mes != "") {
    df <- df %>% filter(anio == Año & mes == Mes)
    
    if(!is.null(Producto)) {
      var <- 39
    } else {
      var <- 34
    }
  } else if (Año != "") {
    df <- df %>% filter(anio == Año)
    
    if(!is.null(Producto)) {
      var <- 40
    } else {
      var <- 37
    }
  } else if (Mes != "") {
    df <- df %>% filter(mes == Mes)
    
    if(!is.null(Producto)) {
      var <- 41
    } else {
      var <- 38
    }
  } else {
    if(!is.null(Producto)) {
      var <- 42
    } else {
      var <- 43
    }
  }
  
  if (!is.null(Producto)) {
    df <- df %>%
      filter(producto == Producto)
  }
  
  df <- df[!(duplicated(df[c("codigo_mpio_destino","codigo_mpio_origen")])),]
  
  colours <- colorRampPalette(c("#F2E203","#0088BB","#0D8D38"))(n_distinct(df[,var]))
  
  importancia_ordenada <- unique(df[,var])
  colnames(importancia_ordenada) <- "importancia"
  importancia_ordenada$importancia <- importancia_ordenada[order(importancia_ordenada$importancia),]
  
  aux <- data.frame(importancia = importancia_ordenada$importancia, 
                    colour = colours)
  
  colnames(df)[var] <- "importancia"
  
  df <- merge(x=df,y=aux,by="importancia")
  
  importancia_max <- round(max(df$importancia)*100,2)
  importancia_min <- round(min(df$importancia)*100,2)
  
  map <- leaflet() %>%
    addTiles() %>%
    addLegend(
      position = "bottomright",
      colors = colorRampPalette(c("#F2E203","#0088BB","#0D8D38"))(10),
      labels = c(importancia_min,"","","","","","","","",importancia_max),
      opacity = 1,
      title = "Importancia (%)"
    )
  
  for(i in 1:nrow(df)) {
    dir <- matrix(unlist(df[i,19][[1]]), ncol = 2)
    map <- map %>% addPolylines(data = dir, color = df$colour[i], stroke = 0.05, opacity = 0.8)
  }
  
  return(list(
    grafico=map,
    datos=df
  ))
}