/* ============================================================
   M4 - Título: Extrayendo métricas clave con SQL
   Proyecto: RetailPro
   Base de datos: Ventas_Tech_DB
   Tabla utilizada: ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
   ============================================================ */


/* ------------------------------------------------------------
   Consulta 1 - Resumen ejecutivo mensual
   Objetivo: total facturado, cantidad de pedidos y ticket promedio por mes
   ------------------------------------------------------------ */
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- Consulta 2 — Ranking de productos: Top 5 de id_producto por total facturado
SELECT TOP 5 id_producto, SUM(cantidad) AS cantidad_vendida, SUM(precio_unitario * cantidad) AS IMPORTE 
FROM ventas
GROUP BY id_producto 
ORDER BY IMPORTE DESC;


-- Consulta 3 — Clientes recurrentes: más de un pedido
SELECT id_cliente, COUNT(*) AS cantidad_de_pedidos, SUM(precio_unitario * cantidad) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- Consulta 4 — Meses por encima/por debajo del promedio
WITH totales_mensuales AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM totales_mensuales)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM totales_mensuales
ORDER BY mes;


/* ============================================================
   Hallazgos

   1. El producto 1 concentra el 55,9% de la facturación total del período
      ($3.600 de $6.444), muy por encima del resto del ranking (el segundo
      puesto, producto 3, factura menos de la mitad: $1.350).

   2. El 100% de la facturación ($6.444) proviene de clientes recurrentes
      (ids 1, 2, 3, 4 y 5, cada uno con exactamente 2 pedidos). En este
      período no se registraron compradores de una sola compra.

   3. Los datos disponibles corresponden a un único mes (mes 3), por lo que
      la comparación contra el promedio general todavía no es representativa:
      al no haber otros meses, el promedio coincide con el total de ese mes,
      y por eso la Consulta 4 lo clasifica como 'Por debajo' (no es
      estrictamente mayor a sí mismo). Esta consulta va a tomar más sentido
      cuando se carguen ventas de varios meses.
   ============================================================ */
