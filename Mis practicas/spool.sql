SPOOL ON;
SET HEADING OFF;
SPOOL SPOOLTEXT.XLS;
select descripcion||chr(9)||precioventa||chr(9)||stock  from neptuno.productos;
SPOOL OFF;
