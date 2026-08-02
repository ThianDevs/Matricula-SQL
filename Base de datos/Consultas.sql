/* 
EJERCICIOS DE CONSULTAS SQL - BASE DE DATOS: MATRICULA
*/
USE matricula;
GO

-- 1. SELECT, TOP, DISTINCT, ORDER BY:
-- Obtener los primeros 10 nombres únicos de los estudiantes, ordenados alfabéticamente.
SELECT DISTINCT 
	TOP 10 nombre
FROM estudiante
ORDER BY nombre 
GO

-- 2. WHERE, LIKE, AND, OR:
-- Seleccionar nombre, primer apellido y teléfono de estudiantes cuyo nombre empiece con 'A' o 'J' 
-- y cuyo primer apellido NO termine con 'Z'.
SELECT 
	nombre, 
	primer_apellido,
	telefono
FROM estudiante
WHERE 
	nombre LIKE 'A%' OR nombre LIKE 'J%'
	AND primer_apellido NOT LIKE '%Z'
GO

-- 3. BETWEEN, IN, NOT:
-- Mostrar dni_profesor, tipo_contrato y salario de los contratos con salario entre 250000 y 450000, 
-- pero que NO sean de tipo 'cátedra' ni 'por horas'.
SELECT 
	dni_profesor, 
	tipo_contrato, 
	salario
FROM contrato
WHERE 
	salario BETWEEN 250000 AND 450000
	AND tipo_contrato NOT IN ('cátedra', 'por horas')
ORDER BY tipo_contrato, dni_profesor
GO

-- 4. IS NULL, IS NOT NULL:
-- Listar los nombres y apellidos de profesores que tienen registrado su segundo apellido 
-- pero cuya fecha_fin en el contrato es NULL (contratos vigentes).
SELECT 
	nombre, 
	primer_apellido, 
	segundo_apellido
FROM profesor pf
INNER JOIN contrato c ON pf.dni = c.dni_profesor
WHERE fecha_fin IS NULL
ORDER BY nombre, primer_apellido, segundo_apellido
GO

-- 5. COUNT, GROUP BY, HAVING:
-- Mostrar el ID de la sección y cuántos estudiantes tiene matriculados. 
-- Filtrar para ver solo las secciones con más de 2 estudiantes.
SELECT 
	id_seccion, 
	COUNT(dni_estudiante) AS cantidad_estudiantes
FROM matricula
GROUP BY id_seccion
HAVING COUNT(dni_estudiante) > 2
ORDER BY cantidad_estudiantes DESC
GO

-- 6. SUM, AVG, MIN, MAX:
-- Calcular el salario total, el promedio, el mínimo y el máximo de todos los 
-- contratos con estado 'activo'.
SELECT 
	SUM(salario) AS inversion_salarial, 
	AVG(salario) AS salario_promedio,
	MIN(salario) AS salario_minimo,
	MAX(salario) AS salario_maximo
FROM contrato
WHERE estado = 'activo'
GO

-- 7. INNER JOIN:
-- Mostrar el nombre del estudiante, el nombre del curso y la nota final obtenida.
SELECT 
	es.nombre,
	cu.nombre,
	nota_final
FROM matricula ma
INNER JOIN estudiante es ON es.dni = ma.dni_estudiante
INNER JOIN seccion se ON se.id_seccion = ma.id_seccion
INNER JOIN curso cu ON cu.id = se.id_curso
ORDER BY nota_final DESC
GO

-- 8. LEFT JOIN e IS NULL:
-- Listar todos los estudiantes (nombre y apellido) y su ID de sección, 
-- incluyendo aquellos que aún no se han matriculado en ninguna sección (estos saldrán con NULL).
SELECT
	nombre, 
	primer_apellido, 
	segundo_apellido, 
	id_seccion
FROM estudiante es
LEFT JOIN matricula ma ON dni = dni_estudiante
GO

-- 9. RIGHT JOIN:
-- Mostrar todos los cursos (id y nombre) y la cantidad de secciones que tienen creadas. 
-- Asegurarse de que se muestren los cursos aunque no tengan secciones asignadas aún.
SELECT 
	cu.id, 
	cu.nombre, 
	COUNT(se.id_seccion) 
	AS secciones_creadas
FROM curso cu
RIGHT JOIN seccion se ON se.id_curso = cu.id
GROUP BY cu.id, cu.nombre
GO

-- 10. SUBCONSULTA (Operador >):
-- Encontrar el nombre y apellidos de los estudiantes que obtuvieron una nota_final 
-- mayor al promedio general de todas las notas de la institución.
SELECT DISTINCT 
	nombre, 
	primer_apellido, 
	segundo_apellido
FROM matricula ma
INNER JOIN estudiante es 
ON es.dni = ma.dni_estudiante
WHERE nota_final > (
	SELECT AVG(nota_final) 
	FROM matricula)
GO

-- 11. SUBCONSULTA (Cláusula IN):
-- Listar los nombres completos de los profesores que dictan el curso con ID 'AD4045' (matemáticas).
SELECT DISTINCT
	nombre,
	primer_apellido,
	segundo_apellido
FROM profesor pr
WHERE dni IN (
	SELECT dni_profesor
	FROM seccion 
	WHERE id_curso = 'AD4045')
GO

-- 12. JOIN COMPLEJO Y LIKE:
-- Mostrar el nombre del profesor y el nombre de los cursos que imparte, 
-- pero solo para cursos cuyo nombre contenga la palabra 'Administración'.
SELECT 
	pr.nombre,
	cu.nombre
FROM profesor pr
INNER JOIN seccion se ON se.dni_profesor = pr.dni
INNER JOIN curso cu ON cu.id = se.id_curso
WHERE cu.nombre LIKE '%Administración%'
GO

-- 13. COUNT DISTINCT y GROUP BY:
-- Contar cuántas modalidades diferentes de clase imparte cada profesor (dni_profesor y cantidad).
SELECT DISTINCT		
	dni_profesor, 
	COUNT(DISTINCT(modalidad)) 
	AS modalidades_impartidas
FROM seccion
WHERE dni_profesor IS NOT NULL
GROUP BY dni_profesor
ORDER BY modalidades_impartidas DESC
GO

-- 14. SUBCONSULTA CORRELACIONADA:
-- Listar los cursos que tienen créditos mayores al promedio de créditos de todos los cursos.
SELECT 
	id, 
	nombre, 
	creditos
FROM curso
WHERE creditos > (
	SELECT AVG(creditos) 
	FROM curso)
ORDER BY creditos DESC
GO

-- 15. BETWEEN y FECHAS:
-- Mostrar los contratos que iniciaron entre el '2017-01-01' y el '2017-12-31'.
SELECT *
FROM contrato
WHERE fecha_inicio 
	BETWEEN '2017-01-01' AND '2017-12-31'
GO

-- 16. NOT IN y SUBCONSULTA:
-- Mostrar los cursos que actualmente NO tienen ninguna sección abierta (no están en la tabla seccion).
SELECT *
FROM curso
WHERE id NOT IN (
	SELECT 
	id_curso 
	FROM seccion)
ORDER BY creditos DESC
GO

-- 17. HAVING y MÚLTIPLES JOINS:
-- Mostrar el nombre de los cursos que tienen un promedio de notas superior a 80.
SELECT 
	cu.nombre, 
	AVG(nota_final) 
	AS notas_promedio
FROM curso cu
INNER JOIN seccion se ON se.id_curso = cu.id
INNER JOIN matricula ma ON ma.id_seccion = se.id_seccion
GROUP BY cu.nombre
HAVING AVG(nota_final) > 80
ORDER BY notas_promedio DESC
GO

-- 18. TOP y ORDER BY (Ranking):
-- Obtener los 10 estudiantes con el promedio de notas más altas de la institución, 
-- mostrando su nombre y su promedio.
SELECT TOP 10
	dni_estudiante, 
	AVG(nota_final) promedio
FROM matricula
GROUP BY dni_estudiante
ORDER BY promedio DESC
GO
 
-- 19. CASE (Opcional - Lógica condicional):
-- Mostrar el nombre del estudiante y un mensaje que diga 'Aprobado' si su nota es >= 70 
-- y 'Reprobado' si es menor. (Usa la tabla matricula) y muestra el curso correspondiente.
SELECT
	es.nombre,
	se.id_curso,
	CASE WHEN
		ma.nota_final >= 70 THEN 'Aprobado'
		ELSE 'Reprobado'
	END AS estado
FROM matricula ma
INNER JOIN estudiante es 
	ON es.dni = ma.dni_estudiante
INNER JOIN seccion se 
	ON se.id_seccion = ma.id_seccion
ORDER BY estado, nombre, id_curso
GO