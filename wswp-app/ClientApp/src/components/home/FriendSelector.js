import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { FriendSearchBar } from './FriendSearchBar';
import { SelectedFriendsList } from './SelectedFriendsList';



export function FriendSelector(props) {

    const [selectedFriends, setSelectedFriends] = useState([]);
    let navigate = useNavigate();

    useEffect(function intialize() {

        //Proceed Button click event
        let container = document.querySelector("#button-container");
        container.addEventListener("click", (e) => {
            if (e.target.nodeName.toLowerCase() == "button") {
                //add the user logged in before proceeding (makes things easier)
                setSelectedFriends(freshSelectedFriends => {
                    freshSelectedFriends.push({
                        id: props.userDetails.id,
                        profilePicUrl: props.userDetails.profilePicUrl,
                        displayName: props.userDetails.displayName
                    })
                    navigate("/games", { state: { selectedFriends: freshSelectedFriends } });
                    return freshSelectedFriends;
                });
            }
        });
    }, [])

    function handleFriendSelected(friendObj) {
        setSelectedFriends(freshSelectedFriends => {
            if (freshSelectedFriends.length + 1 <= props.maxfriends)
                return [...freshSelectedFriends, friendObj]

            alert(`No more than ${props.maxfriends} friends allowed at a time.`);
            return freshSelectedFriends;
        });
    }

    function handleFriendRemoved(friendID) {

        setSelectedFriends(freshSelectedFriends => {
            //Find index
            let foundIndex = freshSelectedFriends.findIndex((friend) => { return friend.id == friendID });
            //Make array of everything but that index
            return freshSelectedFriends.filter((friend, index) => index !== foundIndex);
        });
    }

    const proceedButton = <button id='proceed'>Click to Proceed</button>;

    return (
        <div>
            <FriendSearchBar friendList={props.friendList} selectedFriends={selectedFriends} onFriendSelected={handleFriendSelected} />
            <SelectedFriendsList selectedFriends={selectedFriends} onFriendRemoved={handleFriendRemoved} />
            <div id="button-container">
                {selectedFriends.length > 0 ? proceedButton : null}
            </div>
        </div>
    );
}