-- Catálogo de países
CREATE TABLE paises (
    pais_id      SERIAL PRIMARY KEY,
    nombre       VARCHAR(80) NOT NULL,
    codigo_iso   CHAR(2) NOT NULL UNIQUE,
    continente   VARCHAR(30) NOT NULL
);

-- Ciudades/destinos turísticos. 1 país : N destinos
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

-- Hoteles por destino. 1 destino : N hoteles
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

-- Tipos de habitación por hotel. 1 hotel : N habitaciones
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

-- Catálogo de aerolíneas
CREATE TABLE aerolineas (
    aerolinea_id  SERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    codigo_iata   CHAR(2) NOT NULL UNIQUE
);

-- Vuelos entre destinos. N:1 con aerolineas y destinos (origen/llegada)
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

-- Usuarios que reservan en la plataforma
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

-- Viaje planificado por un cliente, agrupa varias reservaciones
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

-- Reserva de hotel o vuelo dentro de un itinerario (M:N resuelta vía itinerarios)
CREATE TABLE reservaciones (
    reservacion_id   SERIAL PRIMARY KEY,
    itinerario_id    INTEGER NOT NULL,
    tipo_reserva     VARCHAR(10) NOT NULL CHECK (tipo_reserva IN ('HOTEL','VUELO')),
    habitacion_id    INTEGER,
    vuelo_id         INTEGER,
    cantidad_personas SMALLINT NOT NULL DEFAULT 1 CHECK (cantidad_personas > 0),
    precio_total     NUMERIC(10,2) NOT NULL CHECK (precio_total > 0),
    estado_reserva   VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE'
                        CHECK (estado_reserva IN ('PENDIENTE','CONFIRMADA','CANCELADA','COMPLETADA')),
    fecha_reserva    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reservacion_itinerario FOREIGN KEY (itinerario_id)
        REFERENCES itinerarios (itinerario_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservacion_habitacion FOREIGN KEY (habitacion_id)
        REFERENCES habitaciones (habitacion_id) ON DELETE RESTRICT,
    CONSTRAINT fk_reservacion_vuelo FOREIGN KEY (vuelo_id)
        REFERENCES vuelos (vuelo_id) ON DELETE RESTRICT,
    -- Exclusividad: reserva HOTEL solo usa habitacion_id, VUELO solo usa vuelo_id
    CONSTRAINT chk_reservacion_tipo CHECK (
        (tipo_reserva = 'HOTEL' AND habitacion_id IS NOT NULL AND vuelo_id IS NULL)
        OR
        (tipo_reserva = 'VUELO' AND vuelo_id IS NOT NULL AND habitacion_id IS NULL)
    )
);

-- Rating distribuido: nodo_origen identifica el nodo/servidor regional que generó el registro
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
