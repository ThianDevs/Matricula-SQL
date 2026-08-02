USE matricula
GO

INSERT INTO carrera (id, nombre) VALUES 
('TI', 'Ingeniería de Sistemas'), ('AD', 'Administración'), ('II', 'Ingeniería Industrial'),
('DE', 'Derecho'), ('PS', 'Psicología'), ('ME', 'Medicina'),
('AR', 'Arquitectura'), ('EC', 'Economía'), ('BI', 'Biología'),
('EN', 'Enfermería'), ('SO', 'Sociología'), ('QU', 'Química'),
('ED', 'Educación'), ('CO', 'Contabilidad'), ('AG', 'Agronomía');
GO

SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @dni CHAR(9), @carnet CHAR(6), @prov INT, @id_car CHAR(2);
DECLARE @f_ingreso DATE, @dir VARCHAR(255);

-- Listas para aleatoriedad
DECLARE @Nombres TABLE (id INT IDENTITY, n VARCHAR(30));
INSERT INTO @Nombres VALUES ('Juan'),('Maria'),('Luis'),('Ana'),('Carlos'),('Elena'),('Jose'),('Laura'),('Pedro'),('Lucia'),('Diego'),('Sofia'),('Andres'),('Valeria'),('Jorge');
DECLARE @Apellidos TABLE (id INT IDENTITY, a VARCHAR(30));
INSERT INTO @Apellidos VALUES ('Rodriguez'),('Gonzalez'),('Morales'),('Vargas'),('Castillo'),('Jimenez'),('Chaves'),('Mora'),('Solis'),('Pereira'),('Castro'),('Guzman'),('Rojas'),('Salazar'),('Hidalgo');

WHILE @i <= 2000
BEGIN
    SET @prov = (ABS(CHECKSUM(NEWID())) % 7) + 1;
    SET @id_car = (SELECT TOP 1 id FROM carrera ORDER BY NEWID());
    SET @dni = CAST(@prov AS CHAR(1)) + RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR(8)), 8);
    SET @carnet = LEFT(@id_car, 1) + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5);

    SET @dir = CASE @prov 
        WHEN 1 THEN 'San Jose' WHEN 2 THEN 'Alajuela' WHEN 3 THEN 'Cartago' WHEN 4 THEN 'Heredia' 
        WHEN 5 THEN 'Guanacaste' WHEN 6 THEN 'Puntarenas' WHEN 7 THEN 'Limon' END + ', ' + 
        (SELECT TOP 1 a FROM @Apellidos ORDER BY NEWID()) + ' central';

    SET @f_ingreso = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 1825, '2020-01-01');

    IF NOT EXISTS (SELECT 1 FROM estudiante WHERE dni = @dni OR carnet = @carnet)
    BEGIN
        INSERT INTO estudiante (dni, carnet, nombre, primer_apellido, segundo_apellido, telefono, direccion, fecha_ingreso, id_carrera)
        VALUES (
            @dni, @carnet, 
            (SELECT TOP 1 n FROM @Nombres ORDER BY NEWID()), 
            (SELECT TOP 1 a FROM @Apellidos ORDER BY NEWID()), 
            (SELECT TOP 1 a FROM @Apellidos ORDER BY NEWID()),
            -- Lógica corregida: Prefijo (8,7,6) + 7 dígitos exactos con ceros a la izquierda
            CAST((ABS(CHECKSUM(NEWID())) % 3 + 6) AS CHAR(1)) + 
            RIGHT('0000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000 AS VARCHAR(7)), 7),
            @dir, @f_ingreso, @id_car
        );
        SET @i = @i + 1;
    END
END
PRINT '2000 Estudiantes insertados con éxito.';
GO

SET NOCOUNT ON;
DECLARE @j INT = 1;
DECLARE @dni_p CHAR(9), @id_car_p CHAR(2), @prov_p INT;

WHILE @j <= 400
BEGIN
    SET @prov_p = (ABS(CHECKSUM(NEWID())) % 7) + 1;
    -- Asegurar que cada carrera tenga profesores, luego azar
    IF @j <= 15 
        SET @id_car_p = (SELECT id FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn FROM carrera) t WHERE rn = @j);
    ELSE 
        SET @id_car_p = (SELECT TOP 1 id FROM carrera ORDER BY NEWID());

    SET @dni_p = CAST(@prov_p AS CHAR(1)) + RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR(8)), 8);

    IF NOT EXISTS (SELECT 1 FROM profesor WHERE dni = @dni_p)
    BEGIN
        INSERT INTO profesor (dni, nombre, primer_apellido, segundo_apellido, telefono, direccion, id_carrera)
        VALUES (
            @dni_p,
            (SELECT TOP 1 n FROM (VALUES ('Carlos'),('Marta'),('Roberto'),('Ligia'),('Hernan'),('Sonia'),('Ricardo')) AS T(n) ORDER BY NEWID()),
            (SELECT TOP 1 a FROM (VALUES ('Vargas'),('Jimenez'),('Mora'),('Soto'),('Rojas')) AS A(a) ORDER BY NEWID()),
            (SELECT TOP 1 a FROM (VALUES ('Castro'),('Perez'),('Solano'),('Gomez')) AS A2(a) ORDER BY NEWID()),
            -- Lógica corregida: Prefijo 2 o 4 + 7 dígitos exactos
            CAST((ABS(CHECKSUM(NEWID())) % 2 * 2 + 2) AS CHAR(1)) + 
            RIGHT('0000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000 AS VARCHAR(7)), 7),
            (CASE @prov_p WHEN 1 THEN 'San Jose' WHEN 2 THEN 'Alajuela' WHEN 3 THEN 'Cartago' WHEN 4 THEN 'Heredia' 
             WHEN 5 THEN 'Guanacaste' WHEN 6 THEN 'Puntarenas' WHEN 7 THEN 'Limon' END),
            @id_car_p
        );
        SET @j = @j + 1;
    END
END
PRINT '400 Profesores insertados con éxito.';
GO

USE matricula;
GO
SET NOCOUNT ON;

DECLARE @dni_p CHAR(9), @tipo VARCHAR(50), @estado VARCHAR(40), @salario DECIMAL(10,2), @f_ini DATE;

DECLARE prof_cursor CURSOR FOR SELECT dni FROM profesor;
OPEN prof_cursor;
FETCH NEXT FROM prof_cursor INTO @dni_p;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- 1. Decidir si el profesor tiene un contrato viejo finalizado (40% de probabilidad)
    IF (ABS(CHECKSUM(NEWID())) % 10) < 4
    BEGIN
        SET @f_ini = DATEADD(YEAR, -3, '2020-01-01');
        INSERT INTO contrato (dni_profesor, tipo_contrato, estado, jornada, salario, fecha_inicio, fecha_fin)
        VALUES (@dni_p, 'medio tiempo', 'finalizado', 20, 450000, @f_ini, DATEADD(YEAR, 2, @f_ini));
        
        -- Contrato actual activo
        INSERT INTO contrato (dni_profesor, tipo_contrato, estado, jornada, salario, fecha_inicio, fecha_fin)
        VALUES (@dni_p, 'tiempo completo', 'activo', 40, 950000, DATEADD(DAY, 1, DATEADD(YEAR, 2, @f_ini)), NULL);
    END
    ELSE
    BEGIN
        -- Solo contrato activo desde su ingreso
        SET @tipo = (SELECT TOP 1 val FROM (VALUES ('tiempo completo'),('medio tiempo'),('por horas'),('cátedra')) AS T(val) ORDER BY NEWID());
        SET @salario = CASE @tipo WHEN 'tiempo completo' THEN 1000000 WHEN 'medio tiempo' THEN 500000 ELSE 250000 END;
        INSERT INTO contrato (dni_profesor, tipo_contrato, estado, jornada, salario, fecha_inicio, fecha_fin)
        VALUES (@dni_p, @tipo, 'activo', CASE WHEN @tipo='tiempo completo' THEN 40 ELSE 20 END, @salario, '2020-01-01', NULL);
    END
    
    FETCH NEXT FROM prof_cursor INTO @dni_p;
END
CLOSE prof_cursor; DEALLOCATE prof_cursor;
PRINT '400+ Contratos generados.';
GO

SET NOCOUNT ON;
DECLARE @cod_car CHAR(2), @i INT, @nivel INT, @curso_id CHAR(6), @nom_car VARCHAR(100);

DECLARE car_cursor CURSOR FOR SELECT id, nombre FROM carrera;
OPEN car_cursor;
FETCH NEXT FROM car_cursor INTO @cod_car, @nom_car;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @i = 1;
    WHILE @i <= 50
    BEGIN
        SET @nivel = CASE WHEN @i <= 12 THEN 1000 WHEN @i <= 25 THEN 2000 WHEN @i <= 38 THEN 3000 ELSE 4000 END;
        SET @curso_id = @cod_car + CAST(@nivel + @i AS CHAR(4));

        INSERT INTO curso (id, nombre, creditos)
        VALUES (@curso_id, @nom_car + ' Lvl ' + CAST(@i AS VARCHAR), (ABS(CHECKSUM(NEWID())) % 4) + 2);

        -- Requisito lógico: Si es nivel 2000+, pide un curso de nivel inferior de la misma carrera
        IF @nivel > 1000
        BEGIN
            DECLARE @req CHAR(6) = (SELECT TOP 1 id FROM curso WHERE id LIKE @cod_car + '%' AND id < @curso_id ORDER BY id DESC);
            IF @req IS NOT NULL
                INSERT INTO requisitos (id_curso, id_requisito) VALUES (@curso_id, @req);
        END
        SET @i = @i + 1;
    END
    FETCH NEXT FROM car_cursor INTO @cod_car, @nom_car;
END
CLOSE car_cursor; DEALLOCATE car_cursor;
PRINT '750 Cursos y sus requisitos creados.';
GO

SET NOCOUNT ON;
DECLARE @s INT = 1;
WHILE @s <= 1500
BEGIN
    DECLARE @id_c CHAR(6) = (SELECT TOP 1 id FROM curso ORDER BY NEWID());
    DECLARE @prefijo CHAR(2) = LEFT(@id_c, 2);
    
    -- Buscar un profesor que sea de la carrera del curso
    DECLARE @prof CHAR(9) = (SELECT TOP 1 dni FROM profesor WHERE id_carrera = @prefijo ORDER BY NEWID());
    
    -- Si no hay profesor de esa carrera (raro), elegir uno al azar
    IF @prof IS NULL SET @prof = (SELECT TOP 1 dni FROM profesor ORDER BY NEWID());

    DECLARE @y INT = (ABS(CHECKSUM(NEWID())) % 7) + 2020;
    DECLARE @sem INT = (ABS(CHECKSUM(NEWID())) % 2) + 1;

    INSERT INTO seccion (id_curso, dni_profesor, modalidad, cupos, horario, fecha_inicio, fecha_fin)
    VALUES (
        @id_c, @prof,
        (SELECT TOP 1 val FROM (VALUES ('Virtual'), ('Presencial'), ('Bimodal')) AS M(val) ORDER BY NEWID()),
        (ABS(CHECKSUM(NEWID())) % 25) + 15,
        (SELECT TOP 1 d FROM (VALUES ('Lun-Jue'),('Mar-Vie'),('Mie-Sab')) AS D(d) ORDER BY NEWID()) + ' ' + (SELECT TOP 1 h FROM (VALUES ('08:00'),('13:00'),('18:00')) AS H(h) ORDER BY NEWID()),
        CASE WHEN @sem=1 THEN CAST(@y AS VARCHAR)+'-02-01' ELSE CAST(@y AS VARCHAR)+'-08-01' END,
        CASE WHEN @sem=1 THEN CAST(@y AS VARCHAR)+'-06-15' ELSE CAST(@y AS VARCHAR)+'-12-15' END
    );
    SET @s = @s + 1;
END
PRINT '1,500 Secciones creadas (especialidad profesor/curso vinculada).';
GO

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#Pool') IS NOT NULL DROP TABLE #Pool;

-- 1. Crear pool de candidatos válidos (Estudiante -> Seccion de su misma carrera)
SELECT 
    s.id_seccion, e.dni, s.cupos,
    ROW_NUMBER() OVER (PARTITION BY s.id_seccion ORDER BY NEWID()) as FilaCupo
INTO #Pool
FROM seccion s
JOIN estudiante e ON e.id_carrera = LEFT(s.id_curso, 2) -- Misma carrera
WHERE e.fecha_ingreso <= s.fecha_inicio; -- Validar fecha de ingreso

-- 2. Insertar respetando cupos
INSERT INTO matricula (id_seccion, dni_estudiante, nota_final)
SELECT TOP 20000 id_seccion, dni, (ABS(CHECKSUM(NEWID())) % 61) + 40
FROM #Pool
WHERE FilaCupo <= cupos
ORDER BY NEWID();

PRINT 'Matrícula de 20,000 registros completada.';
