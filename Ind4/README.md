# **Índice de vulnerabilidad del abastecimiento de alimentos de Antioquia**

Para construir este índice es necesario conocer la participación que tiene los alimentos que se "producen" en cada municipio, que es calculado utilizando el índice de Herfindahl-Hirschman "Concentracion de los municipios que abastecen los principales centros de acopio en Antioquia" (detallado arriba) y la distancia ponderada por su participación entre el municipio de origen y Medellin, tomando medellin como municipio destino.

$$
V_{it}=\frac{H_{it}+D_{i}}{2}
$$

Donde:

-   $D_i$ es la distancia entre el municipio *m* ponderada por la importancia (peso) del alimento que llega de allí, espcificamente, para calcularlo se siguen estos pasos:

1.  Se calcula la distancia entre el municipio *m* y Medellin. Para todos los municipios que que sean origen del alimento *i* ($d_m$).

2.  Luego de tener todas las distancias, se normaliza, donde obtenemos que la distancia mas grande entre un municipio *m* y Medellin es 1 y la distancia mas pequeña es 0. Dado que algunos productos provienen de otros paises se decide dejar estos como 1, es decir que la distancia más grande posible será cualquier país externo, teniendo en cuenta que el municipio más distante a Medellín es a 994 km se les asigna mil kilometros a todos estos.

3.  Luego de tener la distancia normalizada la multiplicamos por la participación que tiene ese municipio en el total del abastecimiento para el alimento *i* en el periodo *t*.

4.  Finalmente sumamos todas las distancias ponderadas calculadas. Note que el máximo de esta sumatoria es 1, cuando la mayor distancia sea el origen del total de toneladas del alimento *i*.

-   $H_{it}$ es el índice de concentracion de los municipios que abastecen los principales centros de acopio en Antioquia.

Para este índice, utilizamos el índice de Herfindahl-Hirschman (HH) que nos permite medir el nivel de concentración en los mercados. En este caso, nos interesa calcular que la concentración de destinos del alimento *i*. En otras palabras que tan diversificados son los municipios de destino del alimento *i*.

Para construir el índice se debe calcular la participación que tiene cada municipio de destino en la cantidad total del alimento de origen antioqueño *i* en el momento del tiempo *t*. La fórmula utilizada es:

$$
P_{itm}=\frac{d_{itm}}{Q_{it}}
$$

Donde:

-   $𝑃_{i𝑡m}$ es la participación del producto *i*, en el periodo *t*, que provienen del municipio *m*.

-   $d_{𝑖𝑡m}$ es la cantidad enviada a cada municipio de destino *m*, del producto *i*, en el periodo *t*.

-   $Q_{i𝑡}$ es es el total de kilogramos de alimentos disponibles del producto *i* en el periodo *t* que son de origen antioqueño.

Finalmente, el índice de Herfindahl-Hirschman se calcula como:

$$
H_{it}=\sum_{i=1}^{N}P_{itm}^{2}
$$

![](Ind4/preview_tablero.png)

![](www/logo.png)
