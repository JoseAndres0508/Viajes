-- PAISES (10)
INSERT INTO paises (nombre, codigo_iso, continente) VALUES
('Costa Rica',       'CR', 'América'),
('México',            'MX', 'América'),
('España',            'ES', 'Europa'),
('Estados Unidos',    'US', 'América'),
('Francia',           'FR', 'Europa'),
('Italia',            'IT', 'Europa'),
('Brasil',            'BR', 'América'),
('Argentina',         'AR', 'América'),
('Japón',             'JP', 'Asia'),
('Canadá',            'CA', 'América');

-- DESTINOS (10)
INSERT INTO destinos (nombre_ciudad, pais_id, descripcion, zona_horaria, popularidad) VALUES
('San José',        1, 'Capital de Costa Rica, puerta de entrada a la naturaleza tropical', 'America/Costa_Rica', 70),
('Ciudad de México', 2, 'Metrópoli histórica con gastronomía y cultura milenaria', 'America/Mexico_City', 88),
('Barcelona',        3, 'Ciudad costera con arquitectura modernista', 'Europe/Madrid', 92),
('Madrid',           3, 'Capital española, arte y vida nocturna', 'Europe/Madrid', 85),
('Nueva York',       4, 'La ciudad que nunca duerme', 'America/New_York', 97),
('París',            5, 'Ciudad de la luz, romanticismo y museos', 'Europe/Paris', 96),
('Roma',             6, 'Ciudad eterna, historia y ruinas antiguas', 'Europe/Rome', 90),
('Río de Janeiro',   7, 'Playas icónicas y carnaval', 'America/Sao_Paulo', 82),
('Buenos Aires',     8, 'Tango, arquitectura europea y gastronomía', 'America/Argentina/Buenos_Aires', 75),
('Tokio',            9, 'Metrópoli futurista con tradición milenaria', 'Asia/Tokyo', 94);

-- HOTELES (12)
INSERT INTO hoteles (destino_id, nombre, categoria_estrellas, direccion, precio_noche_base) VALUES
(1, 'Hotel Grano de Oro',        4, 'Calle 30, San José',              120.00),
(1, 'Hostal Casa Verde',         2, 'Barrio Escalante, San José',       45.00),
(2, 'Gran Hotel Ciudad de México', 5, 'Av. Madero 1, CDMX',             210.00),
(3, 'Hotel Barceló Raval',       4, 'Rambla del Raval, Barcelona',      160.00),
(3, 'Hostal Gótico',             3, 'Barrio Gótico, Barcelona',          70.00),
(4, 'Hotel Villa Magna',         5, 'Paseo de la Castellana, Madrid',   280.00),
(5, 'The Plaza Hotel',           5, '5th Ave, Nueva York',              450.00),
(5, 'Pod Times Square',          3, 'Times Square, Nueva York',         150.00),
(6, 'Hotel Le Meurice',          5, 'Rue de Rivoli, París',             500.00),
(7, 'Hotel Artemide',            4, 'Via Nazionale, Roma',              180.00),
(8, 'Copacabana Palace',         5, 'Av. Atlântica, Río de Janeiro',    380.00),
(10, 'Park Hyatt Tokyo',         5, 'Shinjuku, Tokio',                  400.00);

-- HABITACIONES (16)
INSERT INTO habitaciones (hotel_id, tipo_habitacion, capacidad, precio_noche, disponible) VALUES
(1,  'Doble Estándar', 2, 120.00, TRUE),
(1,  'Suite Junior',   3, 190.00, TRUE),
(2,  'Individual',     1,  45.00, TRUE),
(3,  'Doble Deluxe',   2, 210.00, TRUE),
(3,  'Suite Presidencial', 4, 520.00, FALSE),
(4,  'Doble Estándar', 2, 160.00, TRUE),
(5,  'Individual',     1,  70.00, TRUE),
(6,  'Suite Ejecutiva',2, 350.00, TRUE),
(7,  'Doble Vista Central Park', 2, 480.00, TRUE),
(7,  'Suite Real',     4, 950.00, TRUE),
(8,  'Doble Estándar', 2, 150.00, TRUE),
(9,  'Suite Deluxe',   2, 600.00, TRUE),
(10, 'Doble Clásica',  2, 180.00, TRUE),
(11, 'Suite Vista al Mar', 3, 480.00, TRUE),
(12, 'Doble Estándar', 2, 400.00, TRUE),
(12, 'Suite Zen',      2, 650.00, TRUE);

-- AEROLINEAS (8)
INSERT INTO aerolineas (nombre, codigo_iata) VALUES
('LATAM Airlines',      'LA'),
('Avianca',             'AV'),
('American Airlines',   'AA'),
('Iberia',              'IB'),
('Air France',          'AF'),
('Alitalia',            'AZ'),
('Copa Airlines',       'CM'),
('Japan Airlines',      'JL');

-- VUELOS (15)
INSERT INTO vuelos (aerolinea_id, destino_origen_id, destino_llegada_id, fecha_salida, fecha_llegada, precio, asientos_disponibles) VALUES
(1, 1, 2,  '2026-08-10 06:30', '2026-08-10 09:10', 320.00, 45),
(2, 1, 4,  '2026-08-12 22:00', '2026-08-13 06:15', 480.00, 30),
(7, 1, 8,  '2026-09-01 14:20', '2026-09-01 22:05', 610.00, 20),
(3, 4, 5,  '2026-08-15 08:00', '2026-08-15 10:45', 520.00, 15),
(4, 4, 3,  '2026-08-18 11:00', '2026-08-18 12:15', 90.00,  60),
(5, 5, 6,  '2026-08-20 19:30', '2026-08-21 08:45', 610.00, 25),
(6, 6, 7,  '2026-08-22 07:15', '2026-08-22 09:00', 140.00, 50),
(1, 2, 9,  '2026-09-05 23:50', '2026-09-06 12:30', 590.00, 18),
(2, 2, 1,  '2026-09-10 07:00', '2026-09-10 09:35', 300.00, 40),
(8, 10, 5, '2026-09-14 01:20', '2026-09-14 21:10', 980.00, 12),
(1, 8, 9,  '2026-09-18 03:10', '2026-09-18 20:40', 720.00, 22),
(4, 3, 4,  '2026-09-20 09:45', '2026-09-20 11:00', 95.00,  55),
(3, 5, 4,  '2026-09-22 20:00', '2026-09-23 09:15', 540.00, 28),
(6, 7, 6,  '2026-09-25 15:30', '2026-09-25 17:20', 145.00, 47),
(7, 9, 1,  '2026-09-28 06:00', '2026-09-28 13:55', 615.00, 19);

-- CLIENTES (15)
INSERT INTO clientes (nombre, apellido, email, telefono, pais_id, fecha_registro) VALUES
('Ana',      'Rodríguez', 'ana.rodriguez@correo.com',    '8888-1111', 1, '2025-01-15'),
('Luis',     'Fernández', 'luis.fernandez@correo.com',   '8888-2222', 1, '2025-02-20'),
('María',    'González',  'maria.gonzalez@correo.com',   '55-1234-0001', 2, '2025-01-30'),
('Carlos',   'Jiménez',   'carlos.jimenez@correo.com',   '55-1234-0002', 2, '2025-03-05'),
('Laura',    'Martínez',  'laura.martinez@correo.com',   '+34-600-111-222', 3, '2025-02-10'),
('Javier',   'López',     'javier.lopez@correo.com',     '+34-600-333-444', 3, '2025-04-01'),
('Emily',    'Johnson',   'emily.johnson@correo.com',    '+1-212-555-0101', 4, '2025-01-22'),
('Michael',  'Smith',     'michael.smith@correo.com',    '+1-212-555-0102', 4, '2025-05-18'),
('Sophie',   'Dubois',    'sophie.dubois@correo.com',    '+33-6-11-22-33', 5, '2025-03-14'),
('Marco',    'Rossi',     'marco.rossi@correo.com',      '+39-320-111-222', 6, '2025-02-27'),
('Beatriz',  'Souza',     'beatriz.souza@correo.com',    '+55-21-99999-0001', 7, '2025-06-01'),
('Diego',    'Fernández', 'diego.fernandez@correo.com',  '+54-11-4444-0001', 8, '2025-03-30'),
('Yuki',     'Tanaka',    'yuki.tanaka@correo.com',      '+81-90-1111-2222', 9, '2025-04-19'),
('Sarah',    'Brown',     'sarah.brown@correo.com',      '+1-416-555-0110', 10, '2025-05-05'),
('Pablo',    'Chaves',    'pablo.chaves@correo.com',     '8888-3333', 1, '2025-06-12');

-- ITINERARIOS (13)
INSERT INTO itinerarios (cliente_id, nombre_viaje, fecha_inicio, fecha_fin, estado, fecha_creacion) VALUES
(1,  'Escapada a México',        '2026-08-10', '2026-08-14', 'CONFIRMADO', '2026-06-01 10:00'),
(2,  'Vacaciones en EE.UU.',     '2026-08-12', '2026-08-20', 'CONFIRMADO', '2026-06-02 11:15'),
(3,  'Ruta Europea',             '2026-08-15', '2026-08-25', 'PLANIFICADO', '2026-06-03 09:30'),
(4,  'Negocios en Barcelona',    '2026-08-18', '2026-08-19', 'CONFIRMADO', '2026-06-04 14:20'),
(5,  'Luna de miel en París',    '2026-08-20', '2026-08-27', 'CONFIRMADO', '2026-06-05 16:00'),
(6,  'Fin de semana en Roma',    '2026-08-22', '2026-08-24', 'PLANIFICADO', '2026-06-06 08:45'),
(7,  'Tour por Sudamérica',      '2026-09-01', '2026-09-08', 'PLANIFICADO', '2026-06-10 12:00'),
(8,  'Aventura en Tokio',        '2026-09-05', '2026-09-12', 'CONFIRMADO', '2026-06-11 13:10'),
(9,  'Reencuentro familiar CR',  '2026-09-10', '2026-09-14', 'PLANIFICADO', '2026-06-12 17:40'),
(10, 'Congreso en Nueva York',   '2026-09-14', '2026-09-16', 'CONFIRMADO', '2026-06-13 09:05'),
(11, 'Vacaciones en Tokio',      '2026-09-18', '2026-09-25', 'PLANIFICADO', '2026-06-14 15:30'),
(12, 'Viaje corto a Barcelona',  '2026-09-20', '2026-09-21', 'CANCELADO',  '2026-06-15 10:50'),
(13, 'Ruta gastronómica Roma',   '2026-09-25', '2026-09-27', 'PLANIFICADO', '2026-06-16 18:25');

-- RESERVACIONES (18: mezcla HOTEL / VUELO)
INSERT INTO reservaciones (itinerario_id, tipo_reserva, habitacion_id, vuelo_id, cantidad_personas, precio_total, estado_reserva, fecha_reserva) VALUES
(1,  'VUELO', NULL, 1,  1, 320.00,  'CONFIRMADA', '2026-06-01 10:05'),
(1,  'HOTEL', 3,    NULL, 1, 180.00,  'CONFIRMADA', '2026-06-01 10:10'),
(2,  'VUELO', NULL, 2,  2, 960.00,  'CONFIRMADA', '2026-06-02 11:20'),
(2,  'HOTEL', 9,    NULL, 2, 3840.00,'CONFIRMADA', '2026-06-02 11:25'),
(3,  'VUELO', NULL, 4,  1, 520.00,  'PENDIENTE',  '2026-06-03 09:35'),
(3,  'HOTEL', 6,    NULL, 1, 1600.00,'PENDIENTE',  '2026-06-03 09:40'),
(4,  'HOTEL', 6,    NULL, 1, 160.00,  'CONFIRMADA', '2026-06-04 14:25'),
(4,  'VUELO', NULL, 5,  1, 90.00,   'CONFIRMADA', '2026-06-04 14:30'),
(5,  'VUELO', NULL, 6,  2, 1220.00,'CONFIRMADA', '2026-06-05 16:05'),
(5,  'HOTEL', 8,    NULL, 2, 2450.00,'CONFIRMADA', '2026-06-05 16:10'),
(6,  'VUELO', NULL, 7,  1, 140.00,  'PENDIENTE',  '2026-06-06 08:50'),
(7,  'VUELO', NULL, 3,  1, 610.00,  'PENDIENTE',  '2026-06-10 12:05'),
(8,  'VUELO', NULL, 8,  1, 590.00,  'CONFIRMADA', '2026-06-11 13:15'),
(8,  'HOTEL', 12,   NULL, 1, 4200.00,'CONFIRMADA', '2026-06-11 13:20'),
(9,  'VUELO', NULL, 9,  1, 300.00,  'PENDIENTE',  '2026-06-12 17:45'),
(10, 'VUELO', NULL, 10, 1, 980.00,  'CONFIRMADA', '2026-06-13 09:10'),
(10, 'HOTEL', 9,    NULL, 1, 1000.00,'CONFIRMADA', '2026-06-13 09:15'),
(13, 'HOTEL', 10,   NULL, 2, 360.00,  'CANCELADA',  '2026-06-16 18:30');

-- RATINGS (16, sistema distribuido con nodo_origen)
INSERT INTO ratings (cliente_id, tipo_entidad, entidad_id, puntuacion, comentario, nodo_origen, verificado, fecha_rating) VALUES
(1,  'HOTEL',   3, 5, 'Excelente ubicación y servicio impecable', 'NODO-AMERICA',  TRUE,  '2026-08-15 09:00'),
(1,  'VUELO',   1, 4, 'Vuelo puntual, buen espacio para piernas', 'NODO-AMERICA',  TRUE,  '2026-08-11 08:30'),
(2,  'HOTEL',   9, 4, 'Habitación amplia, wifi lento', 'NODO-AMERICA',  TRUE,  '2026-08-21 10:15'),
(2,  'VUELO',   2, 3, 'Retraso de 40 minutos en la salida', 'NODO-AMERICA',  FALSE, '2026-08-13 07:00'),
(3,  'DESTINO', 4, 5, 'Madrid tiene una vida cultural increíble', 'NODO-EUROPA',   TRUE,  '2026-08-19 20:10'),
(4,  'HOTEL',   6, 4, 'Muy elegante, precio alto pero justificado', 'NODO-EUROPA',   TRUE,  '2026-08-19 21:00'),
(5,  'VUELO',   6, 5, 'La mejor experiencia en clase ejecutiva', 'NODO-EUROPA',   TRUE,  '2026-08-21 09:00'),
(5,  'HOTEL',   8, 5, 'Vistas espectaculares a Central Park', 'NODO-AMERICA',  TRUE,  '2026-08-27 11:30'),
(6,  'DESTINO', 7, 4, 'Roma es hermosa pero muy concurrida', 'NODO-EUROPA',   FALSE, '2026-08-24 18:00'),
(7,  'VUELO',   3, 2, 'Cancelación de último momento sin aviso', 'NODO-AMERICA',  TRUE,  '2026-09-01 15:00'),
(8,  'HOTEL',  12, 5, 'Servicio de spa excepcional en Tokio', 'NODO-ASIA',     TRUE,  '2026-09-12 22:00'),
(9,  'DESTINO', 1, 4, 'San José como punto de partida es cómodo', 'NODO-AMERICA',  FALSE, '2026-09-14 12:00'),
(10, 'HOTEL',   7, 5, 'Lujo total, vale cada centavo', 'NODO-AMERICA',  TRUE,  '2026-09-16 10:00'),
(11, 'DESTINO', 10,5, 'Tokio combina tradición y modernidad perfectamente', 'NODO-ASIA', TRUE, '2026-09-25 19:00'),
(13, 'DESTINO', 7, 3, 'Muchas colas para entrar a los museos', 'NODO-EUROPA',   FALSE, '2026-09-27 16:20'),
(14, 'VUELO',  10, 4, 'Buen servicio a bordo en vuelo largo', 'NODO-ASIA',     TRUE,  '2026-09-14 08:00');


