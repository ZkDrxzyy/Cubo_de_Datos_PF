# Cubo OLAP de Ventas con Pentaho y Neon (PostgreSQL) 
---
## 📌 Descripción del proyecto 

Este repositorio contiene el proyecto final de Bases de Datos, cuyo objetivo es el diseño, implementación y explotación de un Cubo de Datos (OLAP) utilizando la suite Pentaho Schema Workbench como herramienta de Business Intelligence y Neon (PostgreSQL Serverless) como sistema gestor de base de datos en la nube. 

El proyecto permite analizar información de ventas desde una perspectiva multidimensional, facilitando consultas analíticas como totales por categoría, región, país y rankings de productos mediante MDX. 

---

## 📚 Estructura del repositorio 
```bash
├── sql/ 
│   └── base.sql 
├── schema/ 
│   └── ventas.xml 
├── docs/ 
│   └── Documentacion_Pentaho_Neon.pdf 
└── README.md 
```

---
## 🧠 Arquitectura general 

La solución sigue una arquitectura clásica de Business Intelligence: 

* Base de datos: Neon (PostgreSQL Serverless) 
* Modelo de datos: Data warehouse 
* Motor OLAP: Pentaho (Mondrian) 
* Diseño del cubo: Pentaho Schema Workbench 
* Lenguaje de consulta: MDX (MultiDimensional eXpressions) 

---
## 🗂️ Modelo de Datos 

#### *Data warehouse*

El modelo fue diseñado para optimizar el rendimiento de consultas analíticas. 

#### *Tabla de Hechos: fact_ventas*

‣ Claves foráneas: 

* producto_id 
* pais_id 

‣ Métricas: 

* cantidad (INT) 
* total_dinero (DECIMAL(10,2)) 

‣ Atributo degenerado: 

* fecha 

#### *Tablas de Dimensión* 

‣ dim_producto 

* id (PK) 
* categoria 
* nombre 

‣ dim_pais 

* id (PK) 
* region 
* pais 

---
## 🛠️ Tecnologías utilizadas 

* PostgreSQL 15+ (Neon) 
* Pentaho Schema Workbench 
* Pentaho BI Server 
* JDBC Driver PostgreSQL (42.x.x): Es necesario para conectar la base que está en la nube con nuestro sistema local 
* MDX 
* SQL estándar

---
## 🎬 Video de Muestra

En este video se muestra como hacer compatible la descarga de las versiones para poder hacer un cubo de datos alojado en neonDB.

*  **Link:** https://www.youtube.com/watch?v=6N6mTo5cp7g

---
## ⚙️ Instalación y configuración 

**1️⃣ Requisitos previos**

* Cuenta activa en Neon 
* Java JDK 8 
* Pentaho Schema Workbench 
* Git 

**2️⃣ Clonar el repositorio**
~~~
git clone https://github.com/ZkDrxzyy/Cubo_de_Datos_PF.git 
~~~
~~~
cd Cubo_de_Datos_PF
~~~

**3️⃣ Configuración de la base de datos (Neon)**

1. Crear un proyecto en Neon.

2. Obtener el endpoint de conexión.

3. Ejecutar el script SQL ubicado en:

~~~
/sql/database.sql 
~~~

Este script crea las tablas de hechos y dimensiones usando tipos de datos compatibles con Pentaho. 

**4️⃣ Configuración del Driver JDBC** 

Pentaho no incluye por defecto el driver de PostgreSQL moderno. 

1. Descargar postgresql-42.x.x.jar. 
2. Copiar el archivo en dentro de la careta de pentaho schema workbench: 
~~~
• schema-workbench/drivers/
~~~
~~~
• pentaho-server/tomcat/lib/
~~~

**5️⃣ Conexión con Neon**

Para poder conectarnos a la base de datos, necesitamos hacer la conexión desde pentaho schema workbench, entramos en el menú superior options –> connection y nos desplegara un menú, buscaremos dentro de la lista de connection type: PostgresSQL y en la ista de Access:Native (JDBC). 

Rellenamos el resto con nuestras credenciales que nos proporciona Neon. 

**6️⃣ Conexión segura (SSL)**

Neon requiere conexiones SSL así que dentro del menú de connection busca el apartado Options, y en Parameter ingresa sslmode, a la derecha encontraras el apartado de Value en donde deberás ingresar require. 

Con todo lo anterior realizado probamos la conexión con el botón test que se encuentra abajo del menú, si es correcta podemos aceptar la configuración y seguir con el siguiente paso. 

<div align="center">
<img width="617" height="913" alt="1" src="https://github.com/user-attachments/assets/88d81a6d-f1ad-40fb-bda5-30936f448c76" />
</div>

---
## 🧩 Diseño del Cubo OLAP 

El cubo fue diseñado en Pentaho Schema Workbench mediante un esquema XML. 

#### *Cubo: Ventas*

* Tabla base: fact_ventas 

#### *Métricas*

* Cantidad → SUM(cantidad) 
* Ventas Totales → SUM(total_dinero) 

#### *Dimensiones*

Producto 
* Jerarquía: Categoría → Nombre 
* FK: producto_id

Geografía 
* Jerarquía: Región → País 
* FK: pais_id 

⚠️ Nota: La dimensión Tiempo fue omitida para evitar conflictos iniciales entre Mondrian y PostgreSQL. 

<div align="center">
<img width="617" height="913" alt="1" src="https://github.com/user-attachments/assets/9a581f98-a0ca-4689-97d3-67421bb13210" />
</div>

---
## 📊 Consultas MDX implementadas 

**🔹 Ventas por categoría**

Muestra la cantidad total vendida por categoría de producto. 

~~~
SELECT 
  {[Measures].[Cantidad]} ON COLUMNS, 
  {[Producto].[Categoria].Members} ON ROWS 
FROM [Ventas] 
~~~

**🔹 Matriz cruzada Categoría × Región**

Analiza el desempeño de ventas por región y tipo de producto. 

~~~
SELECT 
  {[Measures].[Cantidad]} ON COLUMNS, 
  {[Geografia].[Pais].Members} ON ROWS 
FROM [Ventas]
~~~

**🔹 Drill-down por país**

Permite navegar desde regiones generales hasta países específicos. 

~~~
SELECT 
  {[Geografia].[Region].Members} ON COLUMNS, 
  {[Producto].[Categoria].Members} ON ROWS 
FROM [Ventas] 
WHERE ([Measures].[Cantidad]) 
~~~

**🔹 Top 3 productos más vendidos**

Ranking de productos según la cantidad vendida. 

~~~
SELECT 
  {[Measures].[Cantidad]} ON COLUMNS, 
  TopCount({[Producto].[Nombre].Members}, 3, [Measures].[Cantidad]) ON ROWS 
FROM [Ventas] 
~~~

<div align="center">
<img width="617" height="913" alt="1" src="https://github.com/user-attachments/assets/bc1f07a6-e888-4204-983d-cdf13722480e" />
</div>

---
## ▶️ Ejecución y uso 

1. Guardar el cubo anteriormente realizado. 
2. Acceder al menú suprior File –> MDX QUERRY. 
3. Ingresamos nuestra consulta MDX y presionamos el botón Execute. 
4. Visualizamos nuestros datos de la consulta MDX. 

---

## 📖 Documentación adicional 

La documentación técnica completa se encuentra en: 
~~~
/docs/Documentacion_Pentaho_Neon.pdf 
~~~

Incluye detalles de arquitectura, diseño del cubo y ejemplos de consultas MDX. 

---
## 📊 OPERACIONES EN CUBOS DE DATOS (OLAP) 

**1. Slice (Corte)**

La operación Slice consiste en seleccionar un único valor de una dimensión específica, lo que reduce el cubo a una “rebanada” del mismo. 

🔹 Características: 

	•	Fija una dimensión en un valor. 

	•	Reduce la dimensionalidad del cubo. 

	•	Facilita el análisis enfocado en un solo escenario. 

🔹 Ejemplo: 

Analizar las ventas correspondientes únicamente al año 2024, sin considerar otros años. 


**2. Dice (Dado)**

Dice permite seleccionar un conjunto de valores en una o más dimensiones, formando un subcubo más pequeño. 

🔹 Características: 

	•	No fija una sola dimensión, sino varias. 

	•	Permite análisis comparativos. 

	•	Es más flexible que slice. 

🔹 Ejemplo: 

Ventas de los productos A y B, en las regiones Norte y Sur, durante los años 2023 y 2024. 


**3. Roll-Up (Agregación)**

La operación Roll-Up resume los datos al subir en la jerarquía de una dimensión, pasando de un nivel detallado a uno más general.  

🔹 Características: 

	•	Reduce el nivel de detalle. 

	•	Utiliza funciones de agregación como suma o promedio. 

	•	Permite ver totales y tendencias generales. 

🔹 Ejemplo: 

Sumar las ventas diarias para obtener las ventas mensuales, o las ventas mensuales para obtener las anuales. 


**4. Drill-Down (Desagregación)**

Drill-Down es la operación contraria a roll-up, ya que permite bajar en la jerarquía y observar datos más detallados. 

🔹 Características: 

	•	Incrementa el nivel de detalle. 

	•	Permite análisis profundo. 

	•	Ayuda a identificar causas específicas. 

🔹 Ejemplo: 

Pasar de ventas anuales a ventas mensuales o incluso diarias.


**5. Drill-Across**

Drill-Across permite analizar y comparar medidas provenientes de diferentes cubos OLAP, siempre que compartan dimensiones comunes. 

🔹 Características: 

	•	Comparación entre cubos. 

	•	Mantiene las mismas dimensiones. 

	•	Útil para análisis financieros. 

🔹 Ejemplo: 

Comparar ventas (cubo de ventas) contra costos (cubo de costos) por producto y tiempo. 


**6. Drill-Through**

La operación Drill-Through permite acceder desde un dato agregado del cubo hasta los datos detallados originales almacenados en la base de datos relacional. 

🔹 Características: 

	•	Acceso al nivel más bajo de datos. 

	•	Útil para auditorías y validaciones. 

	•	Conecta OLAP con bases relacionales. 

🔹 Ejemplo: 

Desde el total de ventas de un mes, consultar las facturas individuales que lo componen. 


**7. Pivot (Rotación)** 

Pivot o rotación cambia la orientación de las dimensiones, permitiendo observar los datos desde otra perspectiva. 

🔹 Características: 

	•	No modifica los datos. 

	•	Solo cambia la presentación. 

	•	Mejora la interpretación visual. 

🔹 Ejemplo: 

Mostrar regiones en filas y productos en columnas, y luego intercambiarlos. 


**8. Slice and Dice**

Es una combinación de las operaciones Slice y Dice, utilizada para realizar análisis más específicos y detallados. 

🔹 Características: 

	•	Aplica múltiples filtros. 

	•	Genera vistas altamente personalizadas. 

	•	Muy usada en reportes ejecutivos. 

🔹 Ejemplo: 

Ventas del año 2024 para los productos A y B en la región Norte. 


**9. Ranking (Clasificación)**

Ranking ordena los elementos de una dimensión con base en una medida específica, de mayor a menor o viceversa. 

🔹 Características: 

	•	Permite identificar líderes y rezagos. 

	•	Facilita comparaciones. 

	•	Útil para toma de decisiones. 

🔹 Ejemplo: 

Clasificar productos según el monto total de ventas. 


**10. Filtering (Filtrado)**

La operación de Filtering elimina los datos que no cumplen con ciertas condiciones establecidas. 

🔹 Características: 

	•	Reduce ruido en los resultados. 

	•	Mejora la claridad del análisis. 

	•	Se basa en condiciones lógicas. 

🔹 Ejemplo: 

Mostrar solo las regiones con ventas superiores a $100,000. 

---
## 🎓 Conclusiones 

* El esquema estrella simplifica y acelera el análisis de datos. 
* La correcta definición de tipos de datos es clave para evitar errores en Pentaho. 
* El uso de SSL es obligatorio en entornos cloud modernos como Neon. 

---
## 👥 Autores 

Proyecto desarrollado por: 

* Cruz Guzmán Carlos Alberto 
* De La Rosa Hernández Tania 
* Delgadillo Díaz Damián 
* González González Erick Emiliano 
* González Hernández Judith 
* Magaña Fierro Elka Natalia 
* Sánchez Ixmatlahua Kathia Jazmín
* Soto Nieves Uriel 

---
Materia: Bases de Datos 





 
