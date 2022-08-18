using GamePollApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using GamePollApp.Services;

namespace GamePollApp.Controllers
{

    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly SteamAPIService _steamService;

        public HomeController(ILogger<HomeController> logger, SteamAPIService steamService)
        {
            _logger = logger;
            _steamService = steamService;
        }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            /*if(User?.Identity?.IsAuthenticated ?? false)
            {
                var steamID = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier).Value;

                SteamUserInfoModel userInfoModel = new SteamUserInfoModel(steamID.Split('/')[^1], _steamService);
                //Wait for all user info to be fetched before loading the page
                await userInfoModel.Initialization;
                return View(userInfoModel);
            }*/

            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }


        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
