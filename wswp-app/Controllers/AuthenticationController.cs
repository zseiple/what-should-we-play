using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Mvc.Client.Extensions;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;

using GamePollApp.JsonTemplates.Authentication;
using GamePollApp.Services;
using GamePollApp.Models;
using Newtonsoft.Json;
using System.Security.Claims;
using System.Net.Http;
using System.Net.Http.Json;
using Microsoft.Extensions.Logging;

namespace GamePollApp.Controllers
{
    [ApiController]
    [Route("api/authenticate")]
    public class AuthenticationController : Controller
    {
        private readonly ILogger<AuthenticationController> _logger;
        private readonly SteamAPIService _steamService;

        public AuthenticationController(ILogger<AuthenticationController> logger, SteamAPIService steamService)
        {
            _logger = logger;
            _steamService = steamService;
        }

        [HttpGet("~/signin")]
        public async Task<IActionResult> SignIn() {
           
            string provider = Array.Find(await HttpContext.GetExternalProvidersAsync(), providerAuthenticationScheme => providerAuthenticationScheme.DisplayName.Equals("Steam")).DisplayName; 
            
            if(string.IsNullOrWhiteSpace(provider))
            {
                return BadRequest();
            }

            if(!await HttpContext.IsProviderSupportedAsync(provider))
            {
                return BadRequest();
            }
            return Challenge(new AuthenticationProperties { RedirectUri = "/" }, provider);
        }

        [HttpGet("~/signout")]
        public IActionResult SignOutCurrentUser()
        {
            return SignOut(new AuthenticationProperties { RedirectUri = "/" }, JwtBearerDefaults.AuthenticationScheme);
        }

        [HttpGet]
        public async Task<IActionResult> GetIdentity()
        {
            AuthenticationDetails_JsonResponse response = new AuthenticationDetails_JsonResponse();
            response.isAuthenticated = User?.Identity?.IsAuthenticated ?? false;
            System.Diagnostics.Debug.WriteLine("AuthenticationController: Executing Get Request");

            if (response.isAuthenticated)
            {
                var steamID = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier).Value;
                SteamUserInfoModel userInfoModel = new SteamUserInfoModel(steamID.Split('/')[^1], _steamService);
                //Wait for all user info to be fetched before loading the page
                await userInfoModel.Initialization;

                SteamUserInfo_JsonResponse userDetails = new SteamUserInfo_JsonResponse();
                userDetails.displayName = userInfoModel.displayName;
                userDetails.id = userInfoModel.id;
                userDetails.profilePicUrl = userInfoModel.profilePicUrl;
                userDetails.friendList = userInfoModel.friendList;

                response.userDetails = userDetails;
            }
            else
            {
                response.userDetails = null;
            }


            return Ok(JsonConvert.SerializeObject(response));

        }
    }
}
