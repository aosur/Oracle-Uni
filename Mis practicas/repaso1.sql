--FACTORIAL
create or replace function scott.fn_factorial(
	p_numero number
) return number
is
	v_contador number := 1;
	v_factorial number := 1;
begin
	loop
		v_factorial := v_factorial * v_contador;
		v_contador := v_contador + 1;
		exit when v_contador > p_numero;
	end loop;
	return v_factorial;
end;
/

--llamando a scott.fn_factorial
select scott.fn_factorial(4)
from dual;

--factorial con FOR
create or replace function scott.fn_factorial2(
	numero number
) return number
is
	factorial number:= 1;
begin
	for n in 1..numero loop
		factorial := factorial * n;
	end loop;
	return factorial;
end;
/

--llamando a scott.fn_factorial2
select scott.fn_factorial2(4)
from dual;

--factorial de los primeros n numeros
set serveroutput on
begin
	for N IN 1..10 loop
	dbms_output.put_line('El factorial de ' || N || ' es: '
								|| scott.fn_factorial2(N));
	end loop;
end;
/
------------------------------------------------------


--suma de los n primeros naturales con for
create or replace function scott.fn_suma_n_primeros(
	numero number
)	return number
is
	suma number := 0;
begin
	for N in 1..numero loop
		suma := suma + N;
	end loop;
	return suma;
end;
/

--llamando funcion scott.fn_suma_n_primeros
select scott.fn_suma_n_primeros(10)
from dual;

--tabla del 12 reverse

create or replace procedure scott.sp_tabla_n(
	numero number
)
is
	msg varchar2(40);
begin
	for p in reverse 1..12 loop
		msg := numero || ' x ' || p || ' = ' || p*numero;
		dbms_output.put_line(msg);
	end loop;
end;
/

--llamando procedimiento
set serveroutput on
execute scott.sp_tabla_n(6);


--elevar un numero a otro
create or replace function scott.fn_potencia(
	base number,
	exponente number
)	return number
is
	contador number := 0;
	potencia number := 1;
begin
	loop 
		potencia := potencia * base;
		contador := contador + 1;
		exit when contador >= exponente;
	end loop;
	return potencia;
end;
/

--llamando a la funcion scott.fn_potencia
select scott.fn_potencia(5, 3)
from dual;

--determina imparidad usando instruccion null
create or replace function scott.fn_imparidad(
	numero number
) return varchar2
is
	msg varchar2(20);
begin
	if(mod(numero, 2) = 0) then
		null;
	else
		msg := numero ||' es impar';
	end if;
	return msg;
end;
/

--llamando a scott.fn_imparidad
select scott.fn_imparidad(20)
from dual;
--------------------------------------------
--REGISTROS
--Consultar el nombre y costo de un producto.
set serveroutput on
create or replace procedure topitop.sp_datos_producto(
	codigo topitop.productos.idproducto%type
)
is
	type registro is record(
		nombre topitop.productos.descripcion%type,
		precio topitop.productos.precioventa%type
	);
  r registro;
begin
	select descripcion, precioventa
	into r
	from topitop.productos
	where idproducto = codigo;
  dbms_output.put_line('Nombre Producto: ' || r.nombre);
	dbms_output.put_line('Precio: ' || r.precio);
end;
/

--llamando a procedimiento
execute topitop.sp_datos_producto('A0005');

--consultar nombre y direccion de cliente
create or replace procedure topitop.sp_datos_cliente(
	codigo topitop.clientes.idcliente%type
)
is
	type registro is record(
		nombre topitop.clientes.nombre%type,
		direccion topitop.clientes.direccion%type
	);
	r registro;
begin
	select nombre, direccion
	into r
	from topitop.clientes
	where idcliente = codigo;
	dbms_output.put_line('Nombre del Cliente: ' || r.nombre);
	dbms_output.put_line('Direccion: ' || r.direccion);
end;
/

execute topitop.sp_datos_cliente('C0005');
--------------------------------------------------
--VARRAYS
declare
	--definiendo tipo de dato
	type ArrayAlumnos is varray(10) of varchar2(40);
	type NotasAlumnos is varray(10) of number;
	
	--declarando las variables
	alumnos ArrayAlumnos;
	notas NotasAlumnos;
	
begin
	alumnos := ArrayAlumnos('Nicolle', 'Bianca', 'Claudio', 'Lucas');
	notas := NotasAlumnos(20, 18, 16, 19);
	dbms_output.put_line('Alumnos - Notas, antes de adicionar:');
	
	for N in 1..alumnos.count loop
		dbms_output.put_line(alumnos(N) || ' - ' || notas(N));
	end loop;
	
	--propiedades
	dbms_output.put_line('Propiedades: ');
	dbms_output.put_line('count: ' || alumnos.count);
	dbms_output.put_line('limit: ' || alumnos.limit);
	
	dbms_output.put_line(' ');
	dbms_output.put_line('Alumnos - Notas, despues de adicionar');
	alumnos.extend(2);
	alumnos(5) := 'Guillermo';
	alumnos(6) := 'Ian';
	notas.extend(2);
	notas(5) := 20;
	notas(6) := 20;
	
	for N in 1..alumnos.count loop
		dbms_output.put_line(alumnos(N) || ' - ' || notas(N));
	end loop;
	
	--propiedades
	dbms_output.put_line('Propiedades: ');
	dbms_output.put_line('count: ' || alumnos.count);
	dbms_output.put_line('limit: ' || alumnos.limit);
end;
/
	
----------------------------------------------
--consultar nombre y email de empleado
create or replace procedure topitop.sp_consulta_empleado(
	codigo topitop.empleados.idempleado%type
)
is
	type registro is record(
		nombre topitop.empleados.nombre%type,
		apellidos topitop.empleados.apellidos%type,
		email topitop.empleados.email%type
	);
	r registro;
begin
	select nombre, apellidos, email
	into r
	from topitop.empleados
	where idempleado = codigo;
	dbms_output.put_line('Nombres: ' || r.apellidos || ', ' || r.nombre);
	dbms_output.put_line('Email: ' || r.email);
end;
/
	
--llamando procedimiento topitop.sp_consulta_empleado
execute topitop.sp_consulta_empleado('E0002');
	
------------------------------------------------------
declare 
		--definiendo tipo
		type ArrayNombres is varray(5) of varchar2(40);
		type ArrayEdades is varray(5) of number;
		
		--declarando variables
		nombres ArrayNombres;
		edades ArrayEdades;
begin
	nombres := ArrayNombres('Jakelin', 'Alan');
	edades := ArrayEdades(36, 36);
	dbms_output.put_line('Antes de agregar');
	for n in 1 .. nombres.count loop
		dbms_output.put_line('Nombre: ' || nombres(n) 
			|| ', Edad: ' || edades(n));
	end loop;
	--propiedades
	dbms_output.put_line('count: ' || nombres.count);
	dbms_output.put_line('limit: ' || nombres.limit);
	
	--adicionando elementos
	nombres.extend;
	nombres(nombres.last) := 'Gato';
	edades.extend;
	edades(edades.last) := 0;
	
	--despues de adicionar
	dbms_output.put_line('despues de agregar');
	for n in 1 .. nombres.count loop
		dbms_output.put_line('Nombre: ' || nombres(n) 
			|| ', Edad: ' || edades(n));
	end loop;
	--propiedades
	dbms_output.put_line('count: ' || nombres.count);
	dbms_output.put_line('limit: ' || nombres.limit);
	
end;
/
	
----------------------------------------------------
DECLARE
-- Definimos los tipos de datos
TYPE VARRAY_EMPLEADOS IS VARRAY(5000) OF HR.EMPLOYEES%ROWTYPE;
-- Definiendo las variables
V_EMPLEADOS VARRAY_EMPLEADOS;
V_CONT NUMBER(8);
BEGIN
V_EMPLEADOS := VARRAY_EMPLEADOS();
DBMS_OUTPUT.PUT_LINE('TAMAÑO INICIAL: ' || V_EMPLEADOS.COUNT);
FOR REC IN (SELECT * FROM HR.EMPLOYEES) LOOP
V_EMPLEADOS.EXTEND;
V_CONT := V_EMPLEADOS.COUNT;
DBMS_OUTPUT.PUT_LINE('V_CONT: ' || V_CONT);
V_EMPLEADOS(V_CONT) := REC;
END LOOP;
DBMS_OUTPUT.PUT_LINE('TAMAÑO FINAL: ' || V_EMPLEADOS.COUNT);
FOR I IN V_EMPLEADOS.FIRST..V_EMPLEADOS.LAST LOOP
DBMS_OUTPUT.PUT_LINE( I || '.- ' || V_EMPLEADOS(I).FIRST_NAME);
END LOOP;
END;
/
-------------------------------------------
--consultar los datos de un empleado
--esquema scott
create or replace function scott.fn_datos_empleado(
	p_codigo scott.emp.empno%type
)return scott.emp%rowtype
is
	v_datos scott.emp%rowtype;
begin
	select * 
	into v_datos
	from scott.emp
	where empno = p_codigo;
	return v_datos;
end;
/

--llamando funcion
set serveroutput on
declare
	v_datos scott.emp%rowtype;
begin
	v_datos := scott.fn_datos_empleado(7934);
	dbms_output.put_line('Nombres: ' || v_datos.ename);
	dbms_output.put_line('Trabajo: ' || v_datos.job);
	dbms_output.put_line('Salario: ' || v_datos.sal);
end;
/
----------------------------------
--funcion para los datos de clientes
--esquema topitop
create or replace function topitop.fn_datos_cliente(
	p_codigo topitop.clientes.idcliente%type
) return topitop.clientes%rowtype
is
	v_cliente topitop.clientes%rowtype;
begin
	select *
	into v_cliente
	from topitop.clientes
	where idcliente = p_codigo;
	return v_cliente;
end;
/

--llamando funcion
declare
	v_cliente topitop.clientes%rowtype;
begin
	v_cliente := topitop.fn_datos_cliente('C0004');
	dbms_output.put_line('Nombres: ' || v_cliente.nombre);
	dbms_output.put_line('Direccion: ' || v_cliente.direccion);
	dbms_output.put_line('Telefono: ' || v_cliente.telefono);
end;
/

--funcion para datos de lineas, usando rowtype
--esquema topitop
create or replace function topitop.fn_datos_lineas(
	p_codigo topitop.lineas.idlinea%type
) return topitop.lineas%rowtype
is
	v_linea topitop.lineas%rowtype;
begin
	select *
	into v_linea
	from topitop.lineas
	where idlinea = p_codigo;
	return v_linea;
end;
/

--llamando funcion topitop.fn_datos_lineas
declare
	v_linea topitop.lineas%rowtype;
begin
	
		v_linea := topitop.fn_datos_lineas(1);
		dbms_output.put_line('Codigo: ' || v_linea.idlinea);
		dbms_output.put_line('Nombre: ' || v_linea.nombre);
	
end;
/
-------------------------------------
--practica registros
--hacer un procedimiento para consultar
--idventa, cliente, idempleado, fecha, total de una venta

create or replace procedure topitop.sp_consulta_venta(
	p_codigo topitop.ventas.idventa%type
)
is
	type registro is record(
		cliente topitop.ventas.idcliente%type,
		empleado topitop.ventas.idempleado%type,
		fecha topitop.ventas.fecha%type,
		total topitop.ventas.total%type
		);
		r registro;
begin
	select idcliente, idempleado, fecha, total
	into r
	from topitop.ventas
	where idventa = p_codigo;
	dbms_output.put_line('CODIGO: ' || p_codigo);
	dbms_output.put_line('CLIENTE: ' || r.cliente);
	dbms_output.put_line('EMPLEADO: ' || r.empleado);
	dbms_output.put_line('FECHA: ' || r.fecha );
	dbms_output.put_line('TOTAL: ' || r.total);
end;
/

--llamando procedimento
execute topitop.sp_consulta_venta(3);

-------------------------------------------
--practica varray
declare
	--definiendo tipo
	type ArrayFiguras is varray(10) of varchar2(15);
	type ArrayLados is varray(10) of number;
	--declarando variables
	figuras ArrayFiguras;
	lados ArrayLados;
begin
	figuras := ArrayFiguras('Triangulo', 'cuadrilatero', 'Pentagono');
	lados := ArrayLados(3, 4, 5);
	dbms_output.put_line('Antes de modificar:');
	for n in 1..figuras.count loop
		dbms_output.put_line('Poligono: ' || figuras(n) || ' - Lados: ' || lados(n));
	end loop;
	dbms_output.put_line('count: ' || figuras.count);
	--dbms_output.put_line('exists(3): ' || figuras.exists(3));
	--dbms_output.put_line('exists(4): ' || figuras.exists(4));
	dbms_output.put_line('first: ' || figuras.first);
	dbms_output.put_line('last: ' || figuras.last);
	dbms_output.put_line('prior(2): ' || figuras.prior(2));
	dbms_output.put_line('prior(1): ' || figuras.prior(1));
	dbms_output.put_line('next(2): ' || figuras.next(2));
	dbms_output.put_line('next(3): ' || figuras.next(3));
	dbms_output.put_line('limit: ' || figuras.limit);
	
	figuras.extend(2);
	figuras(4) := 'Hexagono';
	figuras(figuras.last) := 'Heptagono';
	lados.extend(2);
	lados(4) := 6;
	lados(figuras.last) := 7;
	dbms_output.put_line('------------------------------------------------------');
	dbms_output.put_line('Despues de modificar:');
	for n in 1..figuras.count loop
		dbms_output.put_line('Poligono: ' || figuras(n) || ' - Lados: ' || lados(n));
	end loop;
	dbms_output.put_line('count: ' || figuras.count);
	--dbms_output.put_line('exists(3): ' || figuras.exists(3));
	--dbms_output.put_line('exists(4): ' || figuras.exists(4));
	dbms_output.put_line('first: ' || figuras.first);
	dbms_output.put_line('last: ' || figuras.last);
	dbms_output.put_line('prior(2): ' || figuras.prior(2));
	dbms_output.put_line('prior(1): ' || figuras.prior(1));
	dbms_output.put_line('next(2): ' || figuras.next(2));
	dbms_output.put_line('next(3): ' || figuras.next(3));
	dbms_output.put_line('limit: ' || figuras.limit);
end;
/
--------------------------------------------------
--varray usando for y rowtype
--esquema topitop
declare
		type ArrayClientes is varray(50) of topitop.clientes%rowtype;
		v_clientes ArrayClientes;
		v_contador number;
begin
	v_clientes := ArrayClientes();
	for c in (select * from topitop.clientes) loop
		v_clientes.extend;
		v_contador := v_clientes.count;
		v_clientes(v_contador) := c;
	end loop;
	dbms_output.put_line('Tamaño Final: ' || v_contador);
	for n in v_clientes.first..v_clientes.last loop
		dbms_output.put_line(n || '.- ' || v_clientes(n).nombre);
	end loop;
end;
/
----------------------------------------------------------------
--Matrices asociativas
declare
	type Array_Notas is table of number
	index by binary_integer;
	Notas Array_Notas;
begin
	--cargar notas
	Notas(1) := 20;
	Notas(2) := 18;
	Notas(3) := 15;
	Notas(4) := 17;
	--mostrar notas
	for I in 1..notas.count loop
	dbms_output.put_line('Nota ' || I || ': ' || Notas(I));
	end loop;
end;
/
--matriz asociativa usando rowtype y for para
--recorrerla
declare 
	type Array_Empleado is table of recursos.empleado%rowtype
	index by binary_integer;
	v_emp Array_Empleado;
begin
	dbms_output.put_line('Tamaño inicial: ' || v_emp.count);
	for emp in (select * from recursos.empleado) loop
		v_emp(v_emp.count +  1) := emp;
	end loop;
	dbms_output.put_line('Tamaño final: ' || v_emp.count);
	for n in v_emp.first..v_emp.last loop
		dbms_output.put_line(n || ' .-' || v_emp(n).apellido ||
						', ' || v_emp(n).nombre);
	end loop;
end;
/

	