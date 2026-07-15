# Pizzería Don Piccolo — Sistema de Gestión de Pedidos y Domicilios

## Descripción del proyecto

La empresa Pizzería Don Piccolo desea implementar un sistema de gestión de pedidos y domicilios para mejorar el control de sus operaciones. Actualmente, la empresa maneja los pedidos de forma manual, lo que genera retrasos en la atención y errores en los registros de clientes y entregas.

Tu misión es diseñar y desarrollar la base de datos que permita gestionar los clientes, pizzas, ingredientes, pedidos, repartidores, domicilios y pagos, además de crear funciones, triggers y vistas para optimizar las consultas del negocio.

### Objetivo general

Diseñar un sistema de base de datos relacional en MySQL que permita gestionar la información completa del proceso de venta de pizzas y domicilios, desde el registro de pedidos hasta su entrega y pago.

## Estructura del proyecto

```
Proyecto_pizzeria/
 ├── database.sql        → Creación de BD, tablas, relaciones y datos iniciales
 ├── funciones.sql       → Funciones y procedimiento almacenado
 ├── triggers.sql        → Triggers de automatización
 ├── vistas.sql          → Vistas de reportes
 ├── consultas.sql       → Consultas SQL de ejemplo
 └── README.md           → Documentación del proyecto
```

## Explicación de las tablas y relaciones

### Diagrama de relaciones

```
clientes ──< pedidos ──< detalle_pedido >── pizzas >── pizza_ingredientes <── ingredientes
                │                                       │
                └──< domicilios >── repartidores         └── historial_precios
```

### Tablas

| Tabla | Descripción | Relaciones |
|---|---|---|
| `clientes` | Información del cliente: nombre, teléfono, dirección, correo | 1:N con `pedidos` |
| `ingredientes` | Ingredientes con nombre, stock, estado y costo_ingrediente | N:M con `pizzas` a través de `pizza_ingredientes` |
| `repartidores` | Repartidores: nombre, zona asignada, estado (disponible / no disponible) | 1:N con `domicilios` |
| `pizzas` | Catálogo de pizzas: nombre, tamaño, precio base, tipo (vegetariana, especial, clásica) | N:M con `ingredientes`; 1:N con `detalle_pedido`; 1:N con `historial_precios` |
| `pedidos` | Pedidos: cliente, fecha, método de pago (efectivo, tarjeta, app), estado (pendiente, preparacion, entregado, cancelado), total | N:1 con `clientes`; 1:N con `detalle_pedido`; 1:N con `domicilios` |
| `pizza_ingredientes` | Relación N:M entre pizzas e ingredientes (sin columna cantidad en la DDL; triggers la referencian como `cantidad_ingrediente`) | N:1 con `pizzas` e `ingredientes` |
| `detalle_pedido` | Pizzas incluidas en cada pedido con cantidad | N:1 con `pedidos` y `pizzas` |
| `domicilios` | Entregas a domicilio: repartidor, pedido, hora salida, hora entrega, distancia | N:1 con `repartidores` y `pedidos` |
| `historial_precios` | Auditoría de cambios de precio de pizzas | N:1 con `pizzas` |

## Funciones y procedimientos

1. **`calcular_total_pedido(id_pedido)`** — Calcula el total de un pedido sumando el precio de las pizzas más el costo de envío (distancia × 1000).
2. **`ganancia_neta_diaria(fecha)`** — Calcula la ganancia neta de un día (ventas − costo de ingredientes).
3. **`cambiar_estado(id_pedido)`** — Procedimiento que cambia el estado del pedido a "entregado" y libera al repartidor asignado.

## Triggers

1. **`actualizar_stock`** — Al insertar un detalle de pedido, descuenta ingredientes del stock.
2. **`revertir_stock_delete`** — Al eliminar un detalle, restaura ingredientes al stock.
3. **`ajustar_stock_update`** — Al actualizar cantidades en un detalle, ajusta el stock proporcionalmente.
4. **`auditoria_cambios`** — Al modificar el precio de una pizza, registra el cambio en `historial_precios`.
5. **`marcar_repartidor`** — Al registrar la hora de entrega, marca al repartidor como "disponible".

## Vistas

1. **`vista_resumen_pedidos`** — Resumen por cliente: nombre, cantidad de pedidos, total gastado.
2. **`vista_rendimiento_repartidores`** — Desempeño de repartidores: entregas, tiempo promedio en minutos, zona asignada.
3. **`vista_stock_bajo`** — Ingredientes con stock por debajo del mínimo permitido (≤ 10).

## Ejemplos de consultas

```sql
-- Clientes con pedidos entre dos fechas (BETWEEN)
SELECT * FROM pedidos
WHERE fecha_hora BETWEEN '2026-07-11' AND '2026-07-14';

-- Pizzas más vendidas (GROUP BY + COUNT)
SELECT pi.nombre, COUNT(de.id_pedido) AS total_vendido
FROM detalle_pedido de
JOIN pizzas pi ON de.id_pizza = pi.id_pizza
GROUP BY pi.nombre
ORDER BY total_vendido DESC;

-- Pedidos por repartidor (JOIN)
SELECT re.nombre, COUNT(dom.id_pedido) AS total_pedidos
FROM repartidores re
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
GROUP BY re.id_repartidor, re.nombre
ORDER BY total_pedidos DESC;

-- Promedio de entregas por zona (AVG + JOIN)
SELECT re.zona_asignada AS zona,
       COUNT(dom.id_pedido) AS cantidad_pedidos,
       COUNT(dom.id_pedido) / (SELECT COUNT(*) FROM domicilios) AS proporcion_pedidos
FROM repartidores re
JOIN domicilios dom ON re.id_repartidor = dom.id_repartidor
GROUP BY re.zona_asignada;

-- Clientes que gastaron más de 20000 (HAVING)
SELECT cl.nombre, pe.total
FROM clientes cl
JOIN pedidos pe ON cl.id_cliente = pe.id_cliente
HAVING pe.total >= 20000;

-- Búsqueda por coincidencia parcial (LIKE)
SELECT * FROM pizzas WHERE nombre LIKE '%Peppe%';

-- Subconsulta: clientes frecuentes (más de 5 pedidos)
SELECT nombre, cantidad_pedidos
FROM (
    SELECT cl.nombre, COUNT(*) AS cantidad_pedidos
    FROM pedidos pe
    JOIN clientes cl ON pe.id_cliente = cl.id_cliente
    GROUP BY cl.id_cliente, cl.nombre
    HAVING COUNT(id_pedido) > 5
) AS clientes_frecuentes;
```

## Instrucciones para ejecutar el script

### Requisitos

- MySQL 8.0+ o MariaDB 10.5+
- Cliente MySQL (`mysql`) o administrador gráfico (MySQL Workbench, DBeaver, etc.)

### Orden de ejecución

Los scripts deben ejecutarse en el siguiente orden para respetar las dependencias:

```bash
# 1. Crear base de datos, tablas y datos iniciales
mysql -u usuario -p < database.sql

# 2. Crear funciones y procedimiento almacenado
mysql -u usuario -p < funciones.sql

# 3. Crear triggers
mysql -u usuario -p < triggers.sql

# 4. Crear vistas
mysql -u usuario -p < vistas.sql

# 5. Ejecutar consultas de prueba
mysql -u usuario -p < consultas.sql
```

También se pueden ejecutar todos los scripts en una sola línea:

```bash
cat database.sql funciones.sql triggers.sql vistas.sql consultas.sql | mysql -u usuario -p
```

### Notas

- El script `database.sql` crea la base de datos `pizzeria_don_piccollo` con `CREATE DATABASE IF NOT EXISTS`, por lo que no elimina versiones previas.
- La tabla `ingredientes` se completa con las columnas `nombre` y `costo_ingrediente` mediante sentencias `ALTER TABLE` posteriores a su creación.
- Las funciones, triggers y vistas se crean dentro de la base de datos `pizzeria_don_piccollo` mediante la instrucción `USE`.
- Los datos de inserción incluidos en `database.sql` son datos de ejemplo para pruebas.
