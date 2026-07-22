USE pizzeria_don_piccollo;

-- TRIGGERS

DELIMITER $$

-- Trigger: actualizar_stock
-- Evento: AFTER INSERT ON detalle_pedido (se ejecuta después de insertar un detalle de pedido)
-- Función: descuenta los ingredientes del stock automáticamente cuando se registra un nuevo detalle.
-- Usa NEW.cantidad (cantidad recién insertada) y NEW.id_pizza para saber qué y cuánto descontar.
-- Nota: requiere que la columna cantidad_ingrediente exista en pizza_ingredientes.

CREATE TRIGGER actualizar_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE ingredientes i
    JOIN pizza_ingredientes pi ON i.id_ingrediente = pi.id_ingrediente
    SET i.stock = i.stock - (NEW.cantidad * pi.cantidad_ingrediente)
    WHERE pi.id_pizza = NEW.id_pizza;
END $$

DELIMITER $$

-- Trigger: revertir_stock_delete
-- Evento: AFTER DELETE ON detalle_pedido (se ejecuta después de eliminar un detalle de pedido)
-- Función: restaura los ingredientes al stock cuando se elimina un detalle (por ejemplo, al cancelar un pedido).
-- Usa OLD.cantidad y OLD.id_pizza para saber qué ingredientes y en qué cantidad devolver.

CREATE TRIGGER revertir_stock_delete
AFTER DELETE ON detalle_pedido
FOR EACH ROW
BEGIN
	UPDATE ingredientes i
    JOIN pizza_ingredientes pi ON i.id_ingrediente = pi.id_ingrediente
    SET i.stock = i.stock + (OLD.cantidad * pi.cantidad_ingrediente)
    WHERE pi.id_pizza = OLD.id_pizza;
END $$

DELIMITER $$

-- Trigger: ajustar_stock_update
-- Evento: AFTER UPDATE ON detalle_pedido (se ejecuta después de actualizar un detalle de pedido)
-- Función: ajusta el stock según la diferencia entre la cantidad nueva y la anterior.
-- Solo se ejecuta si OLD.cantidad es diferente de NEW.cantidad, para evitar actualizaciones innecesarias.
-- La diferencia (NEW.cantidad - OLD.cantidad) puede ser positiva (descuenta más stock) o negativa (devuelve stock).

CREATE TRIGGER ajustar_stock_update
AFTER UPDATE ON detalle_pedido
FOR EACH ROW
BEGIN
    IF OLD.cantidad <> NEW.cantidad THEN
        UPDATE ingredientes i
        JOIN pizza_ingredientes pi ON i.id_ingrediente = pi.id_ingrediente
        SET i.stock = i.stock - ((NEW.cantidad - OLD.cantidad) * pi.cantidad_ingrediente)
        WHERE pi.id_pizza = NEW.id_pizza;
    END IF;
END $$

DELIMITER $$

-- Trigger: auditoria_cambios
-- Evento: AFTER UPDATE ON pizzas (se ejecuta después de actualizar una pizza)
-- Función: registra en historial_precios cualquier cambio en el precio_base de una pizza.
-- Solo inserta un registro si el precio anterior (OLD.precio_base) es diferente del nuevo (NEW.precio_base).
-- Guarda el id de la pizza, ambos precios y la fecha actual con NOW().

CREATE TRIGGER auditoria_cambios
AFTER UPDATE ON pizzas
FOR EACH ROW
BEGIN
	IF OLD.precio_base <> NEW.precio_base THEN
		INSERT INTO historial_precios(id_pizza, precio_anterior, precio_nuevo, fecha_cambio) 
        VALUES (NEW.id_pizza, OLD.precio_base, NEW.precio_base, NOW());
	END IF;
END $$

DELIMITER $$

-- Trigger: marcar_repartidor
-- Evento: AFTER UPDATE ON domicilios (se ejecuta después de actualizar un domicilio)
-- Función: cuando se registra la hora_entrega (pasa de NULL a un valor), marca automáticamente
-- al repartidor como 'disponible' para que pueda asignarse a otro pedido.
-- La condición IF verifica que hora_entrega se haya establecido (NEW no es NULL y OLD sí lo era).

CREATE TRIGGER marcar_repartidor
AFTER UPDATE ON domicilios
FOR EACH ROW
BEGIN
    IF NEW.hora_entrega IS NOT NULL AND OLD.hora_entrega IS NULL THEN
		UPDATE repartidores
		SET estado = 'disponible'
        WHERE id_repartidor = NEW.id_repartidor;
    END IF;
END $$

DELIMITER ;
