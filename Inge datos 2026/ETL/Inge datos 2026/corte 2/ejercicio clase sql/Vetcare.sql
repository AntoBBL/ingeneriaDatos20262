-- =========================================================
-- BASE DE DATOS: CLINICA VETERINARIA
-- Generado a partir del diagrama de clases (modelo logico)
-- Estrategia de herencia: tabla por subclase (comparten PK)
-- =========================================================

CREATE DATABASE clinica_veterinaria1;
USE clinica_veterinaria1;

-- =========================================================
-- 1. PERSONA (superclase) y sus subclases
-- =========================================================
CREATE TABLE Persona (
    documentoIdentidad VARCHAR(20) PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    telefono            VARCHAR(20)
);

CREATE TABLE Cliente (
    documentoIdentidad VARCHAR(20) PRIMARY KEY,
    direccion           VARCHAR(200),
    correoElectronico   VARCHAR(100),
    CONSTRAINT fk_cliente_persona
        FOREIGN KEY (documentoIdentidad) REFERENCES Persona(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Veterinario (
    documentoIdentidad VARCHAR(20) PRIMARY KEY,
    CONSTRAINT fk_veterinario_persona
        FOREIGN KEY (documentoIdentidad) REFERENCES Persona(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 2. ESPECIALIDAD y relacion N:M con Veterinario
-- =========================================================
CREATE TABLE Especialidad (
    idEspecialidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL
);

CREATE TABLE Veterinario_Especialidad (
    documentoIdentidad VARCHAR(20) NOT NULL,
    idEspecialidad     INT NOT NULL,
    PRIMARY KEY (documentoIdentidad, idEspecialidad),
    CONSTRAINT fk_ve_veterinario
        FOREIGN KEY (documentoIdentidad) REFERENCES Veterinario(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ve_especialidad
        FOREIGN KEY (idEspecialidad) REFERENCES Especialidad(idEspecialidad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 3. SEDE
-- =========================================================
CREATE TABLE Sede (
    idSede    INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono  VARCHAR(20)
);

-- =========================================================
-- 4. JAULA
-- =========================================================
CREATE TABLE Jaula (
    idJaula INT AUTO_INCREMENT PRIMARY KEY,
    numero  VARCHAR(20) NOT NULL,
    tamano  VARCHAR(20)
);

-- =========================================================
-- 5. MASCOTA (pertenece a un Cliente)
-- =========================================================
CREATE TABLE Mascota (
    idMascota        INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    especie          VARCHAR(50),
    raza             VARCHAR(50),
    fechaNacimiento  DATE,
    sexo             VARCHAR(10),
    peso             FLOAT,
    microchip        VARCHAR(50),
    idCliente        VARCHAR(20) NOT NULL,
    CONSTRAINT fk_mascota_cliente
        FOREIGN KEY (idCliente) REFERENCES Cliente(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 6. HISTORIA CLINICA (1:1 con Mascota)
-- =========================================================
CREATE TABLE HistoriaClinica (
    idHistoriaClinica INT AUTO_INCREMENT PRIMARY KEY,
    idMascota         INT NOT NULL UNIQUE,
    CONSTRAINT fk_historia_mascota
        FOREIGN KEY (idMascota) REFERENCES Mascota(idMascota)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 7. HOSPITALIZACION (1 Mascota : N, 1 Jaula : N)
-- =========================================================
CREATE TABLE Hospitalizacion (
    idHospitalizacion INT AUTO_INCREMENT PRIMARY KEY,
    fechaIngreso      DATE NOT NULL,
    fechaSalida       DATE,
    motivo            VARCHAR(200),
    idMascota         INT NOT NULL,
    idJaula           INT NOT NULL,
    CONSTRAINT fk_hosp_mascota
        FOREIGN KEY (idMascota) REFERENCES Mascota(idMascota)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_hosp_jaula
        FOREIGN KEY (idJaula) REFERENCES Jaula(idJaula)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================================================
-- 8. NOTA EVOLUCION (1 Hospitalizacion : N)
-- =========================================================
CREATE TABLE NotaEvolucion (
    idNotaEvolucion   INT AUTO_INCREMENT PRIMARY KEY,
    fecha             DATE NOT NULL,
    hora              TIME NOT NULL,
    observacion       VARCHAR(300),
    idHospitalizacion INT NOT NULL,
    CONSTRAINT fk_nota_hospitalizacion
        FOREIGN KEY (idHospitalizacion) REFERENCES Hospitalizacion(idHospitalizacion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 9. CITA (1 Mascota : N, 1 Sede : N, 1 Veterinario : N)
-- =========================================================
CREATE TABLE Cita (
    idCita    INT AUTO_INCREMENT PRIMARY KEY,
    fecha     DATE NOT NULL,
    hora      TIME NOT NULL,
    motivo    VARCHAR(200),
    estado    VARCHAR(30),
    idMascota INT NOT NULL,
    idSede    INT NOT NULL,
    idVeterinario VARCHAR(20) NOT NULL,
    CONSTRAINT fk_cita_mascota
        FOREIGN KEY (idMascota) REFERENCES Mascota(idMascota)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_cita_sede
        FOREIGN KEY (idSede) REFERENCES Sede(idSede)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_veterinario
        FOREIGN KEY (idVeterinario) REFERENCES Veterinario(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================================================
-- 10. CONSULTA (0..1 : 1 con Cita -> no toda cita genera consulta)
-- =========================================================
CREATE TABLE Consulta (
    idConsulta   INT AUTO_INCREMENT PRIMARY KEY,
    sintomas     VARCHAR(300),
    diagnostico  VARCHAR(300),
    indicaciones VARCHAR(300),
    idCita       INT NOT NULL UNIQUE,
    CONSTRAINT fk_consulta_cita
        FOREIGN KEY (idCita) REFERENCES Cita(idCita)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 11. EXAMEN LABORATORIO (1 Consulta : N)
-- =========================================================
CREATE TABLE ExamenLaboratorio (
    idExamen        INT AUTO_INCREMENT PRIMARY KEY,
    tipoExamen      VARCHAR(100),
    fechaSolicitud  DATE,
    fechaResultado  DATE,
    resultado       VARCHAR(300),
    idConsulta      INT NOT NULL,
    CONSTRAINT fk_examen_consulta
        FOREIGN KEY (idConsulta) REFERENCES Consulta(idConsulta)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 12. PRODUCTO (superclase) y subclases Vacuna / Medicamento
-- =========================================================
CREATE TABLE Producto (
    idProducto   INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    presentacion VARCHAR(100)
);

CREATE TABLE Vacuna (
    idProducto           INT PRIMARY KEY,
    enfermedadQuePrevine VARCHAR(150),
    CONSTRAINT fk_vacuna_producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Medicamento (
    idProducto      INT PRIMARY KEY,
    principioActivo VARCHAR(150),
    CONSTRAINT fk_medicamento_producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 13. LOTE (1 Producto : N)
-- =========================================================
CREATE TABLE Lote (
    idLote           INT AUTO_INCREMENT PRIMARY KEY,
    numeroLote       VARCHAR(50) NOT NULL,
    fechaVencimiento DATE,
    fechaFabricacion DATE,
    idProducto       INT NOT NULL,
    CONSTRAINT fk_lote_producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 14. APLICACION VACUNA (1 Consulta : N, 1 Vacuna : N)
-- =========================================================
CREATE TABLE AplicacionVacuna (
    idAplicacion   INT AUTO_INCREMENT PRIMARY KEY,
    fechaAplicacion DATE NOT NULL,
    idConsulta     INT NOT NULL,
    idVacuna       INT NOT NULL,
    CONSTRAINT fk_aplicacion_consulta
        FOREIGN KEY (idConsulta) REFERENCES Consulta(idConsulta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_aplicacion_vacuna
        FOREIGN KEY (idVacuna) REFERENCES Vacuna(idProducto)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================================================
-- 15. SEDE <-> PRODUCTO (inventario, relacion N:M)
-- =========================================================
CREATE TABLE Sede_Producto (
    idSede     INT NOT NULL,
    idProducto INT NOT NULL,
    PRIMARY KEY (idSede, idProducto),
    CONSTRAINT fk_sp_sede
        FOREIGN KEY (idSede) REFERENCES Sede(idSede)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_sp_producto
        FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 16. FACTURA (1 Cliente : N)
-- =========================================================
CREATE TABLE Factura (
    idFactura    INT AUTO_INCREMENT PRIMARY KEY,
    fechaEmision DATE NOT NULL,
    valorTotal   FLOAT DEFAULT 0,
    idCliente    VARCHAR(20) NOT NULL,
    CONSTRAINT fk_factura_cliente
        FOREIGN KEY (idCliente) REFERENCES Cliente(documentoIdentidad)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =========================================================
-- 17. LINEA FACTURA (1 Factura : N)
-- =========================================================
CREATE TABLE LineaFactura (
    idLineaFactura INT AUTO_INCREMENT PRIMARY KEY,
    concepto       VARCHAR(150) NOT NULL,
    cantidad       INT NOT NULL,
    valorUnitario  FLOAT NOT NULL,
    subtotal       FLOAT GENERATED ALWAYS AS (cantidad * valorUnitario) STORED,
    idFactura      INT NOT NULL,
    CONSTRAINT fk_linea_factura
        FOREIGN KEY (idFactura) REFERENCES Factura(idFactura)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- 18. PAGO (1 Factura : N)
-- =========================================================
CREATE TABLE Pago (
    idPago    INT AUTO_INCREMENT PRIMARY KEY,
    fecha     DATE NOT NULL,
    monto     FLOAT NOT NULL,
    medioPago VARCHAR(50),
    idFactura INT NOT NULL,
    CONSTRAINT fk_pago_factura
        FOREIGN KEY (idFactura) REFERENCES Factura(idFactura)
        ON UPDATE CASCADE ON DELETE CASCADE
);

create index idxdocumentoIdentidad on Persona(documentoIdentidad);
create index idxIdMascota on Cita(idMascota);
create index idxIdCliente on Factura(idCliente);
create index idxVeterinarioFechaHora on Cita(idVeterinario, fecha, hora);
create index  idxSedeEstadoFecha on Cita(idSede, estado, fecha);
create index idxMascotaFechaIngreso on Hospitalizacion(idMascota, fechaIngreso, fechaSalida);

-- 1. Insertar una Persona (requerido antes de poder insertar el Cliente)
insert into Persona (documentoIdentidad, nombre, telefono)
values ('1020304050', 'Laura Gómez', '3105558899');

-- 2. Insertar el Cliente asociado a esa Persona
insert into Cliente (documentoIdentidad, direccion, correoElectronico)
values ('1020304050', 'Calle 45 #12-30, Bogotá', 'laura.gomez@email.com');

-- 3. Insertar una Mascota perteneciente a ese Cliente
insert into Mascota (nombre, especie, raza, fechaNacimiento, sexo, peso, microchip, idCliente)
values ('Max', 'Canino', 'Labrador', '2021-05-14', 'Macho', 28.5, 'CHIP-000123', '1020304050');



-- =========================================================
-- INSERCIÓN DE DATOS DE PRUEBA (MÍNIMO 10 POR TABLA)
-- =========================================================

-- 1. PERSONA (20 registros: 10 Clientes + 10 Veterinarios)
INSERT INTO Persona (documentoIdentidad, nombre, telefono) VALUES
('1001', 'Carlos Mendoza', '3101112233'),
('1002', 'Ana María Ríos', '3112223344'),
('1003', 'Jorge Martínez', '3123334455'),
('1004', 'Luisa Fernanda Paez', '3134445566'),
('1005', 'Diego Alejandro Silva', '3145556677'),
('1006', 'Sofia Restrepo', '3156667788'),
('1007', 'Andrés Felipe Castro', '3167778899'),
('1008', 'Valeria Morales', '3178889900'),
('1009', 'Gabriel Omar Torres', '3189990011'),
('1010', 'Camila Esperanza Ortiz', '3190001122'),
('2001', 'Dr. Roberto Gómez', '3001234567'),
('2002', 'Dra. Patricia Lara', '3002345678'),
('2003', 'Dr. Esteban Quito', '3003456789'),
('2004', 'Dra. Claudia Blanco', '3004567890'),
('2005', 'Dr. Fernando Hoyos', '3005678901'),
('2006', 'Dra. Mónica Galindo', '3006789012'),
('2007', 'Dr. Hugo Chávez', '3007890123'),
('2008', 'Dra. Beatriz Pinzón', '3008901234'),
('2009', 'Dr. Mario Calderón', '3009012345'),
('2010', 'Dra. Marcela Valencia', '3000123456');

-- 2. CLIENTE (10 registros)
INSERT INTO Cliente (documentoIdentidad, direccion, correoElectronico) VALUES
('1001', 'Calle 10 # 5-12, Bogotá', 'carlos.m@email.com'),
('1002', 'Carrera 15 # 45-20, Medellín', 'ana.rios@email.com'),
('1003', 'Avenida 8 # 12-30, Cali', 'jorge.m@email.com'),
('1004', 'Calle 80 # 11-40, Bogotá', 'luisa.p@email.com'),
('1005', 'Carrera 7 # 100-15, Barranquilla', 'diego.s@email.com'),
('1006', 'Transversal 23 # 8-50, Bucaramanga', 'sofia.r@email.com'),
('1007', 'Calle 53 # 20-10, Pereira', 'andres.c@email.com'),
('1008', 'Carrera 50 # 30-12, Manizales', 'valeria.m@email.com'),
('1009', 'Calle 12 # 4-80, Cartagena', 'gabriel.t@email.com'),
('1010', 'Avenida 19 # 104-05, Santa Marta', 'camila.o@email.com');

-- 3. VETERINARIO (10 registros)
INSERT INTO Veterinario (documentoIdentidad) VALUES
('2001'), ('2002'), ('2003'), ('2004'), ('2005'),
('2006'), ('2007'), ('2008'), ('2009'), ('2010');

-- 4. ESPECIALIDAD (10 registros)
INSERT INTO Especialidad (nombre) VALUES
('Cirugía General'), ('Dermatología'), ('Cardiología'), ('Neurología'),
('Oftalmología'), ('Odontología'), ('Traumatología'), ('Oncología'),
('Nutrición Felina y Canina'), ('Fisioterapia');

-- 5. VETERINARIO_ESPECIALIDAD (10 registros)
INSERT INTO Veterinario_Especialidad (documentoIdentidad, idEspecialidad) VALUES
('2001', 1), ('2002', 2), ('2003', 3), ('2004', 4), ('2005', 5),
('2006', 6), ('2007', 7), ('2008', 8), ('2009', 9), ('2010', 10);

-- 6. SEDE (10 registros)
INSERT INTO Sede (nombre, direccion, telefono) VALUES
('Sede Norte', 'Calle 170 # 15-20', '6017001'),
('Sede Sur', 'Carrera 10 # 27-00 Sur', '6017002'),
('Sede Chapinero', 'Calle 63 # 9-15', '6017003'),
('Sede Poblado', 'Carrera 43A # 1-50', '6047004'),
('Sede Laureles', 'Transversal 39 # 72-10', '6047005'),
('Sede Cali Oeste', 'Avenida 4 Oeste # 2-10', '6027006'),
('Sede Bocagrande', 'Carrera 3 # 6-20', '6057007'),
('Sede Bucaramanga', 'Calle 36 # 22-15', '6077008'),
('Sede Pereira', 'Avenida 30 de Agosto # 40-12', '6067009'),
('Sede Manizales', 'Carrera 23 # 55-10', '6067010');

-- 7. JAULA (10 registros)
INSERT INTO Jaula (numero, tamano) VALUES
('J-101', 'Pequeña'), ('J-102', 'Pequeña'),
('J-201', 'Mediana'), ('J-202', 'Mediana'),
('J-301', 'Grande'),  ('J-302', 'Grande'),
('J-401', 'UCI-Pequeña'), ('J-402', 'UCI-Grande'),
('J-501', 'Aislamiento'), ('J-502', 'Aislamiento');

-- 8. MASCOTA (10 registros)
INSERT INTO Mascota (nombre, especie, raza, fechaNacimiento, sexo, peso, microchip, idCliente) VALUES
('Firulais', 'Canino', 'Criollo', '2020-01-15', 'Macho', 12.5, 'CHIP-001', '1001'),
('Michi', 'Felino', 'Siames', '2021-03-22', 'Hembra', 4.2, 'CHIP-002', '1002'),
('Rocky', 'Canino', 'Boxer', '2019-08-10', 'Macho', 25.0, 'CHIP-003', '1003'),
('Luna', 'Canino', 'Golden Retriever', '2022-05-04', 'Hembra', 28.3, 'CHIP-004', '1004'),
('Garfield', 'Felino', 'Persa', '2018-11-30', 'Macho', 5.8, 'CHIP-005', '1005'),
('Thor', 'Canino', 'Pastor Alemán', '2020-09-18', 'Macho', 32.1, 'CHIP-006', '1006'),
('Nala', 'Felino', 'Angora', '2022-01-01', 'Hembra', 3.9, 'CHIP-007', '1007'),
('Zeus', 'Canino', 'Pug', '2021-07-12', 'Macho', 8.5, 'CHIP-008', '1008'),
('Mimi', 'Felino', 'Criollo', '2023-02-14', 'Hembra', 2.8, 'CHIP-009', '1009'),
('Bruno', 'Canino', 'Beagle', '2019-12-25', 'Macho', 14.2, 'CHIP-010', '1010');

-- 9. HISTORIA CLINICA (10 registros - 1:1 con Mascota)
INSERT INTO HistoriaClinica (idMascota) VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

-- 10. HOSPITALIZACION (10 registros)
INSERT INTO Hospitalizacion (fechaIngreso, fechaSalida, motivo, idMascota, idJaula) VALUES
('2026-01-05', '2026-01-08', 'Gastroenteritis severa', 1, 1),
('2026-01-10', '2026-01-12', 'Observación postquirúrgica', 2, 2),
('2026-01-15', '2026-01-20', 'Fractura de fémur', 3, 5),
('2026-02-01', '2026-02-03', 'Deshidratación por parvovirus', 4, 7),
('2026-02-05', '2026-02-07', 'Obstrucción intestinal', 5, 3),
('2026-02-10', '2026-02-15', 'Neumonía', 6, 8),
('2026-02-18', '2026-02-20', 'Intoxicación por chocolate', 7, 4),
('2026-02-22', '2026-02-25', 'Insuficiencia renal aguda', 8, 9),
('2026-03-01', '2026-03-03', 'Infección urinaria severa', 9, 10),
('2026-03-05', '2026-03-07', 'Herida por pelea', 10, 6);

-- 11. NOTA EVOLUCION (10 registros)
INSERT INTO NotaEvolucion (fecha, hora, observacion, idHospitalizacion) VALUES
('2026-01-06', '08:00:00', 'Paciente tolera alimento húmedo, temperatura estable.', 1),
('2026-01-11', '10:30:00', 'Herida quirúrgica sin signos de infección.', 2),
('2026-01-16', '14:00:00', 'Se administra analgésico, buen estado de ánimo.', 3),
('2026-02-02', '09:15:00', 'Inicia fluidoterapia con suero glucosa.', 4),
('2026-02-06', '16:45:00', 'Expulsa cuerpo extraño de forma natural.', 5),
('2026-02-11', '11:00:00', 'Mejora la capacidad respiratoria.', 6),
('2026-02-19', '07:30:00', 'Frecuencia cardíaca normalizada.', 7),
('2026-02-23', '18:20:00', 'Parámetros renales disminuyendo gradualmente.', 8),
('2026-03-02', '12:00:00', 'Disuria reducida, se retira sonda.', 9),
('2026-03-06', '15:30:00', 'Limpieza y curación de suturas efectuada.', 10);

-- 12. CITA (10 registros)
INSERT INTO Cita (fecha, hora, motivo, estado, idMascota, idSede, idVeterinario) VALUES
('2026-03-10', '08:00:00', 'Chequeo general y vacunas', 'Completada', 1, 1, '2001'),
('2026-03-10', '09:00:00', 'Revisión dermatológica', 'Completada', 2, 2, '2002'),
('2026-03-11', '10:00:00', 'Evaluación cardíaca', 'Completada', 3, 3, '2003'),
('2026-03-11', '11:00:00', 'Consulta por convulsiones', 'Completada', 4, 4, '2004'),
('2026-03-12', '14:00:00', 'Revisión ocular', 'Completada', 5, 5, '2005'),
('2026-03-12', '15:00:00', 'Profilaxis dental', 'Completada', 6, 6, '2006'),
('2026-03-13', '16:00:00', 'Cojera en pata trasera', 'Completada', 7, 7, '2007'),
('2026-03-13', '17:00:00', 'Masa en abdomen', 'Completada', 8, 8, '2008'),
('2026-03-14', '08:30:00', 'Asesoría nutricional', 'Completada', 9, 9, '2009'),
('2026-03-14', '09:30:00', 'Sesión de terapia física', 'Completada', 10, 10, '2010');

-- 13. CONSULTA (10 registros - 1:1 con Cita)
INSERT INTO Consulta (sintomas, diagnostico, indicaciones, idCita) VALUES
('Sin síntomas, examen sano', 'Paciente sano', 'Continuar esquema vacunación', 1),
('Prurito e irritación en piel', 'Dermatitis alérgica', 'Champú medicado cada 3 días', 2),
('Soplos y cansancio rápido', 'Insuficiencia mitral ligera', 'Reposo y medicación diaria', 3),
('Temblores leves', 'Epilepsia idiopática', 'Anticonvulsivo según horario', 4),
('Secreción lagrimal excesiva', 'Conjuntivitis bacteriana', 'Gotas oftálmicas por 7 días', 5),
('Sarro severo y halitosis', 'Enfermedad periodontal grado II', 'Limpieza ultrasonido recomendada', 6),
('Dolor a la palpación en cadera', 'Displasia de cadera', 'Analgésicos y moderar ejercicio', 7),
('Nódulo subcutáneo pequeño', 'Lipoma benigno', 'Control ecográfico en 6 meses', 8),
('Sobrepeso de 1.5kg', 'Obesidad moderada', 'Dieta hipocalórica estricta', 9),
('Rigidez en articulación posterior', 'Artrosis senil', 'Fisioterapia 2 veces por semana', 10);

-- 14. EXAMEN LABORATORIO (10 registros)
INSERT INTO ExamenLaboratorio (tipoExamen, fechaSolicitud, fechaResultado, resultado, idConsulta) VALUES
('Hemograma Completo', '2026-03-10', '2026-03-10', 'Valores normales de leucocitos y eritrocitos', 1),
('Raspado de Piel', '2026-03-10', '2026-03-11', 'Presencia de ácaros Demodex', 2),
('Ecocardiograma', '2026-03-11', '2026-03-11', 'Regurgitación mitral moderada', 3),
('Resonancia Magnética', '2026-03-11', '2026-03-12', 'Sin lesiones estructurales visibles en encéfalo', 4),
('Cultivo Lagrimal', '2026-03-12', '2026-03-14', 'Positivo para Staphylococcus intermedius', 5),
('Radiografía Oral', '2026-03-12', '2026-03-12', 'Pérdida ósea leve en premolares', 6),
('Radiografía de Cadera', '2026-03-13', '2026-03-13', 'Aplanamiento de cabezas femorales', 7),
('Citología de Masa', '2026-03-13', '2026-03-15', 'Células adiposas maduras, sin malignidad', 8),
('Perfil Lipídico', '2026-03-14', '2026-03-14', 'Triglicéridos levemente elevados', 9),
('Ecografía Articular', '2026-03-14', '2026-03-14', 'Desgaste de cartílago articular', 10);

-- 15. PRODUCTO (20 registros: 10 Vacunas + 10 Medicamentos)
INSERT INTO Producto (nombre, presentacion) VALUES
('Vacuna Antirrábica', 'Frasco Ampolla 1ml'),
('Vacuna Triple Felina', 'Frasco Ampolla 1ml'),
('Vacuna Parvovirus/Moquillo', 'Frasco Ampolla 1ml'),
('Vacuna Pentavalente Canina', 'Frasco Ampolla 1ml'),
('Vacuna Leptospira', 'Frasco Ampolla 1ml'),
('Vacuna Giardia', 'Frasco Ampolla 1ml'),
('Vacuna Bordetella', 'Spray Nasal 1ml'),
('Vacuna Leucemia Felina', 'Frasco Ampolla 1ml'),
('Vacuna Coronavirus Canino', 'Frasco Ampolla 1ml'),
('Vacuna Polivalente Felina', 'Frasco Ampolla 1ml'),
('Amoxicilina 250mg', 'Caja x 20 Tabletas'),
('Meloxicam 0.5mg', 'Frasco Gotero 10ml'),
('Prednisolona 10mg', 'Caja x 30 Tabletas'),
('Ketoconazol Champú', 'Frasco 200ml'),
('Fenobarbital 100mg', 'Caja x 30 Tabletas'),
('Tobramicina Gotas', 'Frasco Gotero 5ml'),
('Tramadol 50mg', 'Caja x 10 Tabletas'),
('Condroprotector Articular', 'Frasco x 60 Masticables'),
('Omeprazol 10mg', 'Caja x 14 Cápsulas'),
('Shampoo Antipulgas', 'Frasco 250ml');

-- 16. VACUNA (10 registros - idProducto 1 al 10)
INSERT INTO Vacuna (idProducto, enfermedadQuePrevine) VALUES
(1, 'Rabia'),
(2, 'Panleucopenia, Calicivirus, Rinotraqueitis'),
(3, 'Parvovirus y Moquillo Canino'),
(4, 'Distemper, Hepatitis, Parvovirus, Parainfluenza, Leptospira'),
(5, 'Leptospirosis'),
(6, 'Giardiasis'),
(7, 'Tos de las Perreras (Bordetella bronchiseptica)'),
(8, 'Leucemia Viral Felina'),
(9, 'Coronavirus Entérico Canino'),
(10, 'Panleucopenia, Calicivirus, Rinotraqueitis, Clamidia');

-- 17. MEDICAMENTO (10 registros - idProducto 11 al 20)
INSERT INTO Medicamento (idProducto, principioActivo) VALUES
(11, 'Amoxicilina Trihidrato'),
(12, 'Meloxicam'),
(13, 'Prednisolona Base'),
(14, 'Ketoconazol 2%'),
(15, 'Fenobarbital Sódico'),
(16, 'Tobramicina Sulfato'),
(17, 'Tramadol Clorhidrato'),
(18, 'Glucosamina y Condroitina'),
(19, 'Omeprazol'),
(20, 'Permetrina y Piperonil Butóxido');

-- 18. LOTE (10 registros)
INSERT INTO Lote (numeroLote, fechaVencimiento, fechaFabricacion, idProducto) VALUES
('LOT-VAC-001', '2027-12-31', '2025-01-10', 1),
('LOT-VAC-002', '2027-10-15', '2025-02-01', 2),
('LOT-VAC-003', '2028-01-20', '2025-03-05', 3),
('LOT-VAC-004', '2027-08-30', '2025-01-15', 4),
('LOT-MED-101', '2026-11-30', '2024-11-01', 11),
('LOT-MED-102', '2027-05-18', '2025-02-20', 12),
('LOT-MED-103', '2026-09-12', '2024-09-01', 13),
('LOT-MED-104', '2027-03-25', '2025-01-08', 14),
('LOT-MED-105', '2028-06-14', '2025-04-10', 15),
('LOT-MED-106', '2026-12-01', '2024-12-10', 16);

-- 19. APLICACION VACUNA (10 registros)
INSERT INTO AplicacionVacuna (fechaAplicacion, idConsulta, idVacuna) VALUES
('2026-03-10', 1, 1),
('2026-03-10', 1, 4),
('2026-03-11', 2, 2),
('2026-03-11', 3, 3),
('2026-03-12', 4, 5),
('2026-03-12', 5, 8),
('2026-03-13', 6, 7),
('2026-03-13', 7, 6),
('2026-03-14', 8, 9),
('2026-03-14', 9, 10);

-- 20. SEDE_PRODUCTO (10 registros)
INSERT INTO Sede_Producto (idSede, idProducto) VALUES
(1, 1), (1, 11),
(2, 2), (2, 12),
(3, 3), (3, 13),
(4, 4), (4, 14),
(5, 5), (5, 15);

-- 21. FACTURA (10 registros)
INSERT INTO Factura (fechaEmision, valorTotal, idCliente) VALUES
('2026-03-10', 120000, '1001'),
('2026-03-10', 85000,  '1002'),
('2026-03-11', 250000, '1003'),
('2026-03-11', 180000, '1004'),
('2026-03-12', 95000,  '1005'),
('2026-03-12', 310000, '1006'),
('2026-03-13', 140000, '1007'),
('2026-03-13', 220000, '1008'),
('2026-03-14', 70000,  '1009'),
('2026-03-14', 160000, '1010');

-- 22. LINEA FACTURA (10 registros - Subtotal es autogenerado)
INSERT INTO LineaFactura (concepto, cantidad, valorUnitario, idFactura) VALUES
('Consulta Veterinaria General', 1, 50000, 1),
('Vacuna Antirrábica', 2, 35000, 1),
('Consulta Dermatología', 1, 60000, 2),
('Champú Ketoconazol', 1, 25000, 2),
('Consulta Cardiología + Ecocardiograma', 1, 250000, 3),
('Consulta Neurología', 1, 80000, 4),
('Fenobarbital 100mg', 2, 50000, 4),
('Consulta Oftalmología', 1, 65000, 5),
('Gotas Tobramicina', 1, 30000, 5),
('Profilaxis Dental Ultrasonido', 1, 310000, 6);

-- 23. PAGO (10 registros)
INSERT INTO Pago (fecha, monto, medioPago, idFactura) VALUES
('2026-03-10', 120000, 'Efectivo', 1),
('2026-03-10', 85000,  'Tarjeta Débito', 2),
('2026-03-11', 250000, 'Tarjeta Crédito', 3),
('2026-03-11', 180000, 'Transferencia PSE', 4),
('2026-03-12', 95000,  'Efectivo', 5),
('2026-03-12', 310000, 'Tarjeta Crédito', 6),
('2026-03-13', 140000, 'Transferencia PSE', 7),
('2026-03-13', 220000, 'Tarjeta Débito', 8),
('2026-03-14', 70000,  'Efectivo', 9),
('2026-03-14', 160000, 'Transferencia PSE', 10);