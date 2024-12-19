# Evaluación 4 Bases de datos Relacionales
### Integrantes:
* Diego Reyes
* Carlos Mac-Iver

### Sección:
* AP-172-N2

##
Este documento describe el proceso de configuración, creación de tablas, definición de roles y perfiles, y pruebas de acceso a una base de datos Oracle, creada con el contenedor podman y la imagen oficial de Oracle Database. El objetivo es gestionar de manera eficiente la información relacionada con pacientes, su historia clínica, procedimientos médicos, exámenes, insumos, transporte y finanzas en un sistema hospitalario. Se detallan los pasos para la creación de tablas, asignación de privilegios y roles a usuarios específicos, así como las pruebas de inserción, actualización y eliminación de datos desde diferentes perspectivas de usuario. Esta implementación es una base sólida para la gestión de datos en un entorno de salud, asegurando que los roles y perfiles de usuarios estén correctamente configurados según las responsabilidades de cada uno.

## Diagramas
### Tablas
![schema](./uml/schema.png)
### Perfiles
![perfiles](./uml/perfiles.png)
### Roles 
![roles](./uml/roles.png)


## Configuración inicial
1.Crear contenedor e instalar imagen de Oracle DB
```bash
podman run -d --name mydb2 \
-p 1522:1521 \
-e ORACLE_PWD=NewPass123 \
container-registry.oracle.com/database/free:latest
```
La contraseña registrada aquí será la que utilizara el usuario SYSTEM

---
2.Conectarse a la base de datos con SQL Developer
![SQL Developer Connect](./images/SQLdeveloper_connect.png)

---
## Creación de tablas

Usuario: SYSTEM

 ```SQL
CREATE TABLE PACIENTES (
    paciente_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    apellido VARCHAR2(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    direccion VARCHAR2(255),
    telefono VARCHAR2(20),
    correo VARCHAR2(100)
);

CREATE TABLE HISTORIA_CLINICA (
    historia_id NUMBER PRIMARY KEY,
    paciente_id NUMBER NOT NULL,
    fecha_ingreso DATE NOT NULL,
    diagnostico CLOB,
    tratamiento CLOB,
    FOREIGN KEY (paciente_id) REFERENCES PACIENTES(paciente_id)
);

CREATE TABLE PROCEDIMIENTOS (
    procedimiento_id NUMBER PRIMARY KEY,
    paciente_id NUMBER NOT NULL,
    descripcion CLOB NOT NULL,
    fecha DATE NOT NULL,
    costo NUMBER(10, 2),
    FOREIGN KEY (paciente_id) REFERENCES PACIENTES(paciente_id)
);

CREATE TABLE EXAMENES (
    examen_id NUMBER PRIMARY KEY,
    paciente_id NUMBER NOT NULL,
    tipo_examen VARCHAR2(100) NOT NULL,
    resultado CLOB,
    fecha DATE NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES PACIENTES(paciente_id)
);

CREATE TABLE INSUMOS (
    insumo_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    cantidad NUMBER,
    costo NUMBER(10, 2)
);

CREATE TABLE TRANSPORTES (
    transporte_id NUMBER PRIMARY KEY,
    paciente_id NUMBER NOT NULL,
    tipo_transporte VARCHAR2(50),
    fecha DATE NOT NULL,
    costo NUMBER(10, 2),
    FOREIGN KEY (paciente_id) REFERENCES PACIENTES(paciente_id)
);

CREATE TABLE FINANZAS (
    financia_id NUMBER PRIMARY KEY,
    paciente_id NUMBER NOT NULL,
    monto NUMBER(10, 2),
    tipo_pago VARCHAR2(50),
    fecha_pago DATE NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES PACIENTES(paciente_id)
);
```

## Definición de Roles y Perfiles

CREACION DE USUARIOS
```SQL
-- Crear usuarios con contraseñas predeterminadas
CREATE USER C##medico00 IDENTIFIED BY O7Qw5XUJiduTk;
CREATE USER C##enfermera00 IDENTIFIED BY s4STGJ7JssK8gL;
CREATE USER C##tecnico00 IDENTIFIED BY zHrd6erELU9XxJ;
CREATE USER C##auxiliar00 IDENTIFIED BY YFOvj4bMyx7co2;
CREATE USER C##administrativo00 IDENTIFIED BY QANpFp5A1bdHAr;
CREATE USER C##conductor00 IDENTIFIED BY nNeaPic5cG3ge6;

-- Asignar privilegios básicos para conexión
GRANT CONNECT TO C##medico00, C##enfermera00, C##tecnico00, C##auxiliar00, C##administrativo00, C##conductor00;
```

---
DEFINICION DE ROLES
```SQL
-- Crear roles para los distintos tipos de personal
CREATE ROLE C##ROL_MEDICO;
CREATE ROLE C##ROL_ENFERMERA;
CREATE ROLE C##ROL_TECNICO;
CREATE ROLE C##ROL_AUXILIAR;
CREATE ROLE C##ROL_ADMINISTRATIVO;
CREATE ROLE C##ROL_CONDUCTOR;

-- Asignar privilegios específicos a cada rol según funciones
-- C##ROL_MEDICO: Acceso a todas las tablas relacionadas con pacientes, historia clínica, procedimientos, etc.
GRANT SELECT, INSERT, UPDATE ON PACIENTES TO C##ROL_MEDICO;
GRANT SELECT, INSERT, UPDATE ON HISTORIA_CLINICA TO C##ROL_MEDICO;
GRANT SELECT, INSERT, UPDATE ON PROCEDIMIENTOS TO C##ROL_MEDICO;

-- C##ROL_ENFERMERA: Acceso solo a la visualización de pacientes y su historia clínica
GRANT SELECT ON PACIENTES TO C##ROL_ENFERMERA;
GRANT SELECT ON HISTORIA_CLINICA TO C##ROL_ENFERMERA;

-- C##ROL_TECNICO: Acceso a procedimientos y exámenes
GRANT SELECT, INSERT, UPDATE ON PROCEDIMIENTOS TO C##ROL_TECNICO;
GRANT SELECT, INSERT ON EXAMENES TO C##ROL_TECNICO;

-- C##ROL_AUXILIAR: Acceso limitado a información de pacientes y transportes
GRANT SELECT ON PACIENTES TO C##ROL_AUXILIAR;
GRANT SELECT, INSERT ON TRANSPORTES TO C##ROL_AUXILIAR;

-- C##ROL_ADMINISTRATIVO: Acceso completo a todas las tablas de la base de datos
GRANT ALL PRIVILEGES ON PACIENTES TO C##ROL_ADMINISTRATIVO;
GRANT ALL PRIVILEGES ON HISTORIA_CLINICA TO C##ROL_ADMINISTRATIVO;
GRANT ALL PRIVILEGES ON PROCEDIMIENTOS TO C##ROL_ADMINISTRATIVO;
GRANT ALL PRIVILEGES ON EXAMENES TO C##ROL_ADMINISTRATIVO;
GRANT ALL PRIVILEGES ON INSUMOS TO C##ROL_ADMINISTRATIVO;
GRANT ALL PRIVILEGES ON TRANSPORTES TO C##ROL_ADMINISTRATIVO;
GRANT ALL PRIVILEGES ON FINANZAS TO C##ROL_ADMINISTRATIVO;

-- C##ROL_CONDUCTOR: Acceso solo a la tabla de transportes
GRANT SELECT, INSERT ON TRANSPORTES TO C##ROL_CONDUCTOR;
```

---
CREACION DE PERFILES
```SQL
-- Crear perfiles para limitar recursos
CREATE PROFILE C##perfil_medico LIMIT
    SESSIONS_PER_USER 3
    IDLE_TIME UNLIMITED
    CONNECT_TIME UNLIMITED;

CREATE PROFILE C##perfil_enfermera_tecnico LIMIT
    SESSIONS_PER_USER 2
    IDLE_TIME 30
    CONNECT_TIME 480; -- 8 horas en minutos

CREATE PROFILE C##perfil_auxiliar_conductor LIMIT
    SESSIONS_PER_USER 1
    IDLE_TIME 30
    CONNECT_TIME 240; -- 4 horas en minutos

CREATE PROFILE C##perfil_administrativo LIMIT
    SESSIONS_PER_USER 3
    IDLE_TIME UNLIMITED
    CONNECT_TIME UNLIMITED;
```

---
ASIGNACION DE ROLES Y PERFILES
```SQL
-- Asignar perfiles a los usuarios
ALTER USER C##medico00 PROFILE C##perfil_medico;
ALTER USER C##enfermera00 PROFILE C##perfil_enfermera_tecnico;
ALTER USER C##tecnico00 PROFILE C##perfil_enfermera_tecnico;
ALTER USER C##auxiliar00 PROFILE C##perfil_auxiliar_conductor;
ALTER USER C##conductor00 PROFILE C##perfil_auxiliar_conductor;
ALTER USER C##administrativo00 PROFILE C##perfil_administrativo;

-- Asignar roles a los usuarios
GRANT C##ROL_MEDICO TO C##medico00;
GRANT C##ROL_ENFERMERA TO C##enfermera00;
GRANT C##ROL_TECNICO TO C##tecnico00;
GRANT C##ROL_AUXILIAR TO C##auxiliar00;
GRANT C##ROL_ADMINISTRATIVO TO C##administrativo00;
GRANT C##ROL_CONDUCTOR TO C##conductor00;
```

---
GUARDAR CAMBIOS
```SQL
COMMIT;
```

---
## Testing

### Usuario: medico00
La conexión se realiza con los mismo parámetros, pero hay que cambiar los datos de usuario y contraseña por los definidos en el script anterior.

1. Verificar conexión a la base de datos (consulta de todas las tablas)
```SQL
SELECT * FROM ALL_TABLES WHERE OWNER = 'SYSTEM';
```
![Test medic user connection](./images/medico00_test/test_medic_connection.png)
Si la conexión es exitosa, deberia verse una lista de tablas como esa

---
2. Verificar acceso a la tabla PACIENTES (debe poder consultar)
```SQL
SELECT * FROM SYSTEM.PACIENTES;
```
![Patient select query](./images/medico00_test/pacientes_select_query.png)
La tabla se muestra vacía porque aún no contiene datos.  Se comprueba que la consulta fue exitosa porque aparecen los campos de la tabla.

---
3. Probar inserción de datos en la tabla PACIENTES

Ingresar un nuevo paciente
```SQL
INSERT INTO SYSTEM.PACIENTES (paciente_id, nombre, apellido, fecha_nacimiento)
VALUES (1001, 'Carlos', 'Mendoza', TO_DATE('1985-07-15', 'YYYY-MM-DD'));
```
![1 row inserted](./images/medico00_test/1_row_inserted.png)

---
4. Confirmar que se haya insertado correctamente
```SQL
SELECT * FROM SYSTEM.PACIENTES WHERE paciente_id = 1001;
```
![Patient insertion](./images/medico00_test/insertion_test.png)

---
5. Probar acceso a la tabla HISTORIA_CLINICA (debe tener acceso a insertar y actualizar)
```SQL
INSERT INTO SYSTEM.HISTORIA_CLINICA (historia_id, paciente_id, fecha_ingreso, diagnostico, tratamiento)
VALUES (1001, 1001, TO_DATE('2024-12-18', 'YYYY-MM-DD'), 'Resfriado común', 'Reposo y líquidos');
```
![1 row inserted](./images/medico00_test/1_row_inserted.png)

---
6. Confirmar que se haya insertado correctamente
```SQL
SELECT * FROM SYSTEM.HISTORIA_CLINICA WHERE paciente_id = 1001;
```
![Clinic history insertion test](./images/medico00_test/hc_insertion_test.png)

---
7. Insertar un procedimiento en la tabla PROCEDIMIENTOS
```SQL
INSERT INTO SYSTEM.PROCEDIMIENTOS (procedimiento_id, paciente_id, descripcion, fecha, costo)
VALUES (1, 1001, 'Exámenes de rutina', TO_DATE('2024-12-18', 'YYYY-MM-DD'), 150.00);
```
![1 row inserted](./images/medico00_test/1_row_inserted.png)

---
8. Verificar que el procedimiento se haya insertado correctamente
```SQL
SELECT * FROM SYSTEM.PROCEDIMIENTOS WHERE paciente_id = 1001;
```
![Select on procedimiento](./images/medico00_test/procedimiento_select.png)

---
9. Probar actualización de datos en la tabla PROCEDIMIENTOS
```SQL
UPDATE SYSTEM.PROCEDIMIENTOS
SET costo = 200
WHERE paciente_id = 1001;
```
![1 row updated](./images/medico00_test/1_row_updated.png)

---
10. Confirmar que la actualización se realizó correctamente
```SQL
SELECT * FROM SYSTEM.PROCEDIMIENTOS WHERE paciente_id = 1001;
```
![Procedimiento update test](./images/medico00_test/procedimiento_update_test.png)

---
11. Probar eliminación de datos en la tabla PACIENTES
```SQL
DELETE FROM SYSTEM.PACIENTES WHERE paciente_id = 1001;
```
![Paciente delete test](./images/medico00_test/delete_patient_test.png)
No nos permite borrar el paciente porque el usuario no tiene los permisos necesarios.


## Referencias

1. Oracle. (n.d.). *Oracle Database Free*. Oracle Container Registry. Recuperado de https://container-registry.oracle.com/ords/f?p=113:4:120091765265806:::4:P4_REPOSITORY,AI_REPOSITORY,AI_REPOSITORY_NAME,P4_REPOSITORY_NAME,P4_EULA_ID,P4_BUSINESS_AREA_ID:1863,1863,Oracle%20Database%20Free,Oracle%20Database%20Free,1,0&cs=3cTYLgDuOkSVmJKFhUNzXWm6YZzstok0VZzDl8Wl8_5ggD9Qs--VTfPENF8FAuOlBztCrwTmGpCBzOWS6C_dkAg

2. Oracle. (n.d.). *Oracle SQL Developer Documentation*. Recuperado de https://docs.oracle.com/en/database/oracle/sql-developer/index.html

