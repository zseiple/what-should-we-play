using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using GamePollApp.Models;

namespace GamePollApp.JsonTemplates.Authentication
{
    public class AuthenticationDetails_JsonResponse
    {
        public bool isAuthenticated { get; set; }
        public SteamUserInfo_JsonResponse userDetails { get; set; }
    }

    public class SteamUserInfo_JsonResponse
    {
        public string displayName { get; set; }
        public string id { get; set; }
        public string profilePicUrl { get; set; }
        public List<SteamUserInfoModel.Friend> friendList { get; set; }
    }
}
