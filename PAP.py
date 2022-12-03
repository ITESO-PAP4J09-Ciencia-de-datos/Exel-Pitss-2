import pandas as pd  
import numpy as np
import matplotlib.pyplot as plt
import streamlit as st
import plotly.express as px
import multiprocessing
import warnings
import seaborn as sns
import datetime as dt
from datetime import datetime
from skimage import io
warnings.filterwarnings('ignore', '.*do not.*')


st.set_page_config(page_title="Exel Pitss",
                   page_icon=":bar_chart:",
                   layout="wide")
st.image(io.imread("C:/Users/crist/Desktop/Logo_EXEL_PITSS_Color.png"), width=500)
st.title("PAP ITESO")

#Importando Librerias Servicios PAP.csv
Data_Pitss = pd.read_csv("C:/Users/crist/Desktop/PAP/Exel Pitss Limpio.csv")
datos = pd.read_csv("C:/Users/crist/Desktop/PAP/Servicios.csv")
datos= datos.fillna(.001)

#st.dataframe(Data_Pitss)


st.sidebar.header("Filtros")
city = st.sidebar.multiselect("Selecciona El Estado",
                              options=Data_Pitss["ServiceRouteName"].unique(),
                              default=Data_Pitss["ServiceRouteName"].unique())

tecnico_ejecutor = st.sidebar.multiselect(
    "Selecciones El Tecnico Ejecuto", options=Data_Pitss["tecnicoEjecutor"].unique(),
    default=Data_Pitss["tecnicoEjecutor"].unique())


seleccion = Data_Pitss.query(
    "ServiceRouteName == @city or tecnicoEjecutor == @tecnico_ejecutor")

st.dataframe(seleccion)

#KPIS



#####SOCNAME

st.markdown("En este apartado hicimos gráficas de tipo de máquina, total de visitas, modelo más solicitado y promedio de horas de uso muestran la cantidad de veces que se solicita cada tipo de máquina, el número total de visitas del tecnico ejecutor, el modelo de máquina que se solicita con mayor frecuencia y el promedio de horas que se utilizan para finalizar un pedido, estos datos pueden ayudar al personal de la empresa a tomar decisiones para sastifacer las necesidades y preferencias de sus clientes.")


Tipo = seleccion.groupby(['SOCNAME'])['SOCNAME'].count()

figura_1 = px.bar(Tipo,x="SOCNAME",y=Tipo.index,
                  orientation=("h"), title= "<b> Tipo De Maquina",
                  color_discrete_sequence=["#0083B8"] * len(Tipo),
                  template="plotly")

#####Numero De Visitas

Visitas = seleccion.groupby(['tecnicoEjecutor'])['NumVisitas'].count()

figura_2 = px.bar(Visitas,x="NumVisitas",y=Visitas.index,
                  orientation=("h"), title= "<b> Total de Visitas",
                  color_discrete_sequence=["#0083B8"] * len(Visitas),
                  template="plotly")


#####Modelo
Modelo = seleccion.groupby(['productModel'])['productModel'].count()

figura_3 = px.bar(Modelo,x="productModel",y=Modelo.index,
                  orientation=("h"), title= "<b> Modelo más solicitado",
                  color_discrete_sequence=["#0083B8"] * len(Modelo),
                  template="plotly")

#####Tiempo

Tiempo = seleccion.groupby(['tecnicoEjecutor'])['horas'].mean()

figura_4 = px.bar(Tiempo,x="horas",y=Tiempo.index,
                  orientation=("h"), title= "<b> Promedio De Horas",
                  color_discrete_sequence=["#0083B8"] * len(Tipo),
                  template="plotly")

#####Ratio



a, b, c,d = st.columns(4)

a.plotly_chart(figura_1, use_container_width = True)
b.plotly_chart(figura_2, use_container_width = True)
c.plotly_chart(figura_3, use_container_width = True)
d.plotly_chart(figura_4, use_container_width = True)

#Frecuencia de Estatus
st.title("Modelo 1")

st.header("Frecuencia de Estatus")
freq=pd.value_counts(datos['Estatus'])
st.dataframe(freq)

st.header("Frecuencia Relativa")
frecuencia=pd.DataFrame(freq)
frecuencia.columns = ["Frec_abs"]
frecuencia["Frec_rel_%"] = 100*frecuencia["Frec_abs"]/len(datos)
st.dataframe(frecuencia)
###imagenes
st.header("Frecuencia Relativa de Dias transcurridos para que el proceso sea relativo")
img = io.imread("C:/Users/crist/Desktop/Sin título-4.png")
st.image(img)

img1 = io.imread("C:/Users/crist/Desktop/1.png")
st.image(img1, caption='Observado lo anterior, podemos descartar a partir del día 23 porque el nivel de significancia dentro de nuestros datos no es relevante')


st.header("Tabla de Procesos Resueltos dentro de los primeros 22 días")
st.markdown("Podemos ver acontinuación la frecuencia absoluta de los estados la cuál nos indica el número de veces que se produce un evento en una muestra y por otro lado tenemos la frecuencia relativa que es el cociente entre la frecuencia absoluta y el tamaño de la muestra.")
img = io.imread("C:/Users/crist/Desktop/2.png")
st.image(img, caption='Frecuencia De Estados')

st.header("Segmentación de Regiones")
st.markdown('Procederemos a realizar una regionalización del pais respecto a la Ruta de servicio y observar de manera porcionada el cambio que se obtiene al analizar el tiempo de recepción, tiempo de y tiempo de respuesta para evaluar el comportamiento del modelo en cuestión.')
st.markdown("Crearemos Nuestras regiones con base en las regiones economicas del país.")
img = io.imread("C:/Users/crist/Desktop/6.png")
st.image(img, caption='Segmentación de Datos')

#Matrices

st.header("Matriz de Covarianza Por Región")
st.markdown("La covarianza es una medida de la relación lineal entre dos variables aleatorias. Se puede interpretar como el grado en que las dos variables varían juntas.")
st.markdown("Una covarianza positiva indica que las dos variables aumentan o disminuyen juntas; cuanto mayor sea la covarianza, mayor será el cambio conjunto de las variables. Una covarianza negativa indica que cuando una variable aumenta, la otra variable tiende a disminuir y viceversa; cuanto más negativo sea el valor de la covarianza, mayor será el cambio opuesto de las variables. ")
st.markdown("Utilizamos la covarianza para predecir el comportamiento futuro de una variable en función del comportamiento de otra variable")


#Matrices
ocho, nueve, diez, once, doce, trece, catorce, quince  = st.tabs(["Covarianza Region Norte", "Covarianza Region Noroeste", "Covarianza Region Noreste","Covarianza Region Centro Occidente","Covarianza Region Centro Este","Covarianza Region Oriente","Covarianza Region Sur","Covarianza Yucatán"])

with ocho:
   st.header("Covarianza Region Norte")
   st.image(io.imread("C:/Users/crist/Desktop/8.png"), width=500)

with nueve:
   st.header("Covarianza Region Noroeste")
   st.image(io.imread("C:/Users/crist/Desktop/9.png"), width=500)

with diez:
   st.header("Covarianza Region Noreste")
   st.image(io.imread("C:/Users/crist/Desktop/10.png"), width=500)
   
with once:
   st.header("Covarianza Region Centro Occidente")
   st.image(io.imread("C:/Users/crist/Desktop/11.png"), width=500)

with doce:
   st.header("Covarianza Region Centro Este")
   st.image(io.imread("C:/Users/crist/Desktop/12.png"), width=500)

with trece:
   st.header("Covarianza Region Oriente")
   st.image(io.imread("C:/Users/crist/Desktop/13.png"), width=500)

with catorce:
   st.header("Covarianza Region Sur")
   st.image(io.imread("C:/Users/crist/Desktop/14.png"), width=500)

with quince:
   st.header("Covarianza Yucatán")
   st.image(io.imread("C:/Users/crist/Desktop/15.png"), width=500)     


#Otra cosa
st.header("Gráfica de Tiempo de Respuesta vs. Tiempo de Recepcion vs. Tiempo de Cierre por Region")
st.markdown("Graficamos estas 3 variables por región, para saber si había alguna diferencia significativa en el tiempo de respuesta y el tiempo de cierre entre las regiones")

diez_seis, diez_siete, diez_ocho, diez_nueve, veinte, veinte_uno, veinte_dos, veinte_tres  = st.tabs(["Region Norte", "Region Noroeste", "Region Noreste","Region Centro Occidente","Region Centro Este","Region Oriente","Region Sur","Yucatán"])

with diez_seis:
   st.header("Region Norte")
   st.image(io.imread("C:/Users/crist/Desktop/16.png"), width=500)

with diez_siete:
   st.header("Region Noroeste")
   st.image(io.imread("C:/Users/crist/Desktop/17.png"), width=500)

with diez_ocho:
   st.header("Region Noreste")
   st.image(io.imread("C:/Users/crist/Desktop/18.png"), width=500)
   
with diez_nueve:
   st.header("Region Centro Occidente")
   st.image(io.imread("C:/Users/crist/Desktop/19.png"), width=500)

with veinte:
   st.header("Region Centro Este")
   st.image(io.imread("C:/Users/crist/Desktop/20.png"), width=500)

with veinte_uno:
   st.header("Region Oriente")
   st.image(io.imread("C:/Users/crist/Desktop/21.png"), width=500)

with veinte_dos:
   st.header("Region Sur")
   st.image(io.imread("C:/Users/crist/Desktop/22.png"), width=500)

with veinte_tres:
   st.header("Yucatán")
   st.image(io.imread("C:/Users/crist/Desktop/23.png"), width=500)
   
#Correlación
st.header("Gráfica de Correlación")
st.markdown("Una matriz de correlación es una herramienta estadística que se utiliza para medir la relación entre dos o más variables. Esto se hace calculando el coeficiente de correlación, que es un número entre -1 y 1 que indica la fuerza y dirección de la relación lineal entre las variables. ")
st.markdown("Un valor cercano a 1 significa una fuerte correlación positiva, mientras que un valor cercano a -1 significa una fuerte correlación negativa. Un valor cercano a 0 significaría poca o ninguna correlación. ")
st.markdown("La matriz de correlaciones muestra los resultados en formato tabular para facilitar su lectura e interpretación.")
a, b, c, d, e, f, g, h  = st.tabs(["Region Norte", "Region Noroeste", "Region Norte","Region Centro Occidente","Region Centro Este","Region Oriente","Region Sur","Yucatán"])

with a:
   st.header("Region Norte")
   st.image(io.imread("C:/Users/crist/Desktop/24.png"), width=500)

with b:
   st.header("Region Noroeste")
   st.image(io.imread("C:/Users/crist/Desktop/25.png"), width=500)

with c:
   st.header("Region Noreste")
   st.image(io.imread("C:/Users/crist/Desktop/26.png"), width=500)
   
with d:
   st.header("Region Centro Occidente")
   st.image(io.imread("C:/Users/crist/Desktop/27.png"), width=500)

with e:
   st.header("Region Centro Este")
   st.image(io.imread("C:/Users/crist/Desktop/28.png"), width=500)

with f:
   st.header("Region Oriente")
   st.image(io.imread("C:/Users/crist/Desktop/29.png"), width=500)

with g:
   st.header("Region Sur")
   st.image(io.imread("C:/Users/crist/Desktop/30.png"), width=500)

with h:
   st.header("Yucatán")
   st.image(io.imread("C:/Users/crist/Desktop/31.png"), width=500)

#Nivel
st.header("Nivel de Significancía")
st.markdown("Un nivel de significancia es un umbral estadístico utilizado para determinar si los resultados obtenidos en un experimento son lo suficientemente fuertes como para rechazar la hipótesis nula. ")
st.markdown("El nivel de significancia se expresa como un porcentaje, generalmente entre 0 y 1, que indica el grado de confianza con el que se pueden interpretar los resultados. ")
st.markdown("Si el valor del nivel de significancia es bajo (por ejemplo, menor o igual a 0,05), entonces hay evidencia suficiente para rechazar la hipótesis nula y afirmar que existen diferencias reales entre las variables observadas.")
aa, bb, cc, dd, ee, ff, gg, hh  = st.tabs(["Region Norte", "Region Noroeste", "Region Noreste","Region Centro Occidente","Region Centro Este","Region Oriente","Region Sur","Yucatán"])

with aa:
   st.header("Region Norte")
   st.image(io.imread("C:/Users/crist/Desktop/32.png"), width=500)

with bb:
   st.header("Region Noroeste")
   st.image(io.imread("C:/Users/crist/Desktop/33.png"), width=500)

with cc:
   st.header("Region Noreste")
   st.image(io.imread("C:/Users/crist/Desktop/34.png"), width=500)
   
with dd:
   st.header("Region Centro Occidente")
   st.image(io.imread("C:/Users/crist/Desktop/35.png"), width=500)

with ee:
   st.header("Region Centro Este")
   st.image(io.imread("C:/Users/crist/Desktop/36.png"), width=500)

with ff:
   st.header("Region Oriente")
   st.image(io.imread("C:/Users/crist/Desktop/37.png"), width=500)

with gg:
   st.header("Region Sur")
   st.image(io.imread("C:/Users/crist/Desktop/38.png"), width=500)

with hh:
   st.header("Yucatán")
   st.image(io.imread("C:/Users/crist/Desktop/39.png"), width=500)
   

#Random
st.header("Random Forest")
st.markdown("Un random forest es un algoritmo de aprendizaje automático supervisado que se utiliza para la clasificación y regresión.")
st.markdown("Está compuesto por muchos árboles de decisión, cada uno con sus propias características y parámetros. Los resultados finales se obtienen a partir del promedio o la votación entre los diferentes árboles. ")
st.markdown(" El objetivo principal de este algoritmo es reducir el sobreajuste (overfitting) producido por los árboles individuales, mejorando así su precisión general en problemas de clasificación y regresión.")
aaa, bbb, ccc, ddd, eee, fff, ggg, hhh  = st.tabs(["Region Norte", "Region Noreste", "Region Noroeste","Region Oriente","Region Centro Este","Region Occidente","Region Sur","Yucatán"])

with aaa:
   st.header("Region Norte")
   st.image(io.imread("C:/Users/crist/Desktop/40.png"), width=500)

with bbb:
   st.header("Region Noreste")
   st.image(io.imread("C:/Users/crist/Desktop/41.png"), width=500)

with ccc:
   st.header("Region Noroeste")
   st.image(io.imread("C:/Users/crist/Desktop/42.png"), width=500)
   
with ddd:
   st.header("Region Oriente")
   st.image(io.imread("C:/Users/crist/Desktop/43.png"), width=500)

with eee:
   st.header("Region Centro Este")
   st.image(io.imread("C:/Users/crist/Desktop/44.png"), width=500)

with fff:
   st.header("Region Occidente")
   st.image(io.imread("C:/Users/crist/Desktop/45.png"), width=500)

with ggg:
   st.header("Region Sur")
   st.image(io.imread("C:/Users/crist/Desktop/46.png"), width=500)

with hhh:
   st.header("Yucatán")
   st.image(io.imread("C:/Users/crist/Desktop/47.png"), width=500)

#Modelo 2 
st.title("Modelo 2")
#Random
st.header("Análisis de los Datos")
st.markdown("Un Análisis de los Datos es un proceso para examinar datos con el fin de extraer información útil.")
st.markdown("El análisis se realiza mediante la aplicación de técnicas estadísticas, algoritmos y herramientas visuales para descubrir patrones, tendencias y relaciones entre variables en los datos. ")
st.markdown("Esta información puede luego ser utilizada por las empresas para tomar decisiones mejor informadas o hacer predicciones sobre el comportamiento futuro.")
aaaa, bbbb, cccc   = st.tabs(["Técnicos que realizaron más servicios", "Estados en donde se realizaron más servicios", "Modelos en donde se realizaron más servicios"])

with aaaa:
   st.header("Técnicos que realizaron más servicios")
   st.image(io.imread("C:/Users/crist/Desktop/48.png"), width=500)

with bbbb:
   st.header("Estados en donde se realizaron más servicios")
   st.image(io.imread("C:/Users/crist/Desktop/49.png"), width=500)

with cccc:
   st.header("Modelos en donde se realizaron más servicios")
   st.image(io.imread("C:/Users/crist/Desktop/50.png"), width=500)
   
#Random
st.header("Selección de Clusters")
st.markdown("Una selección de clusters es un proceso en el que los datos se agrupan en grupos basados ​​en características similares.")
st.markdown("Esta técnica de aprendizaje automático no supervisado permite a los científicos de datos identificar patrones y relaciones ocultas entre variables, descubrir estructuras complejas y encontrar subgrupos dentro de un conjunto de datos.")
st.markdown("Los resultados pueden ser útiles para la segmentación del mercado, la minería de texto, el análisis predictivo y muchas otras aplicaciones.")
aaaaa, bbbbb, ccccc   = st.tabs(["Gráfico del Codo", "Mediana los Clusters", "Máximos y Mínimos Medianas Clusters"])

with aaaaa:
   st.header("Gráfico del Codo")
   st.markdown("Un gráfico del codo es una herramienta de análisis para encontrar el número óptimo de clusters en un conjunto de datos.")
   st.markdown("Esta técnica se basa en la representación visual de los errores cuadráticos medios (ECM) obtenidos al aplicar diferentes valores k a un conjunto de datos. ")
   st.image(io.imread("C:/Users/crist/Desktop/51.png"), width=500)

with bbbbb:
   st.header("Mediana los Clusters")
   st.markdown("La mediana de los clusters es una herramienta estadística que se utiliza para determinar la distribución central de un conjunto de datos agrupados en clusters. ")
   st.markdown("Esto significa que, dado un conjunto de datos dividido en grupos o clústeres, la mediana del cluster se refiere a la media aritmética entre el valor más alto y el más bajo dentro del mismo grupo. ")
   st.image(io.imread("C:/Users/crist/Desktop/52.png"), width=500)

with ccccc:
   st.header("Máximos y Mínimos Medianas Clusters")
   st.markdown("Los máximos y mínimos de las medianas de los clusters son los valores extremos (más alto y más bajo) que se encuentran en el conjunto de datos. ")
   st.markdown("Esto puede ser útil para identificar patrones o tendencias dentro del conjunto de datos.")
   st.image(io.imread("C:/Users/crist/Desktop/53.png"), width=500)
   
#Random 1
st.header("Apliación de Clusters")
aaaaaa, bbbbbb, cccccc, dddddd   = st.tabs(["Técnicos con más observaciones en cada cluster", "Estados con más observaciones en cada cluster", "Conteo por tipo de servicio en cada cluster","Modelos con más observaciones en cada cluster"])

with aaaaaa:
   st.header("Técnicos con más observaciones en cada cluster")
   st.image(io.imread("C:/Users/crist/Desktop/54.png"), width=500)

with bbbbbb:
   st.header("Estados con más observaciones en cada cluster")
   st.image(io.imread("C:/Users/crist/Desktop/55.png"), width=500)

with cccccc:
   st.header("Conteo por tipo de servicio en cada cluster")
   
   st.image(io.imread("C:/Users/crist/Desktop/56.png"), width=500)
   
with dddddd:
   st.header("Modelos con más observaciones en cada cluster")
  
   st.image(io.imread("C:/Users/crist/Desktop/57.png"), width=500)
   
#Random 1
st.header("Resultados de Clusters")
aaaaaaaa, bbbbbbbb, cccccccc, dddddddd   = st.tabs(["Técnicos, estados y modelos con más observaciones del cluster 1", "Técnicos, estados y modelos con más observaciones del cluster 2", "Técnicos, estados y modelos con más observaciones del cluster 3","Técnicos, estados y modelos con más observaciones del cluster 4"])

with aaaaaaaa:
   st.header("Técnicos, estados y modelos con más observaciones del cluster 1")
   st.markdown("El cluster 1 es el que tiene más observaciones, con un total de 66,448. Observando los promedios y las medianas del cluster, se puede concluir que el cluster 1 es el más rápido, con un promedio de visitas de 1, tiempo promedio en sitio de 0.83 horas, tiempo de solución total de 3.27 horas, tiempo de solución Pitss de 2.02 horas y una respuesta de técnico de 0.88 horas. Así mismo, es el cluster que tiene mas servicios de tipo “preventivo” y el estado predominante es Jalisco.")
   st.image(io.imread("C:/Users/crist/Desktop/58.png"), width=500)

with bbbbbbbb:
   st.header("Técnicos, estados y modelos con más observaciones del cluster 2")
   st.markdown("El cluster 2 es el segundo con más observaciones, con un total de 23,939. Observando los promedios y las medianas del cluster, se puede concluir que el cluster 2 es el segundo más rápido, con un promedio de visitas de 2, tiempo promedio en sitio de 2.15 horas, tiempo de solución total de 29.83 horas, tiempo de solución pits de 6.97 horas y una respuesta de técnico de 1.5 horas. Así mismo, es el cluster que tiene más servicios de tipo “correctivo” y el estado predominante es Jalisco")
   st.image(io.imread("C:/Users/crist/Desktop/59.png"), width=500)

with cccccccc:
   st.header("Técnicos, estados y modelos con más observaciones del cluster 3")
   st.markdown("El cluster 3 es el tercero con más observaciones, con un total de 2,383. Observando los promedios y las medianas del cluster, se puede concluir que el cluster 3 es el más lento, con un promedio de visitas de 3, tiempo promedio en sitio de 5.2 horas, tiempo de solución total de 186.97 horas, tiempo de solución pits de 41.93 horas y una respuesta de técnico de 1.86 horas. Así mismo, es el segundo cluster que tiene más servicios de tipo “servicio a terceros” y el estado predominante es Jalisco")
   st.image(io.imread("C:/Users/crist/Desktop/60.png"), width=500)
   
with dddddddd:
   st.header("Técnicos, estados y modelos con más observaciones del cluster 4")
   st.markdown("El cluster 4 es el que tiene menos observaciones, con un total de 853. Observando los promedios y las medianas del cluster, se puede concluir que el cluster 4 es el más lento, tiene un promedio de respuesta de técnico más alta y la mayoría de los servicios son a terceros (a diferencia de los otros clusters con mayoría de servicios correctivos). Tiene un promedio de visitas de 1, tiempo promedio en sitio de 1.08 horas, tiempo de solución total de 29.85 horas y un tiempo de solución pits de 25.9 horas. ")
   st.image(io.imread("C:/Users/crist/Desktop/61.png"), width=500)




