/* ============================================================
	PROYECTO 4 - SQL (MODELO ESTRELLA CON FOREIGN KEYS)
   ============================================================ */
   
/* ============================================================
	0. LIMPIEZA PREVIA (ORDEN INVERSO POR FK)
   ============================================================ */
-- Eliminar tablas en orden inverso (primero las que tienen FK)
DROP TABLE IF EXISTS classicmodels.dim_detalle_pedidos;
DROP TABLE IF EXISTS classicmodels.fac_pagos;
DROP TABLE IF EXISTS classicmodels.fac_pedidos;
DROP TABLE IF EXISTS classicmodels.dim_clientes;
DROP TABLE IF EXISTS classicmodels.dim_productos;

/* ============================================================
	1. CREACIÓN DEL ESQUEMA
   ============================================================ */
-- Crear un nuevo esquema llamado “classicModels” para almacenar el modelo de datos definitivo
CREATE SCHEMA IF NOT EXISTS classicModels;

/* ============================================================
	2. EXPLORACIÓN DATOS CRUDOS
   ============================================================ */
SELECT *
FROM raw_classicmodels.products;

SELECT *
FROM raw_classicmodels.customers;

SELECT *
FROM raw_classicmodels.payments;

SELECT *
FROM raw_classicmodels.orders;

SELECT *
FROM raw_classicmodels.orderdetails;

/* ============================================================
	3. LIMPIEZA Y MODELADO TABLA DIM_PRODUCTOS
   ============================================================ */
-- Creación de tabla dim_productos en BD limpia 
-- products --> dim_productos (se renombran tabla y columnas en español)
-- productCode --> pk_producto (se establece como clave primaria)
CREATE TABLE classicModels.dim_productos (
	pk_producto VARCHAR(255) PRIMARY KEY,
    nombre_producto VARCHAR(255),
	linea_producto VARCHAR(255),
	escala VARCHAR(255),
    proveedor VARCHAR(255),
    descripcion TEXT,
    cantidad INT,
    imp_compra DECIMAL (15,2),
    imp_venta DECIMAL (15,2)
) ENGINE=InnoDB;

-- Inserción en tabla limpia dim_productos de todos los registros de las columnas 
-- de la tabla cruda pero renombrando los de la columna productLine al español
INSERT INTO classicModels.dim_productos 
	SELECT
		productCode,
		productName,
		CASE
			WHEN productLine = 'Vintage Cars' THEN 'Coches Vintage'
			WHEN productLine = 'Trucks and Buses' THEN 'Camiones y Autobuses'
			WHEN productLine = 'Trains' THEN 'Trenes'
			WHEN productLine = 'Ships' THEN 'Buques'
			WHEN productLine = 'Planes' THEN 'Aviones'
			WHEN productLine = 'Motorcycles' THEN 'Motos'
			WHEN productLine = 'Classic Cars' THEN 'Coches Clasicos'
		ELSE 'Otros'
		END AS productLine_esp,
		productScale,
		productVendor,
		productDescription,
		quantityInStock,
		buyPrice,
		MSRP
	FROM raw_classicmodels.products;
    
/* ============================================================
	4. LIMPIEZA Y MODELADO TABLA DIM_CLIENTES
   ============================================================ */
-- Creación de tabla dim_clientes en BD limpia 
-- customers --> dim_clientes (se renombran tabla y columnas en español)
-- customerNumber --> pk_cliente (se establece como clave primaria)
CREATE TABLE IF NOT EXISTS classicModels.dim_clientes (
	pk_cliente INT PRIMARY KEY,
    nombre_empresa VARCHAR(50),
	nom_contact_emp VARCHAR(50),
	apell_contact_emp VARCHAR(50),
    direccion_emp VARCHAR (100),
    cod_postal VARCHAR(15),
    ciudad VARCHAR (50),
    pais VARCHAR (50),
    cod_representante_int INT,
    imp_limite_cred DECIMAL (15,2)
) ENGINE=InnoDB;

-- Inserción en tabla limpia dim_clientes de todos los registros de las columnas
-- de la tabla cruda pero separando el nombre del contacto del cliente en 
-- dos columnas diferentes y juntando los campos de dirección en uno solo
INSERT INTO classicmodels.dim_clientes
	SELECT
		customerNumber,
		customerName,
		SUBSTR(lastNameFirstName,INSTR (lastNameFirstName,',')+1,99) AS nombre,
		SUBSTR(lastNameFirstName,1,INSTR (lastNameFirstName,',')-1) AS apellido,
		CONCAT(addressLine1,'', COALESCE(addressLine2,'')) AS direccion,
		postalCode,
		city,
		country,
		salesRepEmployeeNumber,
		creditLimit
	FROM raw_classicmodels.customers;

/* ============================================================
	5. LIMPIEZA Y MODELADO TABLA FAC_PEDIDOS
   ============================================================ */
-- Creación de tabla fac_pedidos en BD limpia 
-- orders --> fac_pedidos (se renombran tabla y columnas en español)
-- ordernumber --> pk_pedido (se establece como clave primaria)
-- Se establece Foreign Key hacia dim_clientes
CREATE TABLE IF NOT EXISTS classicmodels.fac_pedidos(
	pk_pedido INT PRIMARY KEY,
    id_cliente INT,
    fecha_pedido DATE,
    fecha_entrega DATE,
    fecha_envio DATE,
    estado VARCHAR(255),
    comentarios TEXT,
    CONSTRAINT fk_pedidos_clientes FOREIGN KEY (id_cliente) 
		REFERENCES dim_clientes(pk_cliente)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Inserción en tabla limpia fac_pedidos de todos los registros de las columnas
-- de la tabla cruda pero limpiando las columnas orderdate, requireddate y
-- shippedDate y renombrando los registros de la columna status al español
INSERT INTO classicmodels.fac_pedidos
	SELECT
		ordernumber AS pk_pedido,
        customernumber AS id_cliente,
		STR_TO_DATE(orderdate, "%Y%m%d") AS fecha_pedido,
		STR_TO_DATE(requireddate, "%Y%m%d") AS fecha_entrega,
		STR_TO_DATE(shippedDate, "%Y%m%d") AS fecha_envio,
		CASE
			WHEN status = 'Shipped' THEN 'Entregado'
			WHEN status = 'Resolved' THEN 'Resuelto'
			WHEN status = 'Cancelled' THEN 'Cancelado'
			WHEN status = 'On Hold' THEN 'En Espera'
			WHEN status = 'Disputed' THEN 'En Disputa'
			WHEN status = 'In Process' THEN 'En Proceso'
		ELSE 'Otros'
		END AS estado,
		comments AS comentarios
	FROM raw_classicmodels.orders;

/* ============================================================
	6. LIMPIEZA Y MODELADO TABLA FAC_PAGOS
   ============================================================ */
-- Creación de tabla fac_pagos en BD limpia 
-- payments --> fac_pagos (se renombran tabla y columnas en español)
-- checkNumber --> pk_pago (se establece como clave primaria compuesta)
-- Se establece Foreign Key hacia dim_clientes
CREATE TABLE IF NOT EXISTS classicmodels.fac_pagos (
	pk_pago VARCHAR(255),
	id_cliente INT,
	fecha_pago DATETIME,
	importe_pago DECIMAL(15,2),
	PRIMARY KEY (pk_pago, id_cliente),
	CONSTRAINT fk_pagos_clientes FOREIGN KEY (id_cliente) 
		REFERENCES dim_clientes(pk_cliente)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Inserción en tabla limpia fac_pagos de todos los registros de las columnas
-- de la tabla cruda pero limpiando la columna paymentDate
INSERT INTO classicmodels.fac_pagos
	SELECT
		p.checkNumber AS pk_pago,
		c.pk_cliente AS id_cliente,
		STR_TO_DATE(SUBSTR(paymentDate, 1, 17), "%Y%m%d %H:%i:%s") AS fecha_pago,
		p.amount AS importe_pago
	FROM raw_classicmodels.payments p
	LEFT JOIN classicmodels.dim_clientes c ON p.customerName = c.nombre_empresa;

/* ============================================================
	7. LIMPIEZA Y MODELADO TABLA DIM_ORDERDETAILS	
   ============================================================ */
-- Creación de tabla dim_detalle_pedidos en BD limpia 
-- orderdetails --> dim_detalle_pedidos (se renombran tabla y columnas en español)
-- pk_id --> clave primaria autoincremental
-- Se establecen Foreign Keys hacia fac_pedidos y dim_productos
CREATE TABLE IF NOT EXISTS classicmodels.dim_detalle_pedidos (
	pk_id INT PRIMARY KEY AUTO_INCREMENT,
	id_pedido INT,
    codigo_producto VARCHAR(255),
    cantidad_ordenada INT,
    precio_unitario DECIMAL(10,2),
    nro_linea_orden INT,
	CONSTRAINT fk_detalle_pedidos FOREIGN KEY (id_pedido) 
		REFERENCES fac_pedidos(pk_pedido)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fk_detalle_productos FOREIGN KEY (codigo_producto) 
		REFERENCES dim_productos(pk_producto)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Inserción en tabla limpia dim_detalle_pedidos de todos los registros de las columnas
-- de la tabla cruda, teniendo en cuenta que se creó una nueva columna como PK 
-- autoincremental nombrada pk_id
INSERT INTO classicmodels.dim_detalle_pedidos (id_pedido, codigo_producto, cantidad_ordenada, precio_unitario, nro_linea_orden)
	SELECT *
	FROM raw_classicmodels.orderDetails;

/* ============================================================
	FIN DEL CÓDIGO PRINCIPAL DE CARGA, MODELADO Y LIMPIEZA
   ============================================================ */

/* ============================================================
	8. VALIDACIÓN FINAL
   ============================================================ */
-- Por útlimo, verificar ejecutando en classicmodels lo siguiente:
-- Ver tablas creadas
SHOW TABLES FROM classicmodels;

-- Ver claves foráneas
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'classicmodels'
AND REFERENCED_TABLE_NAME IS NOT NULL;
