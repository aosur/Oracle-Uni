/*1. Vuelva a escribir las siguientes instrucciones IF para que no
 use una instrucción IF para establecer el valor de no_revenue . 
 ¿Cuál es la diferencia entre estas dos declaraciones? 
 ¿Cómo afecta esa diferencia a tu respuesta?*
 IF total_sales <= 0 THEN 
 no_revenue := TRUE; 
 ELSE no_revenue := FALSE; 
 END IF; 
 
 IF total_sales <= 0 THEN 
 no_revenue := TRUE; 
 ELSIF total_sales > 0 THEN
 no_revenue := FALSE; 
 END IF;*/
 
declare
	total_sales number := -12;
	no_revenue boolean;
begin
	case
		when total_sales <= 0 then
			no_revenue := true;
			dbms_output.put_line('verdad');
		else
			no_revenue := false;
			dbms_output.put_line('falso');
	end case;
end;
/
	
/*2. How many times does the following loop execute? 
FOR year_index IN REVERSE 12 .. 1 LOOP 
calc_sales (year_index); 
END LOOP;
*/
declare
	cuenta number := 0;
begin
	FOR year_index IN REVERSE 1 .. 12 LOOP 
		dbms_output.put_line(year_index); 
		cuenta := cuenta + 1;
	END LOOP;
	dbms_output.put_line('cuenta:' || cuenta);
end;
/
 
 
 /*3.Escriba un programa PL / SQL para verificar si una 
 fecha cae el fin de semana, es decir, SÁBADO o DOMINGO.*/
 --SOL 1
create or replace procedure scott.sp_sabado_domingo(
	p_fecha in date) 
is	
	res varchar2(40) := 'No cae fin de semana';
	v_dia varchar2(10);
begin
	v_dia := trim(to_char(p_fecha, 'day', 'nls_date_language=spanish'));
	dbms_output.put_line(v_dia);
	if v_dia in ('sßbado','domingo') then
		res := 'Cae fin de semana';
	end if;
	dbms_output.put_line(res);
end;
/
	
declare
	v_date date;
begin
	v_date := to_date('03/05/2020');
	scott.sp_sabado_domingo(v_date);
end;
/

--SOL2
DECLARE
	dt1 DATE := TO_DATE('&new_dt', 'DD-MON-YYYY');
	get_day VARCHAR2(15);
BEGIN
	get_day := RTRIM(TO_CHAR(dt1, 'DAY'));
	IF get_day IN ('SATURDAY', 'SUNDAY') THEN
		--dbms_output.new_line;
		DBMS_OUTPUT.PUT_LINE ('The day of the given date is 
				'||get_day||' and it falls on weekend');
	ELSE
		dbms_output.new_line;
		DBMS_OUTPUT.PUT_LINE ('The day of the given date is '||get_day||'
				and it does not fall on the weekend');
	END IF;
	DBMS_OUTPUT.PUT_LINE ('Execution  done successfully.');
END;
/

/*6. Escriba un procedimiento PL / SQL para calcular el incentivo 
alcanzado de acuerdo con el límite de venta específico.*/

DECLARE
	v_ventas NUMBER := 28000;
	v_incentivo NUMBER;
	PROCEDURE sp_calcula_incentivo(p_ventas IN OUT NUMBER, p_incentivo OUT NUMBER)
	IS		
	BEGIN
		CASE
			WHEN p_ventas > 44000 THEN
				p_incentivo := 1800;
			WHEN p_ventas <= 40000 AND p_ventas > 32000 THEN
				p_incentivo := 800;
			ELSE
				p_incentivo := 500;
		END CASE;
	END;
BEGIN
	sp_calcula_incentivo(v_ventas, v_incentivo);
	DBMS_OUTPUT.PUT_LINE('Ventas: ' || v_ventas || ', Incentivo: ' || v_incentivo );
END;
/

/*7. Escriba un programa PL / SQL para contar el número de empleados
 en el departamento 50 y verifique si este departamento tiene
 vacantes o no. Hay 45 vacantes en este departamento.*/
 
DECLARE
	numero_empleados NUMBER;
BEGIN
	SELECT COUNT(*) INTO numero_empleados
	FROM scott.emp
	WHERE DEPTNO = 50;
	IF numero_empleados > 45 THEN
		DBMS_OUTPUT.PUT_LINE('No hay vacantes disponibles');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Hay vacantes disponibles');
	END IF;
END;
/

/*8. Escriba un programa PL / SQL para mostrar la descripción
 contra una calificación.*/
DECLARE
	calificacion CHAR(1);
	msg VARCHAR2(30);
BEGIN
	calificacion := '&new_calificacion';
	CASE calificacion 
		WHEN 'A' THEN 
			msg := 'Your Grade is: Outstanding';
		WHEN 'B' THEN 
			msg := 'Your Grade is: Excellent';
		WHEN 'C' THEN 
			msg := 'Your Grade is: Very Good';
		WHEN 'D' THEN 
			msg := 'Your Grade is: Average';
		WHEN 'F' THEN 
			msg := 'Your Grade is: Poor';
		ELSE
			msg := 'No such grade in the list.';
	END CASE;
	DBMS_OUTPUT.PUT_LINE(msg);
END;
/

/*13. Escriba un programa PL / SQL para verificar si un
 carácter dado es letra o dígito.*/
 
DECLARE
	caracter CHAR(1);
	nro_ascii NUMBER;
	msg VARCHAR(50);
BEGIN
	caracter := '&new_caracter';
	nro_ascii := ASCII(caracter);
	CASE
		WHEN nro_ascii BETWEEN 48 AND 57 THEN
			msg := 'Ha ingresado un dígito';
		WHEN (nro_ascii BETWEEN 65 AND 90) OR 
			(nro_ascii BETWEEN 97 AND 122) THEN
			msg := 'Ha ingresado una letra';
		ELSE
			msg := 'Su caracter no es ni letra, ni dígito';
	END CASE;
	DBMS_OUTPUT.PUT_LINE('Ingresó: ' || caracter || ', ASCII: ' || nro_ascii);
	DBMS_OUTPUT.PUT_LINE(msg);
END;
/ 

/*14. Escriba un programa PL / SQL para convertir una
 temperatura en grados Fahrenheit a Celsius y viceversa.*/
 
DECLARE
	temperatura NUMBER;
	sistema CHAR(1);	
	resultado NUMBER;
BEGIN
	temperatura := '&new_temperatura';
	sistema := '&new_sistema';
	CASE sistema
		WHEN 'F' THEN
			resultado := (temperatura - 32)/1.8;
		WHEN 'C' THEN
			resultado := (temperatura * 1.8) + 32;
	END CASE;
	DBMS_OUTPUT.PUT_LINE('Conversión: ' || ROUND(resultado,6) 
				|| 'º' || TRIM(sistema from 'FC'));
EXCEPTION
	WHEN CASE_NOT_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Ha ingresado incorrectamente
				el sistema de temperatura');
END;
/

/*15. Write a PL/SQL program to display which day is a
 specific date.*/
DECLARE
	fecha DATE;
	dia VARCHAR2(10);
BEGIN
	fecha := TO_DATE('&new_fecha', 'dd/mm/yyyy');
	dia := TO_CHAR(fecha, 'DAY', 'nls_date_language=spanish');
	DBMS_OUTPUT.PUT_LINE('Cae un día ' || dia);
END;
/

/*18. Escriba un programa en PL / SQL para mostrar
 los usos del bucle anidado.*/
DECLARE
	--v_departamento scott.dept.deptname%TYPE;
--	v_empleado scott.emp.empname%TYPE;
BEGIN
	FOR departamento IN (SELECT * FROM scott.dept) LOOP
	
		DBMS_OUTPUT.PUT_LINE('-------------------');
		DBMS_OUTPUT.PUT_LINE('Departamento: ' || departamento.dname);
		DBMS_OUTPUT.PUT_LINE('-------------------');
		
		FOR empleado IN (SELECT * FROM scott.emp WHERE deptno = 
				departamento.deptno) LOOP
			
			DBMS_OUTPUT.PUT_LINE(empleado.ename);
		END LOOP;
	END LOOP;
END;
/

/*27. Escriba un programa en PL / SQL para imprimir los números 
primos entre 1 y 50.*/
CREATE OR REPLACE PROCEDURE scott.sp_dime_si_primo(
	p_num IN NUMBER,
	p_verdad OUT BOOLEAN
)
IS
	cuenta NUMBER := 0;
BEGIN
	p_verdad := TRUE;
	
	FOR I IN 2..ROUND(SQRT(p_num)) LOOP
		IF (MOD(p_num, I) = 0) THEN
			cuenta := cuenta + 1;
		END IF;
	END LOOP;
	
	IF(cuenta >= 1 OR p_num = 1) THEN
		p_verdad := FALSE;
	END IF;
	
END;
/

--verificando el algoritmo anterior
DECLARE
	v_verdad BOOLEAN;
BEGIN
	scott.sp_dime_si_primo(2, v_verdad);
	IF v_verdad = TRUE THEN 
		DBMS_OUTPUT.PUT_LINE('Primo');
	ELSE
		DBMS_OUTPUT.PUT_LINE('No es primo');
	END IF;
END;
/

--Mostrando los primos entre 1 y 50
DECLARE
	v_verdad BOOLEAN;
BEGIN
	DBMS_OUTPUT.PUT_LINE('Los números primos son:');
	FOR N IN 1..50 LOOP
		scott.sp_dime_si_primo(N, v_verdad);
		IF v_verdad THEN
			DBMS_OUTPUT.PUT(N || '   ');
		END IF;
	END LOOP;
	DBMS_OUTPUT.NEW_LINE;
END;
/

--------------------------------------------
--PL/SQL DataType
--------------------------------------------
/*4. Write a PL/SQL procedure to accepts a BOOLEAN parameter
 and uses a CASE statement to print Unknown if the value of 
 the parameter is NULL, Yes if it is TRUE, and No if it is
 FALSE.*/
CREATE OR REPLACE PROCEDURE scott.sp_dime_verdad(
	p_verdad IN BOOLEAN)
IS
	v_verdad BOOLEAN;
BEGIN
	CASE 
		WHEN p_verdad IS NULL THEN
			DBMS_OUTPUT.PUT_LINE('UNKNOW');
		WHEN p_verdad THEN
			DBMS_OUTPUT.PUT_LINE('TRUE');
		WHEN NOT p_verdad THEN
			DBMS_OUTPUT.PUT_LINE('FALSE');
	END CASE;
EXCEPTION
	WHEN CASE_NOT_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('WRONG PARAMETER VALUE');
END;
/

BEGIN
	scott.sp_dime_verdad(TRUE);
	scott.sp_dime_verdad(FALSE);
	scott.sp_dime_verdad(NULL);
END;
/

/*2. Write a program in PL/SQL to show the uses of CURVAL and NEXTVAL 
with a sequence name.*/

CREATE SEQUENCE SCOTT.SQ_BORRAME
INCREMENT BY 1
START WITH 1; 

DROP SEQUENCE SCOTT.SQ_BORRAME;

DECLARE
	numero NUMBER;
	actual NUMBER;
BEGIN
	numero := SCOTT.SQ_BORRAME.NEXTVAL;
	DBMS_OUTPUT.PUT_LINE('Valor dado de la secuencia: ' 				
											|| numero);
	actual := SCOTT.SQ_BORRAME.CURRVAL; 
	DBMS_OUTPUT.PUT_LINE('Valor actual: ' 
											|| actual);									
END;
/

--Digamos que queremos retroceder la secuencia a 5 e incrementar 
--de uno, entoces hacemos:
ALTER SEQUENCE SCOTT.SQ_BORRAME
INCREMENT BY -3;

SELECT SCOTT.SQ_BORRAME.NEXTVAL FROM DUAL;

SELECT SCOTT.SQ_BORRAME.CURRVAL FROM DUAL;

ALTER SEQUENCE SCOTT.SQ_BORRAME
INCREMENT BY 1;

SELECT SCOTT.SQ_BORRAME.CURRVAL FROM DUAL;



-------------------------------------------------
--PROBANDO LAS FECHAS(VARCHAR A DATE Y VICEVERSA)

--REFERENCIA
/*DECLARE
	fecha DATE;
	dia VARCHAR2(10);
BEGIN
	fecha := TO_DATE('&new_fecha', 'dd/mm/yyyy');
	dia := TO_CHAR(fecha, 'DAY', 'nls_date_language=spanish');
	DBMS_OUTPUT.PUT_LINE('Cae un día ' || dia);
END;
/
*/

--para extraer las horas usar timestamp
SELECT EXTRACT(HOUR FROM TIMESTAMP '2020-12-28 20:30:30') FROM DUAL;

--de varchar a date
DECLARE
	sfecha VARCHAR2(40):= '28-12-2020 20:30:30';
	fecha DATE;
BEGIN 
	fecha := TO_DATE(sfecha, 'dd/mm/yyyy HH24:MI:SS');--  TO_DATE(STRING, FORMATO)
	DBMS_OUTPUT.PUT_LINE('La fecha en DATE es: ' || fecha);
	DBMS_OUTPUT.PUT_LINE('La hora de la cita: ' || EXTRACT(HOUR FROM CAST( sfecha AS TIMESTAMP)));
END;
/

--de date a varchar
DECLARE
	sfecha VARCHAR2(40);
	fecha DATE := SYSDATE;
BEGIN
	sfecha := TO_CHAR(fecha, 'dd/mm/yyyy HH24:MI:SS'); --  TO_CHAR(DATE, FORMATO)
	DBMS_OUTPUT.PUT_LINE('fecha en VARCHAR2: ' || sfecha);
END;
/ 


