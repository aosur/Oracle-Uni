CREATE OR REPLACE PACKAGE SCOTT.PKG_UTILES AS
	
	TYPE string_array IS TABLE OF VARCHAR2(1000) INDEX BY PLS_INTEGER;
	
	FUNCTION separadora(p_datos VARCHAR2, p_separador VARCHAR2) RETURN string_array;
	
	PROCEDURE inserta_empleados(p_datos IN VARCHAR2, p_estado  OUT VARCHAR2);
	
END PKG_UTILES;
/

CREATE OR REPLACE PACKAGE BODY SCOTT.PKG_UTILES AS

FUNCTION separadora(p_datos VARCHAR2, p_separador VARCHAR2) RETURN string_array
IS
	v_datos CLOB;
	longitud NUMBER;
	array_out SCOTT.PKG_UTILES.string_array;
	entrada number := 0;
BEGIN
	v_datos := TRIM(p_datos);
	longitud := LENGTH(v_datos);
	WHILE longitud <> 0 LOOP
		entrada := entrada + 1;
		array_out(entrada) := SUBSTR(v_datos, 1, INSTR(v_datos, p_separador, 1, 1) - 1);
		v_datos := SUBSTR(v_datos, INSTR(v_datos, p_separador, 1, 1) + 1);
		longitud := NVL(LENGTH(v_datos),0);
	END LOOP;
	RETURN array_out;
END;

PROCEDURE inserta_empleados(p_datos IN VARCHAR2, p_estado  OUT VARCHAR2)
IS
	v_registros SCOTT.PKG_UTILES.string_array;
	v_columnas SCOTT.PKG_UTILES.string_array;
BEGIN
	p_estado := 'OK';
  v_registros := SCOTT.PKG_UTILES.separadora(p_datos, '|');
	
	FOR i IN 1..v_registros.COUNT LOOP
		v_columnas := SCOTT.PKG_UTILES.separadora(v_registros(i), '?');
		INSERT INTO scott.emp(empno, ename, sal)
		VALUES(TO_NUMBER(v_columnas(1)), v_columnas(2), TO_NUMBER(v_columnas(3)));
	END LOOP;
	COMMIT;
	
EXCEPTION WHEN OTHERS THEN
	p_estado := SQLERRM;
	ROLLBACK;
END;

END PKG_UTILES;
/

DECLARE
	datos VARCHAR2(1000);
	separador VARCHAR2(1);
	matriz SCOTT.PKG_UTILES.string_array;
BEGIN 
	datos := 'Guille?Lucas?Nicolle?Bianca?';
	separador := '?';
	matriz := SCOTT.PKG_UTILES.separadora(datos, separador);
	dbms_output.put_line('Tamaño de la matriz: ' || matriz.COUNT);
	FOR i IN 1..matriz.COUNT LOOP
		dbms_output.put_line(matriz(i));
	END LOOP;
	
END;
/

DECLARE
	datos VARCHAR2(1000);
	estado VARCHAR2(50);
BEGIN 
	datos := '9001?ALAN?5900?|9002?Jakelin?6000?|9003?Gato1?7200?|9004?Gato2?7500?|';
	SCOTT.PKG_UTILES.inserta_empleados(datos, estado);
	dbms_output.put_line(estado);	
END;
/

--OBTENER DIA DE LA SEMANA
select to_char(sysdate, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')
from dual;
select to_char(sysdate, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH')
from dual;
select to_char(sysdate, 'YEAR', 'NLS_DATE_LANGUAGE=SPANISH')
from dual;