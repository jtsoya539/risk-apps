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

using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Risk.API.Entities;
using Risk.API.Helpers;
using Risk.API.Models;

namespace Risk.API.Services
{
    public class GenService : ServiceBase, IGenService
    {
        private const int ID_VALOR_PARAMETRO = 8;
        private const int ID_SIGNIFICADO_CODIGO = 9;
        private const int ID_VERSION_SISTEMA = 13;
        private const int ID_LISTAR_PAISES = 16;
        private const int ID_RECUPERAR_ARCHIVO = 18;
        private const int ID_GUARDAR_ARCHIVO = 19;

        public GenService(RiskDbContext dbContext, IConfiguration configuration) : base(dbContext, configuration)
        {
        }

        public Respuesta<Dato> VersionSistema()
        {
            JObject prms = new JObject();

            string rsp = base.ApiProcesarServicio(ID_VERSION_SISTEMA, prms.ToString(Formatting.None));
            var entityRsp = JsonConvert.DeserializeObject<YRespuesta<YDato>>(rsp);

            return EntitiesMapper.GetRespuestaFromEntity<Dato, YDato>(entityRsp, EntitiesMapper.GetDatoFromEntity(entityRsp.Datos));
        }

        public Respuesta<Dato> ValorParametro(string parametro)
        {
            JObject prms = new JObject();
            prms.Add("parametro", parametro);

            string rsp = base.ApiProcesarServicio(ID_VALOR_PARAMETRO, prms.ToString(Formatting.None));
            var entityRsp = JsonConvert.DeserializeObject<YRespuesta<YDato>>(rsp);

            return EntitiesMapper.GetRespuestaFromEntity<Dato, YDato>(entityRsp, EntitiesMapper.GetDatoFromEntity(entityRsp.Datos));
        }

        public Respuesta<Dato> SignificadoCodigo(string dominio, string codigo)
        {
            JObject prms = new JObject();
            prms.Add("dominio", dominio);
            prms.Add("codigo", codigo);

            string rsp = base.ApiProcesarServicio(ID_SIGNIFICADO_CODIGO, prms.ToString(Formatting.None));
            var entityRsp = JsonConvert.DeserializeObject<YRespuesta<YDato>>(rsp);

            return EntitiesMapper.GetRespuestaFromEntity<Dato, YDato>(entityRsp, EntitiesMapper.GetDatoFromEntity(entityRsp.Datos));
        }

        public Respuesta<Pagina<Pais>> ListarPaises(int? idPais = null)
        {
            JObject prms = new JObject();
            prms.Add("id_pais", idPais);

            string rsp = base.ApiProcesarServicio(ID_LISTAR_PAISES, prms.ToString(Formatting.None));
            var entityRsp = JsonConvert.DeserializeObject<YRespuesta<YPagina<YPais>>>(rsp);

            Pagina<Pais> datos = null;
            if (entityRsp.Datos != null)
            {
                datos = EntitiesMapper.GetPaginaFromEntity<Pais, YPais>(entityRsp.Datos, EntitiesMapper.GetPaisListFromEntity(entityRsp.Datos.Elementos));
            }

            return EntitiesMapper.GetRespuestaFromEntity<Pagina<Pais>, YPagina<YPais>>(entityRsp, datos);
        }

        public Respuesta<Archivo> RecuperarArchivo(string tabla, string campo, string referencia)
        {
            JObject prms = new JObject();
            prms.Add("tabla", tabla);
            prms.Add("campo", campo);
            prms.Add("referencia", referencia);

            string rsp = base.ApiProcesarServicio(ID_RECUPERAR_ARCHIVO, prms.ToString(Formatting.None));
            var entityRsp = JsonConvert.DeserializeObject<YRespuesta<YArchivo>>(rsp);

            return EntitiesMapper.GetRespuestaFromEntity<Archivo, YArchivo>(entityRsp, EntitiesMapper.GetArchivoFromEntity(entityRsp.Datos));
        }

        public Respuesta<Dato> GuardarArchivo(string tabla, string campo, string referencia, Archivo archivo)
        {
            JObject prms = new JObject();
            prms.Add("tabla", tabla);
            prms.Add("campo", campo);
            prms.Add("referencia", referencia);
            prms.Add("archivo", JToken.FromObject(ModelsMapper.GetYArchivoFromModel(archivo)));

            string rsp = base.ApiProcesarServicio(ID_GUARDAR_ARCHIVO, prms.ToString(Formatting.None));
            var entityRsp = JsonConvert.DeserializeObject<YRespuesta<YDato>>(rsp);

            return EntitiesMapper.GetRespuestaFromEntity<Dato, YDato>(entityRsp, EntitiesMapper.GetDatoFromEntity(entityRsp.Datos));
        }
    }
}
