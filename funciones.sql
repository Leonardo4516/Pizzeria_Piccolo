USE pizzeria_don_piccollo;

-- FUNCIONES

-- 1. Función calcular_total_pedido.
-- Parámetro: id_pedido_buscado INT -> ID del pedido a calcular.
-- Retorna: DECIMAL(10,2) -> Total calculado (subtotal de pizzas + costo de envío).
-- Lógica: suma el precio de cada pizza (precio_base * cantidad) y agrega el costo de envío (distancia * 1000).
-- DETERMINISTIC indica que la función retorna el mismo valor para los mismos parámetros de entrada.

DELIMITER $$

CREATE FUNCTION calcular_total_pedido(id_pedido_buscado INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE subtotal DECIMAL(10,2);
    DECLARE costo_envio DECIMAL(10,2);
    DECLARE total_final DECIMAL(10,2);
    
    -- Calcula el subtotal sumando (precio_base * cantidad) de todas las pizzas del pedido.
    SELECT SUM(p.precio_base * dp.cantidad) INTO subtotal
    FROM detalle_pedido dp
    JOIN pizzas p ON dp.id_pizza = p.id_pizza
    WHERE dp.id_pedido = id_pedido_buscado;
    
    -- Calcula el costo de envío basado en la distancia aproximada (distancia * 1000).
    -- COALESCE devuelve 0 si el pedido no tiene domicilio registrado (valor NULL).
	SELECT COALESCE(distancia_aproximada * 1000, 0) INTO costo_envio
    FROM domicilios
    WHERE id_pedido = id_pedido_buscado;
    
    -- Suma el subtotal y el costo de envío para obtener el total final.
    -- COALESCE maneja posibles valores NULL en cualquiera de las dos partes.
    SET total_final = COALESCE(subtotal, 0) + COALESCE(costo_envio, 0);
    
    RETURN total_final;
END $$

-- 2. Función ganancia_neta_diaria.
-- Parámetro: fecha_buscada DATE -> Fecha para la cual se calcula la ganancia.
-- Retorna: DECIMAL(10,2) -> Ganancia neta (total ventas - total costos de ingredientes).
-- Lógica: suma los totales de los pedidos del día y resta los costos de los ingredientes usados.

DELIMITER $$

CREATE FUNCTION ganancia_neta_diaria(fecha_buscada DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE total_ventas DECIMAL(10,2);
    DECLARE total_costos DECIMAL(10,2);
    
    -- Obtiene el total de ingresos sumando la columna 'total' de los pedidos realizados en la fecha indicada.
    SELECT SUM(total) INTO total_ventas
    FROM pedidos
    WHERE DATE(fecha_hora) = fecha_buscada;
    
    -- Obtiene los costos totales de ingredientes usados en los pedidos del día.
    -- Usa una subconsulta para sumar el costo de cada ingrediente por pizza, evitando duplicados
    -- que podrían generarse al hacer JOIN directo entre varias tablas.
	SELECT SUM(dp.cantidad * (
        SELECT SUM(i.costo_ingrediente)
        FROM pizza_ingredientes pi
        JOIN ingredientes i ON pi.id_ingrediente = i.id_ingrediente
        WHERE pi.id_pizza = p.id_pizza
    )) INTO total_costos
    FROM detalle_pedido dp
    JOIN pizzas p ON dp.id_pizza = p.id_pizza
    JOIN pedidos pe ON dp.id_pedido = pe.id_pedido
    WHERE DATE(pe.fecha_hora) = fecha_buscada;
    
    -- Retorna la diferencia entre ventas y costos. IFNULL maneja valores NULL convirtiéndolos a 0.
    RETURN IFNULL(total_ventas, 0) - IFNULL(total_costos, 0);
END $$

-- PROCEDIMIENTO ALMACENADO

-- 3. Procedimiento cambiar_estado.
-- Parámetro: id_pedido_entregado INT -> ID del pedido que se marca como entregado.
-- Función: actualiza el estado del pedido a 'entregado' y libera al repartidor asignado poniéndolo como 'disponible'.
-- Este procedimiento se invoca manualmente cuando se confirma la entrega de un domicilio.

DELIMITER $$

CREATE PROCEDURE cambiar_estado(IN id_pedido_entregado INT)
BEGIN
    -- 1. Actualiza el estado del pedido a 'entregado' en la tabla pedidos.
    UPDATE pedidos
    SET estado = 'entregado'
    WHERE id_pedido = id_pedido_entregado;
    
    -- 2. Actualiza el estado del repartidor asignado a ese pedido como 'disponible'.
    -- Busca el id_repartidor en la tabla domicilios usando el id del pedido entregado.
    UPDATE repartidores
    SET estado = 'disponible'
    WHERE id_repartidor = (
        SELECT id_repartidor
        FROM domicilios
        WHERE id_pedido = id_pedido_entregado
        LIMIT 1
    );
END $$

DELIMITER ;
