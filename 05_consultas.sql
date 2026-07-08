-- 1) JOIN entre varias tablas: reservas de hotel con cliente y habitación
SELECT
    c.nombre || ' ' || c.apellido AS cliente,
    h.nombre                       AS hotel,
    hb.tipo_habitacion,
    r.precio_total,
    r.estado_reserva
FROM reservaciones r
JOIN itinerarios i   ON i.itinerario_id = r.itinerario_id
JOIN clientes c       ON c.cliente_id = i.cliente_id
JOIN habitaciones hb  ON hb.habitacion_id = r.habitacion_id
JOIN hoteles h        ON h.hotel_id = hb.hotel_id
WHERE r.tipo_reserva = 'HOTEL'
ORDER BY r.fecha_reserva;

-- 2) GROUP BY con COUNT/AVG/SUM: rating promedio e ingresos por hotel
SELECT
    h.hotel_id,
    h.nombre                              AS hotel,
    COUNT(DISTINCT rt.rating_id)          AS cantidad_ratings,
    ROUND(AVG(rt.puntuacion), 2)          AS rating_promedio,
    COALESCE(SUM(r.precio_total), 0)      AS ingresos_totales
FROM hoteles h
LEFT JOIN ratings rt
    ON rt.tipo_entidad = 'HOTEL' AND rt.entidad_id = h.hotel_id
LEFT JOIN habitaciones hb ON hb.hotel_id = h.hotel_id
LEFT JOIN reservaciones r
    ON r.habitacion_id = hb.habitacion_id AND r.tipo_reserva = 'HOTEL'
GROUP BY h.hotel_id, h.nombre
ORDER BY rating_promedio DESC NULLS LAST;

-- 3) WHERE complejo: vuelos desde América, precio < 700, >15 asientos, ago-sep 2026
SELECT
    v.vuelo_id,
    ao.nombre_ciudad  AS origen,
    ad.nombre_ciudad  AS destino,
    al.nombre         AS aerolinea,
    v.fecha_salida,
    v.precio,
    v.asientos_disponibles
FROM vuelos v
JOIN destinos ao      ON ao.destino_id = v.destino_origen_id
JOIN destinos ad       ON ad.destino_id = v.destino_llegada_id
JOIN aerolineas al     ON al.aerolinea_id = v.aerolinea_id
JOIN paises po          ON po.pais_id = ao.pais_id
WHERE po.continente = 'América'
  AND v.precio < 700
  AND v.asientos_disponibles > 15
  AND v.fecha_salida BETWEEN '2026-08-01' AND '2026-09-30'
ORDER BY v.precio ASC;
