![](logo.jpeg)

# Repositorio de Tableros SABA

Este repositorio contiene los códigos fuente de los tableros dinámicos realizados para el proyecto del Sistema de Monitoreo de Abastecimiento Agroalimentario de Antioquia (SIMONAA), desarrollado en colaboración entre la Universidad EAFIT, la Organización de las Naciones Unidas para la Alimentación y la Agricultura (FAO) y la Gobernación de Antioquia.

Los tableros proporcionan visualizaciones detalladas de diversas métricas generadas a partir de los datos del Sistema de Información de Precios y Abastecimiento del Sector Agropecuario (SIPSA), con un enfoque especial en los datos relacionados con Medellín. Cada tablero presenta una métrica específica, ofreciendo una comprensión profunda del abastecimiento agroalimentario en Antioquia.

# Contenido

A continuación se detallan los 18 tableros:

**Pre1**: Permite conocer el comportamiento histórico de los precios generales de los alimentos del abastecimiento de Antioquia. Permite seleccionar el tipo de producto del cual se quiere conocer el precio y además el año para el cual se quiere generar la información.

Está conformado por tres variables que permiten, no solo conocer el precio de los alimentos si no también su variación a lo largo del tiempo. Específicamente, el panel A muestra el precio mensual promedio de los alimentos, el panel B muestra la variación mensual de los alimentos en el tiempo (t) con respecto al tiempo anterior (t-1) y el panel C muestra la variación del precio de los alimentos entre el mes (t) y el mes (t-11); ejemplo, la variación entre enero del 2019 y enero del 2018.

![](Pre1/preview_tablero.png) 

**Pre2**: Constituye una herramienta para conocer y comparar los precios y las cantidades de ciertos alimentos que conforman el abastecimiento en Antioquia. Facilita el acceso a información detallada sobre cada producto, así como la realización de comparaciones a lo largo de los meses del año tanto en términos de precios como de cantidades. Además, el análisis puede extenderse para abarcar cada año.

![](Pre2/preview_tablero.png)

**Pre3**: El tablero facilita la observación y comparación de los precios de los alimentos según el municipio. Por ejemplo, es factible identificar en qué ciudades capitales resulta más costoso adquirir un determinado tipo de alimento. El tablero proporciona información general y el promedio de precios de cada uno de los alimentos, así como la posibilidad de conocer datos específicos por mes o año.

![](Pre3/preview_tablero.png)

**Pre4**: Mantiene la misma información del *Pre3* pero se visualiza en un mapa según el departamento de cada una de las ciudades disponibles.

![](Pre4/preview_tablero.png) 

**Abs1**: El tablero permite comprender la importancia que tiene cada municipio del país en el abastecimiento de Medellín. El tablero proporciona información detallada sobre todos los productos, permitiendo especificar el municipio del cual se desea obtener el alimento y/o el alimento del cual se quiere obtener información, así como el periodo de tiempo para el cual se desea generar la información.

![](Abs1/preview_tablero.png)

**Abs2**: El propósito del tablero es evidenciar la importancia que Antioquia tiene como destino en los envíos de productos alimentarios de otros departamentos. Por ejemplo, en el mapa se puede observar que algunos departamentos envían hasta el 60% de su abastecimiento a Antioquia.

Además, esta herramienta proporciona acceso a información tanto general (para todos los años y todos los productos) como específica, permitiendo seleccionar un año y/o producto determinado.

![](Abs2/preview_tablero.png)

**Abs3**: El propósito del tablero es evidenciar la importancia de la producción en Antioquia para el abastecimiento de otros departamentos. En otras palabras, muestra cuánto dependen los demás departamentos de los alimentos que provienen de municipios antioqueños. Por ejemplo, una lectura típica de este tablero sería: *"Del total de alimentos que recibe el Meta, ¿qué porcentaje proviene de Antioquia?"*.

Este tablero permite generar tanto información general (sobre todos los productos y todo el tiempo disponible) como información más específica, como seleccionar un año y/o producto.

![](Abs3/preview_tablero.png)

**Abs4**: En el tablero se muestran los principales destinos de los alimentos que se tienen como origen (salen de) municipios de Antioquia. Por ejemplo, en la visualización propuesta podemos observar que teniendo en cuenta toda la información (todos los años y meses disponibles), la mayor parte del arroz, exactamente el 40.9% del arroz que sale de Antioquia se queda en Medellín.

![](Abs4/preview_tablero.png)

**Abs5**: El tablero presenta los principales productos que entran a Medellín, esto con el fin de ver cuales productos son más propensos a ser ingresados. Esto lo podemos observar por año, mes o departamento de procedencia.

![](Abs5/preview_tablero.png)

**Abs6**: El tablero presenta los principales productos que salen de Antioquia, esto con el fin de ver cuales productos que tienen como origen el departamento. Esto lo podemos observar por año, mes o la ciudad de destino.

![](Abs6/preview_tablero.png)

**Abs7**: A través este se puede acceder a información sobre el abastecimiento neto de las centrales de acopio de Medellín. Este cálculo tiene como objetivo proporcionar un indicador aproximado del consumo en Medellín. Para obtener este valor, se resta la cantidad de kilogramos de alimentos que salen de Antioquia en el periodo (t) de la cantidad de alimentos que ingresan a Medellín en el mismo periodo (t).

Este tablero ofrece información histórica tanto anual como mensual, tanto general como por producto. Además, permite el análisis de varios productos seleccionados simultáneamente.

![](Abs7/preview_tablero.png)

**Abs8**: Este tablero muestra las cantidades por producto que ingresan (local o externo) y salen de Medellín/Antioquia, además vemos el acumulado porcentual de al menos el 80% de los productos. La información se encuentra disponible para cada uno de los años y meses, así como discriminación por localización de origen/destino.

![](Abs8/preview_tablero.png)

**Ind1**: El tablero presenta los resultados del índice de Herfindahl-Hirschman (HH), diseñado para evaluar la diversidad de alimentos disponibles en Antioquia (concentración de alimentos). El Panel A muestra el comportamiento del índice en términos mensuales o anuales.

![](Ind1/preview_tablero.png)

**Ind2**: El tablero presenta los resultados del Índice Herfindahl-Hirschman, el cual calcula el nivel de concentración de los municipios que abastecen a Medellín. En otras palabras, este índice nos permite comprender qué tan concentrados están los municipios que suministran productos a las centrales de abastecimiento de Medellín. Un índice cercano a cien indica que un solo municipio es responsable del abastecimiento, mientras que un índice cercano a cero indica que la provisión de Medellín depende de varios municipios.

![](Ind2/preview_tablero.png)

**Ind3**: El tablero presenta los resultados del Índice Herfindahl-Hirschman, el cual calcula el nivel de concentración de los municipios que se abastecen de Antioquia. En otras palabras, este índice nos permite comprender qué tan concentrados están los municipios que reciben productos de origen antioqueño. Un índice cercano a cien indica que un solo municipio es receptor de los alimentos, mientras que un índice cercano a cero indica que el destino de alimentos sean diferentes municipios.

![](Ind3/preview_tablero.png)

**Ind4**: El Tablero muestra los resultados del Índice de Vulnerabilidad, el cual se construye considerando el número de municipios que abastecen un determinado alimento y la distancia que dicho alimento debe recorrer para llegar a Medellín. El Panel presenta el índice mensual o anual, tanto en términos generales como por producto. El objetivo es facilitar la comparación para determinar si un producto específico tiene una mayor probabilidad de desabastecimiento o si un mes dado es más vulnerable que el siguiente.

![](Ind4/preview_tablero.png)

**Maps1**: Muestra las importancias de cada una de las rutas viales de abastecimiento del país, ayuda a ver desde que zonas del país provienen los productos alimenticios. Además de ver las vias también se muestra la representación porcentual de alimentos que transita por cada vía. Este cuenta con información a nivel de producto, mes y año.

![](Maps1/preview_tablero.png)

**Maps2**: El tablero muestra diferentes escenarios de vulnerabilidad del abastecimiento partiendo de supuestos de cierres viales. Este muestra los posibles efectos que tendría en las cantidades de alimento que ingresan a las centrales de acopio de Medellín según los diferentes escenarios de vulnerabilidad seleccionados. Esta información está disponible a nivel de año, mes y producto.

![](Maps2/preview_tablero.png)

