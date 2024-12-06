-- Creación de vistas

CREATE OR REPLACE VIEW V_EMPLEADOS_ACTIVOS AS
SELECT e.ID_EMPLEADO, e.NOMBRE, e.APELLIDO, e.CORREO, e.TELEFONO
FROM EMPLEADOS e
LEFT JOIN HISTORIAL_EMPLEOS he ON e.ID_EMPLEADO = he.ID_EMPLEADO
WHERE he.FECHA_FIN IS NULL
;

CREATE OR REPLACE VIEW V_ALTAS_ULTIMOS_MESES AS
SELECT e.ID_EMPLEADO, e.NOMBRE, e.APELLIDO, he.FECHA_INICIO, em.TITULO_EMPLEO
FROM EMPLEADOS e
LEFT JOIN HISTORIAL_EMPLEOS he ON e.ID_EMPLEADO = he.ID_EMPLEADO
JOIN EMPLEOS em ON he.ID_EMPLEO = em.ID_EMPLEO
WHERE he.FECHA_INICIO >= CURDATE() - INTERVAL 12 MONTH
;

CREATE OR REPLACE VIEW V_BAJAS_CAMBIOS_ULTIMOS_MESES AS
SELECT e.ID_EMPLEADO, e.NOMBRE, e.APELLIDO, he.FECHA_INICIO, he.FECHA_FIN, em.TITULO_EMPLEO
FROM HISTORIAL_EMPLEOS he
JOIN EMPLEADOS e ON he.ID_EMPLEADO = e.ID_EMPLEADO
JOIN EMPLEOS em ON he.ID_EMPLEO = em.ID_EMPLEO
WHERE he.FECHA_FIN >= CURDATE() - INTERVAL 12 MONTH
;
 
CREATE OR REPLACE VIEW V_EMPLEADOS_ACTIVOS_POR_DEPARTAMENTO AS
SELECT e.ID_EMPLEADO, e.NOMBRE, e.APELLIDO, d.NOMBRE_DEPARTAMENTO, j.NOMBRE AS NOMBRE_JEFE
FROM EMPLEADOS e
JOIN DEPARTAMENTOS d ON e.ID_EMPLEADO = d.ID_JEFE
LEFT JOIN EMPLEADOS j ON d.ID_JEFE = j.ID_EMPLEADO
LEFT JOIN HISTORIAL_EMPLEOS he ON e.ID_EMPLEADO = he.ID_EMPLEADO
WHERE he.FECHA_FIN IS NULL OR he.FECHA_FIN > CURDATE()
;

CREATE OR REPLACE VIEW V_EMPLEADOS_POR_DEPARTAMENTO_UBICACION AS
SELECT e.ID_EMPLEADO, e.NOMBRE, e.APELLIDO, d.NOMBRE_DEPARTAMENTO, di.DIRECCION, di.CIUDAD
FROM EMPLEADOS e
JOIN DEPARTAMENTOS d ON e.ID_EMPLEADO = d.ID_JEFE
JOIN DIRECCIONES di ON d.ID_DIRECCION = di.ID_DIRECCION
LEFT JOIN HISTORIAL_EMPLEOS he ON e.ID_EMPLEADO = he.ID_EMPLEADO
WHERE he.FECHA_FIN IS NULL OR he.FECHA_FIN > CURDATE()
;

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

    SELECT AVG(DATEDIFF(IFNULL(HE.FECHA_FIN,CURDATE()), HE.FECHA_INICIO))/365
    INTO v_duracion_promedio
    FROM HISTORIAL_EMPLEOS HE
    WHERE he.ID_DEPARTAMENTO = p_departamento
    AND he.ID_EMPLEO = p_empleo;
    
    RETURN v_duracion_promedio;
END $$

DELIMITER //

CREATE FUNCTION calcular_salario_total_departamento(
	p_departamento_id INT,
    p_anio INT,
    p_mes INT
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE salario_total DECIMAL(10, 2);

    -- Sumar los salarios de los empleados activos en el departamento
    SELECT SUM(pe.MONTO) INTO salario_total
    FROM HISTORIAL_PAGOS pe 
    JOIN HISTORIAL_EMPLEOS he ON pe.ID_HIST_EMPLEO = he.ID_HIST_EMPLEO
    WHERE he.ID_DEPARTAMENTO = p_departamento_id
    AND he.FECHA_FIN IS NULL
    AND YEAR(pe.FECHA_PAGO) = p_anio
    AND MONTH(pe.FECHA_PAGO) = p_mes
    ;

    -- Devolver el salario total
    RETURN salario_total;
END //

DELIMITER ;

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
        e.CORREO AS Correo,
        e.TELEFONO AS Telefono
    FROM 
        EMPLEADOS e
    JOIN 
        HISTORIAL_EMPLEOS he ON e.ID_EMPLEADO = he.ID_EMPLEADO
    JOIN 
        DEPARTAMENTOS d ON he.ID_DEPARTAMENTO = d.ID_DEPARTAMENTO
    WHERE 
        d.ID_DIRECCION = p_id_direccion
        AND he.FECHA_FIN IS NULL
    ORDER BY 
        e.ID_EMPLEADO;
END // ;

-- Stored Procedure 2: Insertar registros en tabla EMPLEADOS
DELIMITER //

CREATE PROCEDURE insertar_empleado (
    IN p_nombre VARCHAR(20),
    IN p_apellido VARCHAR(25),
    IN p_correo VARCHAR(25),
    IN p_telefono VARCHAR(20)
)
BEGIN
    INSERT INTO EMPLEADOS (NOMBRE, APELLIDO, CORREO, TELEFONO)
    VALUES (p_nombre, p_apellido, p_correo, p_telefono);
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
        COUNT(he.ID_EMPLEADO) AS TotalEmpleados
    FROM 
        DEPARTAMENTOS d
    LEFT JOIN 
        HISTORIAL_EMPLEOS he ON d.ID_DEPARTAMENTO = he.ID_DEPARTAMENTO
    WHERE 
        d.ID_DIRECCION = p_id_direccion
        AND he.FECHA_FIN IS NULL
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
    FROM HISTORIAL_EMPLEOS he 
    WHERE he.ID_DEPARTAMENTO = OLD.ID_DEPARTAMENTO
    ;

    -- Si hay empleados asociados, generar un error
    IF empleados_asociados > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No se puede eliminar el departamento, hay empleados asociados.';
    END IF;
END //

DELIMITER ;

