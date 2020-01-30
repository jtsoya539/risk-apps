using System.Data;
using System.Reflection;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using Risk.API.Entities;

namespace Risk.API.Services
{
    public class AuthService : ServiceBase, IAuthService
    {
        private const string SQL_API_VALIDAR_CREDENCIALES = "K_SERVICIO.API_VALIDAR_CREDENCIALES";
        private const string SQL_API_INICIAR_SESION = "K_SERVICIO.API_INICIAR_SESION";
        private const string SQL_API_FINALIZAR_SESION = "K_SERVICIO.API_FINALIZAR_SESION";

        public AuthService(RiskDbContext dbContext, IConfiguration configuration) : base(dbContext, configuration)
        {
        }

        public YRespuesta ApiFinalizarSesion(string token)
        {
            base.SetApplicationContext(MethodBase.GetCurrentMethod().DeclaringType.Name, MethodBase.GetCurrentMethod().Name);
            string respuesta = null;
            if (token != null)
            {
                OracleConnection con = GetOracleConnection();

                using (OracleCommand cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = SQL_API_FINALIZAR_SESION;
                    cmd.BindByName = true;

                    OracleParameter return_value = new OracleParameter("return_value", OracleDbType.Clob, ParameterDirection.ReturnValue);
                    cmd.Parameters.Add(return_value);
                    OracleParameter i_token = new OracleParameter("i_token", OracleDbType.Varchar2, token, ParameterDirection.Input);
                    cmd.Parameters.Add(i_token);

                    cmd.ExecuteNonQuery();

                    respuesta = ((OracleClob)cmd.Parameters["return_value"].Value).Value;

                    return_value.Dispose();
                    i_token.Dispose();
                    con.Close();
                }
            }
            return JsonConvert.DeserializeObject<YRespuesta>(respuesta);
        }

        public YRespuesta ApiIniciarSesion(string usuario, string token)
        {
            throw new System.NotImplementedException();
        }

        public YRespuesta ApiValidarCredenciales(string usuario, string clave)
        {
            throw new System.NotImplementedException();
        }
    }

}
