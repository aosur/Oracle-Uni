--procedimientos empleados
create or replace procedure neptuno.sp_create_emp(
p_id neptuno.empleados.idempleado%type,
p_nom neptuno.empleados.nombre%type,
p_ape neptuno.empleados.apellidos%type,
p_email neptuno.empleados.email%type,
p_us neptuno.empleados.usuario%type,
p_cla neptuno.empleados.usuario%type
)
is
begin
	insert into neptuno.empleados
	values(p_id, p_nom, p_ape, p_email, p_us, p_cla);
end;
/


create or replace procedure neptuno.sp_update_emp(
p_id neptuno.empleados.idempleado%type,
p_nom neptuno.empleados.nombre%type,
p_ape neptuno.empleados.apellidos%type,
p_email neptuno.empleados.email%type,
p_us neptuno.empleados.usuario%type,
p_cla neptuno.empleados.usuario%type
)
is
begin
	update neptuno.empleados
	set nombre = p_nom, apellidos = p_ape, email = p_email, 
	usuario = p_us, clave = p_cla
	where idempleado = p_id;
end;
/



create or replace procedure neptuno.sp_delete_emp(
p_id neptuno.empleados.idempleado%type
)
is
begin
	delete from neptuno.empleados
	where idempleado = p_id;
end;
/

-------------------------------------------
--readall
--creando registro
--creando tipo tabla
--crear funcion

create or replace type neptuno.t_record_em is object (
	id varchar2(5),
	nom varchar2(120),
	ape varchar2(120),
	email varchar2(120),
	us varchar2(120),
	cla varchar2(120)
);
/

create or replace type neptuno.EmpleadosArray is table of neptuno.t_record_em;
/


create or replace function neptuno.fn_read_all_emp
return EmpleadosArray
is
	reg t_record_em;
	miArray EmpleadosArray;
begin
	miArray := EmpleadosArray();
	for r in (select * from neptuno.empleados) loop
		reg := t_record_em(r.idempleado, r.nombre, r.apellidos, r.email,
												r.usuario, 	r.clave);
		miArray.extend;
		miArray(miArray.COUNT) := reg;
	end loop;
	for r in miArray.first..miArray.count loop
		dbms_output.put_line(miArray(r).nom);
	end loop;
	return miArray;
end;
/

declare
	empleados neptuno.EmpleadosArray;
begin
	empleados := neptuno.fn_read_all_emp();
	for r in empleados.first..empleados.last loop
		dbms_output.put_line(empleados(r).nom);
	end loop;
end;
/


create or replace function neptuno.fn_find_for_id_emp(
	p_id in neptuno.empleados.idempleado%type) 
	return neptuno.empleados%rowtype
is
	emp neptuno.empleados%rowtype;
begin
	select * into emp
	from neptuno.empleados	
	where idempleado = p_id;
	return emp;
end;
/

/*select neptuno.fn_find_for_id_emp('E0004')
from dual;*/
declare
	nombre neptuno.empleados.nombre%type;
begin
	nombre := neptuno.fn_find_for_id_emp('E0004').nombre;
	dbms_output.put_line(nombre);
end;
/
-------------------------------------------
create or replace type hr.array_empleados is table of hr.employees%rowtype;-- index by binary_integer;
/
	
declare 
	--definimos tipos
	type array_empleados is table of hr.employees%rowtype index by pls_integer;
	--definimos variable
	v_empleados array_empleados;
begin
	for r in (select * from hr.employees) loop
		v_empleados(v_empleados.count + 1) := r;
	end loop;
	for r in v_empleados.first..v_empleados.count loop
		dbms_output.put_line(v_empleados(r).first_name);
	end loop;
end;
/
----------------------------------------------------
--crear tabla temporal conteniendo los siguientes datos
--idempleado, nombres, total de las ventas que realizó
--numero de ventas que realizó
drop table topitop.resumen_empleado;

create global temporary table topitop.resumen_empleado(
	id char(5) primary key,
	nom varchar2(200),
	imp number,
	cant number
) on commit preserve rows;
	
create or replace procedure topitop.llena_resumen_emp
is
	v_imp number;
	v_cant number;
begin
	--limpiar tabla
	delete from topitop.resumen_empleado;
	--calcula imp y cant
	for r in (select * from topitop.empleados) loop
		--agrega nombres e id
		update topitop.resumen_empleado
		set nom = r.nombre || ', ' || r.apellidos, id = r.idempleado
		where id = r.idempleado;
		--importe
		select sum(total)
		into v_imp
		from topitop.ventas
		where idempleado = r.idempleado;
		--cantidad 
		select count(idventa)
		into v_cant
		from topitop.ventas
		where idempleado=r.idempleado;	
		--insertando importe y cantidad en resumen_empleado
		update topitop.resumen_empleado
		set imp = nvl(v_imp,0), cant = nvl(v_cant,0)
		where id = r.idempleado;
	end loop;
	commit;
end;
/

call topitop.llena_resumen_emp();

----------------------------------------------
--Tratamiento errores
create or replace procedure scott.emp_sal(
	p_cod emp.empno%type
)
is
	v_sal number;
	v_nom emp.ename%type;
begin
	select sal, ename into v_sal, v_nom
	from scott.emp
	where empno = p_cod;
	dbms_output.put_line('Nombres: ' || v_nom);
	dbms_output.put_line('Salario: ' || v_sal);
exception
	when no_data_found then
		dbms_output.put_line('EL empleado no existe');
		dbms_output.put_line('Asegurese de haber escrito correctamente');
end;
/

call scott.emp_sal(7900);

--actualiza salario empleado
create or replace procedure scott.sp_update_sal_emp(
	p_cod emp.empno%type,
	p_new_sal emp.sal%type
)
is
	cont number;	
begin
	select count(*) into cont
	from scott.emp
	where empno = p_cod;	
	if(cont = 0) then
		raise no_data_found;
	end if;
	update scott.emp
	set sal = p_new_sal
	where empno = p_cod;
	commit;
	dbms_output.put_line('Proceso okay');	
exception
	when no_data_found then
		dbms_output.put_line('Codigo no existe');
end;
/

call scott.sp_update_sal_emp(7900, 950);

--Desarrollar una segunda versión del procedimiento UpdateSalEmp,
--pero con una excepción de usuario.

create or replace procedure scott.sp_update_sal_emp2(
	p_cod emp.empno%type,
	p_new_sal emp.sal%type
)
is
	cont number;	
	mi_excepcion exception;
begin
	select count(*) into cont
	from scott.emp
	where empno = p_cod;	
	if(cont = 0) then
		raise mi_excepcion;
	end if;
	update scott.emp
	set sal = p_new_sal
	where empno = p_cod;
	commit;
	dbms_output.put_line('Proceso okay');	
exception
	when mi_excepcion then
		dbms_output.put_line('Codigo no existe');
end;
/

call scott.sp_update_sal_emp2(7900, 950);

--Desarrollar una tercera versión del procedimiento, pero
--esta vez genere un mensaje de error.

create or replace procedure scott.sp_update_sal_emp3(
	p_cod emp.empno%type,
	p_new_sal emp.sal%type
)
is
	cont number;	
begin
	select count(*) into cont
	from scott.emp
	where empno = p_cod;	
	if(cont = 0) then
		raise_application_error(-20000, 'Codigo no existe');
	end if;
	update scott.emp
	set sal = p_new_sal
	where empno = p_cod;
	commit;
	dbms_output.put_line('Proceso okay');	
end;
/

call scott.sp_update_sal_emp3(900, 950);

--otra version
create or replace procedure scott.sp_update_sal_emp4(
	p_cod emp.empno%type,
	p_new_sal emp.sal%type
)
is
	cont number;	
begin
	select count(*) into cont
	from scott.emp
	where empno = p_cod;	
	if(cont = 0) then
		raise_application_error(-20000, 'Codigo no existe');
	end if;
	update scott.emp
	set sal = p_new_sal
	where empno = p_cod;
	commit;
	dbms_output.put_line('Proceso okay');	
exception 
	when others then
		dbms_output.put_line('Error Nro. ORA' || sqlcode );
		dbms_output.put_line(sqlerrm);
end;
/

-------------------------------
--repaso excepciones
--muestre el precio de venta y en caso no haya muestre
--un error
create or replace procedure neptuno.sp_precio_pro(
	p_cod neptuno.productos.idproducto%type
)
is
	v_pre number;
	v_nom neptuno.productos.descripcion%type;
begin
	select precioventa, descripcion into v_pre, v_nom
	from neptuno.productos
	where idproducto = p_cod;
	dbms_output.put_line('Nombre: ' || v_nom ||
			'. Precio: ' || v_pre);
exception
	when no_data_found then
		dbms_output.put_line('No existe producto 
				con ese codigo');
end;
/

call neptuno.sp_precio_pro('A0028');

--actualiza precio de venta, controle excepciones con rise 
create or replace procedure neptuno.sp_update_pre_pro(
	p_cod neptuno.productos.idproducto%type,
	p_pre neptuno.productos.precioventa%type
)
is
	cont number;
begin
	select count(*) into cont
		from neptuno.productos
		where idproducto = p_cod;
	if(cont = 0) then
		raise no_data_found;
	end if;
	update neptuno.productos
		set precioventa = p_pre
		where idproducto = p_cod;
	commit;
exception
	when no_data_found then
		dbms_output.put_line('codigo no existe');
end;
/

call neptuno.sp_update_pre_pro('A0028', 1000);

--Desarrollar una segunda versión del procedimiento anterior, 
--pero con una excepción de usuario.
create or replace procedure neptuno.sp_update_pre_pro2(
	p_cod neptuno.productos.idproducto%type,
	p_pre neptuno.productos.precioventa%type
)
is
	cont number;
	mi_excepcion exception;
begin
	select count(*) into cont
		from neptuno.productos
		where idproducto = p_cod;
	if(cont = 0) then
		raise mi_excepcion;
	end if;
	update neptuno.productos
		set precioventa = p_pre
		where idproducto = p_cod;
	commit;
exception
	when mi_excepcion then
		dbms_output.put_line('codigo no existe');
end;
/

call neptuno.sp_update_pre_pro2('A0028', 1000);

--Desarrollar una tercera versión del procedimiento anterior, 
--pero esta vez genere un mensaje de error.
create or replace procedure neptuno.sp_update_pre_pro3(
	p_cod neptuno.productos.idproducto%type,
	p_pre neptuno.productos.precioventa%type
)
is
	cont number;
	mi_excepcion exception;
begin
	select count(*) into cont
		from neptuno.productos
		where idproducto = p_cod;
	if(cont = 0) then
		raise_application_error(-20999, 'No se encontró codigo');
	end if;
	update neptuno.productos
		set precioventa = p_pre
		where idproducto = p_cod;
	commit;
end;
/

call neptuno.sp_update_pre_pro3('A0028', 950);

--Otra versión del mismo procedimiento.
create or replace procedure neptuno.sp_update_pre_pro4(
	p_cod neptuno.productos.idproducto%type,
	p_pre neptuno.productos.precioventa%type
)
is
	cont number;
	mi_excepcion exception;
begin
	select count(*) into cont
		from neptuno.productos
		where idproducto = p_cod;
	if(cont = 0) then
		raise_application_error(-20999, 'No se encontró codigo');
	end if;
	update neptuno.productos
		set precioventa = p_pre
		where idproducto = p_cod;
	commit;
exception
	when others then
		dbms_output.put_line('Error Nro ORA' || sqlcode);
		dbms_output.put_line( sqlerrm);
end;
/

call neptuno.sp_update_pre_pro4('A0000', 950);
-------------------------------------------------------
--CURSORES
create or replace procedure scott.sp_cur_dept
is
	cursor mi_cursor is select * from scott.dept;
	r scott.dept%rowtype;
begin
	open mi_cursor;
	fetch mi_cursor into r;
	close mi_cursor;
	dbms_output.put_line('Nro Departamento: ' || r.deptno);
	dbms_output.put_line('Nombre: ' || r.dname);
	dbms_output.put_line('Localización: ' || r.loc);
end;
/

call scott.sp_cur_dept();

--mostrar todos los empleados de scott
create or replace procedure scott.sp_cur_emp
is
	cursor mi_cursor is select * from scott.emp;
	r scott.emp%rowtype;
begin
	open mi_cursor;
	loop
		fetch mi_cursor into r;
		exit when mi_cursor%notfound;
		dbms_output.put_line(r.empno || ' - ' || r.ename);
	end loop;
	close mi_cursor;
end;
/

call scott.sp_cur_emp();

--mostrar todos los productos de neptuno
create or replace procedure neptuno.sp_cur_pro
is
	cursor mi_cursor is select * from neptuno.productos;
	r neptuno.productos%rowtype;
	cont number := 1;
begin 
	open mi_cursor;
	loop
		fetch mi_cursor into r;
		exit when mi_cursor%notfound;
		dbms_output.put_line(cont || '._ ' || r.descripcion);
		cont := cont + 1;
	end loop;
	close mi_cursor;
end;
/

call neptuno.sp_cur_pro();

/*Tenemos una tabla de nombre PLANILLAMES para guardar la 
planilla por mes, por departamento, la estructura es la siguiente:*/

create or replace table scott.planillames(
	anio number(4),
	mes number(2),
	deptno number(2),
	emps number(2) not null,
	planilla number(10,2) not null,
	constraint fk_planillames primary key(anio, mes, deptno) 
);
alter table scott.planillames
rename column emp to emps;

create or replace procedure scott.sp_planillames(
	p_anio number,
	p_mes number
)
is 
	cursor mi_cursor is select deptno from scott.emp;
	r scott.emp.deptno%type;
	v_cont number;
	v_emps number(2);
	v_planilla number(2);
begin
	select count(*) into v_cont
		from scott.planillames
		where anio = p_anio and mes = p_mes and deptno = p_deptno;
	if (v_cont > 0) then
		raise_application_error(-20000, 'Planilla ya ha sido procesada');
	then if;
	select sum(sal), count(empno) into v_planilla, v_emps
	from scott.emp
	where
	
	
end;
/

--listar los productos con sus respectivos codigos
declare
	cursor mi_cursor is select idproducto, descripcion from neptuno.productos;
	v_cod neptuno.productos.idproducto%type;
	v_nom neptuno.productos.descripcion%type;
begin
	open mi_cursor;
	loop
		fetch mi_cursor into v_cod, v_nom;
		exit when mi_cursor%notfound;
		dbms_output.put_line('Codigo: ' || v_cod || '  Nombre: ' || v_nom);
	end loop;
	close mi_cursor;
end;
/
	
	
--atributo %rowcount
declare
	cursor mi_cursor is select descripcion from neptuno.productos
		where precioventa > 250;
	v_nom neptuno.productos.descripcion%type;
begin
	open mi_cursor;
	loop
		fetch mi_cursor into v_nom;
		exit when mi_cursor%notfound;
		dbms_output.put_line(mi_cursor%rowcount || '.- ' || v_nom);
	end loop;
	close mi_cursor;
end;
/
	
--buscar todos los productos de una linea
--variable acoplada
create or replace procedure neptuno.sp_cur_proxlinea(
	p_li number)
is
	v_li number;
	cursor mi_cursor is select descripcion from neptuno.productos
		where idlinea = v_li; 
	v_nom varchar2(100);
begin
	v_li := p_li;
	open mi_cursor;
	fetch mi_cursor into v_nom;
	while mi_cursor%found loop
		dbms_output.put_line(v_nom);
		fetch mi_cursor into v_nom;
	end loop;
	close mi_cursor;
end;
/

call neptuno.sp_cur_proxlinea(2);

--con for
create or replace procedure neptuno.sp_cur_proxlinea2(
	p_li number)
is
	v_li number;
	cursor mi_cursor is select idproducto,descripcion, precioventa
		from neptuno.productos
			where idlinea = v_li; 
begin
	v_li := p_li;
	for reg in mi_cursor loop
		dbms_output.put_line(reg.idproducto || '-' || reg.descripcion ||
			'-' || reg.precioventa);
	end loop;
end;
/

call neptuno.sp_cur_proxlinea2(2);

/*Procedimiento para determinar el número de empleados y el importe 
de la planilla, por departamento.*/
create or replace procedure scott.sp_planillaxdepartamento
is
	v_emps number;
	v_plani number;
	v_dpto number;
	cursor mi_cursor is select * from scott.dept;
begin
	dbms_output.put_line('Departamento  Empleados  Planilla');
	for r in mi_cursor loop
		select count(*), nvl(sum(sal),0), r.deptno
			into v_emps, v_plani, v_dpto
				from scott.emp
					where deptno = r.deptno;
		dbms_output.put_line(v_dpto || '-------------' || v_emps || '---------'
			|| v_plani);
		end loop;
end;
/

execute scott.sp_planillaxdepartamento();
call scott.sp_planillaxdepartamento();

/*Desarrollar un procedimiento que determine el empleado con
 mayor sueldo por departamento.*/

--paso 1--
--hallando los mayores salarios segun departamento
create or replace procedure scott.sp_max_sal_dpto(
	p_deptno scott.emp.deptno%type
)
is
	v_max number;
	cursor mi_cursor is select * from scott.emp
		where sal = v_max;
begin
	select max(sal) into v_max
		from scott.emp
			where deptno = p_deptno;
	for rec in mi_cursor loop
		dbms_output.put_line(rec.deptno || chr(9)  || rec.empno || 
				chr(9)  || rec.ename || chr(9) || rec.sal);
	end loop;
end;
/

execute scott.sp_max_sal_dpto(40);

--paso 2--
--recorrer todos los departamentos
create or replace procedure scott.sp_mayor_salxdepartamento
is
begin
	dbms_output.put_line('Dpto' || chr(9) || 'Codigo' ||
			chr(9) || 'Nombre' || chr(9) || 'Salario');
	for r in (select * from scott.dept) loop
		scott.sp_max_sal_dpto(r.deptno);
	end loop;
end;
/

execute scott.sp_mayor_salxdepartamento();


/*ejercicio Crear un cursor para ver todos los clientes que 
no hayan hecho pagos (que hayan hecho pagos superiores a 5000).
 Hazlo con un loop.*/
declare
	cursor mi_cursor is select * from jardineria.pagos;
	r jardineria.pagos%rowtype;
begin
	open mi_cursor;
	loop 
		fetch mi_cursor into r;
		exit when mi_cursor%notfound;
		if(r.cantidad >= 5000 ) then
			dbms_output.put_line(r.codigocliente || ' - ' ||	
					jardineria.fn_nombre_cliente(r.codigocliente));
		end if;
	end loop;
	close mi_cursor;
end;
/
	
create or replace function jardineria.fn_nombre_cliente(
	p_cod jardineria.clientes.codigocliente%type) return varchar2
is 
	v_nombre varchar2(100);
begin
	select nombrecliente into v_nombre
		from jardineria.clientes
			where codigocliente = p_cod;
	return v_nombre;
end;
/	

select jardineria.fn_nombre_cliente(35) from dual;

/*Crear un cursor para ver todos los clientes que no hayan
 hecho pagos. Hazlo con un for.*/
 
declare
	cursor mi_cursor is select * from jardineria.pagos;
begin
  for r in mi_cursor loop	
		if(r.cantidad >= 5000 ) then
			dbms_output.put_line(r.codigocliente || ' - ' ||	
					jardineria.fn_nombre_cliente(r.codigocliente));
		end if;
	end loop;
end;
/

/*Determinar el sueldo promedio por departamento*/
create or replace procedure scott.sp_suel_promedio
is
	v_prom number;
begin
	dbms_output.put_line('Dpto' || chr(9) || 'Suel. Promedio');
	for r in (select deptno from scott.dept) loop
		select avg(sal) into v_prom
			from scott.emp 
				where deptno = r.deptno;
		dbms_output.put_line(r.deptno || chr(9) || to_char(nvl(v_prom,0),'999,990.00'));
	end loop;
end;
/

execute scott.sp_suel_promedio();
------------------------------------------------
--SELECT FOR UPDATE
------------------------------------------------
/*Listado de empleados.*/
create or replace procedure scott.sp_listado_empleados
is
	cursor mi_cursor is select * from scott.emp for update wait 2;
begin
	for r in mi_cursor loop
		dbms_output.put_line(r.empno || chr(9) || r.ename || chr(9)
				|| r.sal);
	end loop;
end;
/

execute scott.sp_listado_empleados();

---------------------------------------------------
--CURSORES IMPLICITOS USANDO SQL%ATRIBUTO
---------------------------------------------------
/*Actualizar el salario de un empleado.*/
create or replace procedure scott.sp_emp_sal_update(
	p_cod scott.emp.empno%type,
	p_increm number
)
is
begin
	update scott.emp
		set sal = sal + p_increm
			where empno = p_cod;
	if sql%notfound then
		dbms_output.put_line('No existe');
	else 
		commit;
		dbms_output.put_line('Proceso ok');
	end if;
end;
/

call scott.sp_emp_sal_update(7900, -50);
-------------------------------------------------------
-------------------------------------------------------
create or replace procedure EUREKA.usp_egcc_movimientos
( p_cuenta IN cuenta.chr_cuencodigo%TYPE, 
  p_cursor OUT NOCOPY SYS_REFCURSOR )
as begin
  open p_cursor for 
    select 
      m.chr_cuencodigo cuenta,
      m.int_movinumero nromov,
      m.dtt_movifecha fecha,
      m.chr_tipocodigo tipo,
      t.vch_tipodescripcion descripcion,
      t.vch_tipoaccion accion,
      m.dec_moviimporte importe
    from tipomovimiento t
    join movimiento m 
    on t.chr_tipocodigo = m.chr_tipocodigo
    where m.chr_cuencodigo = p_cuenta;
end;
/

-- Prueba utilizando variables enlazadas

VARIABLE V_MOV REFCURSOR
EXEC EUREKA.usp_egcc_movimientos('00100001', :V_MOV);
PRINT V_MOV

------------------------------------------------------
CREATE TABLE SCOTT.PLANILLAMES( 
  ANIO NUMBER(4), 
  MES NUMBER(2), 
  DEPTNO NUMBER(2), 
  EMPS NUMBER(2) NOT NULL, 
  PLANILLA NUMBER(10,2) NOT NULL, 
  CONSTRAINT PK_PLANILLAMES PRIMARY KEY(ANIO,MES, DEPTNO) 
);

create or replace procedure scott.sp_proc_planilla(
	p_mes number,
	p_anio number
)
is
	cursor mi_cursor is select deptno from scott.dept;
	v_deptno scott.dept.deptno%type;
	v_emps number;
	v_planilla number;
	cont number;
begin
 select count(*) into cont
	from scott.planillames
		where anio = p_anio and mes = p_mes;
	if(cont > 0) then
		dbms_output.put_line('Ya fue procesado');
		return;
	end if;
	open mi_cursor;
	fetch mi_cursor into v_deptno;
	while(mi_cursor%found) loop
		select count(empno), sum(sal) into v_emps, v_planilla
			from scott.emp
				where deptno = v_deptno;
		insert into scott.planillames
		values(p_anio, p_mes, v_deptno, v_emps, nvl(v_planilla,0));
		fetch mi_cursor into v_deptno;
	end loop;
	close mi_cursor;
	commit;
	dbms_output.put_line('Proceso ok');
end;
/

call scott.sp_proc_planilla(3,2020);
select * from scott.planillames;
----------------------------------------------
--ver productos, parametro de salida cursor
----------------------------------------------
create or replace procedure jardineria.sp_cur_productos(
	p_cursor out sys_refcursor
)
is
begin
	open p_cursor for
		select * from jardineria.productos;
end;
/

declare
	v_cursor sys_refcursor;
	rec jardineria.productos%rowtype;
begin
	jardineria.sp_cur_productos(v_cursor);
	loop
		fetch v_cursor into rec;
		exit when v_cursor%notfound;
		dbms_output.put_line(rec.codigoproducto || chr(9) ||
				rec.nombre || chr(9) || rec.gama || chr(9) ||
						rec.cantidadenstock || chr(9) || rec.precioventa);
	end loop;
	close v_cursor;
end;
/

--con variables enlazadas
variable v_cursor refcursor
execute jardineria.sp_cur_productos(:v_cursor);
print v_cursor

----------------------------------------------------
/*Incrementar la comisión, en función del salario, de los empleados de Bostón
 y Nueva York según su antigüedad y cargo¸según la siguiente tabla:*/
 
create or replace procedure scott.sp_aumenta_comm
is 
	cursor mi_cursor is select * from scott.emp;
	rec scott.emp%rowtype;
	incremento number;
	anios number;
begin
	open mi_cursor;
	loop
		fetch mi_cursor into rec;
		exit when mi_cursor%notfound;
		anios := extract(year from sysdate) - extract(year from rec.hiredate); 
		case(rec.deptno) 
			when 10 then
				case(rec.job)
					when 'ANALYST' then
						incremento := 0.12;
					when 'MANAGER' then
						incremento := 0;
					else
						incremento := 0.17;
				end case;
			when 40 then
				case
					when  anios < 10 then
						incremento := 0.10;
					when 10 <= anios and anios <= 20 then
						incremento := 0.15;
					when anios > 20 then
						incremento := 0.20;
				end case;
			else
				incremento := 0;
		end case;
		update scott.emp 
			set comm = comm + sal*incremento
				where empno = rec.empno;
	end loop;
	close mi_cursor;
	commit;
end;
/

call scott.sp_aumenta_comm();

begin
	dbms_output.put_line('Codigo'|| chr(9) || 'Nombre' || chr(9) || 
			'Salario' ||	chr(9) || 'Comision' || chr(9) || 'Departamento' || chr(9)
						|| 'Cargo');--cabecera
	for r in (select * from scott.emp) loop
		dbms_output.put_line(r.empno|| chr(9) || r.ename || chr(9) ||
				r.sal || chr(9) || nvl(r.comm,0) || chr(9) || chr(9) || r.deptno 
						|| chr(9)|| chr(9) || r.job);
	end loop;
end;
/


insert into scott.emp 
values(7940,'URRUNAGA','PRESIDENT',7839,'12/09/1983',10000,1000,40);

insert into scott.emp 
values(7958,'WINTER','ANALYST',7566,'12/09/2006',10000,1000,40);

---------------------------------------------------------------
/*Procedimiento que reciba como argumento un caracter alfabético y visualice
 el número de empleado y la letra inicial y final del apellido de todos los 
 empleados cuyo salario es menor que la media salarial en la empresa. 
 Se generará una excepción de usuario si la letra inicial o final coincide
 con la letra introducida como argumentos*/

create or replace procedure scott.sp_caracter(
	caracter char
)
is
	cursor mi_cursor is select * from scott.emp;
	rec scott.emp%rowtype;
	l_inicial char(1);
	l_final char(1);
	mi_excepcion exception;
	sal_prom number;
	cont number := 0;
begin
	select avg(sal) into sal_prom
	from scott.emp;
	open mi_cursor;
	loop
		fetch mi_cursor into rec;
		exit when mi_cursor%notfound;
		begin
			l_inicial := substr(rec.ename,1,1);
			l_final := substr(rec.ename,-1,1);
			if(upper(l_inicial) = upper(caracter) or upper(l_final) = upper(caracter)) then
				raise mi_excepcion;
			elsif(rec.sal < sal_prom) then
				cont := cont + 1;
				dbms_output.put_line(cont || chr(9) ||
					rec.ename || chr(9) || l_inicial || chr(9) || l_final);
			end if;
		exception
			when mi_excepcion then
				dbms_output.put_line('Las letras del usuario iniciales o finales
						coinciden con la letra: ' || caracter);
		end;
	end loop;
	close mi_cursor;
end;
/

execute scott.sp_caracter('M');

--mostrar todos los clientes con cursorpor defecto
create or replace procedure jardineria.sp_cur_clientes(
	mi_cursor out sys_refcursor
)
is
begin
	open mi_cursor for
	select * from jardineria.clientes;
end;
/

declare
	v_cursor sys_refcursor;
	rec jardineria.clientes%rowtype;
begin
	jardineria.sp_cur_clientes(v_cursor);
	loop
		fetch v_cursor into rec;
		exit when v_cursor%notfound;
		dbms_output.put_line(rec.codigocliente || ' - '
			|| rec.nombrecliente);
	end loop;
	dbms_output.put_line('Total encontrados:' || v_cursor%rowcount);
	close v_cursor;
end;
/

/*Create a cursor displays the name and salary of each employee in 
the EMPLOYEES table whose salary is less than that specified by a 
passed-in parameter value cursor*/

create or replace procedure scott.sp_cur_muestra_sal(
	p_sal in number
)
as
  cursor mi_cursor is select * from scott.emp;
	rec scott.emp%rowtype;
begin
	open mi_cursor;
	loop
		fetch mi_cursor into rec;
		exit when mi_cursor%notfound;
		if (rec.sal < p_sal) then 
			dbms_output.put_line(rec.ename || ' - ' || rec.sal);
		end if;
	end loop;
	close mi_cursor;
end;
/

call scott.sp_cur_muestra_sal(3000);

--con cursor con parametro
create or replace procedure scott.sp_cur_muestra_sal2
as
  cursor mi_cursor(p_sal number) is select * from scott.emp
		where sal < p_sal;
	rec scott.emp%rowtype;
begin
	open mi_cursor(3000);
	loop
		fetch mi_cursor into rec;
		exit when mi_cursor%notfound; 
		dbms_output.put_line(rec.ename || ' - ' || rec.sal);
	end loop;
	close mi_cursor;
end;
/

call scott.sp_cur_muestra_sal2();

/*Write a program in PL/SQL to fetch the first three rows of a 
result set into three records using Same explicit cursor into different 
variables.*/

create or replace procedure jardineria.sp_cur_empl
is
	cursor mi_cursor is select codigoempleado, nombre, 
		apellido1 from jardineria.empleados;
	rec1 jardineria.empleados.codigoempleado%type;
	rec2 jardineria.empleados.nombre%type;
	rec3 jardineria.empleados.apellido1%type;
begin
	open mi_cursor;
	loop
		fetch mi_cursor into rec1, rec2, rec3;
		exit when mi_cursor%rowcount > 3;
		dbms_output.put_line(rec1 || ' - ' ||
			rec2 || ' - ' || rec3);
	end loop;
end;
/

call jardineria.sp_cur_empl();


/*Write a PL/SQL block to display department name, head of the department,
city, and employee with highest salary. Display name, city, hod, emp with
 highest salary*/
 
 --primer paso, encontrar los requerimientos pedidos por depto
 create or replace procedure scott.sp_may_sal_dpto(
	p_dpto scott.dept.deptno%type
 )
as
	v_max number;
	cursor mi_cursor is select dname, loc, ename, sal
		from scott.emp e
			join scott.dept d
				on e.deptno = d.deptno
					where sal = v_max;
	type obj_tipo1 is record(
		dname scott.dept.dname%type,
		loc scott.dept.loc%type,
		ename scott.emp.ename%type,
		sal scott.emp.sal%type
	);
	rec obj_tipo1;
begin
	select max(sal) into v_max
	from scott.emp
	where deptno = p_dpto;
	open mi_cursor;
	loop 
		fetch mi_cursor into rec;
		exit when mi_cursor%notfound;
		dbms_output.put_line(rec.dname || ' - ' || rec.loc ||
			' - ' || rec.ename || ' - '|| rec.sal);
	end loop;
	close mi_cursor;
 end;
 /
 
 call scott.sp_may_sal_dpto(20);
 
--segundo paso, hallar los requerimientos pedidos para 
--todos los departamentos
	
begin
	for r in (select deptno from scott.dept) loop
		scott.sp_may_sal_dpto(r.deptno);
	end loop;
end;
/

 /*Escriba un bloque PL / SQL para mostrar el nombre del departamento,
 el nombre del gerente, el número de empleados en cada departamento
 y el número de empleados enumerados en el historial de trabajos.
Mostrar nombre del departamento, gerente, recuento de empleados*/


--paso 0, obtener el manager de departamento
create or replace function scott.fn_dame_manager(
		nro_depto number
)return varchar2
as
	v_manager varchar2(50);
begin 
	select ename into v_manager
		from scott.emp
			where job = 'MANAGER'
				and deptno = nro_depto;
	return v_manager;
end;
/

select scott.fn_dame_manager(30) from dual;


--paso 1, obtener la informacion requerida 
create or replace procedure scott.sp_cur_gerente
as
	nombre_dept varchar2(40);
	manager varchar2(40);
	nro_emp number;
	cursor mi_cursor is select dname, scott.fn_dame_manager(d.deptno), count(empno)
		from scott.emp e
			join scott.dept d
				on e.deptno = d.deptno
					group by dname, scott.fn_dame_manager(d.deptno);
	
	type TipoRec is record (
		nombre_dept varchar2(40),
		manager varchar2(40),
		nro_emp number
	);
	rec TipoRec;
begin
	open mi_cursor;
	loop
		fetch mi_cursor into rec;
		exit when mi_cursor%notfound;
		dbms_output.put_line(rec.nombre_dept || ' - ' ||
			rec.manager || ' - ' || rec.nro_emp);
	end loop;
	close mi_cursor;
end;
/

call scott.sp_cur_gerente();


/*Write a program in PL/SQL to FETCH multiple records and
 more than one columns from different tables.*/
 
 --bloque anonimo que mostrara producto, nombre de la linea
 --y total vendido, esquema neptuno
 
declare
	cursor mi_cursor is select descripcion, nombre, COUNT(d.idproducto),
		sum(importe)
			from pepito.lineas l
				join pepito.productos p on l.idlinea = p.idlinea
					join pepito.detalleventa d on p.idproducto = d.idproducto
						group by descripcion, nombre;
						
	type tipo_record is record(
		descrip pepito.productos.descripcion%type,
		nom pepito.lineas.nombre%type,
		cant number,
		tot number);
	rec tipo_record;
begin
	open mi_cursor;
		loop
			fetch mi_cursor into rec;
				exit when (mi_cursor%notfound);
				dbms_output.put_line(rec.descrip || ' - ' || rec.nom ||
					 ' - ' || rec.cant || ' - ' || rec.tot);
		end loop;
end;
/

----------------------------------------------------
--CURSORES ANIDADOS
----------------------------------------------------
SELECT

      d.deptno,

      d.dname,

      CURSOR

      (

        SELECT

          empno,

          ename

        FROM

          scott.emp e

        WHERE

          e.deptno=d.deptno

      ) EMP_CUR

  FROM

    scott.dept d;

/*Write a program in PL/SQL to FETCH multiple records with the 
uses of nested cursor.*/
--listar las fechas en que han sido vendidas cada producto
--de esquema pepito

declare
	codigo varchar2(5);
	cursor cur_pro is select * from pepito.productos;
	cursor cur_date(codigo varchar2) is select fecha 
		from pepito.detalleventa d
			join pepito.ventas v on d.idventa = v.idventa
				where idproducto = codigo;
	v_pro pepito.productos%rowtype;
	v_fecha pepito.ventas.fecha%type;
begin
	open cur_pro;
	loop 
		fetch cur_pro into v_pro;
			exit when cur_pro%notfound;
				dbms_output.put_line('Producto: ' || v_pro.descripcion);
				codigo := v_pro.idproducto;
				open cur_date(codigo);
				loop
					fetch cur_date into v_fecha;
					exit when cur_date%notfound;
						dbms_output.put_line(v_fecha);
				end loop;
				close cur_date;
	end loop;
	close cur_pro;
end;
/

	/*if (nvl(length(to_char(v_fecha)),0) > 0) then
						dbms_output.put_line(v_fecha);
					else
						dbms_output.put_line('No registra venta');
					end if;*/



declare
	codigo varchar2(5);
	cursor cur_date(codigo varchar2) is select fecha 
		from pepito.detalleventa d
			join pepito.ventas v on d.idventa = v.idventa
				where idproducto = codigo;
	v_fecha pepito.ventas.fecha%type;
begin
	open cur_date('A0001');
				loop
					fetch cur_date into v_fecha;
					exit when cur_date%notfound;
					dbms_output.put_line(v_fecha);
				end loop;
	close cur_date;
end;
/


/* Write a program in PL/SQL to print a list of managers and
 the name of the departments.*/
declare
	cursor cur_dept is select * from scott.dept;
	cursor cur_manager(p_deptno number) is select ename
		from scott.emp 
			where job = 'MANAGER' and deptno = p_deptno;
	v_deptno number;
begin
	for r_dept in cur_dept loop
		v_deptno := r_dept.deptno;
		for r_emp in cur_manager(v_deptno) loop
			dbms_output.put_line(r_dept.dname || ':::' || r_emp.ename);
		end loop;
	end loop;
end;
/
		
/*24. Write a program in PL/SQL to create a cursor displays the name 
and salary of each employee in the EMPLOYEES table whose salary is 
less than that specified by a passed-in parameter value.*/

declare
	cursor mi_cursor(parametro number) is
		select * from scott.emp
			where sal < parametro;
	rec mi_cursor%rowtype;
	var number := 2000;
begin
	open mi_cursor(var);
	dbms_output.put_line('Nombre' || chr(9) || 'Salario');
	loop
		fetch mi_cursor into rec;
		exit when mi_cursor%notfound;
		dbms_output.put_line(rec.ename || chr(9) || rec.sal);
	end loop;	
end;
/

/*25. Write a program in PL/SQL to show the uses of fetch one record 
at a time using fetch statement inside the loop.*/

------------------------------------------------------------------
--SQL Dinamico
--Permite ejecutar cualquier tipo de instrucción SQL desde PL/SQL.
------------------------------------------------------------------
create or replace procedure pepito.ejecuta_query(cmd varchar2)
as
begin
	execute immediate cmd;
end;
/

declare
	cmd varchar2(100) := 'create table pepito.eliminame(
											id number,
											dato varchar2(30))';
begin
	pepito.ejecuta_query(cmd);
end;
/

execute pepito.ejecuta_query('insert into pepito.eliminame values(1, ''Oracle is powerfull'')');


declare
	cmd varchar2(100) := 'drop table pepito.eliminame';
begin
	pepito.ejecuta_query(cmd);
end;
/

--------------------------------------------------------
--SENTENCIA: SELECT
/*Select columnas into variables/registro
		From NombreTabla
		Where condición;*/
--------------------------------------------------------

/*Consultar la cantidad de empleados y el importe de la planilla de un 
departamento.*/
create or replace procedure scott.sp_consulta_planilla(
	p_dep scott.emp.deptno%type)
is
	v_emp number;
	planilla number;
begin
	select count(*), sum(sal)
		into v_emp, planilla
			from scott.emp
				where deptno = p_dep;
	if v_emp = 0 then
		raise no_data_found;
	end if;
		dbms_output.put_line('Empleados: ' || v_emp || ' Planilla: ' ||planilla );
exception 
	when no_data_found then
		dbms_output.put_line('Departamento no existe');
end;
/

execute scott.sp_consulta_planilla(40);

create or replace procedure scott.FindEmp( Cod Emp.EmpNo%Type )
is
	Salario number;
Begin
	Select Sal Into Salario
		From Emp
			Where EmpNo = Cod;
	DBMS_Output.Put_Line( 'Salario: ' || Salario );
Exception
	When No_Data_Found Then
		DBMS_Output.Put_Line( 'Código no existe.' );
End;
/

--SQL%ATRIBUTO SE USA PARA SENTENCIAS DML
--USANDO SQL%ROWCOUNT
declare 
begin
	update scott.emp
		set comm = 100 
			where comm = 0;
	dbms_output.put_line('Total afectados: ' || sql%rowcount);
	rollback;
end;
/

/*Para este ejemplo crearemos la tabla resumen,  donde 
almacenaremos el número de empleados por departamento y 
el importe de su planilla.*/
create table scott.resumen(
	deptno number,
	emps number,
	planilla number,
	constraint xpk_resumen primary key (deptno)
	);
	
create or replace procedure scott.sp_llena_planillas
as
	cursor mi_cursor(dept_in number) is select count(empno) empleados,
		sum(sal) salarios
		from scott.emp 
			where deptno = dept_in;
			
	rec_planilla mi_cursor%rowtype;
	cursor mi_cursor2 is select deptno 
		from scott.dept;
	rec_deptno mi_cursor2%rowtype;
	cont number;
begin
	open mi_cursor2;
	loop 
		fetch mi_cursor2 into rec_deptno;
		exit when mi_cursor2%notfound;
			begin
				select count(*) into  cont
					from scott.resumen
						where deptno = rec_deptno.deptno;
				if not cont = 0 then
					raise no_data_found;
				end if;
				open mi_cursor(rec_deptno.deptno);
				loop 
					fetch mi_cursor into rec_planilla;
					exit when mi_cursor%notfound;
					insert into scott.resumen
						values(rec_deptno.deptno, rec_planilla.empleados, 
								nvl(rec_planilla.salarios,0));
				end loop;
				close mi_cursor;
			exception
				when no_data_found then
					dbms_output.put_line('Ya se ha llenado planilla de este departamento');
			end;
	end loop;
	close mi_cursor2;
	commit;
end;
/

execute scott.sp_llena_planillas();

/*Desarrollar un procedimiento para eliminar un departamento, primero
 debe verificar que no tenga registros relacionados en la tabla emp.*/
create or replace procedure scott.sp_elimina_dept(
	cod_dept scott.dept.deptno%type
)
as 
	cont number;
	mi_err exception;
	mi_err2 exception;
begin
	select count(*) into cont 
		from scott.dept 
			where deptno = cod_dept;
	if cont = 0 then
		raise mi_err;
	end if;
	select count(*) into cont 
		from scott.emp 
			where deptno = cod_dept;
	if not cont = 0 then
		raise mi_err2;
	end if;
	delete from scott.dept
		where deptno = cod_dept;
	dbms_output.put_line('Proceso Okay');
	dbms_output.put_line('Departamento Eliminado');
	commit;
exception
	when mi_err then
		dbms_output.put_line('Departamento no existe');
	when mi_err2 then
		dbms_output.put_line('No se puede borrar departamento');
		dbms_output.put_line('Hay registros asociados a él en tabla scott.emp');
end;
/

insert into scott.dept values(50,'RRHH', 'NEW JERSEY');

execute scott.sp_elimina_dept(10);

--------------------------------------------------------------
--CLÁUSULA RETURNING
--Sirve para obtener información de la última fila modificada, 
--puede ser utilizado con las sentencias
--INSERT, UPDATE o DELETE.
--------------------------------------------------------------
create sequence pepito.sqtest;
create global temporary table pepito.test(
	id number,
	dato varchar2(30),
	constraint xpk_test primary key (id)
)on commit preserve rows;

create or replace procedure pepito.sp_returning_test(
	msg varchar2
)
as
	v_dato pepito.test.dato%type;
	v_id number;
begin
	insert into pepito.test 
		values(sqtest.nextval, msg)
	returning dato, id into v_dato, v_id;	
	commit;
	dbms_output.put_line('Id: ' || v_id);
	dbms_output.put_line('Dato: ' || v_dato);
end;
/

execute pepito.sp_returning_test('Jejeje, ya me fui');


declare
	v_deptno scott.dept.deptno%type;
	v_dname scott.dept.dname%type;
	v_loc scott.dept.loc%type;
begin
	insert into scott.dept values(50,'RRHH', 'NEW JERSEY')
	return deptno, dname, loc into v_deptno, v_dname, v_loc;
	commit;
	dbms_output.put_line('Nro Dept: ' || v_deptno );
	dbms_output.put_line('Departamento: ' || v_dname );
	dbms_output.put_line('Localizacion: ' || v_loc );
end;
/

-------------------------------------------------------
--ENLACES DE BASE DE DATOS
-------------------------------------------------------
--nos conectamos como system
create public database link link_demo
connect to hr identified by hr
using 'ORCL';--nombre del servicio de la base de datos remota

--ahora nos conectamos como scott
connect scott/tiger

select employee_id, first_name
from employees@link_demo
where department_id = 30;

--BORRAR DATABASE LINK
DROP PUBLIC DATABASE LINK link_demo;

--------------------------------------------------------
--SINÓNIMOS
--------------------------------------------------------
--Facilitan la referencia a tablas de otros esquemas,
--incluso de otros servidores.
--------------------------------------------------------
create or replace public synonym hr_emp
for employees@link_demo;

--ahora nos conectamos como scott
connect scott/tiger

select * from hr_emp where rownum = 1;

---------------------------------------------
--Funciones y Procedimientos
---------------------------------------------
create or replace function scott.fn_dame_num_emp(
	dept in scott.dept.deptno%type
)return number
as
	v_empleados number;
	v_dept number;
	err exception;
begin
	select count(*) into v_dept
		from scott.dept
			where deptno = dept;
	if v_dept = 0 then
		raise err;
	end if;	
	
	select count(*) into v_empleados
		from scott.emp 
			where deptno = dept;
			
	return v_empleados;
exception
	when err then
		dbms_output.put_line('Departamento no existe');
		return -1;
end;
/

select scott.fn_dame_num_emp(60) from dual;

declare
	v_number number;
	vch varchar2(10);
begin
	vch := 'Empleado';
	v_number := scott.fn_dame_num_emp(40);
	if v_number >= 2 then
		vch := 'Empleados';
	end if;
	dbms_output.put_line(vch || ': ' || v_number);
end;
/


declare
	cursor mi_cursor is select deptno
		from scott.dept;
	v_empleados number;
	v_dname varchar2(30);
begin
	for rec in mi_cursor loop
	
		select count(*) into v_empleados
			from scott.emp
				where deptno = rec.deptno;
				
		select dname into v_dname
			from scott.dept
				where deptno = rec.deptno;
				
		dbms_output.put_line( v_dname || ', EMPLEADOS: ' || v_empleados);
	end loop;
end;
/

-------------------------------------------------------
--PAQUETES
-------------------------------------------------------

--creando el paquete
create or replace package pepito.testpackage is

	function suma(num1 in number, num2 in number)
		return number;

end testpackage;
/

--creando el cuerpo del paquete
create or replace package body pepito.testpackage as

	function suma(
		num1 in number,
		num2 in number) return number
	is
		res number;
	begin
		res := num1 + num2;
		return res;
	end;
end testpackage;
/

select pepito.testpackage.suma(10, 20) from dual;

--con bloque anonimo
declare
	res number;
begin
	res := pepito.testpackage.suma(10, 20);
	dbms_output.put_line('Resultado: ' || res);
end;
/

--borrar paquete
drop package pepito.testpackage;

--nuevo paquete
CREATE OR REPLACE PACKAGE scott.paquete_prueba as
	
	cursor mi_cursor(cod_emp emp.empno%type) return emp%rowtype;
		
	mi_excepcion exception;
	
	function factorial(num number) return number;
	
	function suma(n1 number, n2 number) return number;
	
	function suma(v1 number, v2 number) return number;
	
	procedure ejecuta_query(cmd varchar2);
	
	procedure valor_verdad(verdad_char varchar2, verdad_bool boolean);
	
	procedure valor_verdad(p boolean, q boolean, op varchar2);
	
	procedure valor_not(p boolean);
	
	procedure palabras_parecidas(string_test varchar2, patron varchar2);

END paquete_prueba;
/

--cuerpo 
CREATE OR REPLACE PACKAGE BODY scott.paquete_prueba as
	
cursor mi_cursor(cod_emp emp.empno%type) return emp%rowtype
	is select * from emp 	
		where empno = cod_emp;
		
function factorial(num number) return number
is
	fact number; 
begin
	fact := 1;
	for r in 2..num loop
		fact := fact * r;
	end loop;
	return fact;
end;

function suma(n1 number, n2 number) return number
is
	res number;
begin
	res := n1 + n2;
	return res;
end;

function suma(v1 number, v2 number) return number
is
	res number;
begin
	res := v1 + v2 + 100;
	return res;
end;

procedure ejecuta_query(cmd varchar2) 
is
begin 
	execute immediate cmd;
end;

procedure valor_verdad(verdad_char varchar2, verdad_bool boolean)
is
begin
	if verdad_bool is null then
		dbms_output.put_line(verdad_char || ' = NULL');
	elsif verdad_bool = true then
		dbms_output.put_line(verdad_char || ' = TRUE');
	else
		dbms_output.put_line(verdad_char || ' = FALSE');
	end if;
end;

procedure valor_verdad(p boolean, q boolean, op varchar2)
is
	valor boolean;
begin
	case 
		when upper(op) = 'AND' then
			valor := p and q;
		when upper(op) = 'OR' then
			valor := p or q;
		when upper(op) = '=' then
			valor := p = q;
		when upper(op) = '<>' then
			valor := p <> q;
		else
			raise paquete_prueba.mi_excepcion;
	end case;
	paquete_prueba.valor_verdad('p', p);
	paquete_prueba.valor_verdad('q', q);
	paquete_prueba.valor_verdad('p ' || lower(op) ||  ' q', valor);
	exception
		when mi_excepcion then
			dbms_output.put_line('Operador incorrecto');
end;

procedure valor_not(p boolean) 
is
	valor boolean;
begin
	valor := not p;
	paquete_prueba.valor_verdad('p', p);
	paquete_prueba.valor_verdad('not p', valor);
end
;

procedure palabras_parecidas(string_test varchar2, patron varchar2)
is
begin
	if string_test like patron then
		dbms_output.put_line('TRUE');
	else
		dbms_output.put_line('FALSE');
	end if;
end;

END paquete_prueba;
/

--invocando objetos del paquete_prueba_
declare
	empleado scott.paquete_prueba.mi_cursor%rowtype;
	num number := 0;
	cmd varchar2(40) := 'select * from scott.emp';
begin
	open scott.paquete_prueba.mi_cursor(7934);
	loop 
		fetch scott.paquete_prueba.mi_cursor into empleado;
		exit when scott.paquete_prueba.mi_cursor%notfound;
		dbms_output.put_line('Salario: ' || empleado.sal);
	end loop;
	close scott.paquete_prueba.mi_cursor;
	dbms_output.put_line('El factorial de ' || num || ' es ' || scott.paquete_prueba.factorial(num));
	scott.paquete_prueba.ejecuta_query(cmd);
end;
/

--invocando funciones del paquete con sobrecarga
select scott.paquete_prueba.suma(n1=>10,n2=>20) suma1,
					scott.paquete_prueba.suma(v1=>10,v2=>20) suma2
from dual;

-----------------------------------------------------------
--TRIGGERS
-----------------------------------------------------------
create or replace trigger scott.tr_test_emp
after insert or delete or update on scott.emp
begin
	if inserting then
		dbms_output.put_line('Se ha insertado un empleado');
	elsif updating then
		dbms_output.put_line('Se ha actualizado un empleado');
	elsif deleting then
		dbms_output.put_line('Se ha eliminado un empleado');
	end if;
end;
/

insert into scott.emp values(7950, 'Alf', 'Director',6666, '10/12/1999', 5000,35, 10);

update scott.emp 
set ename = 'Alfito'
where empno = 7950;

/*Realizar un desencadenante que registre los cambios de salario
 de un empleado, el usuario que lo realiza y la fecha.*/
 --SOL
 create table scott.sal_history
 (
 empno number(4) not null,
 salold number(7,2) null,
 salnew number(7,2) null,
 startdate date not null,
 setuser varchar2(30) not null
 );
 
 create or replace trigger scott.tr_updateempsal
 after insert or update on scott.emp
 for each row
 begin
	insert into scott.sal_history(empno, salold, salnew, startdate, setuser)
		values(:new.empno, :old.sal, :new.sal, sysdate, user);
 end;
 /
 
 --desabilitar un desencadenante
 alter trigger scott.tr_UpdateEmpSal disable;
 
 --borrar trigger
 drop trigger scott.tr_UpdateEmpSal;
 
 
 ------------------------
 --sys_refcursor
 -----------------------
create or replace function pepito.fn_valida_usuario(
	p_us  pepito.empleados.usuario%type,
	p_pas pepito.empleados.clave%type
 )return sys_refcursor
is
	pas_cursor sys_refcursor;
begin 
	open pas_cursor for select * from pepito.empleados
		where usuario = p_us and clave = p_pas;
	return pas_cursor;
end;
/

declare
	mi_cursor sys_refcursor;
	empleado pepito.empleados%rowtype;
begin
	mi_cursor := pepito.fn_valida_usuario('manolito', 'jugador');
	loop
		fetch mi_cursor into empleado;
		exit when mi_cursor%notfound;
		dbms_output.put_line('Nombre: ' || empleado.nombre);
		dbms_output.put_line('Apellidos: ' || empleado.apellidos);
		dbms_output.put_line('Email: ' || empleado.email);
	end loop;
	if mi_cursor%isopen then
		dbms_output.put_line('Cursor abierto');
	end if;
	--close mi_cursor;
end;
/

----------------------------------------------
--Regreso a triggers
----------------------------------------------
create table pepito.tb_resguardo_producto
(
	cod varchar2(5) not null,
	nom varchar2(50) not null,
	pre_anterior number(8,2) null,
	pre_posterior number(8,2) null,
	fech_cambio date not null,
	usu varchar2(50) not null
);

create or replace trigger pepito.tr_informa_productos
after delete or update or insert on pepito.productos
for each row
declare
	empleado pepito.empleados%rowtype;
	mi_cursor sys_refcursor;
	nombre varchar2(50);
begin
	mi_cursor := pepito.fn_valida_usuario('luisita', 'gatita');
	loop
		fetch mi_cursor into empleado;
		exit when mi_cursor%notfound;
	end loop;	
	
	nombre := empleado.nombre || ', ' ||empleado.apellidos;
	
	if inserting then
		insert into pepito.tb_resguardo_producto
		(cod, nom, pre_posterior, fech_cambio, usu)
		values(:new.idproducto, :new.descripcion, :new.precioventa, sysdate, nombre);
		dbms_output.put_line('Se ha insertado un producto');
	end if;
	
	if deleting then
		insert into pepito.tb_resguardo_producto
		(cod, nom, pre_anterior, fech_cambio, usu)
		values(:old.idproducto, :old.descripcion, :old.precioventa, sysdate, nombre);
		dbms_output.put_line('Se ha eliminado un producto');
	end if;
	
	if updating then	
		insert into pepito.tb_resguardo_producto
		(cod, nom, pre_anterior, pre_posterior,fech_cambio, usu)
		values(:old.idproducto, :old.descripcion, :old.precioventa, :new.precioventa,sysdate, nombre);
		dbms_output.put_line('Se ha actualizado un producto');
	end if;
end;
/

insert into pepito.productos values('A0098', 'TABLET S3', 4, 2000, 2450, 35);
commit;

update pepito.productos set precioventa = 2666 where idproducto = 'A0098';
commit;

delete pepito.productos where idproducto = 'A0098';
commit;

------------------------
begin
  if mi_cursor%isopen then
   dbms_output.put_line('abierto');
  end if;
end;
/
---------------------------------
--creando paquete en esquema pepito para definir un cursor para validar
--usuario y password
CREATE OR REPLACE PACKAGE pepito.paquete_validacion as

	type cursor_type is ref cursor return pepito.empleados%rowtype;
		
	function fn_valida(usu pepito.empleados.usuario%type, pas pepito.empleados.clave%type)
		return cursor_type;
		
END paquete_validacion;
/

CREATE OR REPLACE PACKAGE BODY pepito.paquete_validacion as

function fn_valida(usu pepito.empleados.usuario%type, pas pepito.empleados.clave%type)
		return cursor_type
is
	cursor_valida pepito.paquete_validacion.cursor_type;
	empleado cursor_valida%rowtype;
begin
	open cursor_valida for 
		select * from pepito.empleados 
			where usuario = usu and clave = pas;
	return cursor_valida;
end;

END paquete_validacion;
/


select pepito.paquete_validacion.fn_valida('maritza','maritzita')
from dual;

--ejemplo implicit statement cursor: single ref cursor
CREATE OR REPLACE PROCEDURE scott.rc_procedure_1
	(p_empno IN scott.emp.empno%TYPE, p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
	OPEN p_cursor FOR
		SELECT empno, ename FROM scott.emp WHERE  empno = p_empno;
END;
/
	
	
VARIABLE v_cursor REFCURSOR
BEGIN
	scott.rc_procedure_1('7934', :v_cursor);
END;
/
PRINT v_cursor


--TRIGGERS DE SUSTITUCION
--(Actuan sobre vistas)
CREATE OR REPLACE VIEW scott.vempleados AS
	SELECT empno, ename, job, d.deptno, dname
	FROM scott.emp e
	JOIN scott.dept d ON e.deptno = d.deptno;
	

--trigger
CREATE OR REPLACE TRIGGER scott.tr_vempleados 
	INSTEAD OF DELETE OR INSERT ON scott.vempleados
	FOR EACH ROW
DECLARE
	cuenta number;
BEGIN
	IF INSERTING THEN
		SELECT COUNT(*) INTO cuenta 
		FROM scott.dept WHERE deptno = :new.deptno;
		
		IF cuenta = 0 THEN 
			INSERT INTO scott.dept (deptno, dname)
			VALUES(:new.deptno, :new.dname);
			DBMS_OUTPUT.PUT_LINE('Se ha insertado un departamento en scott.dept');
		END IF;
		
		SELECT COUNT(*) INTO cuenta
		FROM scott.emp WHERE empno = :new.empno;
		
		IF cuenta = 0 THEN
			INSERT INTO scott.emp (empno, ename, job, deptno)
			VALUES(:new.empno, :new.ename, :new.job, :new.deptno);
			DBMS_OUTPUT.PUT_LINE('Se ha insertado un empleado en scott.emp');
		END IF;
  END IF;
	
	IF DELETING THEN
		DELETE FROM scott.emp WHERE empno = :old.empno;
		DBMS_OUTPUT.PUT_LINE('Se ha eliminado un empleado en scott.emp');
	END IF;
END tr_vempleados;
/

INSERT INTO scott.vempleados VALUES(8000, 'Mandrake', 'Analyst', 60, 'OTROS');--estudia todas las variantes
INSERT INTO scott.vempleados VALUES(8000, 'Mandrake', 'Analyst', 50, 'RRHH');
INSERT INTO scott.vempleados VALUES(7950, 'Alfito', 'Director', 10, 'ACCOUNTING');--revisa este

DELETE FROM scott.vempleados WHERE empno = 8000;

SELECT * FROM scott.emp ORDER BY empno;
SELECT * FROM scott.dept;

DELETE FROM scott.dept WHERE deptno = 60;
DELETE FROM scott.emp WHERE empno = 8000; 

--OTORGAR PRIVILEGIOS EN UNA TABLA
CONNECT latinoamerica/mandrakeisalive

GRANT SELECT ON latinoamerica.empleados --privilegios de seleccion
	TO pepito WITH GRANT OPTION; --permite al usuario pepito otorgar privilegios select a otros usuarios

CONNECT PEPITO/oracle
--usuario pepito crea vistas
CREATE OR REPLACE VIEW view_empleados_latinoaut AS
	SELECT idempleado, nombre || ' ' ||apellidos as nombres,
	email 
	FROM latinoamerica.empleados;
	
--pepito otorga privilegios de vista a otro usuario
GRANT SELECT ON pepito.view_empleados_latinoaut
	TO scott;
	
----------------------------
--algunas	cosas interesantes
----------------------------
BEGIN
	dbms_output.put_line(ora_login_user || ' is the current user');
END;
/

BEGIN
	dbms_output.put_line(systimestamp);
END;
/

BEGIN
	dbms_output.put_line(ora_sysevent);
END;
/
-------------------------------------------------------
--UN CURSOR DE PAQUETE SE MANTENDRÁ ABIERTO HASTA QUE 
--EXPLÍCITAMENTE SE CIERRE O LA SESIÓN TERMINE
CREATE OR REPLACE PACKAGE SCOTT.PKG_ELIMINAME AS

CURSOR mi_cursor RETURN SCOTT.EMP%ROWTYPE;

END PKG_ELIMINAME;
/


CREATE OR REPLACE PACKAGE BODY SCOTT.PKG_ELIMINAME AS

CURSOR mi_cursor RETURN SCOTT.EMP%ROWTYPE IS
	SELECT * FROM SCOTT.EMP;
	
END PKG_ELIMINAME;
/


BEGIN 
	OPEN SCOTT.PKG_ELIMINAME.mi_cursor;
END;
/

BEGIN
	IF  SCOTT.PKG_ELIMINAME.mi_cursor%ISOPEN THEN
		DBMS_OUTPUT.PUT_LINE('Cursor abierto');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Cursor cerrado');
	END IF;
END;
/

BEGIN 
	CLOSE SCOTT.PKG_ELIMINAME.mi_cursor;
END;
/

DROP PACKAGE SCOTT.PKG_ELIMINAME;

----------------------------------------------------
--ESCRIBIR UNA FUNCION QUE VALIDE USUARIO EN ESQUEMA PEPITO/oracle
CREATE OR REPLACE PACKAGE PEPITO.PKG_ELIMINAME AS

CURSOR cursor_valida(us VARCHAR2, pas VARCHAR2) RETURN PEPITO.EMPLEADOS%ROWTYPE;

FUNCTION SP_VALIDA(us VARCHAR2, pas VARCHAR2) RETURN PEPITO.EMPLEADOS%ROWTYPE;

END PKG_ELIMINAME;
/


CREATE OR REPLACE PACKAGE BODY PEPITO.PKG_ELIMINAME AS


CURSOR cursor_valida(us VARCHAR2, pas VARCHAR2) RETURN PEPITO.EMPLEADOS%ROWTYPE
IS
SELECT * FROM PEPITO.EMPLEADOS 
WHERE usuario = us AND clave = pas;


FUNCTION SP_VALIDA(us VARCHAR2, pas VARCHAR2) RETURN PEPITO.EMPLEADOS%ROWTYPE
IS
	empleado PEPITO.EMPLEADOS%ROWTYPE;
BEGIN
	OPEN PKG_ELIMINAME.cursor_valida(us, pas);
	LOOP 
		FETCH PKG_ELIMINAME.cursor_valida INTO empleado;
		EXIT WHEN PKG_ELIMINAME.cursor_valida%NOTFOUND;
	END LOOP;
	IF PKG_ELIMINAME.cursor_valida%ROWCOUNT = 0 THEN
		CLOSE PKG_ELIMINAME.cursor_valida;
	END IF;
	RETURN empleado;
END;


END PKG_ELIMINAME;
/

DECLARE
	empleado PEPITO.PKG_ELIMINAME.cursor_valida%ROWTYPE;
BEGIN
	empleado := PEPITO.PKG_ELIMINAME.SP_VALIDA('manolito', 'jugador');
	
	IF PEPITO.PKG_ELIMINAME.cursor_valida%ISOPEN THEN
		DBMS_OUTPUT.PUT_LINE('Se encontró empleado');
		DBMS_OUTPUT.PUT_LINE('Empleado:' || empleado.nombre);
	ELSE
		DBMS_OUTPUT.PUT_LINE('No se encontró empleado');
		DBMS_OUTPUT.PUT_LINE('Empleado: ' || empleado.nombre);
	END IF;	
END;
/

DECLARE 
	r PEPITO.PKG_ELIMINAME.cursor_valida%ROWTYPE;
BEGIN
	IF PEPITO.PKG_ELIMINAME.cursor_valida%ISOPEN THEN
		DBMS_OUTPUT.PUT_LINE('Cursor abierto');
	ELSE 
		DBMS_OUTPUT.PUT_LINE('Cursor cerrado');
	END IF;
END;
/

DECLARE
	CURSOR mi_cursor IS SELECT nombre
	FROM pepito.empleados
	WHERE idempleado = 'E0005';
	empleado mi_cursor%ROWTYPE;
BEGIN
	OPEN mi_cursor;
	FETCH mi_cursor INTO empleado;
	WHILE mi_cursor%FOUND LOOP
		DBMS_OUTPUT.PUT_LINE( mi_cursor%rowcount || '.- '
				|| empleado.nombre);
		FETCH mi_cursor INTO empleado;		
	END LOOP;
	IF mi_cursor%rowcount = 0 THEN
		DBMS_OUTPUT.PUT_LINE('El empleado no existe');
	END IF;
END;
/

DECLARE
	nom pepito.empleados.nombre%type;
BEGIN
	SELECT nombre INTO nom
	FROM PEPITO.EMPLEADOS
	WHERE idempleado = 'E0004';
	DBMS_OUTPUT.PUT_LINE('Empleado: ' || nom);
	
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('No existe empleado');
END;
/