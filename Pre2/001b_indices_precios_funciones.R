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
  
  # Crea el gráfico base con la primera línea de datos
  graf <- plot_ly(datos_producto, x = ~mes, y = ~cantidad, type = "scatter", mode = "lines",
                  name = "Cantidad", text = ~paste("Cantidades: ", round(cantidad)," mil toneladas"), hoverinfo = "text", 
                  line = list(color = "#0D8D38")) %>%
    layout(title = "",#paste("Cantidad, precio mensual y distancia de", alimento, ifelse(is.null(fecha), "", paste("en", fecha))),
           xaxis = list(title = "Mes", tickvals = seq(1, 12, 1), ticktext = c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"), showgrid = FALSE),
           yaxis = list(title = "", showticklabels = FALSE, showgrid = FALSE),
           legend = list(orientation = "h", x = 0.5, y = 1.1, xanchor = "center"),
           plot_bgcolor = "white", 
           paper_bgcolor = "white")  
  
  # Añade las otras líneas con tooltips personalizadas
  graf <- graf %>%
    add_trace(y = ~precio_prom / max(datos_producto$precio_prom) * max(datos_producto$cantidad), name = "Precio/Kg", text = ~paste("Precio: $", formatC(precio_prom, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)),
              hoverinfo = "text", line = list(color = "#00596C")) #%>%
    #add_trace(y = ~distancia / max(datos_producto$distancia) * max(datos_producto$cantidad), name = "Distancia - Km", text = ~paste("Distancia: ", round(distancia),"Km"), hoverinfo = "text", line = list(color = "#F1B709"))
  
  p<-graf
#  p <- plotly::ggplotly(graf, tooltip = "text")

  #p <- (graf)#, tooltip = c("y", "color", "text"))
  
  nombres_meses <- c("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre")
  mes_max <- nombres_meses[datos_producto$mes[which.max(datos_producto$precio_prom)]]
  distancia_max <- round(datos_producto$distancia[which.max(datos_producto$precio_prom)])
  cantidades_max <- round(datos_producto$cantidad[which.max(datos_producto$precio_prom)])
  precio_max <- formatC(max(datos_producto$precio_prom), format = "f", big.mark = ".", decimal.mark = ",", digits = 0)
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

