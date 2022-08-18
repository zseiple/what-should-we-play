import { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { GameFilters } from './GameFilters';

export function CommonGames(props) {

    const [loading, setLoading] = useState(true);
    const [gameData, setGameData] = useState({});
    const [filteredGames, setFilteredGames] = useState({});

    const location = useLocation();

    useEffect(function initialize() {

        fetchOwnedGames();
    }, [])

    const fetchOwnedGames = async () => {
        let params = location.state.selectedFriends.map(friend => "ids=" + friend.id).join('&');

        console.log(`[CommonGames.js] Sending fetch request with uri: api/gamedata/get-games-owned?${params}`)

        fetch("api/gamedata/get-owned-games?" + params)
            .then(response => response.json())
            .then(json => {
                setGameData(json);
                setFilteredGames(json);
                setLoading(false);
            })
            .catch(err => alert(`[CommonGames: fetch api/gamedata/get-games/owned: ${err}`));

        
    }

    const applyFilters = (filteredGames) => {
        setFilteredGames(filteredGames);
    }

    //NEED TO FILL OUT THIS LOGIC TO GENERATE THE TABLE
    const generateTableRows = () => {
        console.log(filteredGames);
        let resultingRows = [];

        for(const player of filteredGames.players)
        {
            for (const game of player.gameLibrary.games) {
                resultingRows.push((
                    <tr>
                        <th>{game.appid}</th>
                    </tr>
                ));
            }
        }

        if (resultingRows.length <= 0) {
            resultingRows.push((
                <tr>No games found for given filters :(</tr>
                ));
        }

        return resultingRows;
    }

    const pageContents = loading ?
        <p>pls wait finding common games</p> :
        (<div>
            <GameFilters playersOwnedGameData={gameData} onFiltersChanged={applyFilters} />
            <p>Game Count: {generateTableRows().length}</p>
            <table>
                {generateTableRows()}
            </table>
        </div>);
        

    return (
        <div>
            <h1>Common Games Page</h1>
            {loading ? <p>pls wait finding common games</p> : <p></p>}
            <div>{pageContents}</div>
        </div>
        );
}