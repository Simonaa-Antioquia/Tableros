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
library(leaflet)
options(scipen = 999)
################################################################################-

## Cargamos la base de datos de origen destino 

abastecimiento_medellin <- readRDS("abastecimiento_rutas_cierre.rds")

ruta <- function(Año = NULL,Mes = NULL,Producto = NULL,Rutas = NULL) {
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
  
  if (!is.null(Rutas)) {
    df <- df %>% dplyr::filter(!id_ruta_externa %in% Rutas)
  }
  
  map <- leaflet() %>%
    addTiles()
  
  for(i in 1:nrow(df)) {
    dir <- matrix(unlist(df[i,18][[1]]), ncol = 2)
    map <- map %>% addPolylines(data = dir, color = df$color[i], stroke = 0.05, opacity = 0.8)
  }
  
  map
}