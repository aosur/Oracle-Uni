set serveroutput on
declare
	v_fecha date;
begin
	select sysdate into v_fecha
	from dual;
	dbms_output.put_line(v_fecha);
end;
/


set serveroutput on
declare
	v_fecha varchar2(40);
begin
	select to_char(sysdate, 'dd/mm/yyyy hh24:mm:ss') into v_fecha
	from dual;
	dbms_output.put_line(v_fecha);
end;
/


--Suma de dos números
create or replace function scott.fn_suma(
	p_num1 number,
	p_num2 number
) return number
is
	v_suma number;
begin
	v_suma := p_num1 + p_num2;
	return v_suma;
end;
/

--llamada 1ra forma
select scott.fn_suma(10, 22.32)
from dual;

--llamda 2da forma
declare
	v_suma number;
begin
	v_suma := scott.fn_suma(10, 22);
	dbms_output.put_line('La suma es: ' || v_suma);
end;
/

-- Ejercicio 1
/*
  Crear una función para calcular 
  el importe de una venta.
*/
set serveroutput on
create or replace procedure scott.sp_calcula_importe(
	p_precio in number,
	p_cantidad in number,
	p_dscto in number,
	p_importe out number,
	p_impuesto out number,
	p_total out number
) 
is
	v_dscto number;
	v_sub number;
begin
	p_importe := p_precio * p_cantidad;
	p_impuesto := 0.18 * p_importe;
	v_sub := p_importe + p_impuesto;
	v_dscto := p_dscto/100 * v_sub;
	p_total := v_sub - v_dscto;
	dbms_output.put_line('Importe: ' || p_importe);
	dbms_output.put_line('Impuesto: ' || p_impuesto);
	dbms_output.put_line('Subtotal: ' || v_sub);
	dbms_output.put_line('Descuento: ' || v_dscto);
	dbms_output.put_line('Total a Pagar: ' || p_total);
end;
/

--llamando a scott.sp_calcula_importe
declare
	v_importe number(8, 2);
	v_impuesto number(8, 2);
	v_total number(8, 2);
begin	
	scott.sp_calcula_importe(10, 3, 5, v_importe, v_impuesto, v_total);
end;
/
	
	
-- Función que retorna el precio de venta de un producto
-- Esquema topitop
create or replace function topitop.fn_dime_precio(
	p_codigo varchar2
) return number
is
	v_precio number;
begin
	select precioventa into v_precio
	from topitop.productos
	where idproducto = p_codigo;
	return v_precio;
end;
/

--Llamando funcion
select topitop.fn_dime_precio('A0005')
from dual;


-- Ejercicio 3
/*
Desarrollar un procedimiento para consultar el nombre
de la moneda y el saldo de una cuenta.
Esquema: EUREKA
*/
create or replace procedure eureka.sp_datos_cuenta(
	p_codigo in eureka.cuenta.chr_cuencodigo%type,
	p_moneda out eureka.moneda.vch_monedescripcion%type,
	p_saldo out eureka.cuenta.dec_cuensaldo%type
)
is
begin
	select vch_monedescripcion, dec_cuensaldo
	into p_moneda, p_saldo
	from eureka.cuenta c
	inner join eureka.moneda m
	on c.chr_monecodigo = m.chr_monecodigo
	where chr_cuencodigo = p_codigo;
	dbms_output.put_line('Moneda: ' || p_moneda);
	dbms_output.put_line('Saldo: ' || p_saldo);
end;
/

--llamando a eureka.sp_datos_cuenta
declare
	v_moneda eureka.moneda.vch_monedescripcion%type;
	v_saldo eureka.cuenta.dec_cuensaldo%type;
begin
	eureka.sp_datos_cuenta('00200003', v_moneda, v_saldo);
end;
/
	
---------------------------------------------------------
--Función para encontrar el mayor de 3 números positivos.
create or replace function scott.fn_mayor_de_tres(
	num1 number,
	num2 number,
	num3 number
) return number
is
	mayor number;
begin
	mayor := num1;
	if(mayor <= num2) then
		mayor := num2;
	end if;
	if(mayor <= num3) then
		mayor := num3;
	end if;
	return mayor;
end;
/

--llamando funcion
select scott.fn_mayor_de_tres(1241, 755, 95)
from dual;


--Función para encontrar el mayor de 3 números positivos con if else.
create or replace function scott.fn_mayor_de_tres_v2(
	num1 number,
	num2 number,
	num3 number
) return number
is
	mayor number;
begin
	if(num1 < num2) then
		mayor := num2;
	else
		mayor := num1;
	end if;
	if(mayor < num3) then
		mayor := num3;
	end if;
	return mayor;
end;
/

--llamando funcion 
select scott.fn_mayor_de_tres_v2(51, 30, 51)
from dual;

--Función para evaluar precio de venta de un producto
--Esquema topitop
create or replace function topitop.fn_evalua_precio(
	p_cod varchar2
) return varchar2
is
	v_msg varchar2(40);
	v_precio number;
begin
	select precioventa into v_precio
	from topitop.productos
	where idproducto = p_cod;
	case
		when (0<= v_precio and v_precio < 200) then
			v_msg := 'Barato';
		when (200 <= v_precio and v_precio < 500) then
			v_msg := 'Regular';
		when (500 <= v_precio) then
			v_msg := 'Caro';
	end case;
	return v_msg;
end;
/

--llamando funcion
select topitop.fn_evalua_precio('A0025')
from dual;

-------------------------
SELECT DECODE(2, 1, 'UNO',
                    2, 'DOS',
                    3, 'TRES',
                    'NO SE') result
FROM DUAL;

--------------------------
-- Ejercicio 1
/*
Desarrollar una función para calcular 
el promedio de un alumno.
Son cuatro notas, se elimina la menor.
Esquema: SCOTT
*/
		
create or replace function scott.fn_menor_de_cuatro(
	nota1 number,
	nota2 number, 
	nota3 number, 
	nota4 number
) return number
is
	menor number;
begin
	menor := nota1;
	if(menor >= nota2) then
		menor := nota2;
	end if;
	if(menor >= nota3) then
		menor := nota3;
	end if;
	if(menor >= nota4) then
		menor := nota4;
	end if;
	return menor;
end;
/

--llamando scott.fn_menor_de_cuatro
select scott.fn_menor_de_cuatro(1, 5, 4, 0)
from dual;

create or replace function scott.fn_alumno_promedio(
	nota1 number,
	nota2 number, 
	nota3 number, 
	nota4 number
) return number
is
	promedio number;
begin
	promedio := (nota1 + nota2 + nota3 + nota4 - 
								scott.fn_menor_de_cuatro(nota1, nota2, nota3, nota4))/3;
	return promedio;
end;
/

--llamando scott.fn_alumno_promedio
select scott.fn_alumno_promedio(16, 18, 20, 10)
from dual;

--loop
set serveroutput on
declare
	v_msg varchar2(40):= 'Care Gato';
	v_cont number := 0;
begin
	loop 
		dbms_output.put_line(v_msg);
		v_cont := v_cont + 1;
		exit when v_cont = 10;
	end loop;
end;
/

--for
--factorial
create or replace function scott.fn_factorial(
	p_num number
) return number
is
	v_fact number := 1;
begin
	for n in 1 .. p_num loop
		v_fact := v_fact * n;
	end loop;
	return v_fact;
end;
/

select scott.fn_factorial(5)
from dual;
	
------------------------------------------
declare
begin
	for n in 1..10 loop
		dbms_output.put_line(n ||'! = ' || scott.fn_factorial(n));
	end loop;
end;
/
----------------------------------
-- Aplicación de Tabla temporal

drop table EUREKA.RESUMEN;

create global temporary table EUREKA.RESUMEN (
  suc_codigo varchar2(10) primary key,
  suc_nombre varchar2(200),
  saldo_soles number(12,2),
  saldo_dolares number(12,2)
) on commit preserve rows; 



CREATE OR REPLACE PROCEDURE EUREKA.CREAR_RESUMEN
IS
  v_ssoles number;
  v_sdolares number;
BEGIN
  -- Limpiar tabla
  delete from EUREKA.RESUMEN;
  -- Carga inicial de datos
  insert into EUREKA.RESUMEN(suc_codigo, suc_nombre)
  select chr_sucucodigo, vch_sucunombre 
  from EUREKA.sucursal;
  -- Calcular saldos
  for r in (select * from EUREKA.RESUMEN) loop
    
    select sum(dec_cuensaldo) into v_ssoles 
    from eureka.cuenta
    where chr_monecodigo = '01'
    and chr_sucucodigo = r.suc_codigo;
    
    select sum(dec_cuensaldo) into v_sdolares 
    from eureka.cuenta
    where chr_monecodigo = '02'
    and chr_sucucodigo = r.suc_codigo;
    
    update EUREKA.RESUMEN
    set saldo_soles = nvl(v_ssoles,0), 
        saldo_dolares = nvl(v_sdolares,0)
    where suc_codigo = r.suc_codigo;
    
  end loop;
  commit;
END;
/

call EUREKA.CREAR_RESUMEN();

select *
from eureka.resumen;

--mostrar con for los numeros del 1 al 10
--al reves
set serveroutput on
declare
begin
	for n in reverse 1..10 loop
		dbms_output.put_line(n);
	end loop;
end;
/

--obtener una tabla temporal con el nombre del producto,
--el nombre de la linea y el precio de venta
--esquema topitop
create global temporary table topitop.producto_resumen(
	id varchar2(10) primary key,
	nombre varchar(50),
	linea varchar2(20),
	precio number
)on commit preserve rows;

create or replace procedure topitop.crear_producto_resumen
is
	v_id varchar2(10);
	v_nombre varchar2(50);
	v_linea varchar2(20);
	v_precio number;
begin
	insert into topitop.producto_resumen(id, nombre, linea, precio)
	select idproducto, descripcion, nombre, precioventa
	from topitop.productos p
	join topitop.lineas l
	on p.idlinea = l.idlinea;
end;
/


call topitop.crear_producto_resumen();


--obtener una tabla temporal con el nombre del empleado,
--su codigo, y el total de ventas que realizó
--esquema topitop
drop table topitop.empleado_resumen;

create global temporary table topitop.empleado_resumen(
	cod varchar2(10) primary key,
	nom varchar2(30),
	ape varchar2(30),
	total_ventas number
)on commit preserve rows;

create or replace procedure topitop.crear_resumen_empleado
is
	v_total number;
begin
	--limpiar tabla
	delete from topitop.empleado_resumen;
	--llenando valores iniciales
	insert into topitop.empleado_resumen(cod, nom, ape)
	select idempleado, nombre, apellidos
	from topitop.empleados;
	--calculo de ventas
	for r in (select * from topitop.ventas) loop
		select count(idempleado) into v_total
		from topitop.ventas
		where idempleado = r.idempleado;
		
		update topitop.empleado_resumen
		set total_ventas = v_total
		where cod = r.idempleado;
	end loop;
	commit;
end;
/
	
call topitop.crear_resumen_empleado();

select * 
from topitop.empleado_resumen;

-------------
--registros
--muestra el nombre del producto y nombre de linea
--esquema topitop
set serveroutput on
create or replace procedure topitop.sp_registro_producto(
	p_cod varchar2)
is 
	type registro is record(
		producto topitop.productos.descripcion%type,
		linea topitop.lineas.nombre%type
	);
	r registro;
begin
  select descripcion into r.producto
	from topitop.productos
	where idproducto = p_cod;
	select nombre into r.linea
	from topitop.lineas
	where idlinea = (select idlinea 
										from topitop.productos
										where idproducto = p_cod);
	
		dbms_output.put_line('Producto: ' || r.producto || '  ' ||
							'Linea: ' || r.linea);
	
end;
/

call topitop.sp_registro_producto('A0025');


--otra forma
create or replace procedure topitop.sp_registro_producto2(
	p_cod varchar2)
is
	type registro is record(
		producto topitop.productos.descripcion%type,
		linea topitop.lineas.nombre%type
	);
	mireg registro;
begin
	select descripcion, nombre
	into mireg.producto, mireg.linea
	from topitop.productos p
	join topitop.lineas l
	on p.idlinea = l.idlinea
	where p.idproducto = p_cod;
	
	dbms_output.put_line('Producto: ' || mireg.producto);
	dbms_output.put_line('Linea: ' || mireg.linea);
end;
/

-------------------------------------------
--registros %rowtype
--registro con la misma estructura que los de la tabla

create or replace procedure topitop.sp_muestra_producto(
	p_cod varchar2
)
is
	v_prod topitop.productos%rowtype;
begin
	select * into v_prod
	from topitop.productos
	where idproducto = p_cod;
	dbms_output.put_line('CODIGO: ' || v_prod.idproducto);
	dbms_output.put_line('NOMBRE: ' || v_prod.descripcion);
	dbms_output.put_line('PRECIO: ' || v_prod.precioventa);
end;
/

call topitop.sp_muestra_producto('A0025');

------------------------------------------
--varrays
declare
	--definiendo tipo
	type AlumnosArray is varray(15) of varchar2(50);
	type NotasArray is varray(15) of number;
	--declarando variables
	alumnos AlumnosArray;
	notas NotasArray;
begin
	--creando los arreglos
	alumnos := AlumnosArray('Guille', 'Ian', 'Lucas', 'Claudio', 'Bianca');
	notas := NotasArray(17, 16, 16, 15, 16);
	--mostrando arreglos
	for n in 1..alumnos.count loop
		dbms_output.put_line('Alumno: ' || alumnos(n) || ' - Nota: ' || notas(n));
	end loop;
	--propiedades
	dbms_output.put_line('count: ' || alumnos.count);
	dbms_output.put_line('limit: ' || alumnos.limit);
	dbms_output.put_line('first: ' || alumnos.first);
	dbms_output.put_line('last: ' || alumnos.last);
	
	alumnos.extend;
	alumnos(6) := 'Nicolle';
	notas.extend;
	notas(6) := '18';
	dbms_output.put_line('Despues de agregar a ' || alumnos(6));
	--propiedades
	dbms_output.put_line('count: ' || alumnos.count);
	dbms_output.put_line('limit: ' || alumnos.limit);
	dbms_output.put_line('first: ' || alumnos.first);
	dbms_output.put_line('last: ' || alumnos.last);
	notas.delete(5);
	alumnos.delete(5);
	for n in 1..alumnos.count loop
		dbms_output.put_line('Alumno: ' || alumnos(n) || ' - Nota: ' || notas(n));
	end loop;
end;
/
---------------------------------
--varray de registros
declare
	type registro is record(
		cod topitop.productos.idproducto%type,
		prod topitop.productos.descripcion%type,
	  linea topitop.lineas.nombre%type
);
	mireg registro;
	type registroArray is varray(500) of registro;
	registros registroArray;
begin
	registros := registroArray();
	for c in (select * from topitop.productos) loop
		select idproducto, descripcion, nombre
		into mireg
		from topitop.productos p
		join topitop.lineas l
		on p.idlinea = l.idlinea
		where p.idproducto = c.idproducto;
		registros.extend;
		registros(registros.count) := mireg;
	end loop;
	for n in 1..registros.count loop
		dbms_output.put_line('CODIGO: ' || registros(n).cod);
		dbms_output.put_line('PRODUCTO: ' || registros(n).prod);
		dbms_output.put_line('LINEA: ' || registros(n).linea);
		dbms_output.put_line('...............................');
	end loop;
end;
/

set serveroutput on
declare
begin
	for n in (select * from topitop.productos) loop
		dbms_output.put_line(n.idproducto);
	end loop;
end;
/


--mostrar el nombre y codigo del empleado indicando 
--el mumero de ventas y el total
--use varrays y registros
create or replace procedure topitop.sp_empleado_ventas
is
	type registro is record(
		cod topitop.empleados.idempleado%type,
		nom topitop.empleados.nombre%type,
		ape topitop.empleados.apellidos%type,
		num_ven number,
		tot_ven number(10, 2)
	);
	mireg registro;
	type registroArray is varray(500) of registro;
	registros registroArray;
begin
	--crea array registros
	registros := registroArray();
	for r in (select * from topitop.empleados) loop
		--carga datos iniciales
		select idempleado, nombre, apellidos
		into mireg.cod, mireg.nom, mireg.ape
		from topitop.empleados
		where idempleado = r.idempleado;
		--carga ventas
		select count(idempleado)
		into mireg.num_ven
		from topitop.ventas
		where idempleado = r.idempleado;
		
		select sum(total) 
		into mireg.tot_ven
		from topitop.ventas
		where idempleado = r.idempleado;	
		--carga registro en array
		registros.extend;
		registros(registros.count) := mireg;
	end loop;
	--muestra contenido del array registros:
	for m in 1..registros.count loop
		dbms_output.put_line('CODIGO: ' || registros(m).cod);
		dbms_output.put_line('NOMBRE: ' || registros(m).nom);
		dbms_output.put_line('APELLIDOS: ' || registros(m).ape);
		dbms_output.put_line('VENTAS: ' || registros(m).num_ven);
		dbms_output.put_line('TOTAL VENTAS: ' || registros(m).tot_ven);
		dbms_output.put_line('............................');
	end loop;
end;
/

call topitop.sp_empleado_ventas();
---------------------------------------------------
--tabla asociativa
--con bloque anonimo
declare
	--definicion tipo
	type NombresArray is table of varchar2(40)
	index by pls_integer;
	--declara variable del tipo NombresArray
	nombres NombresArray;
begin
	--inicializa nombres
	nombres(1) := 'Alan';
	nombres(2) := 'Jakelin';
	nombres(3) := 'Peluchin';
	--imprime array
	for n in nombres.first..nombres.count loop
		dbms_output.put_line(n || '.- ' || nombres(n));
	end loop;
end;
/

--mostrar los clientes usando matriz asociativa y rowtype
declare
		type ClientesArray is table of topitop.clientes%rowtype
		--index by pls_integer;
		index by binary_integer;
		clientes ClientesArray;
begin
		for r in (select * from topitop.clientes) loop
			clientes(clientes.count + 1) := r;
		end loop;
	--imprime array
	for m in clientes.first..clientes.count loop
		dbms_output.put_line('CLIENTE ' || m);
		dbms_output.put_line('NOMBRES: ' || clientes(m).nombre);
		dbms_output.put_line('DIRECCION: ' || clientes(m).direccion);
		dbms_output.put_line('TELEFONO: ' || clientes(m).telefono);
		dbms_output.put_line('................................. ');
	end loop; 
	dbms_output.put_line('TOTAL DE CLIENTES: ' || clientes.count);
end;
/

--ventas totales de un producto	y el numero de ventas
declare
	type registro is record(
		cod topitop.productos.idproducto%type,
		pro topitop.productos.descripcion%type,
		num_de_ventas number,
		total number(8, 2)
	);
	mireg registro;
	type registroArray is varray(200) of registro;
	registros registroArray;
begin	
	registros := registroArray();
	for r in (select*from topitop.productos) loop
		select idproducto, descripcion
		into mireg.cod, mireg.pro
		from topitop.productos
		where idproducto = r.idproducto;
		
		select count(idproducto) 
		into mireg.num_de_ventas
		from topitop.detalleventa
		where idproducto = r.idproducto;
		
		select nvl(sum(importe),0)
		into mireg.total
		from topitop.detalleventa
		where idproducto = r.idproducto;
		
		registros.extend;
		registros(registros.count) := mireg;
	end loop;
	for n in registros.first..registros.count loop
		dbms_output.put_line('Codigo: ' || registros(n).cod);
		dbms_output.put_line('Producto: ' || registros(n).pro);
		dbms_output.put_line('Numero Ventas: ' || registros(n).num_de_ventas);
		dbms_output.put_line('Total Vendido: ' || registros(n).total);
		dbms_output.put_line('.......................... ');
	end loop;
	dbms_output.put_line('Total:' || registros.count);
end;
/
		
--hacer el ejercicio anterior con matriz asociativa
declare
	type registro is record(
		cod topitop.productos.idproducto%type,
		pro topitop.productos.descripcion%type,
		num_de_ventas number,
		total number(8, 2)
	);
	mireg registro;
	type registroArray is table of registro
	index by pls_integer;
	registros registroArray;
begin
	for r in(select * from topitop.productos) loop
		select idproducto, descripcion
		into mireg.cod, mireg.pro
		from topitop.productos
		where idproducto = r.idproducto;
		
		select count(idproducto) 
		into mireg.num_de_ventas
		from topitop.detalleventa
		where idproducto = r.idproducto;
		
		select nvl(sum(importe),0)
		into mireg.total
		from topitop.detalleventa
		where idproducto = r.idproducto;
		
		registros(registros.count + 1) := mireg;
	end loop;
	for n in registros.first..registros.count loop
		dbms_output.put_line('Codigo: ' || registros(n).cod);
		dbms_output.put_line('Producto: ' || registros(n).pro);
		dbms_output.put_line('Numero Ventas: ' || registros(n).num_de_ventas);
		dbms_output.put_line('Total Vendido: ' || registros(n).total);
		dbms_output.put_line('.......................... ');
	end loop;
	dbms_output.put_line('Total:' || registros.count);
end;
/
-----------------------------------------------------------------
--crear procedimiento para ver las lineas y el total de lo vendido
create or replace procedure topitop.sp_venta_lineas
is
	type registro is record(
		nom topitop.lineas.nombre%type,
		tot number
	);
	mireg registro;
	type registroArray is varray(100) of registro;
	registros registroArray;
begin
	registros := registroArray();
	for r in (select * from topitop.lineas) loop
		select nombre into mireg.nom
		from topitop.lineas 
		where idlinea = r.idlinea;
		
		select nvl(sum(importe),0) into mireg.tot
		from topitop.detalleventa d
		join topitop.productos p on d.idproducto = p.idproducto
		join topitop.lineas l on p.idlinea = l.idlinea
		where l.idlinea = r.idlinea;
		
		registros.extend;
		registros(registros.count) := mireg;
	end loop;
	for r in registros.first..registros.last loop
	dbms_output.put_line('Nombre: ' || registros(r).nom || '  Total: ' || registros(r).tot);
	end loop;
end;
/

call topitop.sp_venta_lineas();

-----------------------------------
select descripcion, nombre, importe
from topitop.lineas l
join topitop.productos p on l.idlinea = p.idlinea
join topitop.detalleventa d on p.idproducto = d.idproducto;
----------------------------------------------------	
--ordena array de mayor a menor
----------------------------------------------------
--1ro crear tipos
create or replace type topitop.type_registro is object(
	num number,
	bol char(1)
);
/
	
create or replace type topitop.type_varray_numbers is varray(100) of type_registro;
/
create or replace type topitop.ArrayNumber is varray(100) of number;
/
--vuelve un tipo ArrayNumber en type_varray_numbers
create or replace function topitop.to_type_varray_numbers(
	p_array ArrayNumber
) return topitop.type_varray_numbers
is
	v_array topitop.type_varray_numbers;
begin
	v_array := topitop.type_varray_numbers();
	for i in 1..p_array.count loop
		v_array.extend;
	  v_array(i).num := p_array(i);
		v_array(i).bol := '0';
	end loop;
	for i in 1..v_array.count loop
		dbms_output.put_line( v_array(i).num || ', ' || v_array(i).bol);
	end loop;
	return v_array;
end;
/

declare
	miArray topitop.ArrayNumber;
	miArray_numbers topitop.type_varray_numbers;
begin
	miArray := topitop.ArrayNumber(2, 4, 6, 8, 10);
	miArray_numbers := topitop.to_type_varray_numbers(miArray);
end;
/
	

create or replace function topitop.sp_ordena_array(
	arreglo in type_varray_numbers
) return type_varray_numbers 
is	
	matriz type_varray_numbers;
	mayor number;
	cont number;
begin
	matriz := type_varray_numbers();
	for s in 1..matriz
	for r in 1..arreglo.last loop
		while(arreglo.exists(r)) loop
			mayor := arreglo.first;
			for s in 1..arreglo.last loop
				if(mayor <= arreglo(s)) then
					mayor := arreglo(s);
					cont := s;
				end if;
			end loop;
		end loop;
		matriz.extend;
		matriz(r) := mayor;
	end loop;
end;
/
			
					
		 
		
--productos que ,as se venden
create or replace topitop.sp_prod_mas_vendidos
is 
begin
---------------------------
