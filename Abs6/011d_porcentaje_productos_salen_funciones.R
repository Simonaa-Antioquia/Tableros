#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/04/2024
#Fecha de ultima modificacion: 21/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(treemapify);library(highcharter)
options(scipen = 999)
################################################################################-

salen<-readRDS("base_porcentaje_productos_salen.rds")

salen_prod<-function(año = NULL, Mes = NULL, depto = NULL){
  df<-salen
  if(!is.null(año)&!is.null(Mes)&!is.null(depto)){
    
    df<-df%>%filter(anio == año)%>%filter(mes == Mes)%>%filter(mpio_destino==depto)%>%
      select(producto,grupo_alimento,porcentaje_producto_anio_mes_dpto,toneladas_total_producto_anio_mes_dpto)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_anio_mes_dpto, toneladas_r = toneladas_total_producto_anio_mes_dpto)
    
  }
  
  if(!is.null(año)&!is.null(depto)&is.null(Mes)){
    
    df<-df%>%filter(anio == año)%>%filter(mpio_destino==depto)%>%
      select(producto,grupo_alimento,porcentaje_producto_anio_dpto, toneladas_total_producto_anio_dpto)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_anio_dpto, toneladas_r = toneladas_total_producto_anio_dpto)
    
  }
  
  if(is.null(año)&!is.null(depto)&is.null(Mes)){
    
    df<-df%>%filter(mpio_destino==depto)%>%
      select(producto,grupo_alimento,porcentaje_producto_dpto, toneladas_total_producto_dpto)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_dpto, toneladas_r =  toneladas_total_producto_dpto)
    
  }
  
  if(is.null(año)&is.null(depto)&is.null(Mes)){
    
    df<-df%>%
      select(producto,grupo_alimento,porcentaje_producto,toneladas_total_producto)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto, toneladas_r = toneladas_total_producto)
    
  }
  
  if(!is.null(año)&is.null(depto)&is.null(Mes)){
    
    df<-df%>%filter(anio == año)%>%
      select(producto,grupo_alimento,porcentaje_producto_anio, toneladas_total_producto_anio)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_anio, toneladas_r = toneladas_total_producto_anio)
    
  }
  
  if(!is.null(año)&is.null(depto)&!is.null(Mes)){
    
    df<-df%>%filter(anio == año)%>%filter(mes == Mes)%>%
      select(producto,grupo_alimento,porcentaje_producto_anio_mes, toneladas_total_producto_anio_mes)%>%
      unique()%>%
      rename( columna_porcentaje = porcentaje_producto_anio_mes, toneladas_r = toneladas_total_producto_anio_mes)
    
  }
  
  titulo <- paste0("Productos que salen de Antioquia", ifelse(is.null(año),"",paste0(" para ",año)),
                  ifelse(is.null(Mes),"",paste0(" en el mes ", Mes)), ifelse(is.null(depto),"",paste0(" provenientes de ", depto)))
  
  #col_palette <- c("#1A4922", "#0088BB", "#007CC3", "#456ABB")
  low_color <- "#2E7730"
  high_color <- "#007CC3"
  if(nrow(df)==0){
  p<-  print("No hay datos disponibles")
  p_plano <- NULL
  } else {
    
df$tooltip_text <- paste("Producto:", df$producto , "<br> Porcentaje:", round(df$columna_porcentaje*100, digits = 1), "%","<br> Toneladas:", formatC(df$toneladas_r, format = "f", digits = 0, big.mark = "."))
  
  p <- hchart(df, "treemap", hcaes(x = producto, value = round(columna_porcentaje*100), color = round(columna_porcentaje*100))) %>%
    hc_title(text = "") %>%
    hc_colorAxis(minColor = low_color, maxColor = high_color) %>%
    hc_tooltip(pointFormat = '{point.tooltip_text}')%>%
    hc_caption(text = "Porcentaje", align = "center", verticalAlign = "bottom", y = -10)

  p_plano<-ggplot(df, aes(area = columna_porcentaje, fill = columna_porcentaje,
                    label = producto)) +
    geom_treemap() +
    #geom_treemap_subgroup_border(colour = "white", size = 5) +
    #geom_treemap_subgroup_text(place = "topleft", grow = FALSE,
     #                          alpha = 0.3, colour = "black",
      #                         fontface = "italic", size = 15) +
    geom_treemap_text(colour = "white", place = "centre",
                      size = 15, grow = FALSE)+
    scale_fill_gradient(low = low_color, high = high_color) +  # Usa un gradiente de colores
    labs(title = "", fill = "Porcentaje")
  }
  porcentaje_max<-round(max(df$columna_porcentaje)*100, digits = 1)
  producto_max<-df$producto[which.max(df$columna_porcentaje)]
  return(
    list(
      grafico = p,
      grafico_plano = p_plano,
      datos = df,
      porcentaje_max=porcentaje_max,
      producto_max=tolower(producto_max)
    )
  )
}





#nrow(salen_prod(año=2013,Mes =  1,depto =  "Armenia")$datos)
#salen_prod(2013,,"Medellín")
#salen_prod(depto =  "Medellín")
#salen_prod()
#salen_prod(año=2013)
#salen_prod(año=2013,Mes = 1)

