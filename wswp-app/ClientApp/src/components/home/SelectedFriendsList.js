import { useState, useEffect } from 'react';

export function SelectedFriendsList(props) {

    useEffect(function initialize() {
        let container = document.querySelector("#selected-friend-list-container");
        container.addEventListener("click", (e) => {
            if (e.target.nodeName.toLowerCase() == "button") {
                props.onFriendRemoved(e.target.getAttribute("friend-id"));
            }
        })
    }, []);

 
    function createSelectedFriendListItem(friend) {
        return (
            <li>
                <img src={friend.profilePicUrl} />
                {friend.displayName}
                <button friend-id={friend.id}>Click to Remove</button>
            </li>
            )
    }

    function handleFriendRemoval(friendID) {
        props.onFriendRemoved(friendID)
    }

    //What will be displayed in render
    let friends = props.selectedFriends.length == 0 ?
        [<p>Start picking some friends :)</p>]
        : (<ul>{props.selectedFriends.map(friend => createSelectedFriendListItem(friend))}</ul>);

    //Render
    return (
        <div id="selected-friend-list-container">
                {friends}
        </div>
    );
}