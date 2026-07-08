-- Login y validación de duplicados por email
CREATE INDEX idx_clientes_email ON clientes (email);

-- JOIN frecuente: detalle de reservas por itinerario
CREATE INDEX idx_reservaciones_itinerario ON reservaciones (itinerario_id);

-- Búsqueda de vuelos por rango de fechas
CREATE INDEX idx_vuelos_fecha_salida ON vuelos (fecha_salida);

-- Cálculo de rating promedio por entidad (hotel/vuelo/destino)
CREATE INDEX idx_ratings_entidad ON ratings (tipo_entidad, entidad_id);

-- Listado de hoteles por destino
CREATE INDEX idx_hoteles_destino ON hoteles (destino_id);
