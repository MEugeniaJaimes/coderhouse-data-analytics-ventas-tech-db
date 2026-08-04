/* ============================================================
   M5 - Consultas con JOINs para el proyecto
   Proyecto: RetailPro
   Base de datos: Ventas_Tech_DB
   Tablas: categorias, clientes, productos, ventas

   NOTA sobre el modelo:
   - El modelo original (M2/M3) no incluye columnas de "segmento" 
     ni "región". Se usa "ciudad" (tabla clientes) como el dato 
     geográfico más cercano disponible.
   - La columna "canal" no existía en el modelo original que dimos. Le agregué  con ALTER TABLE + UPDATE antes
de esta entrega, asignando 
     'Online' / 'Presencial' a las 10 ventas ya cargadas, a modo 
     de dato de ejemplo para practicar UNION ALL.
   ============================================================ */
/* ------------------------------------------------------------
   Consulta 1 - Vista base del proyecto (INNER JOIN)
   Objetivo: una fila por venta, con todos los datos enriquecidos.
   Esta es la vista que va a alimentar el dashboard de Power BI.
   ------------------------------------------------------------ */
SELECT 
    v.fecha_venta                      AS fecha,
    c.nombre                           AS nombre_cliente,
    c.ciudad                           AS region,          -- no hay columna "región" ni "segmento" en el modelo
    p.nombre_producto                  AS nombre_producto,
    cat.nombre_categoria               AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario)   AS total_venta,
    v.canal
FROM ventas v
INNER JOIN clientes c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos p  ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;

/* ------------------------------------------------------------
   Consulta 2 - Clientes sin ventas (LEFT JOIN)
   Objetivo: clientes registrados que todavía no compraron nada.
   ------------------------------------------------------------ */
SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

/* ------------------------------------------------------------
   Consulta 3 - Productos sin ventas (LEFT JOIN)
   Objetivo: productos del catálogo sin ninguna venta registrada.
   ------------------------------------------------------------ */
SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v        ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL;


/* ------------------------------------------------------------
   Consulta 4 - Consolidado por canal (UNION ALL)
   Objetivo: apilar ventas Online y Presencial, identificando el 
   origen de cada fila, y calcular el total facturado por canal.
   ------------------------------------------------------------ */

-- Detalle fila por fila, con el canal de cada venta
SELECT 
    v.id_venta,
    v.fecha_venta,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    'Online' AS canal
FROM ventas v
WHERE v.canal = 'Online'

UNION ALL

SELECT 
    v.id_venta,
    v.fecha_venta,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    'Presencial' AS canal
FROM ventas v
WHERE v.canal = 'Presencial';


-- Total facturado por canal (resumen)
SELECT 
    canal,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY canal;
