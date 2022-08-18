using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GamePollApp.JsonTemplates.Steam
{
    public class SteamPlayersAndGames_ResponseJson 
    {
        public SteamPlayersAndGames_ResponseJson()
        {
            players = new List<SteamPlayersAndGames_LinkJson>();
        }

        public List<SteamPlayersAndGames_LinkJson> players { get; set; }

       /*public IEnumerator<SteamPlayersAndGames_LinkJson> GetEnumerator()
        {
           foreach(SteamPlayersAndGames_LinkJson player in players)
            {
                yield return player;
            }
        }*/

    }

    public class SteamPlayersAndGames_LinkJson
    {
        public SteamPlayersAndGames_LinkJson(string id, SteamGetOwnedGames_OverallGameJson games)
        {
            this.id = id;
            this.gameLibrary = games;
        }

        public string id { get; set; }
        public SteamGetOwnedGames_OverallGameJson gameLibrary { get; set; }

    }
}
