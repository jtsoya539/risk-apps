prompt Importing table t_modulos...
set feedback off
set define off
insert into t_modulos (ID_MODULO, NOMBRE, DETALLE, ACTIVO, FECHA_ACTUAL, VERSION_ACTUAL)
values ('MSJ', 'MENSAJER�A', 'M�dulo para env�o de mensajes a los usuarios a trav�s de Correo electr�nico (E-mail), Mensaje de texto (SMS) y Notificaci�n push', 'S', to_date('09-07-2021', 'dd-mm-yyyy'), '0.10.0');

prompt Done.
