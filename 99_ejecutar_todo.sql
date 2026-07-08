-- Ejecuta todo el proyecto en orden. Correr desde la carpeta que contiene los archivos:
-- psql -U postgres -d nombre_bd -f 99_ejecutar_todo.sql
\i 00_limpieza.sql
\i 01_ddl_tablas.sql
\i 02_indices.sql
\i 03_seguridad_roles.sql
\i 04_datos_ejemplo.sql
\i 05_consultas.sql
