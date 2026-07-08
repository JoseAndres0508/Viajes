# Plataforma de Viajes Global — Proyecto BD (ISW-522, Clase 7)

Base de datos PostgreSQL para una plataforma de viajes: destinos, hoteles,
vuelos, reservaciones, itinerarios y un sistema de rating distribuido.

## Archivo

`proyecto_plataforma_viajes_global.sql` — script único, ejecutable de una
sola vez sin errores. Incluye, en orden:

1. Limpieza previa (DROP)
2. DDL: 10 tablas con PK, FK, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`
3. Datos de ejemplo realistas (10–20 filas por tabla)
4. Datos de volumen sintéticos (`generate_series`) para que los índices
   tengan un efecto medible
5. `EXPLAIN ANALYZE` de 5 consultas **antes** de crear los índices (línea base)
6. `CREATE INDEX` de los 5 índices, cada uno con su justificación
7. `EXPLAIN ANALYZE` de las mismas 5 consultas **después** de los índices,
   para comparar directamente contra la sección 5
8. Roles `administrador` (acceso completo) y `operativo` (acceso limitado),
   con `GRANT`/`REVOKE` explícitos
9. 3 consultas de ejemplo: JOIN entre varias tablas, GROUP BY con
   agregación (COUNT/AVG/SUM), WHERE con condiciones complejas

## Modelo de datos

`paises` → `destinos` → `hoteles` → `habitaciones`
`aerolineas` + `destinos` → `vuelos`
`clientes` → `itinerarios` → `reservaciones` (hotel o vuelo)
`clientes` → `ratings` (califica hoteles, vuelos o destinos; `nodo_origen`
simula el nodo regional que generó el registro en un sistema distribuido)

## Cómo ejecutarlo

```bash
createdb viajes_global
psql -d viajes_global -f proyecto_plataforma_viajes_global.sql
```

Para ver la comparación de rendimiento, revisa la salida de las secciones 5
y 7: las mismas 5 consultas deben pasar de `Seq Scan` a `Index Scan` /
`Bitmap Scan`, con una reducción de costo y tiempo de ejecución
significativa (validado en pruebas: entre 32% y 98% según la consulta).

## Roles creados

- **administrador**: `CREATE`, `ALTER`, `DROP`, `INSERT`, `UPDATE`, `DELETE`
  sobre todo el esquema.
- **operativo**: `SELECT` sobre el catálogo (países, destinos, hoteles,
  habitaciones, aerolíneas, vuelos) y `SELECT`/`INSERT` sobre clientes,
  itinerarios, reservaciones y ratings. No puede modificar el catálogo ni
  borrar registros.

Probado en PostgreSQL 16
