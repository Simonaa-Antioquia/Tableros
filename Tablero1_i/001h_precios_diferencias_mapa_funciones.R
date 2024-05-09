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
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel);library(leaflet)
################################################################################-

data <- readRDS("base_precios_vs_medellin.rds")%>%
  mutate(cod_depto=as.numeric(cod_depto))

data$departamento[data$departamento=="Bogotá, D.C."]<-"Bogotá"

shapefile <- st_read("MGN_DPTO_POLITICO.shp")%>%
  janitor::clean_names()%>%filter(dpto_ccdgo!=88)%>%mutate(dpto_ccdgo=as.numeric(dpto_ccdgo))

# Simplificar la geometría del shapefile
shapefile_simplified <- st_simplify(shapefile, dTolerance = 0.01)

# Guardar el shapefile simplificado
#st_write(shapefile_simplified, "MGN_DPTO_POLITICO_simplified.shp")

Anio=2014
#Mes=11
#Producto= "Aguacate papelillo"

mapa_dif<-function(Anio = NULL, Mes = NULL, Producto = NULL){
  df<-data
  if(!is.null(Anio) && !is.null(Mes) && !is.null(Producto)){
    df<-df%>%filter(year==Anio& mes==Mes& producto==Producto)%>%
      dplyr::rename(comp=comparacion_anual_mensual_producto)%>%
      dplyr::select(cod_depto, departamento, comp)%>%
      unique()
  } else if(!is.null(Anio) && !is.null(Mes) && is.null(Producto)){
    df<-df%>%filter(year==Anio& mes==Mes)%>%
      dplyr::rename(comp=comparacion_anual_mensual)%>%
      dplyr::select(cod_depto, departamento, comp)%>%
      unique()
  } else if(!is.null(Anio) && is.null(Mes) && is.null(Producto)){
    df<-df%>%filter(year==Anio)%>%
      dplyr::rename(comp=comparacion_anual)%>%
      dplyr::select(cod_depto, departamento, comp)%>%
      unique()
  } else if(is.null(Anio) && is.null(Mes) && is.null(Producto)){
    df<-df%>%#filter(year==Anio& mes==Mes& producto==Producto)%>%
      dplyr::rename(comp=comparacion)%>%
      dplyr::select(cod_depto, departamento, comp)%>%
      unique()
  } else if(is.null(Anio) && !is.null(Mes) && !is.null(Producto)){
    df<-df%>%filter(mes==Mes& producto==Producto)%>%
      dplyr::rename(comp=comparacion_mensual_producto)%>%
      dplyr::select(cod_depto, departamento, comp)%>%
      unique()
  } else if(is.null(Anio) && is.null(Mes) && !is.null(Producto)){
    df<-df%>%filter(producto==Producto)%>%
      dplyr::rename(comp=comparacion_producto)%>%
      dplyr::select(cod_depto, departamento, comp)%>%
      unique()
  } else if(is.null(Anio) && !is.null(Mes) && is.null(Producto)){
    df<-df%>%filter(mes==Mes)%>%
      dplyr::rename(comp=comparacion_mensual)%>%
      dplyr::select(cod_depto, departamento, comp)%>%
      unique()
  } else {
    df<-df%>%filter(year==Anio&producto==Producto)%>%
      dplyr::rename(comp=comparacion_anual_producto)%>%
      dplyr::select(cod_depto, departamento, comp)%>%
      unique()
  }
  
  mapa<-shapefile%>%dplyr::left_join(df, by = c("dpto_ccdgo"="cod_depto"))
  
  titulo <- paste("Precio con respecto a Medellín", ifelse(is.null(Anio), "", paste("en el año", Anio)),
                  ifelse(is.null(Mes), "", paste("para el mes", Mes)), 
                  ifelse(is.null(Producto), "", paste("-", Producto)))
  
  mapa$tooltip_text<-ifelse(is.na(mapa$departamento),"",paste("Departamento: ",mapa$departamento,
                                                              "<br>Diferencia de precio: $", round(mapa$comp)))
  
  if (nrow(df) == 0) {
    print("No hay datos disponibles")
  } else {
    # Unir el dataframe con el shapefile
    mapa <- shapefile %>% dplyr::left_join(df, by = c("dpto_ccdgo" = "cod_depto"))
    
    # Filtrar para eliminar las filas con valores NA en "comp"
    mapa <- mapa %>% #filter(!is.na(comp))%>% 
      arrange(comp)%>%mutate(comp2=comp*-1)
    
    min_val <- -max(abs(na.omit(mapa$comp)))
    max_val <- max(abs(na.omit(mapa$comp)))
    
    valores_sin_na <- na.omit(mapa$comp2)
    my_palette_sin_na <- colorNumeric(palette = c("#F39F06", "white", "#1A4922"), domain = valores_sin_na)
    
    # Crear una paleta de colores personalizada
    my_palette <- colorNumeric(palette = colorRampPalette(c("#F39F06", "white", "#1A4922"))(length(unique(mapa$comp2))), domain = c(min_val,max_val),  na.color = "#C5C7C6")
    
    # Crear el mapa interactivo
    p <- leaflet(mapa) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(fillColor = ~my_palette(comp2),
                  fillOpacity = 0.8, 
                  color = "#D5D5D5", 
                  weight = 1,
                  popup = ~paste0("<strong>Departamento: </strong>", departamento, 
                                  "<br><strong>Diferencia del precio: </strong>", round(comp)),
                  highlightOptions = highlightOptions(color = "white", 
                                                      weight = 2,
                                                      bringToFront = TRUE)) %>%
      addLegend(pal = my_palette_sin_na, values = ~valores_sin_na, opacity = 0.7, title = "Diferencia del precio")
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





