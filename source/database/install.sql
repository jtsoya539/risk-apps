/*
--------------------------------- MIT License ---------------------------------
Copyright (c) 2019 jtsoya539

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-------------------------------------------------------------------------------
*/

spool install.log

set feedback off
set define off

prompt ###################################
prompt #   _____   _____   _____  _  __  #
prompt #  |  __ \ |_   _| / ____|| |/ /  #
prompt #  | |__) |  | |  | (___  | ' /   #
prompt #  |  _  /   | |   \___ \ |  <    #
prompt #  | | \ \  _| |_  ____) || . \   #
prompt #  |_|  \_\|_____||_____/ |_|\_\  #
prompt #                                 #
prompt #          Proyecto RISK          #
prompt #            jtsoya539            #
prompt ###################################

prompt
prompt ===================================
prompt Instalacion iniciada
prompt ===================================
prompt

prompt
prompt Creando secuencias...
prompt -----------------------------------
prompt
@@sequences/s_id_ciudad.seq
@@sequences/s_id_pais.seq
@@sequences/s_id_persona.seq
@@sequences/s_id_rol.seq
@@sequences/s_id_servicio.seq
@@sequences/s_id_sesion.seq
@@sequences/s_id_usuario.seq
@@sequences/s_id_correo.seq
@@sequences/s_id_correo_adjunto.seq
@@sequences/s_id_mensaje.seq

prompt
prompt Creando tablas...
prompt -----------------------------------
prompt
@@tables/t_sistemas.tab
@@tables/t_aplicaciones.tab
@@tables/t_errores.tab
@@tables/t_significados.tab
@@tables/t_paises.tab
@@tables/t_ciudades.tab
@@tables/t_personas.tab
@@tables/t_usuarios.tab
@@tables/t_roles.tab
@@tables/t_parametros.tab
@@tables/t_rol_parametros.tab
@@tables/t_permisos.tab
@@tables/t_rol_permisos.tab
@@tables/t_rol_usuarios.tab
@@tables/t_servicios.tab
@@tables/t_servicio_parametros.tab
@@tables/t_sesiones.tab
@@tables/t_usuario_claves.tab
@@tables/t_correos.tab
@@tables/t_correo_adjuntos.tab
@@tables/t_mensajes.tab

prompt
prompt Creando types...
prompt -----------------------------------
prompt
@@types/y_serializable.typ
@@types/y_dato.typ
@@types/y_parametro.typ
@@types/y_parametros.typ
@@types/y_respuesta.typ
@@types/y_rol.typ
@@types/y_roles.typ
@@types/y_usuario.typ
@@types/y_sesion.typ

prompt
prompt Creando paquetes...
prompt -----------------------------------
prompt
@@packages/k_sistema.pck
@@packages/k_html.pck
@@packages/k_util.pck
@@packages/k_auditoria.pck
@@packages/k_autenticacion.pck
@@packages/k_error.pck
@@packages/k_servicio.pck
@@packages/k_mensajeria.pck

prompt
prompt Creando triggers...
prompt -----------------------------------
prompt
@@triggers/gs_ciudades.trg
@@triggers/gs_paises.trg
@@triggers/gs_personas.trg
@@triggers/gs_roles.trg
@@triggers/gs_servicios.trg
@@triggers/gs_sesiones.trg
@@triggers/gs_usuarios.trg
@@triggers/gs_correos.trg
@@triggers/gs_correo_adjuntos.trg
@@triggers/gs_mensajes.trg
@@triggers/gb_usuarios.trg
@@triggers/gb_sesiones.trg

prompt
prompt Ejecutando scripts...
prompt -----------------------------------
prompt
@@install_audit.sql
@@compile_schema.sql
@@scripts/ins_t_sistemas.sql
@@scripts/ins_t_aplicaciones.sql
@@scripts/ins_t_significados.sql
@@scripts/ins_t_errores.sql
@@scripts/ins_t_parametros.sql
@@scripts/ins_t_servicios.sql
@@scripts/ins_t_servicio_parametros.sql
@@scripts/ins_t_roles.sql
commit;
/

prompt
prompt ===================================
prompt Instalacion finalizada
prompt ===================================
prompt

spool off
