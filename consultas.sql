USE pizzeria_don_piccollo;

-- CONSULTAS

-- 1. Clientes con pedidos entre dos fechas (BETWEEN).

SELECT *
FROM pedidos
WHERE fecha_hora BETWEEN '2026-07-11' AND '2026-07-14';

-- 2. Pizzas más vendidas (GROUP BY y COUNT).

SELECT pi.nombre AS nombre_pizza, COUNT(de.id_pedido) AS total_vendido
FROM detalle_pedido de
JOIN pizzas pi ON de.id_pizza = pi.id_pizza
GROUP BY pi.nombre
ORDER BY total_vendido DESC;

-- 3. Pedidos por repartidor (JOIN).

-- SELECT re.nombre AS nombre_repartidor, dom.id_domicilio AS cantidad_pedidos
-- FROM repartidores re
-- JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
-- GROUP BY nombre_repartidor
-- ORDER BY cantidad_pedidos;

SELECT re.nombre AS nombre_repartidor, COUNT(dom.id_pedido) AS total_pedidos
FROM repartidores re
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
GROUP BY re.id_repartidor, re.nombre
ORDER BY total_pedidos DESC;

-- 4. Promedio de entrega por zona (AVG y JOIN).

-- SELECT re.zona_asignada AS zona, AVG(dom.id_pedido) AS promedio
-- FROM repartidores re
-- JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
-- GROUP BY re.id_repartidor, re.nombre
-- ORDER BY promedio DESC;

SELECT 
    re.zona_asignada AS zona, 
    COUNT(dom.id_pedido) AS cantidad_pedidos,
    -- Calculamos la proporción dividiendo el conteo de la zona por el total general
    COUNT(dom.id_pedido) / (SELECT COUNT(*) FROM domicilios) AS proporcion_pedidos
FROM repartidores re
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
GROUP BY re.zona_asignada;

-- 5. Clientes que gastaron más de un monto (HAVING).
-- El monto es de 20000 en adelante

SELECT cl.nombre, pe.total AS cantidad
FROM clientes cl
JOIN pedidos pe ON cl.id_cliente = pe.id_cliente
HAVING pe.total >= 20000;

SELECT *
FROM pedidos;

-- 6. Búsqueda por coincidencia parcial de nombre de pizza (LIKE).

SELECT * FROM pizzas
WHERE nombre LIKE '%Peppe%';

-- 7. Subconsulta para obtener los clientes frecuentes (más de 5 pedidos mensuales).

SELECT nombre, cantidad_pedidos
FROM (
	SELECT cl.nombre, COUNT(*) AS cantidad_pedidos
    FROM pedidos pe
    JOIN clientes cl ON pe.id_cliente = cl.id_cliente
    GROUP BY cl.id_cliente, cl.nombre
    HAVING COUNT(id_pedido) > 5
) AS clientes_frecuentes;

-- PRUEBAS DE LAS FUNCIONES

-- 1

SELECT calcular_total_pedido(1) AS total_calculado;

-- 2

SELECT ganancia_neta_diaria('2026-07-10') AS ganancia;

-- 3 

SELECT id_pedido, estado FROM pedidos WHERE id_pedido = 2;

CALL cambiar_estado(2);