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
  
  # Crea el gráfico
  p<-ggplot(datos_producto, aes(x = mes)) +
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

#Gráficas precios----
# Define la función

graficar_variable <- function(df, variable, alimento = NULL, fecha = NULL) {
  # Si no se proporciona alimento, calcula el promedio
  if (!is.null(alimento)) {
    df <- df %>%
      filter(ciudad == "Medellín", producto == alimento)
    
    # Prepara los datos
    df_graf <- df %>%
      arrange(ciudad, producto, mes_y_ano)%>%
      mutate(precio_prom=round(precio_prom)) %>%
      mutate(cambio_pct = round((precio_prom / lag(precio_prom) - 1) * 100))  %>%
      mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month")) %>%
      drop_na(mes_y_ano) %>%
      complete(ciudad, producto, mes_y_ano = seq.Date(min(mes_y_ano, na.rm = TRUE), max(mes_y_ano, na.rm = TRUE), by = "month")) %>%
      mutate(cambio_pct_anual = round((precio_prom / lag(precio_prom, 12) - 1) * 100))
  } else {
    df <- df %>%
      group_by(ciudad, mes_y_ano, anio) %>%
      summarise(precio_prom = round(mean(precio_prom, na.rm = TRUE)), .groups = "drop")
    
    df <- df %>%
      filter(ciudad == "Medellín")
    
    df_graf <- df %>%
      arrange(ciudad, mes_y_ano) %>%
      mutate(precio_prom=round(precio_prom))%>%
      mutate(cambio_pct = round((precio_prom / lag(precio_prom) - 1) * 100)) %>%
      mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month")) %>%
      drop_na(mes_y_ano) %>%
      complete(ciudad, mes_y_ano = seq.Date(min(mes_y_ano, na.rm = TRUE), max(mes_y_ano, na.rm = TRUE), by = "month")) %>%
      mutate(cambio_pct_anual = round((precio_prom / lag(precio_prom, 12) - 1) * 100)) 
  }
  
  # Si se proporciona un valor para fecha, filtra por año
  if (!is.null(fecha)) {
    df_graf <- df_graf %>%
      filter(anio == fecha)
  }
  vaiable2<-ifelse(variable=="precio_prom", "Precio promedio",
                   ifelse(variable=="cambio_pct", "Cambio porcentual","Cambio porcentual año anterior"))
  titulo<-paste("Tendencia de", tolower(vaiable2),ifelse(is.null(alimento),"",paste("para", alimento) ))
  # Crea la gráfica
  
  if(is.null(fecha)){
  p<-ggplot(df_graf, aes(x = mes_y_ano, y = !!sym(variable), group = 1)) +
    geom_line(color = "#0D8D38") +
    scale_x_date(date_labels = "%Y-%m", date_breaks = "6 month") +
    xlab("Fecha")+
    labs( y = "", 
         title = "") +
    theme_minimal()
  }else{
    p<-ggplot(df_graf, aes(x = mes_y_ano, y = !!sym(variable), group = 1)) +
      geom_line(color = "#0D8D38") +
      scale_x_date(date_labels = "%b", date_breaks = "1 month") +
      xlab("Fecha")+
      labs( y = "", 
           title = "") +
      theme_minimal()
  }
  
  map<-plotly::ggplotly(p)
  
  return(
    list(
      grafico=map,
      datos=df_graf
    )
  )
  
}

# graficar_variable(data, "precio_prom")
#, alimento = "", fecha="2020")
# Usa la función para graficar la variable "precio" para la ciudad "Bogota" y el producto "Arroz"

# Define la función
graficar_variables <- function(df, producto=NULL, fecha = NULL) {
  # Crea las tres gráficas
  grafica1 <- graficar_variable(df, "precio_prom", producto,  fecha)
  grafica2 <- graficar_variable(df,"cambio_pct",  producto,  fecha)
  grafica3 <- graficar_variable(df, "cambio_pct_anual", producto, fecha)
  
  # Muestra las tres gráficas juntas
  p<-plotly::subplot(grafica1$grafico, grafica2$grafico, grafica3$grafico, nrows = 3)
  datos<-unique(rbind(grafica1$datos,grafica2$datos,grafica3$datos))
  promedio <- round(mean(datos$precio_prom, na.rm = TRUE))
  fecha_max <- format(as.Date(datos$mes_y_ano[which.max(datos$precio_prom)]), "%B-%Y")
  fecha_min <- format(as.Date(datos$mes_y_ano[which.min(datos$precio_prom)]), "%B-%Y")
  precio_max <- round(max(datos$precio_prom, na.rm = TRUE))
  precio_min <- round(min(datos$precio_prom, na.rm = TRUE))
  return(
    list(
      grafico=p,
      datos=datos,
      promedio=promedio,
      fecha_max=fecha_max,
      fecha_min=fecha_min,
      precio_max=precio_max,
      precio_min=precio_min
    )
  )
}

# Usa la función para graficar las variables "precio_prom", "cambio_pct" y "cambio_pct_anual" para la ciudad "Medellín" y el producto "Papa negra"
#graficar_variables(data, producto = "Papa criolla")


#graficar_variables(data, fecha = "2020")


# Ejemplo 1: Graficar el precio promedio para todas las ciudades y alimentos
#graficar_variable(df, "precio_prom")

# Ejemplo 2: Graficar el cambio porcentual para la ciudad "Medellin" y todos los alimentos
#graficar_variable(data, "cambio_pct")

# Ejemplo 3: Graficar el cambio porcentual anual para el alimento "arroz" en todas las ciudades
#graficar_variable(data, "cambio_pct_anual", alimento = "cebolla cabezona blanca")

# Ejemplo 4: Graficar el precio promedio para la ciudad "Medellin" y el alimento "arroz"
#graficar_variable(data, "precio_prom",  alimento = "papa negra")

# Ejemplo 5: Graficar el cambio porcentual para la ciudad "Medellin" y el alimento "arroz" en el año 2020
#graficar_variable(df, alimento = "papa criolla", fecha = 2020)















