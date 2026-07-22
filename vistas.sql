USE pizzeria_don_piccollo;

-- VISTAS

-- 1. Vista: vista_resumen_pedidos
-- Columnas: nombre (cliente), cantidad_pedidos (total de pedidos realizados), total (suma de montos gastados)
-- Útil para identificar los clientes más frecuentes y los que generan mayores ingresos.
-- Agrupa por nombre de cliente usando JOIN entre clientes y pedidos.

CREATE VIEW vista_resumen_pedidos AS
SELECT cl.nombre, COUNT(*) AS cantidad_pedidos, SUM(pe.total) AS total
FROM clientes cl
JOIN pedidos pe ON cl.id_cliente = pe.id_cliente
GROUP BY cl.nombre;

-- DROP VIEW vista_resumen_pedidos;

-- SELECT * FROM vista_resumen_pedidos;

-- 2. Vista: vista_rendimiento_repartidores
-- Columnas: nombre (repartidor), cantidad_pedidos (entregas realizadas),
--           tiempo_promedio_minutos (promedio de duración de las entregas), zona_asignada
-- Permite evaluar el desempeño de cada repartidor y detectar si alguna zona necesita más cobertura.
-- Calcula el tiempo promedio usando TIMESTAMPDIFF entre hora_salida y hora_entrega.
CREATE VIEW vista_rendimiento_repartidores AS
SELECT re.nombre, COUNT(*) AS cantidad_pedidos, AVG(TIMESTAMPDIFF(MINUTE, dom.hora_salida, dom.hora_entrega)) AS tiempo_promedio_minutos, zona_asignada
FROM repartidores re
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
GROUP BY re.nombre;

-- DROP VIEW vista_rendimiento_repartidores;

SELECT * FROM vista_rendimiento_repartidores;

-- 3. Vista: vista_stock_bajo
-- Columnas: nombre (ingrediente), stock (cantidad actual disponible)
-- Muestra los ingredientes cuyo stock está en 10 unidades o menos.
-- Ayuda a decidir qué ingredientes hay que reabastecer antes de que se agoten.

CREATE VIEW vista_stock_bajo AS
SELECT nombre, stock 
FROM ingredientes
WHERE stock <= 10;

-- DROP VIEW vista_stock_bajo;

-- SELECT * FROM vista_stock_bajo;
