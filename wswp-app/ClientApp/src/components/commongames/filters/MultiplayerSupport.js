import { useState, useEffect } from 'react';
import { cloneDeep } from 'lodash';

export function MultiplayerSupport({ addFilter, onUpdateParams }) {

    const [multiplayerOptions, setMultiplayerOptions] = useState({});
    const [multiplayerSupportByAppID, setMultiplayerSupportByAppID] = useState({});

    useEffect(function initialize() {


        fetch("api/gamedata/get-all-multiplayer-tags")
            .then(response => response.json())
            .then(json => {
                setMultiplayerOptions(json);
            })
            .then(() => { addFilter(multiplayerSupport) })
            .catch(err => console.log(`Error in call to api/gamedata/get-all-multiplayer-tags: ${err}`));
    }, []);

    const multiplayerSupport = async(playersGameData) => {
        //Check for support, return list that meets control specifications

        console.log("Checking for Multiplayer Support");

        //Generate list from each players game library based on games passed in
        let gameDict = {};
        for (const player of playersGameData.players) {
            for (const game of player.gameLibrary.games) {
                if (!(game.appid in gameDict))
                    gameDict[game.appid] = multiplayerOptions;
            }
        }

        //For now i'm going to have this check the request every single session and store in state, which is kind of ass. will need to cache support info for games somewhere
        for (const appid in gameDict) {

            //Check if multiplayer support for the game is already stored in state
            if (appid in multiplayerSupportByAppID) {
                gameDict[appid] = { ...multiplayerSupportByAppID[appid] };
                continue;
            }

            //Miss, need to call api and add result to state
            console.log(`Calling api/gamedata/check-multiplayer?appid=${appid}`)

            fetch(`api/gamedata/check-multiplayer?appid=${appid}`)
                .then(response => response.json())
                .then(json => {
                    gameDict[appid] = { ...json };
                    setMultiplayerSupportByAppID(freshState => {
                        let newValue = cloneDeep(freshState);
                        newValue[appid] = { ...json };
                    })
                });
        }

        //Now need to filter based on selected options

        console.log("Done checking for multiplayer support");

        return playersGameData;
    }


    //Generate Checkboxes for user to control this filter
    const generateOptions = function () {
        let resultOptions = []

        for (const tag in multiplayerOptions) {
            resultOptions.push((
                <div>
                    <label for={tag}>{tag}</label>
                    <input name={tag} type="checkbox" />
                </div>))
        }

        return resultOptions;
    }

    //Render
    return (
        <form id="multiplayersupport-options">
            <div>
                <h2>By Multiplayer Type</h2>
                {generateOptions()}
            </div>
        </form>
    );
}