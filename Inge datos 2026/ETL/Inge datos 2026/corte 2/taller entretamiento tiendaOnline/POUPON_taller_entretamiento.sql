-- SENTENCIAS DML: Lenguaje de Manipulacion de datos
-- 0. es crear la estructura de la BD (modelo físico-diccionario de datos)
-- 1. DATOS PUROS O LIMPIOS (ETL)
-- 2. Manipulacion de datos (hacer registros, consultar registros, modificar registros, eliminar registros)
-- un logica transaccional (sentencias) (indicacion orden una petición transacción) MySQL SQL
-- trabajar sobre el contenido
-- Transaccional: Crear-Insertar Agregar registros (insert)
-- Modificar actualizar (Update)
-- Consultas sobre la BD (Select)
-- Eliminar (Delete)

-- Insert (agregar crear registra insertar datos
-- consulta general select * from nombre_tabla
create database if not exists tiendaOnline;
use tiendaOnline;

create table clientes(
idCliente int primary key auto_increment,
nombreCliente varchar(100) not null,
emailCliente varchar(150) unique,
ciudad varchar(80) null,
creado_en datetime default now()
);

create table productos(
idProducto int primary key auto_increment,
nombreProducto varchar(120) not null,
precioProducto decimal(10,2),
stockProducto int default 0,
categoriaProducto varchar(60)
);

create table pedido(
idPedido int primary key auto_increment,
cantidadProducto int not null,
fechaPedido date,
idClienteFK int,
idProductoFK int,
foreign key (idClienteFK) references clientes(idCliente),
foreign key (idProductoFK) references productos(idProducto)
);

create table cliente_cbackup (
idClienBack int primary key auto_increment,
nombreCliente varchar(100) ,
emailCliente varchar(150),
copiado_en datetime default now()
);
-- select consulta general de las tablas 
select * from clientes;

select * from productos;

select * from pedido;


-- Inserciones insert into nombre_tabla (campos1,campo2,campo3,...) values (valor1,valor2,valor3,...)
-- si el campo es varchar va entre comillas
-- si el campo es autoincrement s debe enviar el campo sin valor ''
-- si el campo es una fecha debe revisar el formato

-- Agregar 1 registro
describe clientes;
insert into clientes(idCliente,nombreCliente,emailCliente,ciudad) values ('','Ana Garcia','ana@mail.com','Madrid');
insert into clientes(nombreCliente,emailCliente,ciudad) values ('Pedro Perez','pedro@mail.com','Barcelona');
 select * from clientes;
-- Agregar Varios registros
describe productos;
insert into productos (nombreProducto,precioProducto,stockProducto,categoriaProducto)
values ('Laptop Pro',1200000,15,'Electrónica'), 
('Mouse USB',50000,80,'Accesorios'),
('Monitor 32"',500000,20,'Electrónica'),
('Teclados',100000,35,'Accesorios');

select * from productos;

insert into cliente_backup (nombreCliente,emailCliente)
select nombreCliente,emailCliente
from clientes
where creado_en<'2026-03-20';

rename table cliente_cbackup to cliente_backup;

select * from cliente_backup;

describe cliente_backup;

-- Update actualizar o modificar los registros en una tabla
-- update nombreTabla set columna1=valor1,columna2=valor2,.... where condicion
select * from clientes;
-- Actualizar un campo
update clientes
set ciudad='Valencia'
where idCliente=1;

-- Actualizar varios campos
select * from productos;

update productos
set
precioProducto=1099000,
stockProducto=10
where idProducto=1;

update productos
set precioProducto=precioProducto * 1.10
where categoriaProducto='Accesorios';

-- delete eliminar registro  Where 

-- investigar los metodos de tipo numericos y caracteres en MySQL
-- investigar si se puede o no revertir una eliminacion de registros pista rollback csi se puede como
-- delete from nombre_tabla where condicion

select * from clientes;
delete from clientes 
where idCliente=2;

select * from productos;
delete from productos
where stockProducto=0 AND categoriaProducto='Descatalogado';

/* NSERT
1. Inserta 3 clientes nuevos con nombre, email y ciudad
2. Inserta 2 productos con nombre, precio, stock y categoría
3. Inserta 1 pedido vinculando un cliente y un producto recién creados
UPDATE
4. Cambia la ciudad de uno de tus clientes insertados
5. Aumenta en 5 unidades el stock de uno de tus productos
6. Modifica el precio del segundo producto aplicando un descuento del 10%
DELETE
7. Elimina el pedido que creaste en el punto 3
8. Elimina el cliente cuya ciudad cambiaste en el punto 4
9. Elimina todos los productos con stock menor a 3

*/

SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;
use tiendaonline;
describe productos;
alter table productos change stockProducto stoProT int(11);

### Sentencia para consultas

select nombreProducto, stoProT from productos;

select nombreProducto as Nombre_Producto, stoProT as stock from productos;

select nombreProducto, stoProT from productos where idProducto=1 ;
select nombreProducto as Nombre_Producto, stoProT as stock from productos where stoProT>=15 and idProducto=1;

select nombreProducto as Nombre_Producto, stoProT as stock 
from productos 
where stoProT>=15 and nombreProducto='Laptop Pro';
### select campos from nombre_tabla order by campo_a_ordenar formaOrden(ASC DESC) 
select nombreProducto as Nombre_Producto, stoProT as stock 
from productos order by nombreProducto DESC;

select nombreProducto as Nombre_Producto, stoProT as stock 
from productos order by nombreProducto ASC;

select nombreProducto as Nombre_Producto, stoProT as stock from productos where stoProT>=25 OR idProducto=1;

## BETWEEN 
## SELECT * FROM NOMBRE_TABLA BETWEEN VALO1 AND VALOR2
select * from productos;
select nombreProducto as Nombre_Producto, precioProducto as precio
 from productos where precioProducto between 50000 and 100000 and stoProT>3 order by precioProducto asc;

##Like que inicien que terminen o que contenga caracteres
## que inicien
select * from productos where nombreProducto not like 'mon%';

## que contenga
select * from productos where nombreProducto not like '%o%';

#que termine
select * from productos where nombreProducto like '%os' order by precioProducto asc limit 10;
use tiendaonline;
## Carga de archivos

load data infile 'C:\ruta\clientes.csv'
into table clientes
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

set foreign_key_checks=0;
set foreign_key_checks=1;
/*Agrupar Group by select camposConsultar from nombreTabla group by campoAgrupar*/

describe productos;

select * from productos group by categoriaProducto;

select categoriaProducto,
 count(*) as Cantidad,
 avg(precioProducto) as promedioMedio
 from productos
 group by categoriaProducto
 having avg(precioProducto)>5000
 order by promedioMedio desc;
 
 select format (precioProducto,2,'es_CO') as precio 
 from productos;
 
 /*funciones calculadas*/
 describe productos;
 select
 count(*) as Total,
 avg(precioProducto) as PromedioPrecio,
 max(precioProducto) as PrecioMaximo,
 min(precioProducto) as PrecioMinimo,
 sum(stoProT) as StockTotal
 from productos;
 
 use tiendaonline;
 
 describe clientes;

select nombreCliente as nombre,
 upper(nombreCliente) as NombreMayuscula,
 concat('nombre Cliente: ',nombreCliente,' email cliente:',emailCliente) as concatenar,
 length(nombreCliente) as TamanioNombre
 from clientes;
 
 ##Subconsultas
									#He creado eso porque no tenia las tablas necesarias para hacer el ejercicio
CREATE TABLE departamentos ( 
idDepartamento INT PRIMARY KEY AUTO_INCREMENT, 
nombreDepartamento VARCHAR(100) NOT NULL UNIQUE );
CREATE TABLE empleados ( 
idEmpleado INT PRIMARY KEY AUTO_INCREMENT, 
nombreEmpleado VARCHAR(100) NOT NULL, 
edad INT NOT NULL, 
salario DECIMAL(10,2) NOT NULL, 
fechaContratacion DATE NOT NULL, 
idDepartamentoFK INT, FOREIGN KEY (idDepartamentoFK) REFERENCES departamentos(idDepartamento) );

INSERT INTO departamentos (nombreDepartamento) VALUES ('IT'), ('Ventas'), ('Recursos Humanos'), ('Marketing'), ('Finanzas');
INSERT INTO empleados (nombreEmpleado, edad, salario, fechaContratacion, idDepartamentoFK) VALUES 
('Ana Garcia', 28, 3500.00, '2022-03-15', 1), 
('Carlos Perez', 35, 4500.00, '2019-07-10', 2), 
('Maria Lopez', 42, 5200.00, '2018-01-20', 3), 
('Andres Martinez', 31, 4800.00, '2021-05-12', 1), 
('Camila Rodriguez', 29, 3900.00, '2023-02-01', 4), 
('Juan Torres', 38, 4100.00, '2020-09-18', 2), 
('Carolina Gomez', 34, 5500.00, '2022-11-05', 5), 
('Pedro Sanchez', 45, 6000.00, '2017-06-25', 3), 
('Alberto Ramirez', 33, 4300.00, '2021-08-14', 1), 
('Laura Hernandez', 27, 3200.00, '2024-01-10', 4);

#Pregunta 1
select nombreEmpleado, edad, salario from empleados;

#Pregunta 2
SELECT nombreEmpleado, salario FROM empleados WHERE salario > 4000;

#Pregunta 3
SELECT e.nombreEmpleado, d.nombreDepartamento FROM empleados e 
INNER JOIN departamentos d ON e.idDepartamentoFK = d.idDepartamento 
WHERE d.nombreDepartamento = 'Ventas';

#Pregunta 4
SELECT nombreEmpleado, edad FROM empleados 
WHERE edad BETWEEN 30 AND 40;

#Pregunta 5
SELECT nombreEmpleado, fechaContratacion FROM empleados 
WHERE fechaContratacion > '2020-12-31';

#Pregunta 6
SELECT d.nombreDepartamento, COUNT(e.idEmpleado) AS cantidadEmpleados FROM departamentos d 
LEFT JOIN empleados e ON d.idDepartamento = e.idDepartamentoFK 
GROUP BY d.idDepartamento, d.nombreDepartamento 
ORDER BY cantidadEmpleados DESC;

#Pregunta 7
SELECT AVG(salario) AS salarioPromedio FROM empleados;

#Pregunta 8
SELECT nombreEmpleado FROM empleados 
WHERE nombreEmpleado LIKE 'A%' OR nombreEmpleado LIKE 'C%';

#Pregunta 9
SELECT e.nombreEmpleado, d.nombreDepartamento FROM empleados e 
INNER JOIN departamentos d ON e.idDepartamentoFK = d.idDepartamento 
WHERE d.nombreDepartamento <> 'IT';

#Pregunta 10
SELECT nombreEmpleado, salario FROM empleados 
WHERE salario = ( SELECT MAX(salario) FROM empleados);