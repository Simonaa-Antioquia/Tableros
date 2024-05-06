#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 17/04/2024
#Fecha de ultima modificacion: 17/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(scales)
library(sf)
options(scipen = 999)
################################################################################-

data_mensual<-read.csv("neto_mensual.csv")%>%
  mutate(fecha = floor_date(as.Date(as.yearmon(fecha, "%Y-%m"), frac = 1), "month"))
data_anual<-read.csv("neto_anual.csv")
data_mensual_producto<-read.csv("neto_mensual_producto.csv")%>%
  mutate(fecha = floor_date(as.Date(as.yearmon(fecha, "%Y-%m"), frac = 1), "month"))
data_anual_producto<-read.csv("neto_anual_producto.csv")


#####
# FUNCION PARA VISUALIZAR LOS RESULTADOS 

# FUNCION 2 
# LINEA DE TIEMPO 
neto_grafica <- function(tipo, productos_seleccionados = "") {
  if (tipo == 1 ) {
    df <- data_anual
  } else if (tipo == 2) {
    df <- data_anual_producto
    df <- df %>%
      select("anio","producto", "total_importado")
    if (length(productos_seleccionados) == 0){
      message("Para esta opcion debe escoger los productos que quiere graficar")
    }
  } else if (tipo == 3) {
    df <- data_mensual
    df <- df %>%
      select("fecha","total_importado")
    df <- rename(df, anio = fecha)
  } else if (tipo == 4) {
    df <- data_mensual_producto
    df <- df %>%
      select("producto", "fecha","total_importado")
    df <- rename(df, anio = fecha)
    if (length(productos_seleccionados) == 0){
      stop("Para esta opcion debe escoger los productos que quiere graficar")
    }
  }
  # Filtrar los productos seleccionados solo para las opciones 2 y 4
  if (tipo %in% c(2)) {
    df <- df[df$producto %in% productos_seleccionados, ]
    p<-ggplot(df, aes(x = anio, y = total_importado, color = producto)) +
      geom_line() +
      labs(x = "Año", y = "Miles de toneladas") +
      scale_x_continuous(breaks = seq(min(df$anio), max(df$anio))) +
      theme_minimal()  
  } else if(tipo %in% c(4)) {
    df <- df[df$producto %in% productos_seleccionados, ]
    p<-ggplot(df, aes(x = anio, y = total_importado, color = producto)) +
      geom_line() +
      labs(x = "Año", y = "Miles de toneladas") +
      #scale_x_continuous(breaks = seq(min(df$anio), max(df$anio))) +
      theme_minimal()  
  }else if(tipo %in% c(3)){
    p<-ggplot(df, aes(x = anio, y = total_importado)) +
      geom_line() +
      labs(x = "Año", y = "Miles de toneladas") +
      #scale_x_continuous(breaks = seq(min(df$anio), max(df$anio))) +
      theme_minimal()  
  }else {
    p<-ggplot(df, aes(x = anio, y = total_importado)) +
      geom_line() +
      labs(x = "Año", y = "Miles de toneladas") +
      scale_x_continuous(breaks = seq(min(df$anio), max(df$anio))) +
      theme_minimal()  
  }
  
  min_ton<-round(min(df$total_importado)*-1)
  fecha_min <- df$anio[which.min(df$total_importado)]
  
  return(list(
    grafico = p,
    datos = df,
    fecha_min=fecha_min,
    min_ton=min_ton
  ))
  
}


# OPCIONES
#neto_grafica(1)
#neto_grafica(2, c("Carne de cerdo","Arroz"))
#neto_grafica(3)
#neto_grafica(4,c("Carne de cerdo","Arroz"))



