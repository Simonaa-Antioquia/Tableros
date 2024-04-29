#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/02/2024
#Fecha de ultima modificacion: 25/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readxl);library(reshape2);library(ggplot2);library(gganimate);library(dplyr);
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel)
################################################################################-

data <- readRDS("base_precios_vs_medellin.rds")%>%
  mutate(cod_depto=as.numeric(cod_depto))

data$departamento[data$departamento=="Bogotá, D.C."]<-"Bogotá"

shapefile <- st_read("MGN_DPTO_POLITICO.shp")%>%
  janitor::clean_names()%>%filter(dpto_ccdgo!=88)%>%mutate(dpto_ccdgo=as.numeric(dpto_ccdgo))

Anio=2014
Mes=11
Producto= "Aguacate papelillo"

mapa_dif<-function(Anio = NULL, Mes = NULL, Producto = NULL){
  df<-data
  if(!is.null(Anio) && !is.null(Mes) && !is.null(Producto)){
    df<-df%>%filter(year==Anio& mes==Mes& producto==Producto)%>%
      rename(comp=comparacion_anual_mensual_producto)%>%
      select(cod_depto, departamento, comp)%>%
      unique()
  } else if(!is.null(Anio) && !is.null(Mes) && is.null(Producto)){
    df<-df%>%filter(year==Anio& mes==Mes)%>%
      rename(comp=comparacion_anual_mensual)%>%
      select(cod_depto, departamento, comp)%>%
      unique()
  } else if(!is.null(Anio) && is.null(Mes) && is.null(Producto)){
    df<-df%>%filter(year==Anio)%>%
      rename(comp=comparacion_anual)%>%
      select(cod_depto, departamento, comp)%>%
      unique()
  } else if(is.null(Anio) && is.null(Mes) && is.null(Producto)){
    df<-df%>%#filter(year==Anio& mes==Mes& producto==Producto)%>%
      rename(comp=comparacion)%>%
      select(cod_depto, departamento, comp)%>%
      unique()
  } else if(is.null(Anio) && !is.null(Mes) && !is.null(Producto)){
    df<-df%>%filter(mes==Mes& producto==Producto)%>%
      rename(comp=comparacion_mensual_producto)%>%
      select(cod_depto, departamento, comp)%>%
      unique()
  } else if(is.null(Anio) && is.null(Mes) && !is.null(Producto)){
    df<-df%>%filter(producto==Producto)%>%
      rename(comp=comparacion_producto)%>%
      select(cod_depto, departamento, comp)%>%
      unique()
  } else if(is.null(Anio) && !is.null(Mes) && is.null(Producto)){
    df<-df%>%filter(mes==Mes)%>%
      rename(comp=comparacion_mensual)%>%
      select(cod_depto, departamento, comp)%>%
      unique()
  } else {
    df<-df%>%filter(year==Anio&producto==Producto)%>%
      rename(comp=comparacion_anual_producto)%>%
      select(cod_depto, departamento, comp)%>%
      unique()
  }
  
  mapa<-shapefile%>%left_join(df, by = c("dpto_ccdgo"="cod_depto"))
  
  titulo <- paste("Precio con respecto a Medellín", ifelse(is.null(Anio), "", paste("en el año", Anio)),
                  ifelse(is.null(Mes), "", paste("para el mes", Mes)), 
                  ifelse(is.null(Producto), "", paste("-", Producto)))
  
  if (nrow(df) == 0) {
    print("No hay datos disponibles")
  } else {
    p <- ggplot() +
    geom_sf(data = mapa, aes(fill = comp)) +
    scale_fill_gradient2(low = "#1A4922", mid = "white", high = "#08384D", midpoint = 0, na.value = "white", name = "Porcentaje") +
    labs(title = titulo) +
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
    }
  precio_max <- ifelse(nrow(df) == 0,"",round(max(df$comp)))
  precio_min <- ifelse(nrow(df) == 0,"",round(min(df$comp)*-1))
  ciudad_max <- df$departamento[which.max(df$comp)]
  ciudad_min <- df$departamento[which.min(df$comp)]
  return(list(
    grafico=p,
    datos=df,
    precio_max=precio_max,
    precio_min=precio_min,
    ciudad_max=ciudad_max,
    ciudad_min=ciudad_min
  ))
  
}

#mapa_dif()
#mapa_dif(Anio=2023)
#mapa_dif(Anio=2023, Mes=1)
#mapa_dif(Anio=2023, Mes=1, Producto = "Aguacate")
#mapa_dif(Mes=1, Producto = "Aguacate")
#mapa_dif(Mes=1)
#mapa_dif(Anio=2023, Producto = "Aguacate")
#mapa_dif(Producto = "Aguacate")





