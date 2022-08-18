using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GamePollApp.JsonTemplates.Steam
{
    public class SteamGetFriendList_ResponseJson
    {
        public SteamGetFriendList_FriendsJson friendslist { get; set; }
    }

    public class SteamGetFriendList_FriendsJson
    {
        public List<SteamGetFriendList_FriendEntryJson> friends {get; set;}
    }

    public class SteamGetFriendList_FriendEntryJson
    {
        public string steamid { get; set; }
        public string relationship { get; set; }
        public string friend_since { get; set; }
    }
}
