-- ROL ADMINISTRADOR: acceso completo (DDL + DML)
CREATE ROLE administrador WITH LOGIN PASSWORD 'Admin_ViajesGlobal_2026!';
GRANT ALL PRIVILEGES ON SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrador;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO administrador;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO administrador;

-- ROL OPERATIVO: solo consulta catálogo + registra clientes/reservas/itinerarios/ratings
CREATE ROLE operativo WITH LOGIN PASSWORD 'Operativo_ViajesGlobal_2026!';

GRANT SELECT ON paises, destinos, hoteles, habitaciones, aerolineas, vuelos TO operativo;
GRANT SELECT, INSERT ON clientes, itinerarios, reservaciones, ratings TO operativo;

GRANT USAGE, SELECT ON
    clientes_cliente_id_seq,
    itinerarios_itinerario_id_seq,
    reservaciones_reservacion_id_seq,
    ratings_rating_id_seq
TO operativo;

-- Refuerzo explícito: operativo no altera catálogo ni borra información
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON paises, destinos, hoteles, habitaciones, aerolineas, vuelos FROM operativo;
REVOKE DELETE, TRUNCATE ON clientes, itinerarios, reservaciones, ratings FROM operativo;
REVOKE UPDATE ON ratings FROM operativo;
