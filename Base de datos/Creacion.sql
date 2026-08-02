-- Creacion e inicializacion de base de datos
USE master;
DROP DATABASE matricula

CREATE DATABASE matricula
GO

USE matricula;
GO

/* Tabla: carrera
Registra las carreras existentes
*/
CREATE TABLE carrera (
    id CHAR(2) PRIMARY KEY, -- 'TI', 'AD', 'ME'...
    nombre VARCHAR(50) NOT NULL
);

/*
Tabla: estudiante
Registra información personal y académica de los alumnos.
*/
CREATE TABLE estudiante(
dni CHAR(9) PRIMARY KEY CHECK (dni NOT LIKE '%[^0-9]%'), -- Garantizar formato de cédula nacional
carnet CHAR(6) UNIQUE, -- Código institnucional único (Ej: C12X15)
nombre VARCHAR(30) NOT NULL, -- Nombre del alumno
primer_apellido VARCHAR(30) NOT NULL, -- Primer apellido obligatorio
segundo_apellido VARCHAR(30), -- Segundo apelldio opcional
telefono CHAR(8) CHECK (telefono NOT LIKE '%[^0-9]%'), -- Formato de celular local 
direccion VARCHAR(255), -- Dirección de vivienda
fecha_ingreso DATE NOT NULL, -- Fecha de incorporación a la institución
id_carrera CHAR(2) REFERENCES carrera(id)
);
GO


/*
Tabla: profesor
Registra información personal de los docentes de la institución
*/
CREATE TABLE profesor(
dni CHAR(9) PRIMARY KEY CHECK (dni NOT LIKE '%[^0-9]%'), -- Garantizar formato de cédula nacional
nombre VARCHAR(30) NOT NULL, -- Nombre del alumno
primer_apellido VARCHAR(30) NOT NULL, -- Primer apellido obligatorio
segundo_apellido VARCHAR(30), -- Segundo apelldio opcional
telefono CHAR(8) CHECK (telefono NOT LIKE '%[^0-9]%'), -- Formato de celular local 
direccion VARCHAR(255), -- Dirección de vivienda
id_carrera CHAR(2) REFERENCES carrera(id)
);
GO

/*
Tabla contrato
Historico de contratos laborales asignados a los profesores.
*/
CREATE TABLE contrato(
id INT PRIMARY KEY IDENTITY (1,1), -- Identificador autoincremental
dni_profesor CHAR(9) REFERENCES profesor(dni) NOT NULL, -- Referencia al profesor
tipo_contrato VARCHAR(50) NOT NULL CHECK (tipo_contrato IN  
	('tiempo completo', 'medio tiempo','por horas', 'cátedra')), -- Modalidades permitidas
estado VARCHAR(40) NOT NULL CHECK (estado IN  
	('activo', 'finalizado', 'suspendido')), -- Estado de la relación laboral
jornada tinyint NOT NULL CHECK (jornada BETWEEN 0 AND 48), -- Carga horaria semanal
salario DECIMAL(10,2) NOT NULL CHECK (salario >= 0), -- Monto salarial
fecha_inicio DATE NOT NULL, -- Inicio de vigencia del contrato
fecha_fin DATE,
CONSTRAINT CHK_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio) -- Fin de vigencia
);
GO

/*
Tabla curso
Catálogo de materias que ofrece la institución
*/
CREATE TABLE curso(
id CHAR(6) PRIMARY KEY, -- Formato esperado: 2 letras de dpto + 4 números (Ej: MA1001)
nombre VARCHAR(127) NOT NULL, -- Nombre de la asignatura
creditos tinyint NOT NULL CHECK (creditos BETWEEN 0 AND 20) -- Valor académico (0 a 20)
);
GO

/*
Tabla requisito
Mapea relacioón N:M para los prerrequisitos entre cursos
*/
CREATE TABLE requisitos (
id_curso CHAR(6) REFERENCES curso(id),
id_requisito CHAR(6) REFERENCES curso(id)
PRIMARY KEY (id_curso, id_requisito),
CONSTRAINT chk_requisito_diferente CHECK (id_requisito <> id_curso) -- El CHECK definido a nivel de tabla sí puede comparar dos columnas
);
GO

/*
Tabla seccion
Ofertas para impartir cursos en un ciclo.
*/
CREATE TABLE seccion(
id_seccion INT PRIMARY KEY IDENTITY (1,1), -- Identificador único
id_curso CHAR(6) NOT NULL REFERENCES curso(id), -- Curos al que pertenece
dni_profesor CHAR(9) REFERENCES profesor(dni), -- Profesor asignado 
modalidad VARCHAR(127) NOT NULL CHECK (modalidad IN 
	('Virtual', 'Presencial', 'Bimodal')), -- Modalidad de dictado
cupos tinyint NOT NULL CHECK (cupos BETWEEN 1 AND 60), -- Limite máximo de alumnos por sección
horario VARCHAR(511) NOT NULL, -- Días y horas de impartición (Texto estructurado)
fecha_inicio DATE NOT NULL, -- Inicio del periodo lectivo
fecha_fin DATE NOT NULL -- Cierre del periodo lectivo
);
GO

/*
Tabla matricula
Registrar la inscripción de un estudiante en una sección
Resuelve relación N:M entre estudiante y seccion
*/
CREATE TABLE matricula(
id_seccion INT REFERENCES seccion(id_seccion), -- Seccion inscrita
dni_estudiante CHAR(9) REFERENCES estudiante(dni), -- Estudiante matriculado
nota_final TINYINT CHECK (nota_final BETWEEN 0 AND 100) -- Calificación obtenida
PRIMARY KEY(id_seccion, dni_estudiante)
);
GO