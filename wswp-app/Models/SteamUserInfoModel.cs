using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using GamePollApp.Services;
using GamePollApp.JsonTemplates.Steam;

namespace GamePollApp.Models
{
    public class SteamUserInfoModel
    {
        private readonly SteamAPIService _steamService;

        public Task Initialization;
        public string displayName { get; private set; }
        public string id { get; }
        public string profilePicUrl { get; private set; }
        public List<Friend> friendList { get; }
        public struct Friend
        {
            public Friend(string id, string profilePicUrl, string displayName) => (this.id, this.profilePicUrl, this.displayName) = (id, profilePicUrl, displayName);
            public string id { get; }
            public string profilePicUrl { get; }
            public string displayName { get; }
        }

        public SteamUserInfoModel(string User_ID, SteamAPIService steamService)
        {
            (this.id, _steamService) = (User_ID, steamService);
            friendList = new List<Friend>();

            Initialization = InitializeAsync();
        }

        private async Task InitializeAsync()
        {
            //Initialize Player info
            var playerSummaryJson = await _steamService.GetSteamPlayerSummaryAsync(id);
            displayName = playerSummaryJson.response.players[0].personaname;
            profilePicUrl = playerSummaryJson.response.players[0].avatar;

            //Establish Friend info
            var friendListJson = await _steamService.GetSteamFriendListAsync(id);
            List<string> friendIDs = new List<string>();

            foreach(var friend in friendListJson.friendslist.friends)
            {
                friendIDs.Add(friend.steamid);
            }

            var friendPlayerSummaryJsons = await _steamService.GetSteamPlayerSummaryAsync(friendIDs.ToArray());

            foreach(var friendPlayerSummaryJson in friendPlayerSummaryJsons)
            {
                foreach(var friendPlayerSummary in friendPlayerSummaryJson.response.players)
                {
                    friendList.Add(new Friend(friendPlayerSummary.steamid,
                                              friendPlayerSummary.avatar,
                                              friendPlayerSummary.personaname));
                }
            }

        }
    }
}
