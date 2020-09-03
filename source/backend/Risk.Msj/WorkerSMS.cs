using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Risk.API.Client.Model;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;

namespace Risk.Msj
{
    public class WorkerSMS : BackgroundService
    {
        private readonly ILogger<WorkerSMS> _logger;
        private readonly IConfiguration _configuration;

        // Risk Configuration
        private readonly IRiskAPIClientConnection _riskAPIClientConnection;

        // Twilio Configuration
        private string phoneNumberFrom;

        public WorkerSMS(ILogger<WorkerSMS> logger, IConfiguration configuration, IRiskAPIClientConnection riskAPIClientConnection)
        {
            _logger = logger;
            _configuration = configuration;

            // Risk Configuration
            _riskAPIClientConnection = riskAPIClientConnection;
        }

        // Twilio Configuration
        private void Configurar()
        {
            phoneNumberFrom = _configuration["TwilioConfiguration:PhoneNumberFrom"];

            TwilioClient.Init(_configuration["TwilioConfiguration:AccountSid"], _configuration["TwilioConfiguration:AuthToken"]);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                if (_configuration.GetValue<bool>("EnableSMS") && _riskAPIClientConnection.MensajeriaActiva)
                {
                    _logger.LogInformation($"WorkerSMS running at: {DateTimeOffset.Now}");

                    var mensajes = _riskAPIClientConnection.ListarMensajesPendientes();

                    if (mensajes.Any())
                    {
                        // Twilio Configuration
                        Configurar();

                        foreach (var item in mensajes)
                        {
                            try
                            {
                                var message = MessageResource.Create(
                                    from: new PhoneNumber(phoneNumberFrom),
                                    to: new PhoneNumber(item.NumeroTelefono),
                                    body: item.Contenido
                                );

                                // Cambia estado de la mensajería a E-ENVIADO
                                _riskAPIClientConnection.CambiarEstadoMensajeria(TipoMensajeria.SMS, item.IdMensaje, EstadoMensajeria.Enviado, JsonConvert.SerializeObject(message));
                            }
                            catch (Twilio.Exceptions.ApiException e)
                            {
                                // Cambia estado de la mensajería a R-PROCESADO CON ERROR
                                _riskAPIClientConnection.CambiarEstadoMensajeria(TipoMensajeria.SMS, item.IdMensaje, EstadoMensajeria.ProcesadoError, e.Message);
                            }
                        }
                    }
                }

                await Task.Delay(TimeSpan.FromSeconds(_configuration.GetValue<double>("ExecuteDelaySeconds")), stoppingToken);
            }
        }
    }
}