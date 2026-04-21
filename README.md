# 🗄️ Carga, Modelado y Limpieza de Datos – Classic Models

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Modelado Dimensional](https://img.shields.io/badge/Modelado%20Dimensional-FF6B35?style=for-the-badge&logo=databricks&logoColor=white)

---

## 💡 Resultados del proyecto

| Métrica | Resultado |
|---|---|
| Tablas modeladas y limpiadas | ✅ 5 tablas |
| Fechas estandarizadas | ✅ 100% en formato ISO |
| Categorías traducidas al español | ✅ 100% |
| Separación de nombres compuestos | ✅ 2 campos independientes |
| Consolidación de direcciones | ✅ De 2 columnas a 1 con manejo de nulos |
| Estado final | ✅ Base lista para análisis de ventas, clientes e inventario |

---

## 🏢 Contexto del negocio

Classic Models es una empresa que comercializa réplicas en miniatura de distintos vehículos. El proyecto trabaja con su base de datos operacional, preparando la información para garantizar correcta estructura, consistencia y disponibilidad para análisis.

---

## 🎯 Objetivo

Estructurar la base de datos siguiendo un **modelo dimensional (estrella/copo de nieve)**, definiendo:

- 3 tablas dimensionales: `dim_productos`, `dim_clientes`, `dim_detalle_pedidos`
- 2 tablas de hechos: `fac_pagos`, `fac_pedidos`
- Relaciones mediante claves primarias y foráneas
- Tipos de datos optimizados (`VARCHAR`, `INT`, `DECIMAL`, `DATE`, `DATETIME`, `TEXT`)
- Nomenclatura en español para facilitar el análisis del negocio

---

## 📁 Estructura del dataset

| Tabla original | Tabla resultante | Tipo | Descripción |
|---|---|---|---|
| `products` | `dim_productos` | Dimensión | Catálogo de vehículos en miniatura |
| `customers` | `dim_clientes` | Dimensión | Información de clientes corporativos |
| `orderdetails` | `dim_detalle_pedidos` | Dimensión | Detalle de productos por pedido |
| `payments` | `fac_pagos` | Hecho | Registros de pagos realizados |
| `orders` | `fac_pedidos` | Hecho | Pedidos realizados por clientes |

### Relaciones implementadas
- `dim_clientes → fac_pagos` (1:N) — Un cliente puede realizar múltiples pagos
- `dim_clientes → fac_pedidos` (1:N) — Un cliente puede realizar múltiples pedidos
- `fac_pedidos → dim_detalle_pedidos` (1:N) — Un pedido contiene múltiples líneas de detalle
- `dim_productos → dim_detalle_pedidos` (1:N) — Un producto puede aparecer en múltiples detalles

---

## 🔧 Transformaciones principales

### Estandarización de nomenclatura
- Traducción de tablas y columnas al español
- Renombramiento de líneas de producto (`Vintage Cars` → `Coches Vintage`)
- Traducción de estados de pedidos (`Shipped` → `Enviado`)

### Limpieza de datos
- Conversión de fechas de string a formato `DATE`/`DATETIME` con `STR_TO_DATE()`
- Separación de nombres y apellidos con `SUBSTR()` e `INSTR()`
- Consolidación de direcciones con `CONCAT()` y manejo de nulos con `COALESCE()`
- Eliminación de espacios con `RTRIM()`

### Modelado dimensional
- Creación de tablas dimensionales y de hechos
- Integridad referencial con constraints de claves primarias y foráneas
- Clave primaria autoincremental para `dim_detalle_pedidos`

---

## ⚙️ Tecnología utilizada

**SGBD:** MySQL

**Técnicas aplicadas:**
```
├── Funciones de string (SUBSTR, INSTR, CONCAT, RTRIM, COALESCE)
├── Funciones de fecha (STR_TO_DATE)
├── Sentencias CASE para transformación de valores
├── LEFT JOIN para relaciones entre tablas
└── Constraints (PRIMARY KEY, AUTO_INCREMENT, FOREIGN KEY)
```

---

## 📈 Análisis posibles con esta base de datos

- Análisis de ventas por línea de producto
- Seguimiento de estados de pedidos y tiempos de entrega
- Análisis de comportamiento de pago por cliente
- Gestión de inventario y stock
- Análisis geográfico de clientes
- Evaluación de límites de crédito

---

## 🔗 Acceso al proyecto

👉 [Ver código SQL completo en Google Drive](https://drive.google.com/file/d/1sEeALqKlUdaNM1xZvX8mB7Ah5YfaYlPo/view?usp=sharing)

---

## 👩‍💻 Autora

**María Sofía Nolazco** — Ingeniera Civil | Analista de Datos  
[LinkedIn](https://www.linkedin.com/in/mariasofia-nolazco-4a69a0134) · [Portfolio](https://sofianolazco.github.io/)
