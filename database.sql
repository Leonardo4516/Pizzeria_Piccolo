DROP DATABASE pizzeria_don_piccollo;
CREATE DATABASE IF NOT EXISTS pizzeria_don_piccollo;
USE pizzeria_don_piccollo;

CREATE TABLE clientes(
	id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    correo VARCHAR(80) NOT NULL
);

CREATE TABLE ingredientes(
	id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    stock INT NOT NULL,
    estado ENUM('disponible', 'no disponible') NOT NULL
);

ALTER TABLE ingredientes
ADD COLUMN nombre VARCHAR(100) NOT NULL;

CREATE TABLE repartidores(
	id_repartidor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    zona_asignada VARCHAR(50) NOT NULL,
    estado ENUM('disponible', 'no disponible')
);

CREATE TABLE pizzas(
	id_pizza INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tamaño ENUM('pequeña', 'mediana', 'grande') NOT NULL,
    precio_base DECIMAL(10,2),
    tipo ENUM('vegetariana', 'especial', 'clasica') NOT NULL
);

CREATE TABLE pedidos(
	id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('efectivo', 'tarjeta', 'app') NOT NULL,
    estado ENUM('pendiente', 'preparacion', 'entregado', 'cancelado'),
    total DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE pizza_ingredientes(
	id_pizza INT,
    id_ingrediente INT,
    FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza),
    FOREIGN KEY (id_ingrediente) REFERENCES ingredientes(id_ingrediente),
    PRIMARY KEY(id_pizza, id_ingrediente)
);

CREATE TABLE detalle_pedido(
	id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT, 
    id_pizza INT,
    cantidad INT NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza)
);

CREATE TABLE domicilios(
	id_domicilio INT AUTO_INCREMENT PRIMARY KEY,
    id_repartidor INT,
    id_pedido INT,
    hora_salida DATETIME DEFAULT CURRENT_TIMESTAMP,
    hora_entrega DATETIME DEFAULT NULL,
    distancia_aproximada DECIMAL(10,2),
    FOREIGN KEY (id_repartidor) REFERENCES repartidores(id_repartidor),
	FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

CREATE TABLE historial_precios(
	id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME
);

ALTER TABLE ingredientes
ADD costo_ingrediente DECIMAL(10,2);

-- Clientes
INSERT INTO clientes (nombre, telefono, direccion, correo) VALUES 
('Juan Pérez', '3001111111', 'Calle 10 # 5-20', 'juan@email.com'),
('María López', '3002222222', 'Av. Siempre Viva 123', 'maria@email.com'),
('Carlos Ruiz', '3003333333', 'Carrera 15 # 8-40', 'carlos@email.com'),
('Ana Torres', '3004444444', 'Calle 20 # 10-10', 'ana@email.com'),
('Luis Díaz', '3005555555', 'Transversal 5 # 3-30', 'luis@email.com');

-- Repartidores
INSERT INTO repartidores (nombre, zona_asignada, estado) VALUES 
('Pedro Rápido', 'Norte', 'disponible'),
('Ana Veloz', 'Sur', 'disponible'),
('Jorge Moto', 'Centro', 'no disponible'),
('Sara Entrega', 'Norte', 'disponible'),
('Tito Reparto', 'Sur', 'no disponible');

-- Ingredientes (Recuerda que agregamos costo_ingrediente)
INSERT INTO ingredientes (stock, estado, costo_ingrediente, nombre) VALUES 
(100, 'disponible', 500.00, 'Queso'),
(60, 'disponible', 800.00, 'Pepperoni'),
(40, 'disponible', 300.00, 'Masa'),
(10, 'disponible', 400.00, 'Salsa'),
(50, 'disponible', 600.00, 'Champiñones');

-- Pizzas
INSERT INTO pizzas (nombre, tamaño, precio_base, tipo) VALUES 
('Pepperoni Grande', 'grande', 25000.00, 'especial'),
('Vegetariana Mediana', 'mediana', 20000.00, 'vegetariana'),
('Clásica Pequeña', 'pequeña', 15000.00, 'clasica'),
('Hawaiana Grande', 'grande', 28000.00, 'especial'),
('Margarita Mediana', 'mediana', 18000.00, 'clasica');

-- Pizza-Ingredientes (Relaciones básicas)
INSERT INTO pizza_ingredientes (id_pizza, id_ingrediente) VALUES 
(1, 1), (1, 2), (2, 1), (2, 5), (3, 3), (3, 4), (4, 1), (5, 1), (5, 4);

-- Pedidos (Fecha actual: 12 de julio de 2026)
INSERT INTO pedidos (id_cliente, metodo_pago, estado, total, fecha_hora) VALUES 
(1, 'app', 'entregado', 25000.00, '2026-07-13 10:00:00'),
(2, 'efectivo', 'preparacion', 20000.00, '2026-07-12 11:30:00'),
(4, 'app', 'entregado', 15000.00, '2026-07-11 19:00:00'),
(5, 'efectivo', 'preparacion', 18000.00, '2026-07-10 13:00:00');

INSERT INTO pedidos (id_cliente, metodo_pago, estado, total, fecha_hora) VALUES 
(5, 'app', 'entregado', 25000.00, '2026-07-10 10:00:00');

INSERT INTO pedidos (id_cliente, metodo_pago, estado, total, fecha_hora) VALUES 
(4, 'app', 'entregado', 25000.00, '2026-07-10 10:00:00'),
(5, 'app', 'entregado', 20000.00, '2026-07-10 11:30:00'),
(5, 'tarjeta', 'entregado', 28000.00, '2026-07-10 12:00:00'),
(5, 'app', 'entregado', 15000.00, '2026-07-09 19:00:00'),
(5, 'tarjeta', 'entregado', 18000.00, '2026-07-09 13:00:00');

-- UPDATE pedidos
-- SET fecha_hora = '2026-07-10 13:00:00'
-- WHERE id_cliente = 5;

-- SELECT * FROM pedidos;

-- Detalle Pedido
INSERT INTO detalle_pedido (id_pedido, id_pizza, cantidad) VALUES 
(1, 1, 1), (2, 2, 1), (3, 4, 1), (4, 3, 1), (5, 5, 1), (6, 5, 1), (7, 2, 1), (8, 4, 1), (9, 3, 1),(10, 5, 1),(11, 5, 1);

-- Domicilios

-- Insertamos los 5 registros con sus horas
INSERT INTO domicilios (id_repartidor, id_pedido, distancia_aproximada, hora_salida, hora_entrega) VALUES 
-- Pedido 1: Ya entregado
(3, 1, 2.5, '2026-07-12 09:30:00', '2026-07-12 10:00:00'),

-- Pedido 2: En proceso (sin hora de entrega)
(5, 2, 4.0, '2026-07-12 11:35:00', NULL),

-- Pedido 3: En proceso (sin hora de entrega)
(1, 3, 3.2, '2026-07-12 12:05:00', NULL),

-- Pedido 4: Ya entregado (ayer)
(2, 4, 1.5, '2026-07-11 18:30:00', '2026-07-11 19:00:00'),

-- Pedido 5: En proceso (sin hora de entrega)
(3, 5, 5.0, '2026-07-12 13:10:00', NULL);
