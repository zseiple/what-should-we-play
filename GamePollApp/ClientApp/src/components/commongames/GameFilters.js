import { useState, useEffect } from 'react';
import { MinPlayersOwned } from './filters/MinPlayersOwned';
import { cloneDeep } from 'lodash.clonedeep';

export function GameFilters({ playersOwnedGameData, onFiltersChanged }) {

    const [selectedFilters, setSelectedFilters] = useState([]);

    //Parameter state variables. Each be accessed directly by filtered functions to change appropriately with filter choices
    //const [minPlayersOwnedParams, setMinPlayersOwnedParams] = useState({ minPlayersOwned: playersOwnedGameData.players.length });

    useEffect(function updateFilters() {
        applyFilters()
    }, [selectedFilters]);

    const applyFilters = () => {
        console.log("Applying Filters");

        //No filters?
        if (selectedFilters.length == undefined)
            return;
        console.log("Player game data before filter:");
        console.log(playersOwnedGameData);
        let resultingFilteredGames = cloneDeep(playersOwnedGameData);
        for(const func of selectedFilters)
        {
            //Filters need one parameter for game list from previous filter (if any, sorta like a recursive thing)
            resultingFilteredGames = func(resultingFilteredGames);
            console.log("applied a filter, heres the result")
            console.log(resultingFilteredGames);
        }

        onFiltersChanged(resultingFilteredGames);

        console.log("Applying filters complete");
    }

    const addFilter = (filterFunc) => {
        setSelectedFilters(freshSelectedFilters => {
            //Not Found
            if (freshSelectedFilters.indexOf(filterFunc) == -1)
                freshSelectedFilters.push(filterFunc)
            return freshSelectedFilters;
        });
    }

    const removeFilter = (filterFunc) => {
        setSelectedFilters(freshSelectedFilters => {
            let index;
            //Found
            if ((index = freshSelectedFilters.indexOf(filterFunc)) != -1)
                freshSelectedFilters.splice(index, 1);
            return freshSelectedFilters;
        })
    }


    return (
        <div id="filter-container">
            <MinPlayersOwned addFilter={addFilter} onUpdateParams={applyFilters} numPlayers={playersOwnedGameData.players.length}/>
        </div>
    );
}