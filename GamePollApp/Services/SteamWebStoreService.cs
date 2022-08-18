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
    public class SteamWebStoreService
    {
        private readonly HttpClient Client;

        public const string STOREPAGE_URL_BASE = "https://store.steampowered.com/app/";

        public SteamWebStoreService(HttpClient client)
        {
            client.BaseAddress = new Uri("https://store.steampowered.com/app/");

            Client = client;
        }


        public async Task<string> GetStorePageHTML(string app_id)
        {
            var response = await Client.SendAsync(new HttpRequestMessage(HttpMethod.Get, app_id));
            string htmlPage;

            if (response.IsSuccessStatusCode)
            {
                htmlPage = await response.Content.ReadAsStringAsync();
            }
            else
            {
                throw new Exception("[SteamWebStoreService] Request to get Steam Store page has failed.");
            }

            return htmlPage;
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
