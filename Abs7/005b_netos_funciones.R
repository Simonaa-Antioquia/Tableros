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
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(scales);library(plotly)
library(sf)
options(scipen = 999)
################################################################################-

data_mensual<-readRDS("neto_mensual.rds")%>%
  mutate(fecha = floor_date(as.Date(as.yearmon(fecha, "%Y-%m"), frac = 1), "month"))
data_anual<-readRDS("neto_anual.rds")
data_mensual_producto<-readRDS("neto_mensual_producto.rds")%>%
  mutate(fecha = floor_date(as.Date(as.yearmon(fecha, "%Y-%m"), frac = 1), "month"))
data_anual_producto<-readRDS("neto_anual_producto.rds")

col_palette <- c("#1A4922", "#2E7730", "#0D8D38", "#85A728", "#AEBF22", "#F2E203", "#F1B709", "#F39F06", "#BE7E11",
                 "#08384D", "#094B5C", "#00596C", "#006A75", "#007A71", "#00909C", "#0088BB", "#007CC3", "#456ABB")


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
      select("anio","producto", "total_importado","sale_kg","ingresa_kg")
    if (length(productos_seleccionados) == 0){
      message("Para esta opcion debe escoger los productos que quiere graficar")
    }
  } else if (tipo == 3) {
    df <- data_mensual
    df <- df %>%
      select("fecha","total_importado","sale_kg","ingresa_kg","mes")
    df <- rename(df, anio = fecha)
  } else if (tipo == 4) {
    df <- data_mensual_producto
    df <- df %>%
      select("producto", "fecha","total_importado","sale_kg","ingresa_kg","mes")
    df <- rename(df, anio = fecha)
    if (length(productos_seleccionados) == 0){
      stop("Para esta opcion debe escoger los productos que quiere graficar")
    }
  }
  # Filtrar los productos seleccionados solo para las opciones 2 y 4
  if (tipo %in% c(2)) {
    df <- df[df$producto %in% productos_seleccionados, ]
    df$tooltip_text <- paste("Año: ", df$anio , "<br> Volumen de salidas (mil t):" , round(df$sale_kg, digits = 1),"mil", "<br> Volumen de ingreso (mil t):",round(df$ingresa_kg, digits = 1),"mil", "<br> Balance Alimentos:",round(df$total_importado, digits = 1),"mil")
    p_plano <- ggplot(df, aes(x = anio, y = total_importado, color = producto)) +
      geom_line() +
      geom_point(aes(text = tooltip_text),size = 1e-8) +
      labs(x = "Año", y = "Miles de toneladas") +
      scale_x_continuous(breaks = seq(min(df$anio), max(df$anio))) +
      scale_color_manual(values = col_palette) +  
      theme_minimal()
    
  } else if(tipo %in% c(4)) {
    df <- df[df$producto %in% productos_seleccionados, ]
    df$tooltip_text <- paste("Año: ", df$anio , "<br>Mes:",df$mes, "<br> Volumen de salidas (mil t):" , round(df$sale_kg, digits = 1),"mil", "<br> Volumen de ingreso (mil t):",round(df$ingresa_kg, digits = 1),"mil", "<br> Balance Alimentos:",round(df$total_importado, digits = 1),"mil")
    p_plano <-ggplot(df, aes(x = anio, y = total_importado, color = producto)) +
      geom_line() +
      geom_point(aes(text = tooltip_text),size = 1e-8) +
      labs(x = "Año", y = "Miles de toneladas") +
      #scale_x_continuous(breaks = seq(min(df$anio), max(df$anio))) +
      scale_color_manual(values = col_palette) +  
      theme_minimal()  
  }else if(tipo %in% c(3)){
    df$tooltip_text <- paste("Año: ", df$anio , "<br>Mes:",df$mes, "<br> Volumen de salidas (mil t):" , round(df$sale_kg, digits = 1),"mil", "<br> Volumen de ingreso (mil t):",round(df$ingresa_kg, digits = 1),"mil", "<br> Balance Alimentos:",round(df$total_importado, digits = 1),"mil")
    p_plano<-ggplot(df, aes(x = anio, y = total_importado)) +
      geom_line(colour = "#1A4922") +
      geom_point(aes(text = tooltip_text),size = 1e-8) +
      labs(x = "Año", y = "Miles de toneladas") +
      #scale_x_continuous(breaks = seq(min(df$anio), max(df$anio))) +
      scale_color_manual(values = col_palette) +  
      theme_minimal()  
  }else {
    df$tooltip_text <- paste("Año: ", df$anio , "<br> Volumen de salidas (mil t):" , round(df$sale_kg, digits = 1),"mil", "<br> Volumen de ingreso (mil t):",round(df$ingresa_kg, digits = 1),"mil", "<br> Balance Alimentos:",round(df$total_importado, digits = 1),"mil")
    p_plano <-ggplot(df, aes(x = anio, y = total_importado)) +
      geom_line(colour = "#1A4922") +
      geom_point(aes(text = tooltip_text),size = 1e-8) +
      labs(x = "Año", y = "Miles de toneladas") +
      scale_x_continuous(breaks = seq(min(df$anio), max(df$anio))) +
      scale_color_manual(values = col_palette) +  
      theme_minimal()  
  }
  
  min_ton<-round(min(df$total_importado)*-1)
  fecha_min <- df$anio[which.min(df$total_importado)]
  df<-df%>%select(-tooltip_text)
  
  p <- plotly::ggplotly(p_plano, tooltip = "text")
  return(list(
    grafico = p,
    grafico_plano = p_plano,
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



