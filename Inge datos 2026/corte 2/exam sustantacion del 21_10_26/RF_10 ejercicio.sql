-- Ejercicio RF 10 para administrar los catalogos

USE liwi_flor_eterna;

START TRANSACTION;

-- ver las opciones de lo que tenemos en nuestra base de datos
select 'Ciudad' as catalogo, COUNT(*) as opciones from Ciudad
union all select 'MetodoPago', COUNT(*) from MetodoPago
union all select 'TipoDocumento',COUNT(*) from TipoDocumento
union all select 'Categoria', COUNT(*) from Categoria
union all select 'CategoriaGasto',COUNT(*) from CategoriaGasto
union all select 'Etiqueta', COUNT(*) from Etiqueta;

-- anadir una opcion para pagar, aqui transferencias
insert into MetodoPago (nombreMetodoPago) values ('Transferencia');
select * from MetodoPago;

-- modificar una opcion, para cambiar de nombre por ej
update MetodoPago set nombreMetodoPago = 'Transferencia bancaria' where nombreMetodoPago = 'Transferencia';
select * from MetodoPago;


-- Debemos prohibir el caso o una opcion podre tener el mismo nombre que una otre. Debe ser unica

-- pro ej, decidio de escibir Bogota pero sigue existe, debe me dar un error 
insert into Ciudad (nombreCiudad) values ('Bogotá'); -- eso me da bien un error

-- eso tambien debe me dar un error. porque debe ser unica
insert into Etiqueta (nombreEtiqueta) values ('LIWI'); -- y despues la ejecucion eso me da tambien un error

ROLLBACK;
