-- Insertar datos en la tabla PAIS
INSERT INTO PAIS (ID_PAIS, NOMBRE_PAIS) VALUES
('ARG', 'Argentina');

-- Insertar datos en la tabla PROVINCIA
INSERT INTO PROVINCIA (NOMBRE_PROVINCIA, ID_PAIS) VALUES
('Córdoba', 'ARG'),
('Santa Fe', 'ARG'),
('Mendoza', 'ARG');

-- Insertar datos en la tabla DIRECCIONES
INSERT INTO DIRECCIONES (DIRECCION, CODIGO_POSTAL, CIUDAD, ID_PAIS, ID_PROVINCIA) VALUES
('Av. Colón 1234', '5000', 'Córdoba', 'ARG', 1),
('San Martín 567', '5001', 'Villa Carlos Paz', 'ARG', 1),
('Rivadavia 890', '5002', 'Alta Gracia', 'ARG', 1);

-- Insertar datos en la tabla DEPARTAMENTOS
INSERT INTO DEPARTAMENTOS (NOMBRE_DEPARTAMENTO, ID_JEFE, ID_DIRECCION) VALUES
('Ventas', NULL, 1),
('Recursos Humanos', NULL, 1),
('Desarrollo', NULL, 2),
('Soporte Técnico', NULL, 2),
('Marketing', NULL, 1);

-- Insertar datos en la tabla EMPLEOS
INSERT INTO EMPLEOS (ID_EMPLEO, TITULO_EMPLEO, SALARIO_MINIMO, SALARIO_MAXIMO) VALUES
('DEV001', 'Desarrollador Junior', 70000.00, 120000.00),
('DEV002', 'Desarrollador Senior', 120000.00, 200000.00),
('HR001', 'Analista de Recursos Humanos', 80000.00, 140000.00),
('SOP001', 'Técnico de Soporte', 60000.00, 100000.00),
('MK001', 'Especialista en Marketing', 85000.00, 130000.00),
('VEN001', 'Representante de Ventas', 75000.00, 110000.00),
('HR002', 'Coordinador de Recursos Humanos', 90000.00, 150000.00),
('DEV003', 'Desarrollador Líder', 150000.00, 250000.00),
('SOP002', 'Ingeniero de Soporte', 100000.00, 160000.00),
('MK002', 'Gerente de Marketing', 130000.00, 180000.00),
('VEN002', 'Gerente de Ventas', 120000.00, 170000.00),
('HR003', 'Director de Recursos Humanos', 140000.00, 200000.00);

-- Insertar datos en la tabla EMPLEADOS
INSERT INTO EMPLEADOS (NOMBRE, APELLIDO, CORREO, TELEFONO, FECHA_CONTRATACION, ID_EMPLEO, SALARIO, PORCENTAJE_COMISION, ID_JEFE, ID_DEPARTAMENTO) VALUES
('Juan', 'Martínez', 'jmartinez@example.com', '3511234567', '2022-03-01', 'DEV002', 85000.00, 5.00, NULL, 3),
('Ana', 'Gómez', 'agomez@example.com', '3517654321', '2021-07-15', 'DEV002', 150000.00, 7.50, NULL, 3),
('Pedro', 'López', 'plopez@example.com', '3515678901', '2023-01-10', 'HR001', 95000.00, 4.00, NULL, 2),
('María', 'Rodríguez', 'mrodriguez@example.com', '3518765432', '2020-09-05', 'SOP001', 70000.00, 3.50, NULL, 4),
('Luis', 'Fernández', 'lfernandez@example.com', '3512347890', '2023-05-21', 'MK001', 90000.00, 6.00, NULL, 5),
('Sofía', 'Pérez', 'sperez@example.com', '3518901234', '2021-04-10', 'VEN001', 80000.00, 4.50, NULL, 1),
('Jorge', 'Ramírez', 'jramirez@example.com', '3516789012', '2019-08-22', 'HR002', 105000.00, 5.00, NULL, 2),
('Laura', 'Castillo', 'lcastillo@example.com', '3513456789', '2022-11-15', 'DEV003', 160000.00, 7.00, NULL, 3),
('Miguel', 'Díaz', 'mdiaz@example.com', '3515671234', '2023-02-01', 'SOP002', 110000.00, 4.00, NULL, 4),
('Valeria', 'Ruiz', 'vruiz@example.com', '3518762345', '2021-01-30', 'MK002', 135000.00, 6.50, NULL, 5),
('Carlos', 'Jiménez', 'cjimenez@example.com', '3514321987', '2022-06-18', 'VEN002', 125000.00, 5.50, NULL, 1),
('Elena', 'Morales', 'emorales@example.com', '3517654322', '2021-12-01', 'HR003', 150000.00, 8.00, NULL, 2),
('Andrés', 'Navarro', 'anavarro@example.com', '3513451289', '2020-03-15', 'DEV001', 95000.00, 4.00, NULL, 3),
('Marta', 'Cabrera', 'mcabrera@example.com', '3511289345', '2023-04-25', 'DEV002', 145000.00, 6.50, NULL, 3),
('Pablo', 'Benítez', 'pbenitez@example.com', '3514527891', '2022-10-11', 'HR001', 98000.00, 3.50, NULL, 2),
('Florencia', 'Sosa', 'fsosa@example.com', '3518975612', '2021-02-20', 'SOP001', 72000.00, 4.00, NULL, 4),
('Cecilia', 'Vega', 'cvega@example.com', '3515679812', '2020-07-14', 'MK001', 92000.00, 5.00, NULL, 5),
('Rodrigo', 'Herrera', 'rherrera@example.com', '3513457689', '2021-11-19', 'VEN001', 83000.00, 4.20, NULL, 1),
('Lucía', 'Páez', 'lpaez@example.com', '3519081234', '2023-09-10', 'DEV003', 155000.00, 6.80, NULL, 3),
('Fernando', 'Duarte', 'fduarte@example.com', '3515612378', '2022-01-05', 'SOP002', 115000.00, 4.50, NULL, 4);

-- Insertar datos en la tabla HISTORIAL_EMPLEOS
INSERT INTO HISTORIAL_EMPLEOS (ID_EMPLEADO, FECHA_INICIO, FECHA_FIN, ID_EMPLEO, ID_DEPARTAMENTO) VALUES
(1, '2021-01-01', '2022-02-28', 'DEV002', 3),
(2, '2020-05-01', '2021-07-14', 'DEV002', 3),
(3, '2021-12-01', '2023-01-09', 'HR001', 2),
(4, '2019-01-10', '2020-09-04', 'SOP001', 4),
(5, '2021-06-01', '2023-05-20', 'MK001', 5);
