# Plataforma de Viajes Global — Proyecto BD (ISW-522, Clase 7)

Base de datos PostgreSQL para una plataforma de viajes: destinos, hoteles,
vuelos, reservaciones, itinerarios y un sistema de rating distribuido.

## Estructura del proyecto

| Archivo | Contenido |
|---|---|
| `00_limpieza.sql` | DROP de tablas y roles (permite re-ejecutar el proyecto) |
| `01_ddl_tablas.sql` | DDL: 10 tablas con PK, FK, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT` |
| `02_indices.sql` | 5 índices sobre columnas de búsqueda/JOIN frecuente |
| `03_seguridad_roles.sql` | Roles `administrador` (acceso completo) y `operativo` (acceso limitado), con `GRANT`/`REVOKE` |
| `04_datos_ejemplo.sql` | Datos de ejemplo (8–18 filas por tabla) |
| `05_consultas.sql` | 3 consultas: JOIN múltiple, GROUP BY con agregación, WHERE complejo |
| `99_ejecutar_todo.sql` | Ejecuta los 6 archivos anteriores en orden |

## Modelo de datos

`paises` → `destinos` → `hoteles` → `habitaciones`
`aerolineas` + `destinos` → `vuelos`
`clientes` → `itinerarios` → `reservaciones` (hotel o vuelo)
`clientes` → `ratings` (califica hoteles, vuelos o destinos; `nodo_origen` simula el nodo regional que generó el registro en un sistema distribuido)

## Cómo ejecutarlo

```bash
createdb viajes_global
psql -d viajes_global -f 99_ejecutar_todo.sql
```

O archivo por archivo, en este orden: `00` → `01` → `02` → `03` → `04` → `05`.

## Roles creados

- **administrador**: `CREATE`, `ALTER`, `DROP`, `INSERT`, `UPDATE`, `DELETE` sobre todo el esquema.
- **operativo**: `SELECT` sobre el catálogo (países, destinos, hoteles, habitaciones, aerolíneas, vuelos) y `SELECT`/`INSERT` sobre clientes, itinerarios, reservaciones y ratings. No puede modificar el catálogo ni borrar registros.

Probado en PostgreSQL 16.
