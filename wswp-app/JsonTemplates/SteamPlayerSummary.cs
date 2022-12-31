using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GamePollApp.JsonTemplates.Steam
{
   
    public class SteamPlayerSummary_ResponseJson
    {
        public SteamPlayerSummary_PlayerListJson response { get; set; }
    }
    public class SteamPlayerSummary_PlayerListJson
    {
        public List<SteamPlayerSummary_PlayerJson> players { get; set; }
    }

    public class SteamPlayerSummary_PlayerJson
    {
        public string steamid { get; set; }
        public int communityvisibilitystate { get; set; }
        public int profilestate { get; set; }
        public string personaname { get; set; }
        public string profileurl { get; set; }
        public string avatar { get; set; }
        public string avatarmedium { get; set; }
        public string avatarfull { get; set; }
        public string avatarhash { get; set; }
        public string lastlogoff { get; set; }
        public int personastate { get; set; }
        public string realname { get; set; }
        public string primaryclanid { get; set; }
        public string timecreated { get; set; }
        public int personastateflags { get; set; }
    }
}
