#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 16/04/2024
#Fecha de ultima modificacion: 16/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(plotly)
options(scipen = 999)
################################################################################-

data<-readRDS("base_precios_cambio.rds")%>%
  filter(ciudad == "Medellín")
complet<-readRDS("base_precios_cantidades_distancias.rds")

##Funcion para ver el promedio por mes de los precios y cantidades en todos los años

# Define la función
graficar_producto_y_precio <- function(df, alimento, fecha = NULL) {
  # Filtra los datos para el producto específico, a menos que alimento sea "total"
  if (alimento != "total") {
    df <- df %>% filter(producto == alimento)
  }
  if (!is.null(fecha)){
    df <- df %>% filter(anio == fecha)
  }
  # Calcula la cantidad y el precio promedio por mes
  datos_producto <- df %>% filter(ciudad=="Medellín") %>%
    mutate(mes = month(mes_y_ano)) %>%
    group_by(mes) %>%
    summarise(cantidad = sum(suma_kg, na.rm = TRUE)/1000000, precio_prom = mean(precio_prom, na.rm = TRUE),
              distancia = mean(distancia, na.rm = TRUE))
  
  datos_producto$tooltip_text1<-paste()
  
  # Crea el gráfico
  graf<-ggplot(datos_producto, aes(x = mes)) +
    geom_line(aes(y = cantidad, color = "Cantidad"), size = 1) +
    geom_line(aes(y = precio_prom / max(datos_producto$precio_prom) * max(datos_producto$cantidad), color = "Precio/Kg"), size = 1) +
    geom_line(aes(y = distancia / max(datos_producto$distancia) * max(datos_producto$cantidad), color = "Distancia - Km"), size = 1) +
    geom_text(aes(y = distancia / max(datos_producto$distancia) * max(datos_producto$cantidad), label = round(distancia, 1)), color = "black", check_overlap = TRUE) +
    scale_y_continuous(
      name = "Miles de toneladas",
      sec.axis = sec_axis(~ . * max(datos_producto$precio_prom) / max(datos_producto$cantidad), name = "Precio/Kg")
    ) +
    scale_x_continuous(breaks = seq(1, 12, 1), labels = c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")) + 
    scale_color_manual(values = c("Cantidad" = "#0D8D38", "Precio/Kg" = "#00596C", "Distancia - Km" = "#F1B709")) +
    labs(title = paste("Cantidad, precio mensual y distancia de", alimento, ifelse(is.null(fecha), "", paste("en", fecha))),
         x = "Mes",
         color = "Variable") +
    theme_minimal()
  
  p<-plotly::ggplotly(graf)
  
  nombres_meses <- c("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre")
  mes_max <- nombres_meses[datos_producto$mes[which.max(datos_producto$precio_prom)]]
  distancia_max <- round(datos_producto$distancia[which.max(datos_producto$precio_prom)], 1)
  cantidades_max <- round(datos_producto$cantidad[which.max(datos_producto$precio_prom)], 1)
  precio_max <- round(max(datos_producto$precio_prom), 1)
  producto_sel <- ifelse(alimento == "total", "todos los productos", alimento)
  anio_sel <- c(fecha,"todos los años")
  
  return(
    list(
      grafico=p,
      datos =datos_producto,
      mes_max =mes_max,
      distancia_max=distancia_max,
      cantidades_max=cantidades_max,
      precio_max=precio_max
      #producto_sel=producto_sel,
      #anio_sel=anio_sel
    )
  )
}

# Usa la función para graficar la cantidad y el precio mensual de un producto específico
# (reemplaza 'nombre_del_producto' con el nombre del producto que quieres graficar)
#graficar_producto_y_precio(complet, 'total')

