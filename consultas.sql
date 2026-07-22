USE pizzeria_don_piccollo;

-- CONSULTAS

-- 1. Clientes con pedidos entre dos fechas específicas.
-- Usa BETWEEN para filtrar los pedidos cuyo fecha_hora esté dentro del rango indicado.
-- Es útil para obtener reportes de actividad en un período determinado.

SELECT *
FROM pedidos
WHERE fecha_hora BETWEEN '2026-07-11' AND '2026-07-14';

-- 2. Pizzas más vendidas.
-- Aplica GROUP BY sobre el nombre de la pizza y COUNT para contar cuántas veces aparece cada una en detalle_pedido.
-- ORDER BY DESC muestra primero las pizzas con mayor demanda.

SELECT pi.nombre AS nombre_pizza, COUNT(de.id_pedido) AS total_vendido
FROM detalle_pedido de
JOIN pizzas pi ON de.id_pizza = pi.id_pizza
GROUP BY pi.nombre
ORDER BY total_vendido DESC;

-- 3. Pedidos entregados por cada repartidor.
-- Usa JOIN entre repartidores y domicilios para enlazar cada repartidor con los pedidos que ha entregado.
-- GROUP BY agrupa por repartidor y COUNT suma la cantidad de domicilios asignados.

SELECT re.nombre AS nombre_repartidor, COUNT(dom.id_pedido) AS total_pedidos
FROM repartidores re
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
GROUP BY re.id_repartidor, re.nombre
ORDER BY total_pedidos DESC;

-- 4. Promedio de tiempo de entrega por zona.
-- Calcula el tiempo promedio en minutos entre hora_salida y hora_entrega usando TIMESTAMPDIFF.
-- Filtra con WHERE para incluir solo entregas que ya tienen hora_entrega registrada.
-- GROUP BY agrupa por la zona asignada del repartidor.

SELECT re.zona_asignada AS zona, AVG(TIMESTAMPDIFF(MINUTE, dom.hora_salida, dom.hora_entrega)) AS tiempo_promedio_min
FROM repartidores re
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
WHERE dom.hora_entrega IS NOT NULL;

-- 5. Clientes que gastaron $20000 o más en un pedido.
-- Aplica HAVING sobre la columna total para filtrar después de la agregación.

SELECT cl.nombre, pe.total AS cantidad
FROM clientes cl
JOIN pedidos pe ON cl.id_cliente = pe.id_cliente
HAVING pe.total >= 20000;

SELECT *
FROM pedidos;

-- 6. Búsqueda de pizzas por coincidencia parcial en el nombre.
-- Usa LIKE con el comodín % para encontrar cualquier pizza que contenga el texto indicado.
-- Es útil para implementar un buscador dentro del sistema.

SELECT * FROM pizzas
WHERE nombre LIKE '%Peppe%';

-- 7. Subconsulta para obtener los clientes frecuentes (más de 5 pedidos mensuales).
-- La subconsulta interna cuenta los pedidos por cliente y filtra con HAVING COUNT > 5.
-- La consulta externa selecciona solo el nombre y la cantidad de los que superan el umbral.

SELECT nombre, cantidad_pedidos
FROM (
	SELECT cl.nombre, COUNT(*) AS cantidad_pedidos
    FROM pedidos pe
    JOIN clientes cl ON pe.id_cliente = cl.id_cliente
    GROUP BY cl.id_cliente, cl.nombre
    HAVING COUNT(id_pedido) > 5
) AS clientes_frecuentes;

-- PRUEBAS DE LAS FUNCIONES

-- 1. Prueba de calcular_total_pedido: calcula el total del pedido con ID 1.

SELECT calcular_total_pedido(1) AS total_calculado;

-- 2. Prueba de ganancia_neta_diaria: calcula la ganancia neta del día 2026-07-10.

SELECT ganancia_neta_diaria('2026-07-10') AS ganancia;

-- 3. Prueba del procedimiento cambiar_estado.
-- Primero se consulta el estado actual del pedido 2, luego se ejecuta el procedimiento para cambiarlo a 'entregado'.

SELECT id_pedido, estado FROM pedidos WHERE id_pedido = 2;

CALL cambiar_estado(2);

-- CONSULTA DE ENTREGAS REALIZADAS POR CADA REPARTIDOR

SELECT re.nombre AS nombre_repartidor, COUNT(dom.id_pedido) AS total_pedidos_entregados -- traigo los valores que necesito mostrar en la tabla
FROM repartidores re -- llamo la tabla que necesito 
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor -- hago un JOIN porque necesito valores externos de otra tabla que tienen relación con la tabla ya llamada
WHERE hora_entrega IS NOT NULL -- Los valores que cumplan la condición
GROUP BY re.id_repartidor, re.nombre
ORDER BY total_pedidos_entregados DESC; -- Estas dos casillas son para organizar los resultados
-- En este caso el ejercicio pide que sea con estado = 'entregado', pero yo tengo ese "entregado" al momento de que se registra una hora_entrega, si no hay valor en esta columna
-- el pedido se toma como no entregado, y cuando el pedido si registra hora_entrega lo toma como entregado, entonces en este caso, en la consulta utilicé la comlumna de hora_entrega
-- como estado de "entregado". La consulta es funional, muestra los pedidos que solo registan hora de entrega.

-- CONSULTA DE PEDIDOS DEMORADOS
SELECT dom.id_pedido AS id_pedido, TIMESTAMPDIFF(MINUTE, dom.hora_salida, dom.hora_entrega) AS tiempo_min -- traigo los valores que necesito mostrar en la tabla
FROM domicilios dom -- llamo la tabla que necesito 
WHERE TIMESTAMPDIFF(MINUTE, dom.hora_salida, dom.hora_entrega) > 40; -- Los valores que cumplan la condición
-- En este caso el ejercicio pide que sea mayor a 40 minutos, pero yo tengo un pedido que demora 40 minutos exactos, entonces para hacer la prueba de que la consulta funciona
-- hice un ejemplo con >= 40, que es el ejemplo que tengo para poder probar la que sirve la función. Especificación por si se causa alguna duda de que no bote nada la consulta.

-- CONSULTA DE REPOARTIDORES ACTIVOS SIN ENTREGAS

SELECT id_repartidor, nombre 
FROM repartidores
WHERE estado = 'disponible';

SELECT dom.id_repartidor, re.nombre, re.estado -- traigo los valores que necesito mostrar en la tabla
FROM domicilios dom -- llamo la tabla que necesito 
LEFT JOIN repartidores re ON dom.id_repartidor = re.id_repartidor -- hago un LEFT JOIN porque necesito valores que están a la izquierda de otra tabla que tienen relación con la tabla ya llamada
WHERE estado = 'disponible' -- Los valores que cumplan la condición
GROUP BY id_repartidor; -- Organizar código
-- Realicé dos consultas por si algúna llega a fallar y para confirmar resultados.