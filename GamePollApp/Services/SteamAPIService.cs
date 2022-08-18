using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using GamePollApp.JsonTemplates.Steam;
using GamePollApp.Extensions.Array;
using System.Text.RegularExpressions;

namespace GamePollApp.Services
{
    public class SteamAPIService
    {
        private readonly HttpClient Client;

        public const int PLAYERSUMMARY_MAX_ID_COUNT = 100;
        public const string STOREPAGE_URL_BASE = "https://store.steampowered.com/app/";

        public SteamAPIService(HttpClient client)
        {
            client.BaseAddress = new Uri("http://api.steampowered.com/");
            client.DefaultRequestHeaders.Add("x-webapi-key", "580BB521A741E7C62074F007668E9E2A");

            Client = client;
        }

        //http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=580BB521A741E7C62074F007668E9E2A&steamid=76561198047893995&include_appinfo=1&include_played_free_games=1&format=json

        public async Task<SteamPlayerSummary_ResponseJson> GetSteamPlayerSummaryAsync(string steam_id)
        {
            return await SendSteamAPIRequestWithParamsAsync<SteamPlayerSummary_ResponseJson>(
                "/ISteamUser/GetPlayerSummaries/v0002/",
                new KeyValuePair<string, string>[]
                {
                    new KeyValuePair<string,string>("steamids", steam_id),
                    new KeyValuePair<string, string>("format", "json")
                });
        }

        /// <summary>
        /// Makes calls to Steam GetPlayerSummaries API in batches of fixed size (PLAYERSUMMARY_MAX_ID_COUNT) using an Array of string Steam IDs and returns a JSON response
        /// </summary>
        /// <param name="steam_ids">The Steam IDs to get Player Summaries for</param>
        /// <returns>A C# SteamPlayerSummary_ResponseJson Object representation of the response JSON</returns>
        public async Task<SteamPlayerSummary_ResponseJson[]> GetSteamPlayerSummaryAsync(string[] steam_ids)
        {
            List<SteamPlayerSummary_ResponseJson> result = new List<SteamPlayerSummary_ResponseJson>();

            //Send requests in batches with a maximum of PLAYERSUMMARY_MAX_ID_COUNT
            for (var i = 0; i < MathF.Ceiling(steam_ids.Length / (float) PLAYERSUMMARY_MAX_ID_COUNT); i++)
            {

                var steam_id_input = String.Join(',', 
                    steam_ids.Splice(i * PLAYERSUMMARY_MAX_ID_COUNT, 
                                     Math.Min(steam_ids.Length - i * PLAYERSUMMARY_MAX_ID_COUNT, PLAYERSUMMARY_MAX_ID_COUNT)));

                result.Add(await SendSteamAPIRequestWithParamsAsync<SteamPlayerSummary_ResponseJson>(
                "/ISteamUser/GetPlayerSummaries/v0002/",
                new KeyValuePair<string, string>[]
                {
                    new KeyValuePair<string,string>("steamids", steam_id_input),
                    new KeyValuePair<string, string>("format", "json")
                }));
            }

            return result.ToArray();
        }

        public async Task<SteamGetFriendList_ResponseJson> GetSteamFriendListAsync(string steam_id)
        {
            return await SendSteamAPIRequestWithParamsAsync<SteamGetFriendList_ResponseJson>(
                "/ISteamUser/GetFriendList/v0001/",
                new KeyValuePair<string, string>[] 
                {
                    new KeyValuePair<string,string>("steamid", steam_id),
                    new KeyValuePair<string, string>("relationship", "friend"),
                    new KeyValuePair<string, string>("format", "json")
                });

        }

        public async Task<SteamGetOwnedGames_ResponseJson> GetOwnedGamesAsync(string steam_id, string[] filterArray = null, string include_appinfo = "1", string include_free = "1")
        {
            var args = new KeyValuePair<string, string>[]
            {
                    new KeyValuePair<string,string>("steamid", steam_id),
                    new KeyValuePair<string,string>("include_appinfo", include_appinfo),
                    new KeyValuePair<string,string>("include_played_free_games", include_free),
                    new KeyValuePair<string,string>("format", "json")
            };

            if (filterArray != null)
            {
                args.Append(new KeyValuePair<string, string>("input_json",
                    JsonConvert.DeserializeObject("{ appid_filter: [" + string.Join(',', filterArray) + "]}").ToString()));
            }

            return await SendSteamAPIRequestWithParamsAsync<SteamGetOwnedGames_ResponseJson>("/IPlayerService/GetOwnedGames/v0001/", args);
        }


        /// <summary>
        /// Generic function for sending an API call to various Steam APIs
        /// </summary>
        /// <typeparam name="T">The JSON Template Class expected on return</typeparam>
        /// <param name="apiExtension">The extension of the needed API</param>
        /// <param name="paramNameValuePairs">Parameters for API request in the form <"param name", "value">></param>
        /// <returns></returns>
        private async Task<T> SendSteamAPIRequestWithParamsAsync<T>(string apiExtension, params KeyValuePair<string, string>[] paramNameValuePairs)
        {
            string callPath = apiExtension + "?";
            for (int i = 0; i < paramNameValuePairs.Length; i++)
            {
                    callPath = String.Concat(callPath, 
                                  paramNameValuePairs[i].Key,"=",paramNameValuePairs[i].Value,
                                  (i != paramNameValuePairs.Length - 1 ? "&":""));
                
            }

            Console.WriteLine("CALL PATH: " + callPath);

            var response = await Client.SendAsync(new HttpRequestMessage(HttpMethod.Get, callPath));
            response.EnsureSuccessStatusCode();

            var stringResponse = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<T>(stringResponse);
        }
    }
}
