-- Usuario: C##medic00
-- Verificar conexión a la base de datos (consulta de todas las tablas)
SELECT * FROM ALL_TABLES WHERE OWNER = 'SYSTEM';

-- Verificar acceso a la tabla PACIENTES (debe poder consultar)
SELECT * FROM SYSTEM.PACIENTES;

-- Probar inserción de datos en la tabla PACIENTES
-- Ingresar un nuevo paciente
INSERT INTO SYSTEM.PACIENTES (paciente_id, nombre, apellido, fecha_nacimiento)
VALUES (1001, 'Carlos', 'Mendoza', TO_DATE('1985-07-15', 'YYYY-MM-DD'));

-- Confirmar que se haya insertado correctamente
SELECT * FROM SYSTEM.PACIENTES WHERE paciente_id = 1001;

-- Probar acceso a la tabla HISTORIA_CLINICA (debe tener acceso a insertar y actualizar)
INSERT INTO SYSTEM.HISTORIA_CLINICA (historia_id, paciente_id, fecha_ingreso, diagnostico, tratamiento)
VALUES (1001, 1001, TO_DATE('2024-12-18', 'YYYY-MM-DD'), 'Resfriado común', 'Reposo y líquidos');

-- Confirmar que se haya insertado correctamente
SELECT * FROM SYSTEM.HISTORIA_CLINICA WHERE paciente_id = 1001;

-- Insertar un procedimiento en la tabla PROCEDIMIENTOS
INSERT INTO SYSTEM.PROCEDIMIENTOS (procedimiento_id, paciente_id, descripcion, fecha, costo)
VALUES (1, 1001, 'Exámenes de rutina', TO_DATE('2024-12-18', 'YYYY-MM-DD'), 150.00);

-- Verificar que el procedimiento se haya insertado correctamente
SELECT * FROM SYSTEM.PROCEDIMIENTOS WHERE paciente_id = 1001;

-- Probar actualización de datos en la tabla PROCEDIMIENTOS
UPDATE SYSTEM.PROCEDIMIENTOS
SET costo = 200
WHERE paciente_id = 1001;

-- Probar eliminación de datos en la tabla PACIENTES
DELETE FROM SYSTEM.PACIENTES WHERE paciente_id = 1001;

-- Guardar cambios (COMMIT)
COMMIT;
