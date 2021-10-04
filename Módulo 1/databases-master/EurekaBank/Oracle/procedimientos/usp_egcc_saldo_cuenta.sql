----------------------------------------------------
-- Autor:   Eric Gustavo Coronel Castillo
-- Blog:    gcoronelc.blogspot.com
-- Email:   gcoronelc@gmail.com
-- Youtube: https://goo.gl/9GFBaC
----------------------------------------------------

-- Procedimiento

create or replace procedure usp_egcc_saldo_cuenta
( p_cuenta varchar2, p_saldo out number )
is
begin

	select dec_cuensaldo into p_saldo
	from cuenta
	where chr_cuencodigo = p_cuenta;

end;
/

-- Prueba

set serveroutput on

declare
	v_saldo number;
begin
	usp_egcc_saldo_cuenta('00100001',v_saldo);
	dbms_output.put_line('Saldo: ' || v_saldo);
end;
/

declare
	v_saldo number;
	v_cuenta char(8);
begin
	usp_egcc_saldo_cuenta(&v_cuenta,v_saldo);
	dbms_output.put_line('Saldo: ' || v_saldo);
end;
/

