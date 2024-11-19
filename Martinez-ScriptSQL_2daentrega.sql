-- Crear las vistas

-- Vista 1: Empleados con sus departamentos y puestos actuales
CREATE VIEW vista_empleados_departamentos AS
SELECT 
    e.ID_EMPLEADO, 
    e.NOMBRE, 
    e.APELLIDO, 
    d.NOMBRE_DEPARTAMENTO, 
    em.TITULO_EMPLEO, 
    e.SALARIO
FROM 
    EMPLEADOS e
JOIN 
    DEPARTAMENTOS d ON e.ID_DEPARTAMENTO = d.ID_DEPARTAMENTO
JOIN 
    EMPLEOS em ON e.ID_EMPLEO = em.ID_EMPLEO;

-- Vista 2: Agrupar empleados por departamento y mostrar estadísticas de sus salarios
CREATE VIEW vista_salarios_departamentos AS
SELECT 
    d.NOMBRE_DEPARTAMENTO,
    COUNT(e.ID_EMPLEADO) AS NUMERO_EMPLEADOS,
    AVG(e.SALARIO) AS SALARIO_PROMEDIO,
    MAX(e.SALARIO) AS SALARIO_MAXIMO,
    MIN(e.SALARIO) AS SALARIO_MINIMO
FROM 
    EMPLEADOS e
JOIN 
    DEPARTAMENTOS d ON e.ID_DEPARTAMENTO = d.ID_DEPARTAMENTO
GROUP BY 
    d.NOMBRE_DEPARTAMENTO;

-- Crear las funciones

-- Función 1: Calcular duración promedio de empleo por departamento y puesto
DELIMITER $$

CREATE FUNCTION duracion_promedio_empleo_departamento(
    p_departamento INT, 
    p_empleo VARCHAR(10)
) 
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE v_duracion_promedio FLOAT;

    SELECT AVG(DATEDIFF(HE.FECHA_FIN, HE.FECHA_INICIO))/365
    INTO v_duracion_promedio
    FROM HISTORIAL_EMPLEOS HE
    WHERE he.ID_DEPARTAMENTO = p_departamento
    AND he.ID_EMPLEO = p_empleo;
    
    RETURN v_duracion_promedio;
END $$

-- Función 2: Calcular salario total considerando sueldo y comisiones según ventas ingresadas manual
DELIMITER //

CREATE FUNCTION calcular_salario_total(emp_id INT, venta DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE salario_base DECIMAL(10, 2);
    DECLARE pct_comision DECIMAL(5, 2);
    DECLARE salario_total DECIMAL(10, 2);

    -- Recuperar el salario base del empleado
    SELECT SALARIO INTO salario_base
    FROM EMPLEADOS
    WHERE ID_EMPLEADO = emp_id;

    -- Recuperar el porcentaje de comisión del empleado
    SELECT PORCENTAJE_COMISION INTO pct_comision
    FROM EMPLEADOS
    WHERE ID_EMPLEADO = emp_id;

    -- Calcular el salario total incluyendo las comisiones
    SET salario_total = salario_base + (venta * (pct_comision / 100));

    RETURN salario_total;
END //

-- Crear los Stored Procedures

-- Stored Procedure 1: Consultar según una dirección los empleados y su información de contacto
DELIMITER //

CREATE PROCEDURE obtener_empleados_por_direccion(
    IN p_id_direccion INT
)
BEGIN
    SELECT 
        e.ID_EMPLEADO AS EmpleadoID,
        e.NOMBRE AS Nombre,
        e.APELLIDO AS Apellido,
        em.TITULO_EMPLEO AS TituloEmpleo,
        e.CORREO AS Correo,
        e.TELEFONO AS Telefono
    FROM 
        EMPLEADOS e
    JOIN 
        DEPARTAMENTOS d ON e.ID_DEPARTAMENTO = d.ID_DEPARTAMENTO
    JOIN 
        EMPLEOS em ON e.ID_EMPLEO = em.ID_EMPLEO
    WHERE 
        d.ID_DIRECCION = p_id_direccion
    ORDER BY 
        e.ID_EMPLEADO;
END // ;

-- Stored Procedure 2: Insertar registros entabla EMPLEADOS
DELIMITER //

CREATE PROCEDURE insertar_empleado (
    IN p_nombre VARCHAR(20),
    IN p_apellido VARCHAR(25),
    IN p_correo VARCHAR(25),
    IN p_telefono VARCHAR(20),
    IN p_fecha_contratacion DATE,
    IN p_id_empleo VARCHAR(10),
    IN p_salario DECIMAL(10, 2),
    IN p_porcentaje_comision DECIMAL(5, 2),
    IN p_id_jefe INT,
    IN p_id_departamento INT
)
BEGIN
    INSERT INTO EMPLEADOS (NOMBRE, APELLIDO, CORREO, TELEFONO, FECHA_CONTRATACION, ID_EMPLEO, SALARIO, PORCENTAJE_COMISION, ID_JEFE, ID_DEPARTAMENTO)
    VALUES (p_nombre, p_apellido, p_correo, p_telefono, p_fecha_contratacion, p_id_empleo, p_salario, p_porcentaje_comision, p_id_jefe, p_id_departamento);
END //
DELIMITER ;

-- Stored Procedure 3: Contar empleados por departamento para una dirección específica

DELIMITER //

CREATE PROCEDURE contar_empleados_por_direccion(
    IN p_id_direccion INT
)
BEGIN
    SELECT 
        d.NOMBRE_DEPARTAMENTO AS Departamento,
        COUNT(e.ID_EMPLEADO) AS TotalEmpleados
    FROM 
        DEPARTAMENTOS d
    LEFT JOIN 
        EMPLEADOS e ON d.ID_DEPARTAMENTO = e.ID_DEPARTAMENTO
    WHERE 
        d.ID_DIRECCION = p_id_direccion
    GROUP BY 
        d.ID_DEPARTAMENTO, d.NOMBRE_DEPARTAMENTO
    ORDER BY 
        TotalEmpleados DESC;
END //

DELIMITER;

-- Crear los triggers

-- Trigger 1: AFTER INSERT en EMPLEADOS para auditoría

DELIMITER //

CREATE TABLE AUDITORIA (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ACCION VARCHAR(50),
    FECHA DATETIME,
    USUARIO VARCHAR(100)
);

// ;

DELIMITER //

CREATE TRIGGER after_insert_empleados
AFTER INSERT ON EMPLEADOS
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA (ACCION, FECHA, USUARIO)
    VALUES ('INSERT', NOW(), USER());
END //

DELIMITER ;

-- Trigger 2: BEFORE DELETE en DEPARTAMENTOS que impida la eliminación si hay empleados asociados
DELIMITER //

CREATE TRIGGER before_delete_departamentos
BEFORE DELETE ON DEPARTAMENTOS
FOR EACH ROW
BEGIN
    -- Declarar la variable al inicio del bloque
    DECLARE empleados_asociados INT;

    -- Verificar si hay empleados asociados al departamento
    SELECT COUNT(*) INTO empleados_asociados 
    FROM EMPLEADOS 
    WHERE ID_DEPARTAMENTO = OLD.ID_DEPARTAMENTO;

    -- Si hay empleados asociados, generar un error
    IF empleados_asociados > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No se puede eliminar el departamento, hay empleados asociados.';
    END IF;
END //

DELIMITER ;