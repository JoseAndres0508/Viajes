# Plataforma de Viajes Global — Proyecto BD (ISW-522, Clase 7)

Base de datos PostgreSQL para una plataforma de viajes: destinos, hoteles,
vuelos, reservaciones, itinerarios y un sistema de rating distribuido.

## Archivo

`viajeScript.sql` — script único, ejecutable de una
sola vez sin errores. Todos los objetos se crean en el schema dedicado
`viajes` (no se usa `public`). Incluye, en orden:

1. Limpieza previa (`DROP`) y creación del schema `viajes`
2. DDL: 10 tablas con PK, FK, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`
   (las llaves primarias son `INTEGER` con id asignado explícitamente)
3. Datos de ejemplo realistas (20 filas por tabla)
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
psql -d viajes_global -f viajeScript.sql
```

El script crea el schema `viajes` y fija el `search_path`, por lo que corre
completo sin configuración extra. Para consultar las tablas después de la
carga, sitúate en el schema (o califica los nombres):

```sql
SET search_path = viajes, public;   -- o: SELECT * FROM viajes.hoteles;
```

Para ver la comparación de rendimiento, revisa la salida de las secciones 5
y 7: las mismas 5 consultas deben pasar de `Seq Scan` a `Index Scan` /
`Bitmap Scan`. El costo estimado por el planificador baja entre ~57% y ~99%
según la consulta (métrica estable; los tiempos de ejecución son
sub-milisegundo y varían por corrida en este dataset).

## Roles creados

- **administrador**: `CREATE`, `ALTER`, `DROP`, `INSERT`, `UPDATE`, `DELETE`
  sobre todo el schema `viajes`.
- **operativo**: `SELECT` sobre el catálogo (países, destinos, hoteles,
  habitaciones, aerolíneas, vuelos) y `SELECT`/`INSERT` sobre clientes,
  itinerarios, reservaciones y ratings. No puede modificar el catálogo ni
  borrar registros. Como las PK son `INTEGER` sin autoincremento, sus
  `INSERT` deben indicar el valor del id.

Probado en PostgreSQL 16