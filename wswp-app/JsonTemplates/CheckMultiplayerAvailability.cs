using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GamePollApp.JsonTemplates.GameData
{
    public class CheckMultiplayerAvailability_ResponseJson
    {
        public CheckMultiplayerAvailability_ResponseJson(bool multiplayerAvailable, 
            bool onlineCoop = false, 
            bool onlinePvP  = false, 
            bool lanCoop    = false, 
            bool lanPvP     = false)
        {
            this.multiplayerAvailable = multiplayerAvailable;
            this.multiplayerTypes = new CheckMultiplayerAvailability_MultiplayerTypesJson(onlineCoop, onlinePvP, lanCoop, lanPvP);
        }

        public bool multiplayerAvailable { get; set; }
        public CheckMultiplayerAvailability_MultiplayerTypesJson multiplayerTypes { get; set; }
    }

    public class CheckMultiplayerAvailability_MultiplayerTypesJson
    {
        public CheckMultiplayerAvailability_MultiplayerTypesJson(bool onlineCoop, bool onlinePvP, bool lanCoop, bool lanPvP)
        {
            this.onlineCoop = onlineCoop;
            this.onlinePvP = onlinePvP;
            this.lanCoop = lanCoop;
            this.lanPvP = lanPvP;
        }

        public bool onlineCoop { get; set; }
        public bool onlinePvP { get; set; }
        public bool lanCoop { get; set; }
        public bool lanPvP { get; set; }
    }
}
