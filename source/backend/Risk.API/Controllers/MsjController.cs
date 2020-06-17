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

using System.Net.Mime;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Risk.API.Attributes;
using Risk.API.Models;
using Risk.API.Services;
using Swashbuckle.AspNetCore.Annotations;

namespace Risk.API.Controllers
{
    [SwaggerTag("Servicios del dominio MENSAJERÍA", "https://jtsoya539.github.io/risk/")]
    [Authorize(Roles = "ADMINISTRADOR,USUARIO")]
    [Route("Api/[controller]")]
    [ApiController]
    public class MsjController : RiskControllerBase
    {
        private readonly IMsjService _msjService;
        private readonly IConfiguration _configuration;

        public MsjController(IMsjService msjService, IConfiguration configuration)
        {
            _msjService = msjService;
            _configuration = configuration;
        }

        [HttpPost("CambiarEstadoMensaje")]
        [SwaggerOperation(OperationId = "CambiarEstadoMensaje", Summary = "CambiarEstadoMensaje", Description = "Permite cambiar el estado de un mensaje de texto (SMS)")]
        [Consumes(MediaTypeNames.Application.Json)]
        [Produces(MediaTypeNames.Application.Json)]
        [SwaggerResponse(StatusCodes.Status200OK, "Operación exitosa", typeof(Respuesta<Dato>))]
        [SwaggerResponse(StatusCodes.Status400BadRequest, "Operación con error", typeof(Respuesta<Dato>))]
        [SwaggerResponse(StatusCodes.Status500InternalServerError, "Error inesperado", typeof(Respuesta<Dato>))]
        [SwaggerResponse(StatusCodes.Status501NotImplemented, "Servicio no implementado o inactivo", typeof(Respuesta<Dato>))]
        public IActionResult CambiarEstadoMensaje([FromBody] CambiarEstadoMensajeRequestBody requestBody)
        {
            var respuesta = _msjService.CambiarEstadoMensaje(requestBody.IdMensaje, requestBody.Estado, requestBody.RespuestaEnvio);
            return ProcesarRespuesta(respuesta);
        }
    }
}