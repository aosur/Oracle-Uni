/*1. Escriba un bloque PL / SQL para calcular el incentivo de 
un empleado cuya ID es 7900.*/
--SOL
--suponiendo incentivo del 0.12
declare
	incentivo number(8,2);
begin
	select sal * 0.12 into incentivo
		from scott.emp
			where empno = 7900;
	dbms_output.put_line('Incentivo: ' || incentivo);
end;
/

/*2. Escriba un bloque PL / SQL para mostrar una referencia no
sensible a mayúsculas y minúsculas a un identificador definido
por el usuario entre comillas y sin comillas.*/
--SOL
declare
	"BIENVENIDO" varchar2(10) := 'Bienvenido';
begin
	dbms_output.put_line("Bienvenido");
end;
/

/*3. Escribir un bloque PL / SQL para mostrar que una palabra 
reservada se puede usar como un identificador definido por el
 usuario.*/
--SOL
declare
	"BEGIN" varchar2(20) := 'CASO MAYUSCULAS';
	"Begin" varchar2(20) := 'Caso alternado';
	"begin" varchar2(20) := 'caso minusculas';
begin
	dbms_output.put_line("BEGIN");
	dbms_output.put_line("Begin");
	dbms_output.put_line("begin");
	--dbms_output.put_line("BeGiN"); lanza error
end;
/

/*4. Escriba un bloque PL / SQL para mostrar el resultado para
 descuidar las comillas dobles en el identificador de palabra 
 reservado.*/
 --SOL
declare
	"WELCOME" varchar2(10) := 'welcome';--no es palabra reservada
	"BEGIN" varchar2(10) := 'begin';--es palbra reservada
begin
	dbms_output.put_line(welcome);--no son necesarias las comillas, insensible a mayusculas
	dbms_output.put_line("BEGIN");--son necesarias las comillas, sensible a mayúsculas
end;
/

/*5. Escriba un bloque PL / SQL para mostrar el resultado para descuidar
 la distinción entre mayúsculas y minúsculas de un identificador definido 
 por el usuario, que también es una palabra reservada.*/
 --SOL
 --ver ejercicio anterior
 
/*6. Escriba un bloque PL / SQL para explicar comentarios únicos y multilínea.*/

/*para varias lineas utilizamos*/
--para una sola linea utilizamos "--"

/*12. Escriba un bloque PL / SQL para crear un procedimiento utilizando 
el "Operador IS [NOT] NULL" y muestre que el operador AND devuelve TRUE 
si y solo si ambos operandos son TRUE.*/

--SOL
begin
	dbms_output.put_line('-------Para p y q verdaderos--------');
	scott.paquete_prueba.valor_verdad(true, true, 'and');
	dbms_output.put_line('-------Para p verdadero y q falso--------');
	scott.paquete_prueba.valor_verdad(true, false, 'and');
	dbms_output.put_line('-------Para p verdadero y q null--------');
	scott.paquete_prueba.valor_verdad(true, null, 'and');
	dbms_output.put_line('-------Para p falso y q verdadero--------');
	scott.paquete_prueba.valor_verdad(false, true, 'and');
	dbms_output.put_line('-------Para p y q falsos--------');
	scott.paquete_prueba.valor_verdad(false, false, 'and');
	dbms_output.put_line('-------Para p falso y q null--------');
	scott.paquete_prueba.valor_verdad(false, null, 'and');
	dbms_output.put_line('-------Para p null y q verdadero--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>true, op=>'and');
	dbms_output.put_line('-------Para p null y q falso--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>false, op=>'and');
	dbms_output.put_line('-------Para p y q nullos--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>null, op=>'and');
end;
/

/*13. Escriba un bloque PL / SQL para crear un procedimiento utilizando 
el "Operador IS [NOT] NULL" y muestre que el operador OR devuelve 
VERDADERO si cualquiera de los operandos es VERDADERO.*/

--SOL
begin
	dbms_output.put_line('-------Para p y q verdaderos--------');
	scott.paquete_prueba.valor_verdad(true, true, 'or');
	dbms_output.put_line('-------Para p verdadero y q falso--------');
	scott.paquete_prueba.valor_verdad(true, false, 'or');
	dbms_output.put_line('-------Para p verdadero y q null--------');
	scott.paquete_prueba.valor_verdad(true, null, 'or');
	dbms_output.put_line('-------Para p falso y q verdadero--------');
	scott.paquete_prueba.valor_verdad(false, true, 'or');
	dbms_output.put_line('-------Para p y q falsos--------');
	scott.paquete_prueba.valor_verdad(false, false, 'or');
	dbms_output.put_line('-------Para p falso y q null--------');
	scott.paquete_prueba.valor_verdad(false, null, 'or');
	dbms_output.put_line('-------Para p null y q verdadero--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>true, op=>'or');
	dbms_output.put_line('-------Para p null y q falso--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>false, op=>'or');
	dbms_output.put_line('-------Para p y q nullos--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>null, op=>'or');
end;
/

/*14. Escriba un bloque PL / SQL para crear un procedimiento utilizando el
 "Operador IS [NOT] NULL" y muestre que el operador NOT devuelve el opuesto
 de su operando, a menos que el operando sea NULL.*/
 begin
	dbms_output.put_line('-------Para p verdadero--------');
	scott.paquete_prueba.valor_not(true);
	dbms_output.put_line('-------Para p falso--------');
	scott.paquete_prueba.valor_not(false);
	dbms_output.put_line('-------Para p null--------');
	scott.paquete_prueba.valor_not(null);
end;
/

/*15. Escriba un bloque PL / SQL para describir el uso de valores NULL en
 comparación igual, comparación desigual y NOT NULL es igual a comparación NULL.*/
begin
	dbms_output.put_line('-------Para p null y q null--------');
	scott.paquete_prueba.valor_verdad(null, null, '<>');
	dbms_output.put_line('-------Para p falso y q null--------');
	scott.paquete_prueba.valor_verdad(false, null, '<>');
	dbms_output.put_line('-------Para p null y q verdadero--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>true, op=>'<>');
	dbms_output.put_line('-------Para p null y q falso--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>false, op=>'<>');
	dbms_output.put_line('-------Para p y q nullos--------');
	scott.paquete_prueba.valor_verdad(p=>null, q=>null, op=>'<>');
end;
/

/*16. Escriba un bloque PL / SQL para describir el uso del operador LIKE, 
incluidos los caracteres comodín y el carácter de escape.*/
begin
	scott.paquete_prueba.palabras_parecidas('Alan', '%a_');
	scott.paquete_prueba.palabras_parecidas('Alan', '%L_n');
end;
/
 
