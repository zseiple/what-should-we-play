import { useState, useEffect, useRef } from 'react';

export function MinPlayersOwned({ addFilter, onUpdateParams, numPlayers }) {

    const [ownedByAllChecked, setOwnedByAllChecked] = useState(true);
    const [minPlayersOwned, setMinPlayersOwned] = useState(1);
    const minPlayersOwnedRef = useRef();

    minPlayersOwnedRef.current = minPlayersOwned;

    //Add by default
    useEffect(function initialize() {
        addFilter(minPlayersOwnedFilter);
        document.querySelector("#min-players-owned-container").style.display = "none";
    }, []);

    useEffect(function onParamUpdate() {
        onUpdateParams()
    }, [minPlayersOwned]);

    const minPlayersOwnedFilter = (playersGameData) => {

        console.log("minPlayerOwnedFilter Starting value");
        console.log(playersGameData);
        //Structure { appid: {playersOwned: #, playerIds[id1, id2, etc]}}
        let gameOwnersDictionary = {};
        const createGameOwnerDetails = () => ({ playersOwned: 0, playerIds: [] });

        //Count games and add them to dictionary
        for (const player of playersGameData.players) {
            for (const game of player.gameLibrary.games) {
                if (!(game.appid in gameOwnersDictionary)) {
                    //console.log(`App ID ${game.appid} not found in dict, adding now`);
                    gameOwnersDictionary[game.appid] = createGameOwnerDetails();
                }

                gameOwnersDictionary[game.appid].playersOwned++;
                gameOwnersDictionary[game.appid].playerIds.push(player.id)
            }
        }
        console.log("Game Owners Dict before delete");
        console.log(gameOwnersDictionary);

        //Delete games that don't have enough players owning them, needs to be nested in set statement since attached to event
        for (let appid in gameOwnersDictionary) {
            if (gameOwnersDictionary[appid].playersOwned < minPlayersOwnedRef.current)
                delete gameOwnersDictionary[appid];
        }

        console.log(`freshMinPlayersOwned: ${minPlayersOwnedRef.current}`);


        console.log(`Post delete (only games with ${minPlayersOwnedRef.current} players):`);
        console.log(gameOwnersDictionary);

        //Filter each players gameLibrary down to those in gameOwnersDictionary
        for (let player of playersGameData.players) {
            console.log(`games count before filter: ${player.gameLibrary.games.length}`);
            player.gameLibrary.games = player.gameLibrary.games.filter(game => game.appid in gameOwnersDictionary);
            console.log(`games count after filter: ${player.gameLibrary.games.length}`);
        }

        console.log("minPlayersOwnedFilter final result");
        console.log(playersGameData);

        return playersGameData;

    }

    const handleCheck = () => {
        setOwnedByAllChecked(isChecked => {
            isChecked = !isChecked;
            if (!isChecked) {
                document.querySelector("#min-players-owned-container").style.display = "block";
                setMinPlayersOwned(document.querySelector("#min-players-owned").value);
            }
            if (isChecked) {
                document.querySelector("#min-players-owned-container").style.display = "none";
                setMinPlayersOwned(document.querySelector("#owned-by-all-checkbox").value);
            }

            return isChecked;
        });
        
    }

    const handleNumberChange = () => {
        setMinPlayersOwned(document.querySelector("#min-players-owned").value);
    }

    //Render
    return (
        <form id="minplayersowned-options">
            <div id="owned-by-count">
                <input type="checkbox" id="owned-by-all-checkbox" name="owned-by-all" value={numPlayers} onChange={handleCheck} checked={ownedByAllChecked} />
                <label for="owned-by-all">Owned By Everyone</label>
                <div id="min-players-owned-container">
                    <label for="min-players-owned">Owned By:</label>
                    <input type="number" id="min-players-owned" name="min-players-owned" min="1" max={numPlayers} onChange={handleNumberChange}/>
                </div>
            </div>
        </form>
        );
}