DROP DATABASE IF EXISTS viveros;
CREATE DATABASE viveros;

\c viveros 
--Para conectarse a la base de datos recién creada

-- Limpieza previa si existen tablas
DROP TABLE IF EXISTS DETALLE_PEDIDO CASCADE;
DROP TABLE IF EXISTS PEDIDO CASCADE;
DROP TABLE IF EXISTS CLIENTE_PLUS CASCADE;
DROP TABLE IF EXISTS CLIENTE CASCADE;
DROP TABLE IF EXISTS HISTORICO_PUESTO CASCADE;
DROP TABLE IF EXISTS EMPLEADO CASCADE;
DROP TABLE IF EXISTS STOCK_ZONA CASCADE;
DROP TABLE IF EXISTS PRODUCTO CASCADE;
DROP TABLE IF EXISTS ZONA CASCADE;
DROP TABLE IF EXISTS VIVERO CASCADE;

-- 1. VIVERO
CREATE TABLE VIVERO (
    id_vivero SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    latitud NUMERIC(9,6) NOT NULL CHECK (latitud BETWEEN -90 AND 90),
    longitud NUMERIC(9,6) NOT NULL CHECK (longitud BETWEEN -180 AND 180)
);

-- 2. ZONA (Entidad débil respecto a VIVERO)
CREATE TABLE ZONA (
    id_vivero INT REFERENCES VIVERO(id_vivero) ON DELETE CASCADE ON UPDATE CASCADE,
    id_zona INT,
    nombre VARCHAR(100) NOT NULL,
    latitud NUMERIC(9,6) NOT NULL CHECK (latitud BETWEEN -90 AND 90),
    longitud NUMERIC(9,6) NOT NULL CHECK (longitud BETWEEN -180 AND 180),
    PRIMARY KEY (id_vivero, id_zona)
);

-- 3. PRODUCTO
CREATE TABLE PRODUCTO (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50),
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0)
);

-- 4. STOCK_ZONA (Relación 'Almacena' M:N entre ZONA y PRODUCTO)
CREATE TABLE STOCK_ZONA (
    id_vivero INT,
    id_zona INT,
    id_producto INT REFERENCES PRODUCTO(id_producto) ON DELETE CASCADE ON UPDATE CASCADE,
    stock INT NOT NULL CHECK (stock >= 0),
    PRIMARY KEY (id_vivero, id_zona, id_producto),
    FOREIGN KEY (id_vivero, id_zona) REFERENCES ZONA(id_vivero, id_zona) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. EMPLEADO
CREATE TABLE EMPLEADO (
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(15)
);

-- 6. HISTORICO_PUESTO (Relación 'Trabaja' M:N entre EMPLEADO y ZONA)
CREATE TABLE HISTORICO_PUESTO (
    id_historico SERIAL PRIMARY KEY,
    id_empleado INT REFERENCES EMPLEADO(id_empleado) ON DELETE CASCADE ON UPDATE CASCADE,
    id_vivero INT,
    id_zona INT,
    puesto VARCHAR(50),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    productividad NUMERIC(5,2) CHECK (productividad >= 0),
    FOREIGN KEY (id_vivero, id_zona) REFERENCES ZONA(id_vivero, id_zona) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 7. CLIENTE (Superclase)
CREATE TABLE CLIENTE (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- 8. CLIENTE_PLUS (Especialización Es_un)
CREATE TABLE CLIENTE_PLUS (
    id_cliente INT PRIMARY KEY REFERENCES CLIENTE(id_cliente) ON DELETE CASCADE ON UPDATE CASCADE,
    fecha_ingreso DATE NOT NULL DEFAULT CURRENT_DATE,
    bonificacion_acumulada NUMERIC(10,2) DEFAULT 0.00 CHECK (bonificacion_acumulada >= 0)
);

-- 9. PEDIDO
CREATE TABLE PEDIDO (
    num_pedido SERIAL PRIMARY KEY,
    id_cliente INT REFERENCES CLIENTE(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_empleado INT REFERENCES EMPLEADO(id_empleado) ON DELETE SET NULL ON UPDATE CASCADE,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    importe_total NUMERIC(10,2) DEFAULT 0.00 CHECK (importe_total >= 0)
);

-- 10. DETALLE_PEDIDO (Relación 'Incluye' entre PEDIDO y PRODUCTO)
CREATE TABLE DETALLE_PEDIDO (
    num_pedido INT REFERENCES PEDIDO(num_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
    id_producto INT REFERENCES PRODUCTO(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    PRIMARY KEY (num_pedido, id_producto)
);

-- INSERCIÓN DE DATOS (Mínimo 5 filas por tabla)

INSERT INTO VIVERO (nombre, latitud, longitud) VALUES
('Vivero Central', 28.468245, -16.321589),
('Vivero Anaga', 28.530123, -16.200145),
('Vivero Sur', 28.058912, -16.715423),
('Vivero Norte', 28.389123, -16.521456),
('Vivero Teide', 28.272341, -16.642512);

INSERT INTO ZONA (id_vivero, id_zona, nombre, latitud, longitud) VALUES
(1, 1, 'Exterior Plantas', 28.468250, -16.321590),
(1, 2, 'Almacén Central', 28.468300, -16.321600),
(2, 1, 'Exposición Rosas', 28.530130, -16.200150),
(3, 1, 'Cactus y Suculentas', 28.058920, -16.715430),
(4, 1, 'Herramientas', 28.389130, -16.521460);

INSERT INTO PRODUCTO (nombre, tipo, precio) VALUES
('Rosal Rojo', 'Planta', 12.50),
('Sustrato Universal 50L', 'Tierra', 8.95),
('Tijeras de Podar', 'Herramienta', 15.00),
('Cactus Asiento de Suegra', 'Planta', 6.50),
('Abono Líquido 1L', 'Fertilizante', 5.20);

INSERT INTO STOCK_ZONA (id_vivero, id_zona, id_producto, stock) VALUES
(1, 1, 1, 50),
(1, 2, 2, 200),
(2, 1, 1, 30),
(3, 1, 4, 80),
(4, 1, 3, 15);

INSERT INTO EMPLEADO (nombre, apellidos, telefono) VALUES
('Juan', 'Pérez Gómez', '600111222'),
('Maria', 'López Hernández', '600222333'),
('Carlos', 'González Dorta', '600333444'),
('Ana', 'Rodríguez Martín', '600444555'),
('Pedro', 'Sánchez Díaz', '600555666');

INSERT INTO HISTORICO_PUESTO (id_empleado, id_vivero, id_zona, puesto, fecha_inicio, fecha_fin, productividad) VALUES
(1, 1, 1, 'Jardinero Senior', '2024-01-01', '2024-06-30', 95.50),
(1, 1, 2, 'Encargado Almacén', '2024-07-01', NULL, 98.00),
(2, 2, 1, 'Especialista Rosas', '2024-01-01', NULL, 90.00),
(3, 3, 1, 'Cuidador Cactus', '2024-02-01', NULL, 88.50),
(4, 4, 1, 'Atención Cliente', '2024-03-01', NULL, 92.00);

INSERT INTO CLIENTE (nombre) VALUES
('Laura Blanco'),
('David Suárez'),
('Elena Torres'),
('Empresa Jardines S.L.'),
('Carmen Morales');

INSERT INTO CLIENTE_PLUS (id_cliente, fecha_ingreso, bonificacion_acumulada) VALUES
(1, '2024-01-15', 15.50),
(2, '2024-02-20', 8.00),
(3, '2024-03-10', 0.00),
(5, '2024-05-12', 22.10),
(4, '2024-06-01', 50.00);

INSERT INTO PEDIDO (id_cliente, id_empleado, fecha, importe_total) VALUES
(1, 1, '2024-09-01', 37.50),
(2, 2, '2024-09-02', 17.90),
(3, 1, '2024-09-03', 15.00),
(4, 3, '2024-09-04', 26.00),
(5, 4, '2024-09-05', 10.40);

INSERT INTO DETALLE_PEDIDO (num_pedido, id_producto, cantidad) VALUES
(1, 1, 3),
(2, 2, 2),
(3, 3, 1),
(4, 4, 4),
(5, 5, 2);

-- EJEMPLOS DE PRUEBA DELETE
-- Borrar un Vivero (Prueba CASCADE en Zonas y Stock)
DELETE FROM VIVERO WHERE id_vivero = 5;

-- Borra automáticamente el registro de stock asociado en stock_zona (no se puede borrar el producto si está en algún pedido)
-- DELETE FROM producto WHERE id_producto = 5;

-- Borra las filas de stock agotado
DELETE FROM STOCK_ZONA WHERE stock = 0;

-- Borrar un Cliente (Prueba RESTRICT: Dará error si tiene pedidos asociados)
-- DELETE FROM CLIENTE WHERE id_cliente = 1;
