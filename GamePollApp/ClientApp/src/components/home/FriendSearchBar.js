import React, { useState, useEffect, useRef } from 'react';

export function FriendSearchBar (props) {

    //Filtered friends based on search text
    const [filteredFriends, setFilteredFriends] = useState([]);
    const searchText = useRef("");

    useEffect(function initialize() {

        let searchBar = document.getElementById("friend-search");
        searchBar.addEventListener("keyup", () => {
            searchText.current = searchBar.value.toLowerCase();
        });
        searchBar.addEventListener("keyup", filterFriends);

        let form = document.getElementById("friend-form");
        form.addEventListener("submit", (e) => e.preventDefault());
        searchBar.addEventListener("keyup", handleFriendSelection);
    }, []);

    //updates filteredFriends based on comparison to text in 
    function filterFriends() {

        setFilteredFriends(props.friendList
            .filter(friend => {
                return friend.displayName.toLowerCase().includes(searchText.current);
            })
            .sort((first, second) => {
                const firstIndex = first.displayName.toLowerCase().indexOf(searchText.current);
                const secondIndex = second.displayName.toLowerCase().indexOf(searchText.current);

                if (firstIndex < secondIndex)
                    return -1;
                else if (firstIndex > secondIndex)
                    return 1;
                else
                    return 0;
            })
        );

    }


    //Generates possible selections based on user's friend list and then returns an array of the results
    function generateSelectionOptions() {
        let selectionOptions = [];

        for (const friend of filteredFriends) {
            //Check to make sure friend isn't already selected
            if (props.selectedFriends.filter(selectedFriend => selectedFriend.id === friend.id).length > 0)
                continue;

            selectionOptions.push(
                <option value={friend.displayName}>{friend.displayName}</option>
            );
        }
        return selectionOptions;
    }


    function handleFriendSelection() {

        //If current search text DOES NOT match any of the possible friend options then ignore
        let datalistArray = [...document.getElementById("friend-options").childNodes];
        if (datalistArray.filter(child => child.value.toLowerCase() == searchText.current).length <= 0) {
            return;
        }

        //Need to find the friend Object to pass
        const friendObj = props.friendList.find(friend => friend.displayName.toLowerCase() == searchText.current);

        //If friend was not found (for some reason?)
        if (friendObj == undefined) {
            return;
        }

        props.onFriendSelected(friendObj);

        clearSearchBar();
    }

    function clearSearchBar() {
        const searchBar = document.getElementById("friend-search");
        searchBar.value = "";
        searchBar.focus();
    }

    return (

        <div>
            <form id="friend-form" autocomplete="off">
                <input id="friend-search" type="text" list="friend-options" name="friendSearch" placeholder="Search for Friends..." />
                <datalist id="friend-options">
                    {generateSelectionOptions()}
                </datalist>


            </form>
        </div>
    );
}