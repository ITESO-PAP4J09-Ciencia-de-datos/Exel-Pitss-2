import pandas as pd  
import numpy as np
import matplotlib.pyplot as plt
import streamlit as st
import plotly.express as px


st.set_page_config(page_title="Exel Pitss",
                   page_icon=":bar_chart:",
                   layout="wide")
st.title("PAP ITESO")

#Importando Librerias
Data_Pitss = pd.read_csv("C:/Users/crist/Desktop/PAP/Exel Pitss Limpio.csv")
#st.dataframe(Data_Pitss)


st.sidebar.header("Filtros")
city = st.sidebar.multiselect("Selecciona El Estado",
                              options=Data_Pitss["ServiceRouteName"].unique(),
                              default=Data_Pitss["ServiceRouteName"].unique())

tecnico_ejecutor = st.sidebar.multiselect(
    "Selecciones El Tecnico Ejecuto", options=Data_Pitss["tecnicoEjecutor"].unique(),
    default=Data_Pitss["tecnicoEjecutor"].unique())


seleccion = Data_Pitss.query(
    "ServiceRouteName == @city & tecnicoEjecutor == @tecnico_ejecutor")

st.dataframe(seleccion)

#KPIS



#####SOCNAME

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


























































