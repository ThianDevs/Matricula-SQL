USE matricula;
GO
-- 1.1 CREATE VIEW:
-- Crear una vista llamada 'Vista_Detalle_Secciones' que muestre: 
-- ID de sección, nombre del curso, nombre del profesor y modalidad.
CREATE OR ALTER VIEW Vista_Detalle_Secciones AS
SELECT 
	id_seccion, 
	cu.nombre AS estudiante, 
	pr.nombre AS profesor, 
	modalidad
FROM seccion se
INNER JOIN curso cu ON cu.id = se.id_curso
INNER JOIN profesor pr ON pr.dni = se.dni_profesor
GO

-- 1.2. CONSULTA SOBRE VISTA:
-- Utilizando la vista 'Vista_Detalle_Secciones', filtrar solo las secciones que son 'Virtuales'.
SELECT * 
FROM Vista_Detalle_Secciones
WHERE modalidad = 'Virtual'
GO

-- 2.1. CREATE VIEW (Resumen Financiero):
-- Crear una vista llamada 'Vista_Nomina_Activa' que sume el salario total que la institución 
-- paga por cada tipo de contrato, solo para contratos 'activos'.
CREATE OR ALTER VIEW Vista_Nomina_Activa AS
SELECT 
	tipo_contrato, 
	SUM(salario) AS total_salarios
FROM contrato
WHERE estado = 'Activo'
GROUP BY tipo_contrato
GO

-- 2.2 CONSULTA SOBRE VISTA:
-- Utilizando la vista 'Vista_Nomina_Activa', ordernarlos de los salarios más altos a los más bajos.
SELECT * FROM Vista_Nomina_Activa
ORDER BY total_salarios DESC
GO

-- 3.1 CREATE VIEW (Vista de cupos disponibles)
-- Crear una vista llamada 'Vista_Cupos_Disponibles' que verifique la cantidad de cupos disponibles
-- en el año actual
CREATE OR ALTER VIEW Vista_Cupos_Disponibles AS
SELECT ma.id_seccion, 
		cupos, 
		cupos - COUNT(*) 
		AS cupos_disponibles
FROM matricula ma
INNER JOIN seccion se
	ON se.id_seccion = ma.id_seccion
WHERE YEAR(fecha_inicio) = YEAR(GETDATE())
GROUP BY ma.id_seccion, cupos
GO

-- 2.2 CONSULTA SOBRE VISTA:
-- Utilizando la vista 'Vista_Cupos_Disponibles', con los 10 cursos con más cupos disponibles.
SELECT TOP 10 * 
FROM Vista_Cupos_Disponibles
ORDER BY cupos_disponibles DESC
