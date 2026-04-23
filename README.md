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
| Integridad referencial | ✅ 4 Foreign Keys implementadas con ON DELETE / ON UPDATE |
| Estado final | ✅ Base lista para análisis de ventas, clientes e inventario |

---

## 🏢 Contexto del negocio

Classic Models es una empresa que comercializa réplicas en miniatura de distintos vehículos. El proyecto trabaja con su base de datos operacional (`raw_classicmodels`), transformándola en un modelo dimensional limpio, estructurado y listo para análisis.

---

## 🎯 Objetivo

Construir un **modelo dimensional tipo estrella** desde cero sobre los datos crudos, definiendo tablas dimensionales y de hechos con relaciones, tipos de datos optimizados y nomenclatura en español.

---

## 📁 Estructura del modelo

| Tabla original | Tabla resultante | Tipo | Descripción |
|---|---|---|---|
| `products` | `dim_productos` | Dimensión | Catálogo de vehículos en miniatura |
| `customers` | `dim_clientes` | Dimensión | Información de clientes corporativos |
| `orderdetails` | `dim_detalle_pedidos` | Dimensión | Detalle de productos por pedido |
| `payments` | `fac_pagos` | Hecho | Registros de pagos realizados |
| `orders` | `fac_pedidos` | Hecho | Pedidos realizados por clientes |

### Relaciones implementadas

- `dim_clientes → fac_pagos` — FK con `ON DELETE RESTRICT` / `ON UPDATE CASCADE`
- `dim_clientes → fac_pedidos` — FK con `ON DELETE RESTRICT` / `ON UPDATE CASCADE`
- `fac_pedidos → dim_detalle_pedidos` — FK con `ON DELETE CASCADE` / `ON UPDATE CASCADE`
- `dim_productos → dim_detalle_pedidos` — FK con `ON DELETE RESTRICT` / `ON UPDATE CASCADE`

---

## 🔧 Transformaciones principales

### dim_productos
- Traducción de líneas de producto con `CASE` (`Classic Cars` → `Coches Clasicos`, etc.)
- Tipos de datos optimizados: `VARCHAR`, `TEXT`, `INT`, `DECIMAL(15,2)`
- `productCode` como `PRIMARY KEY`

### dim_clientes
- Separación de nombre y apellido del contacto con `SUBSTR()` + `INSTR()` sobre el campo `lastNameFirstName`
- Consolidación de `addressLine1` y `addressLine2` con `CONCAT()` + `COALESCE()` para manejo de nulos
- `customerNumber` como `PRIMARY KEY`

### fac_pagos
- Conversión de fechas de `VARCHAR` a `DATETIME` con `STR_TO_DATE(SUBSTR(paymentDate, 1, 17), "%Y%m%d %H:%i:%s")`
- Manejo del caso especial con dos timestamps en un mismo campo
- Clave primaria compuesta `(pk_pago, id_cliente)`
- `id_cliente` obtenido mediante `LEFT JOIN` con `dim_clientes`

### fac_pedidos
- Conversión de tres columnas de fecha (`orderdate`, `requireddate`, `shippedDate`) con `STR_TO_DATE()`
- Traducción de estados con `CASE` (`Shipped` → `Entregado`, `On Hold` → `En Espera`, etc.)
- FK hacia `dim_clientes` con `ON DELETE RESTRICT` / `ON UPDATE CASCADE`

### dim_detalle_pedidos
- Clave primaria autoincremental `pk_id INT AUTO_INCREMENT` (la tabla original no tenía PK natural)
- FKs hacia `fac_pedidos` y `dim_productos`
- `INSERT INTO` especificando columnas por separado del campo autoincremental

---

## ⚙️ Tecnología utilizada

**SGBD:** MySQL Workbench

**Funciones y técnicas aplicadas:**
```sql
-- Exploración
DESCRIBE tabla;
SELECT MAX(LENGTH(columna)) AS max_caracteres FROM tabla;
SELECT COUNT(*), COUNT(DISTINCT columna) FROM tabla;

-- Transformación
CASE WHEN ... THEN ... ELSE ... END
STR_TO_DATE(SUBSTR(campo, 1, 17), "%Y%m%d %H:%i:%s")
SUBSTR(lastNameFirstName, INSTR(lastNameFirstName, ',')+1, 99)
CONCAT(addressLine1, '', COALESCE(addressLine2, ''))

-- Modelado
PRIMARY KEY, AUTO_INCREMENT
FOREIGN KEY ... REFERENCES ... ON DELETE ... ON UPDATE
LEFT JOIN
ENGINE=InnoDB
```

---

## 📈 Análisis posibles con esta base

- Ventas por línea de producto y período
- Seguimiento de estados de pedidos y tiempos de entrega
- Comportamiento de pagos por cliente
- Gestión de inventario y stock
- Análisis geográfico de clientes
- Evaluación de límites de crédito

---

## 🔗 Acceso al proyecto

👉 [Ver código SQL completo](./proyecto_classic_models.sql)

---

## 👩‍💻 Autora

**María Sofía Nolazco** — Ingeniera Civil | Analista de Datos  
[LinkedIn](https://www.linkedin.com/in/maria-sofia-nolazco-4a69a0134) · [Portfolio](https://sofianolazco.github.io/)
