#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 18/04/2024
#Fecha de ultima modificacion: 18/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(treemapify);library(highcharter)
options(scipen = 999)
################################################################################-

entran<-read.csv("base_porcentaje_productos_entran.csv")

entran_prod<-function(año = NULL, Mes = NULL, depto = NULL){
  df<-entran
  if(!is.null(año)&!is.null(Mes)&!is.null(depto)){
    
    df<-df%>%filter(anio == año)%>%filter(mes == Mes)%>%filter(depto_origen==depto)%>%
      select(producto,grupo_alimento,porcentaje_producto_anio_mes_dpto)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_anio_mes_dpto)
  
    }
  
  if(!is.null(año)&!is.null(depto)&is.null(Mes)){
    
    df<-df%>%filter(anio == año)%>%filter(depto_origen==depto)%>%
      select(producto,grupo_alimento,porcentaje_producto_anio_dpto)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_anio_dpto)
    
  }
  
  if(is.null(año)&!is.null(depto)&is.null(Mes)){
    
    df<-df%>%filter(depto_origen==depto)%>%
      select(producto,grupo_alimento,porcentaje_producto_dpto)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_dpto)
    
  }
  
  if(is.null(año)&is.null(depto)&is.null(Mes)){
    
    df<-df%>%
      select(producto,grupo_alimento,porcentaje_producto)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto)
    
  }
  
  if(!is.null(año)&is.null(depto)&is.null(Mes)){
    
    df<-df%>%filter(anio == año)%>%
      select(producto,grupo_alimento,porcentaje_producto_anio)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_anio)
    
  }
  
  if(!is.null(año)&is.null(depto)&!is.null(Mes)){
    
    df<-df%>%filter(anio == año)%>%filter(mes == Mes)%>%
      select(producto,grupo_alimento,porcentaje_producto_anio_mes)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_anio_mes)
    
  }
  
  titulo <- paste0("Productos que entran a Antioquia", ifelse(is.null(año),"",paste0(" para ",año)),
                   ifelse(is.null(Mes),"",paste0(" en el mes ", Mes)), ifelse(is.null(depto),"",paste0(" provenientes de ", depto)))
  
  #col_palette <- c("#1A4922", "#0088BB", "#007CC3", "#456ABB")
  
  low_color <- "#2E7730"
  
  high_color <- "#007CC3"
  
  #df$color <- colorRampPalette(c(low_color, high_color))(nrow(df))
  
  p <- hchart(df, "treemap", hcaes(x = producto, value = round(columna_porcentaje*100), color = round(columna_porcentaje*100))) %>%
    hc_title(text = "") %>%
    hc_colorAxis(minColor = low_color, maxColor = high_color)
  
  porcentaje_max<-round(max(df$columna_porcentaje)*100)
  producto_max<-df$producto[which.max(df$columna_porcentaje)]
  
  return(
    list(
      grafico = p,
      datos = df,
      porcentaje_max=porcentaje_max,
      producto_max=tolower(producto_max)
    )
  )
}


#entran_prod(año=2013,Mes =  1,depto =  "Antioquia")
#entran_prod(2013,,"Antioquia")
#entran_prod(depto =  "Antioquia")
#entran_prod()
#entran_prod(año=2013)
#entran_prod(año=2013,Mes = 1)

