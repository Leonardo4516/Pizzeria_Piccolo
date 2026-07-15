USE pizzeria_don_piccollo;

-- FUNCIONES

-- 1. Función para calcular el total de un pedido (sumando precios de pizzas + costo de envío + IVA).

DELIMITER $$

CREATE FUNCTION calcular_total_pedido(id_pedido_buscado INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE subtotal DECIMAL(10,2);
    DECLARE costo_envio DECIMAL(10,2);
    DECLARE total_final DECIMAL(10,2);
    
    -- Sumar el costo de las pizzas en el pedido
    SELECT SUM(p.precio_base * dp.cantidad) INTO subtotal
    FROM detalle_pedido dp
    JOIN pizzas p ON dp.id_pizza = p.id_pizza
    WHERE dp.id_pedido = id_pedido_buscado;
    
    -- Costo de envío
	SELECT COALESCE(distancia_aproximada * 1000, 0) INTO costo_envio
    FROM domicilios
    WHERE id_pedido = id_pedido_buscado;
    
    -- Sumamos los totales para llegar a el costo final
    SET total_final = COALESCE(subtotal, 0) + COALESCE(costo_envio, 0);
    
    RETURN total_final;
END $$

-- 2. Función para calcular la ganancia neta diaria (ventas - costos de ingredientes).

DELIMITER $$

CREATE FUNCTION ganancia_neta_diaria(fecha_buscada DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE total_ventas DECIMAL(10,2);
    DECLARE total_costos DECIMAL(10,2);
    
    -- Obtener ingresos
    SELECT SUM(total) INTO total_ventas
    FROM pedidos
    WHERE DATE(fecha_hora) = fecha_buscada;
    
    -- Obtener costos (subconsulta para evitar duplicación por JOIN con pizza_ingredientes)
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
    
    RETURN IFNULL(total_ventas, 0) - IFNULL(total_costos, 0);
END $$

-- PROCEDIMIENTO

DELIMITER $$

-- 3. Procedimiento para cambiar automáticamente el estado del pedido a “entregado” cuando se registre la hora de entrega.

CREATE PROCEDURE cambiar_estado(IN id_pedido_entregado INT)
BEGIN
    -- 1. Actualizamos el estado del pedido
    UPDATE pedidos
    SET estado = 'entregado'
    WHERE id_pedido = id_pedido_entregado;
    
    -- 2. Actualizamos al repartidor asignado
    UPDATE repartidores
    SET estado = 'disponible'
    WHERE id_repartidor = (
        SELECT id_repartidor
        FROM domicilios
        WHERE id_pedido = id_pedido_entregado -- Aquí estaba el error: corregido "id_peido" a "id_pedido"
        LIMIT 1
    );
END $$

DELIMITER ;