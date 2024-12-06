-- 1. Muestra todos los empleados que actualmente están activos en la empresa.
SELECT * FROM V_EMPLEADOS_ACTIVOS;

-- 2. Lista de empleados que han sido contratados en los últimos meses.
SELECT * FROM V_ALTAS_ULTIMOS_MESES;

-- 3. Muestra los empleados que se han dado de baja o que han cambiado de puesto en los últimos meses.
SELECT * FROM V_BAJAS_CAMBIOS_ULTIMOS_MESES;

-- 4. Lista de empleados activos organizados por departamento.
SELECT * FROM V_EMPLEADOS_ACTIVOS_POR_DEPARTAMENTO;

-- 5. Muestra el número de empleados por cada combinación de departamento y ubicación.
SELECT * FROM V_EMPLEADOS_POR_DEPARTAMENTO_UBICACION;

-- 6. Calcula el salario total de los empleados de un departamento específico para un mes y año dados.
SELECT calcular_salario_total_departamento(1, 2024, 11);

-- 7. Calcula la duración promedio de empleo en años para un departamento y empleo específicos.
SELECT duracion_promedio_empleo_departamento(1, 'ADM02');

-- 8. Cuenta el número de empleados asociados a una dirección específica.
CALL contar_empleados_por_direccion(1);

-- 9. Muestra la lista de empleados asociados a una dirección específica.
CALL obtener_empleados_por_direccion(2);

-- 10. Inserta un nuevo empleado con los datos especificados.
CALL insertar_empleado('Mario', 'Martinez', 'amartinez@dev.com', '3513513513');

-- 11. Busca al empleado recién insertado en la base de datos.
SELECT * FROM empleados
WHERE nombre = 'Mario' AND apellido = 'Martinez';

-- 12. Muestra el registro de auditoría, que incluye las acciones realizadas en la base de datos.
SELECT * FROM auditoria;

-- 13. Intenta eliminar un departamento específico. Si hay empleados asociados, el trigger bloquea la operación.
DELETE FROM DEPARTAMENTOS WHERE ID_DEPARTAMENTO = 1;