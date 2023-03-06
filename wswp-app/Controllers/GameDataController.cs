using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using GamePollApp.Services;
using GamePollApp.JsonTemplates.Steam;
using GamePollApp.JsonTemplates.GameData;
using Newtonsoft.Json;
using System.Net.Http;
using HtmlAgilityPack;
using System.IO;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Hosting;

namespace GamePollApp.Controllers
{
    [ApiController]
    [Route("api/gamedata")]
    public class GameDataController : Controller
    {
        private readonly ILogger<GameDataController> _logger;
        private readonly IWebHostEnvironment _webHostEnvironment;
        private readonly SteamAPIService _steamService;
        private readonly SteamWebStoreService _steamWebService;

        /*[08/04/2022] You implemented a metric fuckton just to scalp the steam store page and determine whether a game is multiplayer or
         * not and return a json that specifies the kind of multiplayer a game supports. However you were unable to test it because the
         * file path of the multiplayer-tags file was not able to be found, read, and assigned to multiplayer tags variable. Figure out
         * how to obtain a file path for a file in this ASP .NET Core / React project */
        private string multiplayerTagsFilePath = "ClientApp/public/config/multiplayer-tags.csv";
        private readonly string[] multiplayerTags;
        private static readonly Regex spacesAndDashes = new Regex(@"(\s+|-+)");



        public GameDataController(ILogger<GameDataController> logger, IWebHostEnvironment webHostEnvironment, SteamAPIService steamService, SteamWebStoreService steamWebService)
        {
            _logger = logger;
            _webHostEnvironment = webHostEnvironment;
            _steamService = steamService;
            _steamWebService = steamWebService;

            System.Diagnostics.Debug.WriteLine($"CONTENTROOTPATH: {_webHostEnvironment.ContentRootPath}");

            multiplayerTagsFilePath = Path.Combine(_webHostEnvironment.ContentRootPath, multiplayerTagsFilePath);

            if (System.IO.File.Exists(multiplayerTagsFilePath))
            {
                multiplayerTags = System.IO.File.ReadAllText(multiplayerTagsFilePath).Split(',');
                System.Diagnostics.Debug.WriteLine($"MULTIPLAYER TAG FILE FOUND :) \nPath Found: {multiplayerTagsFilePath}");
            }
            else
                System.Diagnostics.Debug.WriteLine($"MULTIPLAYER TAG FILE NOT FOUND :( \nPath Found: {multiplayerTagsFilePath}");
        }


        [HttpGet("get-owned-games")]
        public async Task<IActionResult> GamesOwned([FromQuery] string[] ids)
        {
            //Create a single JSON response
            SteamPlayersAndGames_ResponseJson unserializedResponse = new SteamPlayersAndGames_ResponseJson();

            //Get owned games from steam API
            foreach(string current_id in ids)
            {
                var games = await _steamService.GetOwnedGamesAsync(current_id);

                unserializedResponse.players.Add(new SteamPlayersAndGames_LinkJson(current_id, games.response));
            }

            //Done, serialize the response and return
            return Ok(JsonConvert.SerializeObject(unserializedResponse));

        }

        //NEED TO REFORMAT THIS FUNCTION TO WORK IN BATCHES & stop being lazy & do the AWS DynamoDB implementation :/
        //...after all this time... i did it
        [HttpGet("check-multiplayer")]
        public async Task<IActionResult> CheckMultiplayerSupport([FromQuery] string[] appids)
        {
            
            const int BATCH_SIZE = 100;
            List<int> batch = new List<int>();

        //Need to figure out how to call the AWS API gateway and then we're golden... so close to front-end development :)



            return Ok();
        }

    }
}
