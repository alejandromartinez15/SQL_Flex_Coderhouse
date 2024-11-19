select * from vista_empleados_departamentos;

select * from vista_salarios_departamentos;

select calcular_salario_total (1, 20000);

select duracion_promedio_empleo_departamento(3, 'DEV002');

call contar_empleados_por_direccion(1);

call obtener_empleados_por_direccion(2);

call insertar_empleado('Mario', 'Martinez', 'amartinez@dev.com', '3513513513', '2024-11-19', 'DEV002', 1000000, 2.00, NULL, 3);

select * from empleados
where nombre = 'Mario' and apellido = 'Martinez';

select * from auditoria;

delete from DEPARTAMENTOS where ID_DEPARTAMENTO = 1;