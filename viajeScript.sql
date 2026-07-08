-- =============================================================================
-- PROYECTO INTEGRADOR - ISW-522 CLASE 7
-- TEMA: PLATAFORMA DE VIAJES GLOBAL
-- Destinos, Hoteles, Vuelos, Reservaciones, Itinerarios, Rating Distribuido
-- Motor: PostgreSQL 16 | Script único, ejecutable de una sola vez sin errores
-- Orden: limpieza -> DDL -> datos -> EXPLAIN ANALYZE (antes) -> índices ->
--        EXPLAIN ANALYZE (después) -> seguridad -> consultas de ejemplo
-- =============================================================================


-- =============================================================================
-- 1. LIMPIEZA PREVIA (permite re-ejecutar el script sin errores)
-- =============================================================================
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS reservaciones CASCADE;
DROP TABLE IF EXISTS itinerarios CASCADE;
DROP TABLE IF EXISTS vuelos CASCADE;
DROP TABLE IF EXISTS aerolineas CASCADE;
DROP TABLE IF EXISTS habitaciones CASCADE;
DROP TABLE IF EXISTS hoteles CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS destinos CASCADE;
DROP TABLE IF EXISTS paises CASCADE;
DROP ROLE IF EXISTS operativo;
DROP ROLE IF EXISTS administrador;


-- =============================================================================
-- 2. DDL - CREATE TABLE
-- 10 tablas, cada una con su propósito, PK/FK, NOT NULL, UNIQUE, CHECK, DEFAULT.
-- =============================================================================

-- Catálogo de países: origen de clientes y ubicación de destinos.
CREATE TABLE paises (
    pais_id      SERIAL PRIMARY KEY,
    nombre       VARCHAR(80) NOT NULL,
    codigo_iso   CHAR(2) NOT NULL UNIQUE,     -- ISO 3166-1 alpha-2
    continente   VARCHAR(30) NOT NULL
);

-- Ciudades/destinos turísticos ofrecidos por la plataforma. 1 país : N destinos.
CREATE TABLE destinos (
    destino_id      SERIAL PRIMARY KEY,
    nombre_ciudad   VARCHAR(100) NOT NULL,
    pais_id         INTEGER NOT NULL,
    descripcion     VARCHAR(300),
    zona_horaria    VARCHAR(50) NOT NULL,
    popularidad     SMALLINT NOT NULL DEFAULT 0 CHECK (popularidad BETWEEN 0 AND 100),
    CONSTRAINT fk_destino_pais FOREIGN KEY (pais_id)
        REFERENCES paises (pais_id) ON DELETE RESTRICT
);

-- Hoteles disponibles por destino. 1 destino : N hoteles.
CREATE TABLE hoteles (
    hotel_id             SERIAL PRIMARY KEY,
    destino_id           INTEGER NOT NULL,
    nombre               VARCHAR(120) NOT NULL,
    categoria_estrellas  SMALLINT NOT NULL CHECK (categoria_estrellas BETWEEN 1 AND 5),
    direccion            VARCHAR(200) NOT NULL,
    precio_noche_base    NUMERIC(10,2) NOT NULL CHECK (precio_noche_base > 0),
    CONSTRAINT fk_hotel_destino FOREIGN KEY (destino_id)
        REFERENCES destinos (destino_id) ON DELETE CASCADE
);

-- Tipos de habitación por hotel. 1 hotel : N habitaciones.
CREATE TABLE habitaciones (
    habitacion_id   SERIAL PRIMARY KEY,
    hotel_id        INTEGER NOT NULL,
    tipo_habitacion VARCHAR(50) NOT NULL,
    capacidad       SMALLINT NOT NULL CHECK (capacidad BETWEEN 1 AND 10),
    precio_noche    NUMERIC(10,2) NOT NULL CHECK (precio_noche > 0),
    disponible      BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_habitacion_hotel FOREIGN KEY (hotel_id)
        REFERENCES hoteles (hotel_id) ON DELETE CASCADE
);

-- Catálogo de aerolíneas que operan vuelos en la plataforma.
CREATE TABLE aerolineas (
    aerolinea_id  SERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    codigo_iata   CHAR(2) NOT NULL UNIQUE
);

-- Vuelos entre destinos. N:1 con aerolineas, N:1 con destinos (origen y llegada).
CREATE TABLE vuelos (
    vuelo_id             SERIAL PRIMARY KEY,
    aerolinea_id         INTEGER NOT NULL,
    destino_origen_id    INTEGER NOT NULL,
    destino_llegada_id   INTEGER NOT NULL,
    fecha_salida         TIMESTAMP NOT NULL,
    fecha_llegada        TIMESTAMP NOT NULL,
    precio               NUMERIC(10,2) NOT NULL CHECK (precio > 0),
    asientos_disponibles INTEGER NOT NULL DEFAULT 0 CHECK (asientos_disponibles >= 0),
    CONSTRAINT fk_vuelo_aerolinea FOREIGN KEY (aerolinea_id)
        REFERENCES aerolineas (aerolinea_id) ON DELETE RESTRICT,
    CONSTRAINT fk_vuelo_origen FOREIGN KEY (destino_origen_id)
        REFERENCES destinos (destino_id) ON DELETE RESTRICT,
    CONSTRAINT fk_vuelo_llegada FOREIGN KEY (destino_llegada_id)
        REFERENCES destinos (destino_id) ON DELETE RESTRICT,
    CONSTRAINT chk_vuelo_fechas CHECK (fecha_llegada > fecha_salida),
    CONSTRAINT chk_vuelo_rutas CHECK (destino_origen_id <> destino_llegada_id)
);

-- Usuarios que reservan en la plataforma.
CREATE TABLE clientes (
    cliente_id      SERIAL PRIMARY KEY,
    nombre          VARCHAR(60) NOT NULL,
    apellido        VARCHAR(60) NOT NULL,
    email           VARCHAR(120) NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    pais_id         INTEGER NOT NULL,
    fecha_registro  DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_cliente_pais FOREIGN KEY (pais_id)
        REFERENCES paises (pais_id) ON DELETE RESTRICT
);

-- Viaje planificado por un cliente; agrupa varias reservaciones. 1 cliente : N itinerarios.
CREATE TABLE itinerarios (
    itinerario_id    SERIAL PRIMARY KEY,
    cliente_id       INTEGER NOT NULL,
    nombre_viaje     VARCHAR(120) NOT NULL,
    fecha_inicio     DATE NOT NULL,
    fecha_fin        DATE NOT NULL,
    estado           VARCHAR(20) NOT NULL DEFAULT 'PLANIFICADO'
                        CHECK (estado IN ('PLANIFICADO','CONFIRMADO','EN_CURSO','COMPLETADO','CANCELADO')),
    fecha_creacion   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_itinerario_cliente FOREIGN KEY (cliente_id)
        REFERENCES clientes (cliente_id) ON DELETE CASCADE,
    CONSTRAINT chk_itinerario_fechas CHECK (fecha_fin >= fecha_inicio)
);

-- Reserva de hotel o vuelo dentro de un itinerario.
-- Resuelve la relación M:N entre clientes<->hoteles y clientes<->vuelos vía itinerarios.
-- El CHECK final obliga exclusividad: HOTEL usa solo habitacion_id, VUELO usa solo vuelo_id.
CREATE TABLE reservaciones (
    reservacion_id    SERIAL PRIMARY KEY,
    itinerario_id     INTEGER NOT NULL,
    tipo_reserva      VARCHAR(10) NOT NULL CHECK (tipo_reserva IN ('HOTEL','VUELO')),
    habitacion_id     INTEGER,
    vuelo_id          INTEGER,
    cantidad_personas SMALLINT NOT NULL DEFAULT 1 CHECK (cantidad_personas > 0),
    precio_total      NUMERIC(10,2) NOT NULL CHECK (precio_total > 0),
    estado_reserva    VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE'
                        CHECK (estado_reserva IN ('PENDIENTE','CONFIRMADA','CANCELADA','COMPLETADA')),
    fecha_reserva     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reservacion_itinerario FOREIGN KEY (itinerario_id)
        REFERENCES itinerarios (itinerario_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservacion_habitacion FOREIGN KEY (habitacion_id)
        REFERENCES habitaciones (habitacion_id) ON DELETE RESTRICT,
    CONSTRAINT fk_reservacion_vuelo FOREIGN KEY (vuelo_id)
        REFERENCES vuelos (vuelo_id) ON DELETE RESTRICT,
    CONSTRAINT chk_reservacion_tipo CHECK (
        (tipo_reserva = 'HOTEL' AND habitacion_id IS NOT NULL AND vuelo_id IS NULL)
        OR
        (tipo_reserva = 'VUELO' AND vuelo_id IS NOT NULL AND habitacion_id IS NULL)
    )
);

-- Sistema de rating distribuido: clientes califican hoteles, vuelos o destinos.
-- entidad_id es una FK polimórfica (según tipo_entidad), no se referencia con FK real.
-- nodo_origen identifica el nodo/servidor regional que generó el registro.
CREATE TABLE ratings (
    rating_id      SERIAL PRIMARY KEY,
    cliente_id     INTEGER NOT NULL,
    tipo_entidad   VARCHAR(10) NOT NULL CHECK (tipo_entidad IN ('HOTEL','VUELO','DESTINO')),
    entidad_id     INTEGER NOT NULL,
    puntuacion     SMALLINT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    comentario     VARCHAR(300),
    nodo_origen    VARCHAR(20) NOT NULL DEFAULT 'NODO-CENTRAL',
    verificado     BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_rating   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rating_cliente FOREIGN KEY (cliente_id)
        REFERENCES clientes (cliente_id) ON DELETE CASCADE
);


-- =============================================================================
-- 3. DATOS DE EJEMPLO (DML) - casos reales, respetan FK y constraints
-- =============================================================================

INSERT INTO paises (nombre, codigo_iso, continente) VALUES
('Costa Rica','CR','América'),('México','MX','América'),('España','ES','Europa'),
('Estados Unidos','US','América'),('Francia','FR','Europa'),('Italia','IT','Europa'),
('Brasil','BR','América'),('Argentina','AR','América'),('Japón','JP','Asia'),
('Canadá','CA','América'),('Alemania','DE','Europa'),('Reino Unido','GB','Europa'),
('Portugal','PT','Europa'),('Chile','CL','América'),('Colombia','CO','América'),
('Perú','PE','América'),('China','CN','Asia'),('Corea del Sur','KR','Asia'),
('Australia','AU','Oceanía'),('Países Bajos','NL','Europa');

INSERT INTO destinos (nombre_ciudad, pais_id, descripcion, zona_horaria, popularidad) VALUES
('San José',1,'Capital de Costa Rica, puerta a la naturaleza tropical','America/Costa_Rica',70),
('Ciudad de México',2,'Metrópoli histórica con gastronomía y cultura milenaria','America/Mexico_City',88),
('Barcelona',3,'Ciudad costera con arquitectura modernista','Europe/Madrid',92),
('Madrid',3,'Capital española, arte y vida nocturna','Europe/Madrid',85),
('Nueva York',4,'La ciudad que nunca duerme','America/New_York',97),
('París',5,'Ciudad de la luz, romanticismo y museos','Europe/Paris',96),
('Roma',6,'Ciudad eterna, historia y ruinas antiguas','Europe/Rome',90),
('Río de Janeiro',7,'Playas icónicas y carnaval','America/Sao_Paulo',82),
('Buenos Aires',8,'Tango, arquitectura europea y gastronomía','America/Argentina/Buenos_Aires',75),
('Tokio',9,'Metrópoli futurista con tradición milenaria','Asia/Tokyo',94),
('Berlín',11,'Historia, arte y vida nocturna en Alemania','Europe/Berlin',80),
('Londres',12,'Capital británica, museos y teatro','Europe/London',93),
('Lisboa',13,'Ciudad costera de calles empedradas','Europe/Lisbon',78),
('Santiago',14,'Puerta de entrada a los Andes chilenos','America/Santiago',72),
('Bogotá',15,'Capital colombiana en la cordillera','America/Bogota',68),
('Lima',16,'Capital gastronómica de Sudamérica','America/Lima',71),
('Beijing',17,'Capital histórica de China','Asia/Shanghai',84),
('Seúl',18,'Metrópoli tecnológica y cultural','Asia/Seoul',86),
('Sídney',19,'Puerto icónico y playas urbanas','Australia/Sydney',89),
('Ámsterdam',20,'Canales, museos y bicicletas','Europe/Amsterdam',91);

INSERT INTO hoteles (destino_id, nombre, categoria_estrellas, direccion, precio_noche_base) VALUES
(1,'Hotel Grano de Oro',4,'Calle 30, San José',120.00),
(1,'Hostal Casa Verde',2,'Barrio Escalante, San José',45.00),
(2,'Gran Hotel Ciudad de México',5,'Av. Madero 1, CDMX',210.00),
(3,'Hotel Barceló Raval',4,'Rambla del Raval, Barcelona',160.00),
(3,'Hostal Gótico',3,'Barrio Gótico, Barcelona',70.00),
(4,'Hotel Villa Magna',5,'Paseo de la Castellana, Madrid',280.00),
(5,'The Plaza Hotel',5,'5th Ave, Nueva York',450.00),
(5,'Pod Times Square',3,'Times Square, Nueva York',150.00),
(6,'Hotel Le Meurice',5,'Rue de Rivoli, París',500.00),
(7,'Hotel Artemide',4,'Via Nazionale, Roma',180.00),
(8,'Copacabana Palace',5,'Av. Atlântica, Río de Janeiro',380.00),
(10,'Park Hyatt Tokyo',5,'Shinjuku, Tokio',400.00),
(11,'Hotel Adlon Kempinski',5,'Unter den Linden, Berlín',380.00),
(12,'The Savoy',5,'Strand, Londres',420.00),
(13,'Hotel Avenida Palace',4,'Rossio, Lisboa',150.00),
(14,'Hotel Plaza San Francisco',4,'Alameda, Santiago',130.00),
(15,'Hotel De La Ópera',4,'La Candelaria, Bogotá',110.00),
(16,'Belmond Miraflores Park',5,'Miraflores, Lima',260.00),
(17,'Beijing Hotel NUO',5,'Chaoyang, Beijing',190.00),
(18,'Lotte Hotel Seoul',5,'Jung-gu, Seúl',230.00);

INSERT INTO habitaciones (hotel_id, tipo_habitacion, capacidad, precio_noche, disponible) VALUES
(1,'Doble Estándar',2,120.00,TRUE),(1,'Suite Junior',3,190.00,TRUE),
(2,'Individual',1,45.00,TRUE),
(3,'Doble Deluxe',2,210.00,TRUE),(3,'Suite Presidencial',4,520.00,FALSE),
(4,'Doble Estándar',2,160.00,TRUE),
(5,'Individual',1,70.00,TRUE),
(6,'Suite Ejecutiva',2,350.00,TRUE),
(7,'Doble Vista Central Park',2,480.00,TRUE),(7,'Suite Real',4,950.00,TRUE),
(8,'Doble Estándar',2,150.00,TRUE),
(9,'Suite Deluxe',2,600.00,TRUE),
(10,'Doble Clásica',2,180.00,TRUE),
(11,'Suite Vista al Mar',3,480.00,TRUE),
(12,'Doble Estándar',2,400.00,TRUE),(12,'Suite Zen',2,650.00,TRUE),
(13,'Suite Berlín',2,300.00,TRUE),
(15,'Doble Lisboa',2,140.00,TRUE),
(18,'Doble Lima',2,220.00,TRUE),
(20,'Suite Seúl',2,350.00,TRUE);

INSERT INTO aerolineas (nombre, codigo_iata) VALUES
('LATAM Airlines','LA'),('Avianca','AV'),('American Airlines','AA'),('Iberia','IB'),
('Air France','AF'),('Alitalia','AZ'),('Copa Airlines','CM'),('Japan Airlines','JL'),
('Lufthansa','LH'),('British Airways','BA'),('TAP Air Portugal','TP'),('Qantas','QF'),
('KLM','KL'),('Korean Air','KE'),('China Southern','CZ'),('LATAM Perú','4M'),
('Air Canada','AC'),('Emirates','EK'),('Turkish Airlines','TK'),('Singapore Airlines','SQ');

INSERT INTO vuelos (aerolinea_id, destino_origen_id, destino_llegada_id, fecha_salida, fecha_llegada, precio, asientos_disponibles) VALUES
(1,1,2,'2026-08-10 06:30','2026-08-10 09:10',320.00,45),
(2,1,4,'2026-08-12 22:00','2026-08-13 06:15',480.00,30),
(7,1,8,'2026-09-01 14:20','2026-09-01 22:05',610.00,20),
(3,4,5,'2026-08-15 08:00','2026-08-15 10:45',520.00,15),
(4,4,3,'2026-08-18 11:00','2026-08-18 12:15',90.00,60),
(5,5,6,'2026-08-20 19:30','2026-08-21 08:45',610.00,25),
(6,6,7,'2026-08-22 07:15','2026-08-22 09:00',140.00,50),
(1,2,9,'2026-09-05 23:50','2026-09-06 12:30',590.00,18),
(2,2,1,'2026-09-10 07:00','2026-09-10 09:35',300.00,40),
(8,10,5,'2026-09-14 01:20','2026-09-14 21:10',980.00,12),
(1,8,9,'2026-09-18 03:10','2026-09-18 20:40',720.00,22),
(4,3,4,'2026-09-20 09:45','2026-09-20 11:00',95.00,55),
(3,5,4,'2026-09-22 20:00','2026-09-23 09:15',540.00,28),
(6,7,6,'2026-09-25 15:30','2026-09-25 17:20',145.00,47),
(7,9,1,'2026-09-28 06:00','2026-09-28 13:55',615.00,19),
(9,11,6,'2026-10-02 07:00','2026-10-02 09:00',120.00,80),
(10,12,5,'2026-10-05 10:00','2026-10-05 18:30',650.00,40),
(13,20,12,'2026-10-08 09:00','2026-10-08 10:15',95.00,100),
(14,18,10,'2026-10-10 14:00','2026-10-10 16:20',210.00,60),
(12,19,9,'2026-10-12 23:00','2026-10-13 09:00',890.00,30);

INSERT INTO clientes (nombre, apellido, email, telefono, pais_id, fecha_registro) VALUES
('Ana','Rodríguez','ana.rodriguez@correo.com','8888-1111',1,'2025-01-15'),
('Luis','Fernández','luis.fernandez@correo.com','8888-2222',1,'2025-02-20'),
('María','González','maria.gonzalez@correo.com','55-1234-0001',2,'2025-01-30'),
('Carlos','Jiménez','carlos.jimenez@correo.com','55-1234-0002',2,'2025-03-05'),
('Laura','Martínez','laura.martinez@correo.com','+34-600-111-222',3,'2025-02-10'),
('Javier','López','javier.lopez@correo.com','+34-600-333-444',3,'2025-04-01'),
('Emily','Johnson','emily.johnson@correo.com','+1-212-555-0101',4,'2025-01-22'),
('Michael','Smith','michael.smith@correo.com','+1-212-555-0102',4,'2025-05-18'),
('Sophie','Dubois','sophie.dubois@correo.com','+33-6-11-22-33',5,'2025-03-14'),
('Marco','Rossi','marco.rossi@correo.com','+39-320-111-222',6,'2025-02-27'),
('Beatriz','Souza','beatriz.souza@correo.com','+55-21-99999-0001',7,'2025-06-01'),
('Diego','Fernández','diego.fernandez@correo.com','+54-11-4444-0001',8,'2025-03-30'),
('Yuki','Tanaka','yuki.tanaka@correo.com','+81-90-1111-2222',9,'2025-04-19'),
('Sarah','Brown','sarah.brown@correo.com','+1-416-555-0110',10,'2025-05-05'),
('Pablo','Chaves','pablo.chaves@correo.com','8888-3333',1,'2025-06-12'),
('Hans','Müller','hans.muller@correo.com','+49-30-1111-0001',11,'2025-07-01'),
('Oliver','Smith','oliver.smith@correo.com','+44-20-2222-0001',12,'2025-07-05'),
('Camila','Silva','camila.silva@correo.com','+56-2-3333-0001',14,'2025-07-10'),
('Wei','Zhang','wei.zhang@correo.com','+86-10-4444-0001',17,'2025-07-15'),
('Mia','Wilson','mia.wilson@correo.com','+61-2-5555-0001',19,'2025-07-20');

INSERT INTO itinerarios (cliente_id, nombre_viaje, fecha_inicio, fecha_fin, estado, fecha_creacion) VALUES
(1,'Escapada a México','2026-08-10','2026-08-14','CONFIRMADO','2026-06-01 10:00'),
(2,'Vacaciones en EE.UU.','2026-08-12','2026-08-20','CONFIRMADO','2026-06-02 11:15'),
(3,'Ruta Europea','2026-08-15','2026-08-25','PLANIFICADO','2026-06-03 09:30'),
(4,'Negocios en Barcelona','2026-08-18','2026-08-19','CONFIRMADO','2026-06-04 14:20'),
(5,'Luna de miel en París','2026-08-20','2026-08-27','CONFIRMADO','2026-06-05 16:00'),
(6,'Fin de semana en Roma','2026-08-22','2026-08-24','PLANIFICADO','2026-06-06 08:45'),
(7,'Tour por Sudamérica','2026-09-01','2026-09-08','PLANIFICADO','2026-06-10 12:00'),
(8,'Aventura en Tokio','2026-09-05','2026-09-12','CONFIRMADO','2026-06-11 13:10'),
(9,'Reencuentro familiar CR','2026-09-10','2026-09-14','PLANIFICADO','2026-06-12 17:40'),
(10,'Congreso en Nueva York','2026-09-14','2026-09-16','CONFIRMADO','2026-06-13 09:05'),
(11,'Vacaciones en Tokio','2026-09-18','2026-09-25','PLANIFICADO','2026-06-14 15:30'),
(12,'Viaje corto a Barcelona','2026-09-20','2026-09-21','CANCELADO','2026-06-15 10:50'),
(13,'Ruta gastronómica Roma','2026-09-25','2026-09-27','PLANIFICADO','2026-06-16 18:25'),
(14,'Congreso en Londres','2026-10-05','2026-10-07','CONFIRMADO','2026-06-17 09:00'),
(15,'Viaje a Berlín','2026-10-02','2026-10-06','PLANIFICADO','2026-06-18 10:30'),
(16,'Visita a París','2026-10-02','2026-10-04','CONFIRMADO','2026-06-19 11:45'),
(17,'Negocios en Nueva York','2026-10-05','2026-10-08','PLANIFICADO','2026-06-20 13:00'),
(18,'Tour asiático','2026-10-10','2026-10-15','PLANIFICADO','2026-06-21 14:15'),
(19,'Turismo en Tokio','2026-10-10','2026-10-14','CONFIRMADO','2026-06-22 15:30'),
(20,'Vacaciones en Sudamérica','2026-10-12','2026-10-20','PLANIFICADO','2026-06-23 16:45');

INSERT INTO reservaciones (itinerario_id, tipo_reserva, habitacion_id, vuelo_id, cantidad_personas, precio_total, estado_reserva, fecha_reserva) VALUES
(1,'VUELO',NULL,1,1,320.00,'CONFIRMADA','2026-06-01 10:05'),
(1,'HOTEL',3,NULL,1,180.00,'CONFIRMADA','2026-06-01 10:10'),
(2,'VUELO',NULL,2,2,960.00,'CONFIRMADA','2026-06-02 11:20'),
(2,'HOTEL',9,NULL,2,3840.00,'CONFIRMADA','2026-06-02 11:25'),
(3,'VUELO',NULL,4,1,520.00,'PENDIENTE','2026-06-03 09:35'),
(3,'HOTEL',6,NULL,1,1600.00,'PENDIENTE','2026-06-03 09:40'),
(4,'HOTEL',6,NULL,1,160.00,'CONFIRMADA','2026-06-04 14:25'),
(4,'VUELO',NULL,5,1,90.00,'CONFIRMADA','2026-06-04 14:30'),
(5,'VUELO',NULL,6,2,1220.00,'CONFIRMADA','2026-06-05 16:05'),
(5,'HOTEL',8,NULL,2,2450.00,'CONFIRMADA','2026-06-05 16:10'),
(6,'VUELO',NULL,7,1,140.00,'PENDIENTE','2026-06-06 08:50'),
(7,'VUELO',NULL,3,1,610.00,'PENDIENTE','2026-06-10 12:05'),
(8,'VUELO',NULL,8,1,590.00,'CONFIRMADA','2026-06-11 13:15'),
(8,'HOTEL',12,NULL,1,4200.00,'CONFIRMADA','2026-06-11 13:20'),
(9,'VUELO',NULL,9,1,300.00,'PENDIENTE','2026-06-12 17:45'),
(10,'VUELO',NULL,10,1,980.00,'CONFIRMADA','2026-06-13 09:10'),
(10,'HOTEL',9,NULL,1,1000.00,'CONFIRMADA','2026-06-13 09:15'),
(13,'HOTEL',10,NULL,2,360.00,'CANCELADA','2026-06-16 18:30'),
(16,'VUELO',NULL,16,1,120.00,'CONFIRMADA','2026-06-19 11:50'),
(19,'VUELO',NULL,19,1,210.00,'CONFIRMADA','2026-06-22 15:35');

INSERT INTO ratings (cliente_id, tipo_entidad, entidad_id, puntuacion, comentario, nodo_origen, verificado, fecha_rating) VALUES
(1,'HOTEL',3,5,'Excelente ubicación y servicio impecable','NODO-AMERICA',TRUE,'2026-08-15 09:00'),
(1,'VUELO',1,4,'Vuelo puntual, buen espacio para piernas','NODO-AMERICA',TRUE,'2026-08-11 08:30'),
(2,'HOTEL',9,4,'Habitación amplia, wifi lento','NODO-AMERICA',TRUE,'2026-08-21 10:15'),
(2,'VUELO',2,3,'Retraso de 40 minutos en la salida','NODO-AMERICA',FALSE,'2026-08-13 07:00'),
(3,'DESTINO',4,5,'Madrid tiene una vida cultural increíble','NODO-EUROPA',TRUE,'2026-08-19 20:10'),
(4,'HOTEL',6,4,'Muy elegante, precio alto pero justificado','NODO-EUROPA',TRUE,'2026-08-19 21:00'),
(5,'VUELO',6,5,'La mejor experiencia en clase ejecutiva','NODO-EUROPA',TRUE,'2026-08-21 09:00'),
(5,'HOTEL',8,5,'Vistas espectaculares a Central Park','NODO-AMERICA',TRUE,'2026-08-27 11:30'),
(6,'DESTINO',7,4,'Roma es hermosa pero muy concurrida','NODO-EUROPA',FALSE,'2026-08-24 18:00'),
(7,'VUELO',3,2,'Cancelación de último momento sin aviso','NODO-AMERICA',TRUE,'2026-09-01 15:00'),
(8,'HOTEL',12,5,'Servicio de spa excepcional en Tokio','NODO-ASIA',TRUE,'2026-09-12 22:00'),
(9,'DESTINO',1,4,'San José como punto de partida es cómodo','NODO-AMERICA',FALSE,'2026-09-14 12:00'),
(10,'HOTEL',7,5,'Lujo total, vale cada centavo','NODO-AMERICA',TRUE,'2026-09-16 10:00'),
(11,'DESTINO',10,5,'Tokio combina tradición y modernidad perfectamente','NODO-ASIA',TRUE,'2026-09-25 19:00'),
(13,'DESTINO',7,3,'Muchas colas para entrar a los museos','NODO-EUROPA',FALSE,'2026-09-27 16:20'),
(14,'VUELO',10,4,'Buen servicio a bordo en vuelo largo','NODO-ASIA',TRUE,'2026-09-14 08:00'),
(16,'HOTEL',13,5,'Ubicación perfecta en el centro de Berlín','NODO-EUROPA',TRUE,'2026-10-06 12:00'),
(17,'VUELO',17,4,'Buen servicio a bordo en el vuelo transatlántico','NODO-EUROPA',TRUE,'2026-10-08 09:00'),
(19,'DESTINO',18,5,'Comida increíble y ciudad muy limpia','NODO-ASIA',TRUE,'2026-10-14 20:00'),
(20,'VUELO',20,3,'Vuelo muy largo, poco entretenimiento a bordo','NODO-AMERICA',FALSE,'2026-10-13 10:00');


-- =============================================================================
-- 4. DATOS DE VOLUMEN (para que EXPLAIN ANALYZE muestre una mejora real y medible)
-- Sección aparte de los datos de ejemplo: genera miles de filas sintéticas con
-- generate_series() para que las tablas dejen de caber en unas pocas páginas y
-- el planificador de PostgreSQL tenga motivo real para usar los índices.
-- =============================================================================

INSERT INTO clientes (nombre, apellido, email, telefono, pais_id, fecha_registro)
SELECT 'Cliente'||i, 'Prueba'||i, 'cliente_bulk_'||i||'@correo.com',
       '0000-'||lpad(i::text,4,'0'), 1+floor(random()*10)::int,
       CURRENT_DATE - (floor(random()*365)::int || ' days')::interval
FROM generate_series(1,8000) i;

INSERT INTO hoteles (destino_id, nombre, categoria_estrellas, direccion, precio_noche_base)
SELECT 1+floor(random()*10)::int, 'Hotel Bulk '||i, 1+floor(random()*5)::int,
       'Dirección genérica '||i, round((50+random()*450)::numeric,2)
FROM generate_series(1,2000) i;

INSERT INTO habitaciones (hotel_id, tipo_habitacion, capacidad, precio_noche, disponible)
SELECT 1+floor(random()*(SELECT COUNT(*) FROM hoteles))::int, 'Doble', 2,
       round((50+random()*300)::numeric,2), TRUE
FROM generate_series(1,2000) i;

INSERT INTO vuelos (aerolinea_id, destino_origen_id, destino_llegada_id, fecha_salida, fecha_llegada, precio, asientos_disponibles)
SELECT aerolinea_id, origen, destino, salida, salida + interval '3 hours',
       round((80+random()*900)::numeric,2), floor(random()*200)::int
FROM (
    SELECT 1+floor(random()*8)::int AS aerolinea_id,
           1+floor(random()*10)::int AS origen,
           1+floor(random()*10)::int AS destino,
           TIMESTAMP '2026-01-01' + (floor(random()*365))*interval '1 day' + (floor(random()*24))*interval '1 hour' AS salida
    FROM generate_series(1,15000)
) sub
WHERE origen <> destino;

INSERT INTO itinerarios (cliente_id, nombre_viaje, fecha_inicio, fecha_fin, estado, fecha_creacion)
SELECT 1+floor(random()*(SELECT COUNT(*) FROM clientes))::int, 'Viaje Bulk '||i,
       d1, d1 + (1+floor(random()*10))::int * interval '1 day',
       (ARRAY['PLANIFICADO','CONFIRMADO','EN_CURSO','COMPLETADO','CANCELADO'])[1+floor(random()*5)::int],
       CURRENT_TIMESTAMP
FROM (SELECT i, CURRENT_DATE - (floor(random()*200))::int * interval '1 day' AS d1 FROM generate_series(1,10000) i) s;

WITH c AS (
    SELECT (SELECT COUNT(*) FROM habitaciones) AS n_hab,
           (SELECT COUNT(*) FROM vuelos)       AS n_vue,
           (SELECT COUNT(*) FROM itinerarios)  AS n_itin
)
INSERT INTO reservaciones (itinerario_id, tipo_reserva, habitacion_id, vuelo_id, cantidad_personas, precio_total, estado_reserva, fecha_reserva)
SELECT
    1+floor(random()*c.n_itin)::int,
    tipo,
    CASE WHEN tipo='HOTEL' THEN 1+floor(random()*c.n_hab)::int ELSE NULL END,
    CASE WHEN tipo='VUELO' THEN 1+floor(random()*c.n_vue)::int ELSE NULL END,
    1+floor(random()*4)::int,
    round((50+random()*900)::numeric,2),
    (ARRAY['PENDIENTE','CONFIRMADA','CANCELADA','COMPLETADA'])[1+floor(random()*4)::int],
    CURRENT_TIMESTAMP
FROM (SELECT (ARRAY['HOTEL','VUELO'])[1+floor(random()*2)::int] AS tipo FROM generate_series(1,10000)) t, c;

WITH c AS (
    SELECT (SELECT COUNT(*) FROM clientes) AS n_cli,
           (SELECT COUNT(*) FROM hoteles)  AS n_hot,
           (SELECT COUNT(*) FROM vuelos)   AS n_vue
)
INSERT INTO ratings (cliente_id, tipo_entidad, entidad_id, puntuacion, comentario, nodo_origen, verificado, fecha_rating)
SELECT
    1+floor(random()*c.n_cli)::int,
    tipo,
    CASE tipo WHEN 'HOTEL' THEN 1+floor(random()*c.n_hot)::int
              WHEN 'VUELO' THEN 1+floor(random()*c.n_vue)::int
              ELSE 1+floor(random()*10)::int END,
    1+floor(random()*5)::int,
    'Comentario generado automáticamente',
    (ARRAY['NODO-AMERICA','NODO-EUROPA','NODO-ASIA'])[1+floor(random()*3)::int],
    (random()>0.5),
    CURRENT_TIMESTAMP - (floor(random()*180)::int || ' days')::interval
FROM (SELECT (ARRAY['HOTEL','VUELO','DESTINO'])[1+floor(random()*3)::int] AS tipo FROM generate_series(1,15000)) t, c;


-- =============================================================================
-- 5. EXPLAIN ANALYZE - ANTES DE CREAR LOS ÍNDICES (línea base, con Seq Scan)
-- =============================================================================
ANALYZE;

EXPLAIN ANALYZE SELECT * FROM vuelos WHERE fecha_salida BETWEEN '2026-06-01' AND '2026-06-07';
EXPLAIN ANALYZE SELECT * FROM hoteles WHERE destino_id = 3;
EXPLAIN ANALYZE SELECT * FROM reservaciones WHERE itinerario_id = 5;
EXPLAIN ANALYZE SELECT * FROM ratings WHERE tipo_entidad = 'HOTEL' AND entidad_id = 3;
EXPLAIN ANALYZE SELECT * FROM itinerarios WHERE cliente_id = 5;


-- =============================================================================
-- 6. ÍNDICES ESTRATÉGICOS
-- =============================================================================

-- Búsqueda de vuelos por rango de fechas (la operación más común del buscador)
CREATE INDEX idx_vuelos_fecha_salida ON vuelos (fecha_salida);

-- Listado de hoteles filtrado por destino
CREATE INDEX idx_hoteles_destino ON hoteles (destino_id);

-- JOIN/lookup muy frecuente: detalle de reservas de un itinerario
CREATE INDEX idx_reservaciones_itinerario ON reservaciones (itinerario_id);

-- Cálculo de rating promedio por entidad (hotel/vuelo/destino); índice compuesto
CREATE INDEX idx_ratings_entidad ON ratings (tipo_entidad, entidad_id);

-- Consulta "mis itinerarios" de un cliente
CREATE INDEX idx_itinerarios_cliente ON itinerarios (cliente_id);


-- =============================================================================
-- 7. EXPLAIN ANALYZE - DESPUÉS DE CREAR LOS ÍNDICES (comparar cost= y Execution Time
--    contra la sección 5: deben pasar de Seq Scan a Index/Bitmap Scan, con una
--    reducción de costo y tiempo significativa, por encima del 50% en este dataset)
-- =============================================================================
ANALYZE;

EXPLAIN ANALYZE SELECT * FROM vuelos WHERE fecha_salida BETWEEN '2026-06-01' AND '2026-06-07';
EXPLAIN ANALYZE SELECT * FROM hoteles WHERE destino_id = 3;
EXPLAIN ANALYZE SELECT * FROM reservaciones WHERE itinerario_id = 5;
EXPLAIN ANALYZE SELECT * FROM ratings WHERE tipo_entidad = 'HOTEL' AND entidad_id = 3;
EXPLAIN ANALYZE SELECT * FROM itinerarios WHERE cliente_id = 5;


-- =============================================================================
-- 8. SEGURIDAD - ROLES Y PERMISOS
-- =============================================================================

-- ADMINISTRADOR: acceso completo (DDL + DML) para operación y soporte de la plataforma
CREATE ROLE administrador WITH LOGIN PASSWORD 'Admin_ViajesGlobal_2026!';
GRANT ALL PRIVILEGES ON SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrador;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO administrador;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO administrador;
-- GRANT ALL PRIVILEGES ON SCHEMA otorga CREATE, permitiendo CREATE/ALTER/DROP además de INSERT/UPDATE/DELETE.

-- OPERATIVO: personal de atención al cliente. Consulta el catálogo y registra
-- clientes/itinerarios/reservaciones/ratings, pero no modifica el catálogo maestro
-- ni borra información.
CREATE ROLE operativo WITH LOGIN PASSWORD 'Operativo_ViajesGlobal_2026!';

GRANT SELECT ON paises, destinos, hoteles, habitaciones, aerolineas, vuelos TO operativo;
GRANT SELECT, INSERT ON clientes, itinerarios, reservaciones, ratings TO operativo;

GRANT USAGE, SELECT ON
    clientes_cliente_id_seq,
    itinerarios_itinerario_id_seq,
    reservaciones_reservacion_id_seq,
    ratings_rating_id_seq
TO operativo;

-- Refuerzo explícito: operativo nunca altera el catálogo ni borra registros
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON paises, destinos, hoteles, habitaciones, aerolineas, vuelos FROM operativo;
REVOKE DELETE, TRUNCATE ON clientes, itinerarios, reservaciones, ratings FROM operativo;
REVOKE UPDATE ON ratings FROM operativo;   -- las calificaciones no se editan, solo se crean


-- =============================================================================
-- 9. CONSULTAS DE EJEMPLO (entregable: JOIN, GROUP BY con agregación, WHERE complejo)
-- =============================================================================

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
ORDER BY r.fecha_reserva
LIMIT 20;

-- 2) GROUP BY con COUNT/AVG/SUM: rating promedio e ingresos por hotel
--    (subconsultas agregadas por separado para evitar doble conteo por el JOIN)
SELECT
    h.hotel_id,
    h.nombre                             AS hotel,
    COALESCE(rt.cantidad_ratings, 0)     AS cantidad_ratings,
    rt.rating_promedio,
    COALESCE(res.ingresos_totales, 0)    AS ingresos_totales
FROM hoteles h
LEFT JOIN (
    SELECT entidad_id, COUNT(*) AS cantidad_ratings, ROUND(AVG(puntuacion),2) AS rating_promedio
    FROM ratings WHERE tipo_entidad = 'HOTEL' GROUP BY entidad_id
) rt ON rt.entidad_id = h.hotel_id
LEFT JOIN (
    SELECT hb.hotel_id, SUM(r.precio_total) AS ingresos_totales
    FROM reservaciones r
    JOIN habitaciones hb ON hb.habitacion_id = r.habitacion_id
    WHERE r.tipo_reserva = 'HOTEL'
    GROUP BY hb.hotel_id
) res ON res.hotel_id = h.hotel_id
ORDER BY rating_promedio DESC NULLS LAST
LIMIT 20;

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
JOIN destinos ao    ON ao.destino_id = v.destino_origen_id
JOIN destinos ad    ON ad.destino_id = v.destino_llegada_id
JOIN aerolineas al  ON al.aerolinea_id = v.aerolinea_id
JOIN paises po      ON po.pais_id = ao.pais_id
WHERE po.continente = 'América'
  AND v.precio < 700
  AND v.asientos_disponibles > 15
  AND v.fecha_salida BETWEEN '2026-08-01' AND '2026-09-30'
ORDER BY v.precio ASC
LIMIT 20;
