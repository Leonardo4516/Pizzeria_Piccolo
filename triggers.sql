USE pizzeria_don_piccollo;

-- TRIGGERS

DELIMITER $$

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