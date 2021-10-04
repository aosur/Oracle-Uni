--Ejercicios propuestos plsql
/*6. Mostrar los numeros del 1 al 100 con un loop.*/
declare 
	cont number := 0;
begin
	loop 	
		cont := cont + 1;
		dbms_output.put_line(cont);
	exit when (cont = 100);
	end loop;
end;
/

/*7. Mostrar el nombre de un cliente dado su codigo. Esquema jardineria*/
create or replace procedure jardineria.sp_nombre_cliente(
	p_cod in jardineria.clientes.codigocliente%type,
	p_nom out jardineria.clientes.nombrecliente%type
)
is
begin
	select nombrecliente 
	into p_nom
	from jardineria.clientes
	where codigocliente = p_cod;
end;
/

declare
	v_nombre jardineria.clientes.nombrecliente%type;
	v_cod jardineria.clientes.codigocliente%type := 5;
begin
	jardineria.sp_nombre_cliente(v_cod, v_nombre);
	dbms_output.put_line('Codigo: ' || v_cod || '  Nombre: ' || v_nombre);
end;
/

--el mismo ejercicio pero para todos los clientes
create or replace procedure jardineria.sp_todos_clientes
is
	nom jardineria.clientes.nombrecliente%type;
begin
	for r in (select * from jardineria.clientes) loop
		jardineria.sp_nombre_cliente(r.codigocliente, nom);
		dbms_output.put_line('Codigo: ' || r.codigocliente || '  Nombre: ' ||nom);
	end loop;
end;
/

call jardineria.sp_todos_clientes();

declare
	nom jardineria.clientes.nombrecliente%type;
begin 
	for r in (select * from jardineria.clientes) loop
			jardineria.sp_nombre_cliente(r.codigocliente, nom);
			dbms_output.put_line('Codigo: ' || r.codigocliente || '  Nombre: ' ||nom);
	end loop;
end;
/


declare
begin 
	for r in (select * from jardineria.clientes) loop
		dbms_output.put_line(r.codigocliente);
	end loop;
end;
/
