using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GamePollApp.JsonTemplates.Steam
{
    public class SteamGetOwnedGames_ResponseJson
    {
        public SteamGetOwnedGames_OverallGameJson response { get; set; }
    }

    public class SteamGetOwnedGames_OverallGameJson 
    {
        [JsonProperty("game_count")]
        public int game_count { get; set; }
        [JsonProperty("games")]
        public List<SteamGetOwnedGames_GameJson> games { get; set; }
    }

    public class SteamGetOwnedGames_GameJson
    {
        [JsonProperty("appid")]
        public string appid { get; set; }

        [JsonProperty("name")]
        public string name { get; set; }

        [JsonProperty("playtime_forever")]
        public int playtime_forever { get; set; }

        [JsonProperty("img_icon_url")]
        public string img_icon_url { get; set; }

        [JsonProperty("playtime_windows_forever")]
        public int playtime_windows_forever { get; set; }

        [JsonProperty("playtime_mac_forever")]
        public int playtime_mac_forever { get; set; }

        [JsonProperty("playtime_linux_forever")]
        public int playtime_linux_forever { get; set; }

        [JsonProperty("has_community_visible_stats")]
        public bool has_community_visible_stats { get; set; }

        public override bool Equals(object obj)
        {
            return this.appid == ((SteamGetOwnedGames_GameJson)obj).appid;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(appid, name);
        }
    }

}
