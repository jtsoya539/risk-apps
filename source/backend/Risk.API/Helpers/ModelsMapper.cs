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

using System.Collections.Generic;
using Risk.API.Entities;
using Risk.API.Models;

namespace Risk.API.Helpers
{
    public class ModelsMapper
    {
        public static YDispositivo GetYDispositivoFromModel(Dispositivo model)
        {
            YDispositivo entity;
            if (model == null)
            {
                entity = null;
            }
            else
            {
                entity = new YDispositivo
                {
                    IdDispositivo = model.IdDispositivo,
                    TokenDispositivo = model.TokenDispositivo,
                    NombreSistemaOperativo = model.NombreSistemaOperativo,
                    VersionSistemaOperativo = model.VersionSistemaOperativo,
                    Tipo = model.Tipo,
                    NombreNavegador = model.NombreNavegador,
                    VersionNavegador = model.VersionNavegador,
                    TokenNotificacion = model.TokenNotificacion
                };
            }
            return entity;
        }

        public static YArchivo GetYArchivoFromModel(Archivo model)
        {
            YArchivo entity;
            if (model == null)
            {
                entity = null;
            }
            else
            {
                entity = new YArchivo
                {
                    Contenido = model.Contenido,
                    Checksum = model.Checksum,
                    Tamano = model.Tamano,
                    Nombre = model.Nombre,
                    Extension = model.Extension
                };
            }
            return entity;
        }
    }
}