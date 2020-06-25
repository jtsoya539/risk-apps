CREATE OR REPLACE PACKAGE k_servicio IS

  /**
  Agrupa operaciones relacionadas con los Servicios Web del sistema
  
  %author jtsoya539 27/3/2020 16:42:26
  */

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

  -- C�digos de respuesta
  c_ok                       CONSTANT VARCHAR2(10) := '0';
  c_servicio_no_implementado CONSTANT VARCHAR2(10) := 'api0001';
  c_error_parametro          CONSTANT VARCHAR2(10) := 'api0002';
  c_error_general            CONSTANT VARCHAR2(10) := 'api0099';
  c_error_inesperado         CONSTANT VARCHAR2(10) := 'api9999';

  -- Excepciones
  ex_servicio_no_implementado EXCEPTION;
  ex_error_parametro          EXCEPTION;
  ex_error_general            EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_servicio_no_implementado, -6550);

  PROCEDURE p_limpiar_historial;

  PROCEDURE p_validar_parametro(io_respuesta IN OUT NOCOPY y_respuesta,
                                i_expresion  IN BOOLEAN,
                                i_mensaje    IN VARCHAR2);

  PROCEDURE p_respuesta_ok(io_respuesta IN OUT NOCOPY y_respuesta,
                           i_datos      IN y_objeto DEFAULT NULL);

  PROCEDURE p_respuesta_error(io_respuesta IN OUT NOCOPY y_respuesta,
                              i_codigo     IN VARCHAR2,
                              i_mensaje    IN VARCHAR2,
                              i_mensaje_bd IN VARCHAR2 DEFAULT NULL);

  PROCEDURE p_respuesta_excepcion(io_respuesta   IN OUT NOCOPY y_respuesta,
                                  i_error_number IN NUMBER,
                                  i_error_msg    IN VARCHAR2,
                                  i_error_stack  IN VARCHAR2);

  FUNCTION f_objeto_parse_json(i_json        IN CLOB,
                               i_nombre_tipo IN VARCHAR2) RETURN anydata;

  FUNCTION f_objeto_to_json(i_objeto IN anydata) RETURN CLOB;

  FUNCTION f_procesar_parametros(i_id_servicio IN NUMBER,
                                 i_parametros  IN CLOB) RETURN y_parametros;

  FUNCTION f_valor_parametro(i_parametros IN y_parametros,
                             i_nombre     IN VARCHAR2) RETURN anydata;

  FUNCTION f_paginar_elementos(i_elementos           IN y_objetos,
                               i_numero_pagina       IN INTEGER DEFAULT NULL,
                               i_cantidad_por_pagina IN INTEGER DEFAULT NULL,
                               i_no_paginar          IN VARCHAR2 DEFAULT NULL)
    RETURN y_pagina;

  FUNCTION f_procesar_servicio(i_id_servicio IN NUMBER,
                               i_parametros  IN CLOB) RETURN CLOB;

END;
/
CREATE OR REPLACE PACKAGE BODY k_servicio IS

  PROCEDURE lp_registrar_ejecucion(i_id_servicio IN NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE t_servicios
       SET cantidad_ejecuciones   = nvl(cantidad_ejecuciones, 0) + 1,
           fecha_ultima_ejecucion = SYSDATE
     WHERE id_servicio = i_id_servicio;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE lp_registrar_log(i_id_servicio IN NUMBER,
                             i_parametros  IN CLOB,
                             i_respuesta   IN CLOB) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO t_servicio_logs
      (id_servicio, parametros, respuesta)
    VALUES
      (i_id_servicio, i_parametros, i_respuesta);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  FUNCTION lf_procesar_servicio(i_id_servicio IN NUMBER,
                                i_parametros  IN CLOB) RETURN y_respuesta IS
    l_rsp              y_respuesta;
    l_prms             y_parametros;
    l_nombre_servicio  t_servicios.nombre%TYPE;
    l_dominio_servicio t_servicios.dominio%TYPE;
  BEGIN
    -- Inicializa respuesta
    l_rsp := NEW y_respuesta();
  
    l_rsp.lugar := 'Buscando nombre y dominio del servicio';
    BEGIN
      SELECT upper(nombre), upper(dominio)
        INTO l_nombre_servicio, l_dominio_servicio
        FROM t_servicios
       WHERE activo = 'S'
         AND id_servicio = i_id_servicio;
    EXCEPTION
      WHEN no_data_found THEN
        p_respuesta_error(l_rsp,
                          c_servicio_no_implementado,
                          'Servicio inexistente o inactivo');
        RAISE ex_error_parametro;
    END;
  
    l_rsp.lugar := 'Procesando parametros del servicio';
    BEGIN
      l_prms := f_procesar_parametros(i_id_servicio, i_parametros);
    EXCEPTION
      WHEN OTHERS THEN
        p_respuesta_error(l_rsp,
                          c_error_parametro,
                          CASE
                          k_error.f_tipo_excepcion(utl_call_stack.error_number(1)) WHEN
                          k_error.c_user_defined_error THEN
                          utl_call_stack.error_msg(1) WHEN
                          k_error.c_oracle_predefined_error THEN
                          k_error.f_mensaje_error(c_error_parametro) END,
                          dbms_utility.format_error_stack);
        RAISE ex_error_parametro;
    END;
  
    l_rsp.lugar := 'Procesando servicio';
    BEGIN
      EXECUTE IMMEDIATE 'BEGIN :1 := K_SERVICIO_' || l_dominio_servicio || '.' ||
                        l_nombre_servicio || '(:2); END;'
        USING OUT l_rsp, IN l_prms;
    EXCEPTION
      WHEN ex_servicio_no_implementado THEN
        p_respuesta_error(l_rsp,
                          c_servicio_no_implementado,
                          'Servicio no implementado',
                          dbms_utility.format_error_stack);
        RAISE ex_error_general;
      WHEN OTHERS THEN
        p_respuesta_error(l_rsp,
                          'api0004',
                          CASE
                          k_error.f_tipo_excepcion(utl_call_stack.error_number(1)) WHEN
                          k_error.c_user_defined_error THEN
                          utl_call_stack.error_msg(1) WHEN
                          k_error.c_oracle_predefined_error THEN
                          'Error al procesar servicio' END,
                          dbms_utility.format_error_stack);
        RAISE ex_error_general;
    END;
  
    IF l_rsp.codigo = c_ok THEN
      COMMIT;
    ELSE
      RAISE ex_error_general;
    END IF;
  
    p_respuesta_ok(l_rsp, l_rsp.datos);
    RETURN l_rsp;
  EXCEPTION
    WHEN ex_error_parametro THEN
      RETURN l_rsp;
    WHEN ex_error_general THEN
      ROLLBACK;
      RETURN l_rsp;
    WHEN OTHERS THEN
      ROLLBACK;
      p_respuesta_error(l_rsp,
                        c_error_inesperado,
                        k_error.f_mensaje_error(c_error_inesperado),
                        dbms_utility.format_error_stack);
      RETURN l_rsp;
  END;

  PROCEDURE p_limpiar_historial IS
  BEGIN
    UPDATE t_servicios
       SET cantidad_ejecuciones = NULL, fecha_ultima_ejecucion = NULL;
  END;

  PROCEDURE p_validar_parametro(io_respuesta IN OUT NOCOPY y_respuesta,
                                i_expresion  IN BOOLEAN,
                                i_mensaje    IN VARCHAR2) IS
  BEGIN
    IF NOT nvl(i_expresion, FALSE) THEN
      p_respuesta_error(io_respuesta,
                        c_error_parametro,
                        nvl(i_mensaje,
                            k_error.f_mensaje_error(c_error_parametro)));
      RAISE ex_error_parametro;
    END IF;
  END;

  PROCEDURE p_respuesta_ok(io_respuesta IN OUT NOCOPY y_respuesta,
                           i_datos      IN y_objeto DEFAULT NULL) IS
  BEGIN
    io_respuesta.codigo     := c_ok;
    io_respuesta.mensaje    := 'OK';
    io_respuesta.mensaje_bd := NULL;
    io_respuesta.lugar      := NULL;
    io_respuesta.datos      := i_datos;
  END;

  PROCEDURE p_respuesta_error(io_respuesta IN OUT NOCOPY y_respuesta,
                              i_codigo     IN VARCHAR2,
                              i_mensaje    IN VARCHAR2,
                              i_mensaje_bd IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF i_codigo = c_ok THEN
      io_respuesta.codigo  := c_error_inesperado;
      io_respuesta.mensaje := k_error.f_mensaje_error(io_respuesta.codigo);
    ELSE
      io_respuesta.codigo  := substr(i_codigo, 1, 10);
      io_respuesta.mensaje := substr(i_mensaje, 1, 4000);
    END IF;
    io_respuesta.mensaje_bd := substr(i_mensaje_bd, 1, 4000);
    io_respuesta.datos      := NULL;
  END;

  PROCEDURE p_respuesta_excepcion(io_respuesta   IN OUT NOCOPY y_respuesta,
                                  i_error_number IN NUMBER,
                                  i_error_msg    IN VARCHAR2,
                                  i_error_stack  IN VARCHAR2) IS
  BEGIN
    IF k_error.f_tipo_excepcion(i_error_number) =
       k_error.c_user_defined_error THEN
      p_respuesta_error(io_respuesta,
                        c_error_general,
                        i_error_msg,
                        i_error_stack);
    ELSIF k_error.f_tipo_excepcion(i_error_number) =
          k_error.c_oracle_predefined_error THEN
      p_respuesta_error(io_respuesta,
                        c_error_inesperado,
                        k_error.f_mensaje_error(c_error_inesperado),
                        i_error_stack);
    END IF;
  END;

  FUNCTION f_objeto_parse_json(i_json        IN CLOB,
                               i_nombre_tipo IN VARCHAR2) RETURN anydata IS
    l_retorno anydata;
    l_objeto  y_objeto;
  BEGIN
    IF i_json IS NOT NULL AND i_nombre_tipo IS NOT NULL THEN
      EXECUTE IMMEDIATE 'BEGIN :1 := ' || lower(i_nombre_tipo) ||
                        '.parse_json(i_json => :2); END;'
        USING OUT l_objeto, IN i_json;
      l_retorno := anydata.convertobject(l_objeto);
    END IF;
    RETURN l_retorno;
  END;

  FUNCTION f_objeto_to_json(i_objeto IN anydata) RETURN CLOB IS
    l_json     CLOB;
    l_typeinfo anytype;
    l_typecode PLS_INTEGER;
  BEGIN
    IF i_objeto IS NOT NULL THEN
      l_typecode := i_objeto.gettype(l_typeinfo);
      IF l_typecode = dbms_types.typecode_object THEN
        EXECUTE IMMEDIATE 'DECLARE
  l_retorno PLS_INTEGER;
  l_anydata anydata := :1;
  l_object  ' || i_objeto.gettypename || ';
  l_clob    CLOB;
BEGIN
  l_retorno := l_anydata.getobject(obj => l_object);
  :2        := l_object.to_json();
END;'
          USING IN i_objeto, OUT l_json;
      END IF;
    END IF;
    RETURN l_json;
  END;

  FUNCTION f_procesar_parametros(i_id_servicio IN NUMBER,
                                 i_parametros  IN CLOB) RETURN y_parametros IS
    l_parametros   y_parametros;
    l_parametro    y_parametro;
    l_json_object  json_object_t;
    l_json_element json_element_t;
  
    CURSOR c_servicio_parametros IS
      SELECT id_servicio,
             lower(nombre) nombre,
             direccion,
             tipo_dato,
             formato,
             obligatorio,
             valor_defecto
        FROM t_servicio_parametros
       WHERE activo = 'S'
         AND id_servicio = i_id_servicio
       ORDER BY orden;
  BEGIN
    -- Inicializa respuesta
    l_parametros := NEW y_parametros();
  
    IF i_parametros IS NULL OR dbms_lob.getlength(i_parametros) = 0 THEN
      l_json_object := json_object_t.parse('{}');
    ELSE
      l_json_object := json_object_t.parse(i_parametros);
    END IF;
  
    FOR par IN c_servicio_parametros LOOP
      IF par.obligatorio = 'S' THEN
        IF NOT l_json_object.has(par.nombre) THEN
          raise_application_error(-20000,
                                  'Parametro ' || par.nombre ||
                                  ' obligatorio');
        ELSE
          l_json_element := l_json_object.get(par.nombre);
          IF l_json_element.is_null THEN
            raise_application_error(-20000,
                                    'Parametro ' || par.nombre ||
                                    ' debe tener valor');
          END IF;
        END IF;
      END IF;
    
      l_parametro        := NEW y_parametro();
      l_parametro.nombre := par.nombre;
    
      CASE par.tipo_dato
        WHEN 'S' THEN
          -- String
          l_parametro.valor := anydata.convertvarchar2(l_json_object.get_string(par.nombre));
          IF l_parametro.valor.accessvarchar2 IS NULL AND
             par.valor_defecto IS NOT NULL THEN
            l_parametro.valor := anydata.convertvarchar2(par.valor_defecto);
          END IF;
        WHEN 'N' THEN
          -- Number
          l_parametro.valor := anydata.convertnumber(l_json_object.get_number(par.nombre));
          IF l_parametro.valor.accessnumber IS NULL AND
             par.valor_defecto IS NOT NULL THEN
            l_parametro.valor := anydata.convertnumber(to_number(par.valor_defecto));
          END IF;
        WHEN 'B' THEN
          -- Boolean
          l_parametro.valor := anydata.convertnumber(sys.diutil.bool_to_int(l_json_object.get_boolean(par.nombre)));
          IF l_parametro.valor.accessnumber IS NULL AND
             par.valor_defecto IS NOT NULL THEN
            l_parametro.valor := anydata.convertnumber(to_number(par.valor_defecto));
          END IF;
        WHEN 'D' THEN
          -- Date
          l_parametro.valor := anydata.convertdate(l_json_object.get_date(par.nombre));
          IF l_parametro.valor.accessdate IS NULL AND
             par.valor_defecto IS NOT NULL THEN
            l_parametro.valor := anydata.convertdate(to_date(par.valor_defecto,
                                                             'YYYY-MM-DD'));
          END IF;
        WHEN 'O' THEN
          -- Object
          IF l_json_object.get(par.nombre) IS NOT NULL THEN
            l_parametro.valor := f_objeto_parse_json(l_json_object.get(par.nombre)
                                                     .to_clob,
                                                     par.formato);
          END IF;
        
          IF l_parametro.valor IS NULL AND par.valor_defecto IS NOT NULL THEN
            l_parametro.valor := f_objeto_parse_json(par.valor_defecto,
                                                     par.formato);
          END IF;
        ELSE
          raise_application_error(-20000, 'Tipo de dato no soportado');
      END CASE;
    
      l_parametros.extend;
      l_parametros(l_parametros.count) := l_parametro;
    END LOOP;
    RETURN l_parametros;
  END;

  FUNCTION f_valor_parametro(i_parametros IN y_parametros,
                             i_nombre     IN VARCHAR2) RETURN anydata IS
    l_valor anydata;
    i       INTEGER;
  BEGIN
    -- Busca el par�metro en la lista
    i := i_parametros.first;
    WHILE i IS NOT NULL AND l_valor IS NULL LOOP
      IF lower(i_parametros(i).nombre) = lower(i_nombre) THEN
        l_valor := i_parametros(i).valor;
      END IF;
      i := i_parametros.next(i);
    END LOOP;
  
    -- Si el par�metro no se encuentra en la lista carga un valor nulo de tipo
    -- VARCHAR2 para evitar el error ORA-30625 al acceder al valor a trav�s de
    -- AnyData.Access*
    IF l_valor IS NULL THEN
      l_valor := anydata.convertvarchar2(NULL);
    END IF;
  
    RETURN l_valor;
  END;

  FUNCTION f_paginar_elementos(i_elementos           IN y_objetos,
                               i_numero_pagina       IN INTEGER DEFAULT NULL,
                               i_cantidad_por_pagina IN INTEGER DEFAULT NULL,
                               i_no_paginar          IN VARCHAR2 DEFAULT NULL)
    RETURN y_pagina IS
    l_pagina              y_pagina;
    l_objetos             y_objetos;
    l_numero_pagina       INTEGER;
    l_cantidad_por_pagina INTEGER;
    l_rango_i             INTEGER;
    l_rango_j             INTEGER;
    l_no_paginar          BOOLEAN;
  BEGIN
    -- Inicializa respuesta
    l_pagina                    := NEW y_pagina();
    l_pagina.numero_actual      := 0;
    l_pagina.numero_siguiente   := 0;
    l_pagina.numero_ultima      := 0;
    l_pagina.numero_primera     := 0;
    l_pagina.numero_anterior    := 0;
    l_pagina.cantidad_elementos := 0;
  
    l_no_paginar := nvl(i_no_paginar, 'N') = 'S';
  
    -- Carga la cantidad total de elementos
    l_pagina.cantidad_elementos := i_elementos.count;
    --
  
    -- Valida par�metro de cantidad por p�gina
    IF l_no_paginar THEN
      l_cantidad_por_pagina := l_pagina.cantidad_elementos;
    ELSE
      l_cantidad_por_pagina := nvl(i_cantidad_por_pagina,
                                   to_number(k_util.f_valor_parametro('PAGINACION_CANTIDAD_DEFECTO_POR_PAGINA')));
    END IF;
  
    IF l_cantidad_por_pagina <= 0 THEN
      l_cantidad_por_pagina := to_number(k_util.f_valor_parametro('PAGINACION_CANTIDAD_DEFECTO_POR_PAGINA'));
    END IF;
  
    IF NOT l_no_paginar AND
       l_cantidad_por_pagina >
       to_number(k_util.f_valor_parametro('PAGINACION_CANTIDAD_MAXIMA_POR_PAGINA')) THEN
      l_cantidad_por_pagina := to_number(k_util.f_valor_parametro('PAGINACION_CANTIDAD_MAXIMA_POR_PAGINA'));
    END IF;
    --
  
    -- Calcula primera p�gina y �ltima p�gina
    l_pagina.numero_ultima := ceil(l_pagina.cantidad_elementos /
                                   l_cantidad_por_pagina);
  
    IF l_pagina.numero_ultima > 0 THEN
      l_pagina.numero_primera := 1;
    END IF;
    --
  
    -- Valida par�metro de n�mero de p�gina
    l_numero_pagina := nvl(i_numero_pagina, 1);
  
    IF l_numero_pagina < l_pagina.numero_primera THEN
      l_numero_pagina := l_pagina.numero_primera;
    END IF;
  
    IF l_numero_pagina > l_pagina.numero_ultima THEN
      l_numero_pagina := l_pagina.numero_ultima;
    END IF;
    --
  
    -- Carga p�gina actual
    l_pagina.numero_actual := l_numero_pagina;
    --
  
    -- Calcula p�gina anterior y p�gina siguiente
    l_pagina.numero_anterior  := l_pagina.numero_actual - 1;
    l_pagina.numero_siguiente := l_pagina.numero_actual + 1;
  
    IF l_pagina.numero_anterior < l_pagina.numero_primera THEN
      l_pagina.numero_anterior := l_pagina.numero_primera;
    END IF;
  
    IF l_pagina.numero_siguiente > l_pagina.numero_ultima THEN
      l_pagina.numero_siguiente := l_pagina.numero_ultima;
    END IF;
    --
  
    -- Calcula el rango de elementos
    l_rango_i := ((l_pagina.numero_actual - 1) * l_cantidad_por_pagina) + 1;
    l_rango_j := l_pagina.numero_actual * l_cantidad_por_pagina;
  
    IF l_rango_i < 0 THEN
      l_rango_i := 0;
    END IF;
  
    IF l_rango_j > l_pagina.cantidad_elementos THEN
      l_rango_j := l_pagina.cantidad_elementos;
    END IF;
    --
  
    -- Carga elementos dentro del rango
    l_objetos := NEW y_objetos();
    IF l_pagina.cantidad_elementos > 0 THEN
      FOR i IN l_rango_i .. l_rango_j LOOP
        l_objetos.extend;
        l_objetos(l_objetos.count) := i_elementos(i);
      END LOOP;
    END IF;
    l_pagina.elementos := l_objetos;
    --
  
    RETURN l_pagina;
  END;

  FUNCTION f_procesar_servicio(i_id_servicio IN NUMBER,
                               i_parametros  IN CLOB) RETURN CLOB IS
    l_rsp CLOB;
  BEGIN
    -- Registra ejecuci�n
    lp_registrar_ejecucion(i_id_servicio);
    -- Procesa servicio
    l_rsp := lf_procesar_servicio(i_id_servicio, i_parametros).to_json;
    -- Registra log con datos de entrada y salida
    lp_registrar_log(i_id_servicio, i_parametros, l_rsp);
    RETURN l_rsp;
  END;

END;
/
