-- Usuario: SYSTEM

-- CREACION DE TABLAS

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




-- CREACION DE USUARIOS

-- Crear usuarios con contraseñas predeterminadas
CREATE USER C##medico00 IDENTIFIED BY O7Qw5XUJiduTk;
CREATE USER C##enfermera00 IDENTIFIED BY s4STGJ7JssK8gL;
CREATE USER C##tecnico00 IDENTIFIED BY zHrd6erELU9XxJ;
CREATE USER C##auxiliar00 IDENTIFIED BY YFOvj4bMyx7co2;
CREATE USER C##administrativo00 IDENTIFIED BY QANpFp5A1bdHAr;
CREATE USER C##conductor00 IDENTIFIED BY nNeaPic5cG3ge6;

-- Asignar privilegios básicos para conexión
GRANT CONNECT TO C##medico00, C##enfermera00, C##tecnico00, C##auxiliar00, C##administrativo00, C##conductor00;



-- DEFINICION DE ROLES

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



-- CREACION DE PERFILES

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


-- ASIGNACION DE ROLES Y PERFILES

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


-- GUARDAR CAMBIOS
COMMIT;