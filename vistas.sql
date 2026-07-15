USE pizzeria_don_piccollo;

-- VISTAS

-- 1. Vista de resumen de pedidos por cliente (nombre del cliente, cantidad de pedidos, total gastado).

CREATE VIEW vista_resumen_pedidos AS
SELECT cl.nombre, COUNT(*) AS cantidad_pedidos, SUM(pe.total) AS total
FROM clientes cl
JOIN pedidos pe ON cl.id_cliente = pe.id_cliente
GROUP BY cl.nombre;

-- DROP VIEW vista_resumen_pedidos;

-- SELECT * FROM vista_resumen_pedidos;

-- 2. Vista de desempeño de repartidores (número de entregas, tiempo promedio, zona).

CREATE VIEW vista_rendimiento_repartidores AS
SELECT re.nombre, COUNT(*) AS cantidad_pedidos, AVG(TIMESTAMPDIFF(MINUTE, dom.hora_salida, dom.hora_entrega)) AS tiempo_promedio_minutos, zona_asignada
FROM repartidores re
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
GROUP BY re.nombre;

-- DROP VIEW vista_rendimiento_repartidores;

-- SELECT * FROM vista_rendimiento_repartidores;

-- 3. Vista de stock de ingredientes por debajo del mínimo permitido.
-- El mínimo es 10

CREATE VIEW vista_stock_bajo AS
SELECT nombre, stock 
FROM ingredientes
WHERE stock <= 10;

-- DROP VIEW vista_stock_bajo;

-- SELECT * FROM vista_stock_bajo;