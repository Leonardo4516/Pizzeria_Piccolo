CREATE DATABASE IF NOT EXISTS pizzeria_don_piccollo;
USE pizzeria_don_piccollo;

-- Tabla de clientes. Almacena los datos básicos de quien realiza un pedido.
-- id_cliente se genera automáticamente como clave primaria para identificar cada registro de forma única.
CREATE TABLE clientes(
	id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    correo VARCHAR(80) NOT NULL
);

-- Ingredientes disponibles en inventario. Controla el stock actual y la disponibilidad de cada uno.
-- La columna estado usa un ENUM para indicar si el ingrediente se puede usar en la preparación.
CREATE TABLE ingredientes(
	id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    stock INT NOT NULL,
    estado ENUM('disponible', 'no disponible') NOT NULL
);

-- Se agrega la columna 'nombre' a ingredientes mediante ALTER TABLE,
-- ya que no fue incluida en la definición inicial de la tabla.
ALTER TABLE ingredientes
ADD COLUMN nombre VARCHAR(100) NOT NULL;

-- Repartidores y la zona geográfica asignada a cada uno.
-- El campo estado (ENUM 'disponible'/'no disponible') permite filtrar rápidamente quién puede tomar un nuevo pedido.
CREATE TABLE repartidores(
	id_repartidor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(15),
    zona_asignada VARCHAR(50) NOT NULL,
    estado ENUM('disponible', 'no disponible')
);

-- Catálogo de pizzas del menú. Cada pizza tiene nombre, tamaño, precio base y tipo.
-- Los ENUM de tamaño (pequeña, mediana, grande) y tipo (vegetariana, especial, clasica) estandarizan las opciones disponibles.
CREATE TABLE pizzas(
	id_pizza INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tamaño ENUM('pequeña', 'mediana', 'grande') NOT NULL,
    precio_base DECIMAL(10,2),
    tipo ENUM('vegetariana', 'especial', 'clasica') NOT NULL
);

-- Pedidos realizados por los clientes. Incluye referencia al cliente (FK), fecha, método de pago, estado y total.
-- La FK id_cliente asegura que solo existan pedidos de clientes registrados en la tabla clientes.
CREATE TABLE pedidos(
	id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('efectivo', 'tarjeta', 'app') NOT NULL,
    estado ENUM('pendiente', 'preparacion', 'entregado', 'cancelado'),
    total DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Relación muchos a muchos entre pizzas e ingredientes.
-- Una pizza puede tener varios ingredientes y un ingrediente puede estar en varias pizzas.
-- La clave primaria compuesta (id_pizza, id_ingrediente) evita duplicados en la relación.
CREATE TABLE pizza_ingredientes(
	id_pizza INT,
    id_ingrediente INT,
    FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza),
    FOREIGN KEY (id_ingrediente) REFERENCES ingredientes(id_ingrediente),
    PRIMARY KEY(id_pizza, id_ingrediente)
);

-- Detalle de cada pedido: registra qué pizzas se pidieron y en qué cantidad.
-- Las FK vinculan cada detalle con su pedido y con el catálogo de pizzas.
CREATE TABLE detalle_pedido(
	id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT, 
    id_pizza INT,
    cantidad INT NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza)
);

-- Control de entregas a domicilio. Asigna un repartidor a un pedido y registra
-- la hora de salida, la hora de entrega y la distancia aproximada del recorrido.
-- Las FK garantizan que el repartidor y el pedido existan previamente en sus tablas.
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

-- Historial de cambios de precio de las pizzas. Cada vez que se actualiza el precio_base,
-- se guarda el precio anterior, el nuevo valor y la fecha del cambio.
-- Funciona como auditoría para rastrear modificaciones en los precios del menú.
CREATE TABLE historial_precios(
	id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME
);

-- Agrega la columna costo_ingrediente a la tabla ingredientes.
-- Permite calcular el costo de producción de cada pizza sumando los costos individuales de sus ingredientes.
ALTER TABLE ingredientes
ADD costo_ingrediente DECIMAL(10,2);

-- Datos de prueba: cinco clientes registrados con distintos datos de contacto.
-- Se incluyen teléfono, dirección y correo para simular pedidos en el sistema.
INSERT INTO clientes (nombre, telefono, direccion, correo) VALUES 
('Juan Pérez', '3001111111', 'Calle 10 # 5-20', 'juan@email.com'),
('María López', '3002222222', 'Av. Siempre Viva 123', 'maria@email.com'),
('Carlos Ruiz', '3003333333', 'Carrera 15 # 8-40', 'carlos@email.com'),
('Ana Torres', '3004444444', 'Calle 20 # 10-10', 'ana@email.com'),
('Luis Díaz', '3005555555', 'Transversal 5 # 3-30', 'luis@email.com');

-- Datos de prueba: cinco repartidores asignados a zonas Norte, Sur y Centro.
-- Dos están como 'no disponible' para simular repartidores que ya tienen entregas activas.
INSERT INTO repartidores (nombre, telefono, zona_asignada, estado) VALUES 
('Pedro Rápido', '3165896574', 'Norte', 'disponible'),
('Ana Veloz', '3115468795', 'Sur', 'disponible'),
('Jorge Moto', '3126589745', 'Centro', 'no disponible'),
('Sara Entrega', '3201564897', 'Norte', 'disponible'),
('Tito Reparto', '3215648974', 'Sur', 'no disponible');

-- Datos de prueba: ingredientes básicos para preparar las pizzas del menú.
-- Cada registro incluye el stock actual, el estado de disponibilidad, el costo unitario y el nombre.
INSERT INTO ingredientes (stock, estado, costo_ingrediente, nombre) VALUES 
(100, 'disponible', 500.00, 'Queso'),
(60, 'disponible', 800.00, 'Pepperoni'),
(40, 'disponible', 300.00, 'Masa'),
(10, 'disponible', 400.00, 'Salsa'),
(50, 'disponible', 600.00, 'Champiñones');

-- Datos de prueba: cinco pizzas del menú con diferentes tamaños, tipos y precios base.
-- Sirven como catálogo inicial para registrar los pedidos de ejemplo.
INSERT INTO pizzas (nombre, tamaño, precio_base, tipo) VALUES 
('Pepperoni Grande', 'grande', 25000.00, 'especial'),
('Vegetariana Mediana', 'mediana', 20000.00, 'vegetariana'),
('Clásica Pequeña', 'pequeña', 15000.00, 'clasica'),
('Hawaiana Grande', 'grande', 28000.00, 'especial'),
('Margarita Mediana', 'mediana', 18000.00, 'clasica');

-- Datos de prueba: asignación de ingredientes a cada pizza del catálogo.
-- Por ejemplo, la pizza 1 (Pepperoni) usa los ingredientes 1 (Queso) y 2 (Pepperoni).
INSERT INTO pizza_ingredientes (id_pizza, id_ingrediente) VALUES 
(1, 1), (1, 2), (2, 1), (2, 5), (3, 3), (3, 4), (4, 1), (5, 1), (5, 4);

-- Datos de prueba: primeros pedidos registrados en el sistema.
-- Algunos están en estado 'entregado' y otros en 'preparacion', con distintos métodos de pago.
INSERT INTO pedidos (id_cliente, metodo_pago, estado, total, fecha_hora) VALUES 
(1, 'app', 'entregado', 25000.00, '2026-07-13 10:00:00'),
(2, 'efectivo', 'preparacion', 20000.00, '2026-07-12 11:30:00'),
(4, 'app', 'entregado', 15000.00, '2026-07-11 19:00:00'),
(5, 'efectivo', 'preparacion', 18000.00, '2026-07-10 13:00:00');

-- Pedido adicional del cliente 5 pagado con la app.
-- Se inserta por separado para probar consultas con múltiples pedidos del mismo cliente.
INSERT INTO pedidos (id_cliente, metodo_pago, estado, total, fecha_hora) VALUES 
(5, 'app', 'entregado', 25000.00, '2026-07-10 10:00:00');

-- Datos de prueba: pedidos adicionales de los clientes 4 y 5.
-- Se insertan varios registros para generar volumen de datos y probar consultas con GROUP BY y agregaciones.
INSERT INTO pedidos (id_cliente, metodo_pago, estado, total, fecha_hora) VALUES 
(4, 'app', 'entregado', 25000.00, '2026-07-10 10:00:00'),
(5, 'app', 'entregado', 20000.00, '2026-07-10 11:30:00'),
(5, 'tarjeta', 'entregado', 28000.00, '2026-07-10 12:00:00'),
(5, 'app', 'entregado', 15000.00, '2026-07-09 19:00:00'),
(5, 'tarjeta', 'entregado', 18000.00, '2026-07-09 13:00:00');

-- Datos de prueba: detalle de las pizzas incluidas en cada pedido.
-- Cada registro vincula un id_pedido con un id_pizza y la cantidad solicitada.
INSERT INTO detalle_pedido (id_pedido, id_pizza, cantidad) VALUES 
(1, 1, 1), (2, 2, 1), (3, 4, 1), (4, 3, 1), (5, 5, 1), (6, 5, 1), (7, 2, 1), (8, 4, 1), (9, 3, 1),(10, 5, 1),(11, 5, 1);

-- Datos de prueba: asignación de domicilios a los pedidos registrados.
-- Se indica qué repartidor lleva cada pedido, la distancia y las horas de salida y entrega.
INSERT INTO domicilios (id_repartidor, id_pedido, distancia_aproximada, hora_salida, hora_entrega) VALUES

-- Pedido 1: entregado. El repartidor 3 (Jorge Moto) lo completó en 30 minutos.
(3, 1, 2.5, '2026-07-12 09:30:00', '2026-07-12 10:00:00'),

-- Pedido 2: salió pero aún no se registra la hora de entrega.
(5, 2, 4.0, '2026-07-12 11:35:00', NULL),

-- Pedido 3: también en camino, sin entrega registrada.
(1, 3, 3.2, '2026-07-12 12:05:00', NULL),

-- Pedido 4: entregado. La repartidora 2 (Ana Veloz) lo completó en 30 minutos.
(2, 4, 1.5, '2026-07-11 18:30:00', '2026-07-11 19:00:00'),

-- Pedido 5: salió hace poco, aún sin confirmación de entrega.
(3, 5, 5.0, '2026-07-12 13:10:00', NULL);

-- Domicilios de pedidos 6 al 10. Todos corresponden a entregas ya completadas de días anteriores.
INSERT INTO domicilios (id_repartidor, id_pedido, distancia_aproximada, hora_salida, hora_entrega) VALUES

-- Pedido 6: Ana Torres pidió pizza a las 10am y Sara Entrega la entregó en 30 minutos.
(4, 6, 2.8, '2026-07-10 10:05:00', '2026-07-10 10:35:00'),

-- Pedido 7: Luis Díaz pidió al mediodía y Ana Veloz lo repartió en 35 minutos.
(2, 7, 3.5, '2026-07-10 11:35:00', '2026-07-10 12:10:00'),

-- Pedido 8: otro de Luis Díaz que Pedro Rápido entregó en 40 minutos.
(1, 8, 4.2, '2026-07-10 12:10:00', '2026-07-10 12:50:00'),

-- Pedido 9: del día anterior, en la noche. Tito Reparto lo completó en 25 minutos.
(5, 9, 2.0, '2026-07-09 19:05:00', '2026-07-09 19:30:00'),

-- Pedido 10: también del día anterior, en la tarde. Jorge Moto se encargó y tardó 35 minutos.
(3, 10, 3.0, '2026-07-09 13:05:00', '2026-07-09 13:40:00');
