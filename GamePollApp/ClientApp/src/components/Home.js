import React, { useState, useEffect, createRef } from 'react';
import { FriendSelector } from './home/FriendSelector';

export function Home(props) {

    const [loading, setLoading] = useState(true);
    const [authenticationDetails, setAuthenticationDetails] = useState(null);
    const friendSelector = createRef();

    //Get Initial Authentication State
    useEffect(function getUserAuthentication() {
        fetch("api/authenticate")
            .then(response => response.json())
            .then(json => {
                setAuthenticationDetails(json);
                setLoading(false);
                return json;
            })
            .then((info) => { console.log(info); });

    }, []);

    //Display for authenticated user
    function authenticatedUserDisplay() {
        
        const userDisplayName = authenticationDetails.userDetails.displayName;
        const friendList = authenticationDetails.userDetails.friendList;
        const MAX_FRIENDS = 8;

        //const selectedFriendCount = friendSelector.current.selectedFriendCount ?? 0;
       // console.log(friendSelector.current.selectedFriendCount);

        return (
            <div>
                <h1>Welcome {userDisplayName}</h1>
                <p>Please select who you'd like to play with (up to {MAX_FRIENDS} people)</p>
                <FriendSelector maxfriends={MAX_FRIENDS} friendList={friendList} userDetails={authenticationDetails.userDetails}/>
                <a href="/signout"><button>Click to Signout</button></a>
            </div>
        );
    }

    //Display for user who still needs to be authenticated
    function unauthenticatedUserDisplay() {
        return (
            <div>
                <h1>Welcome! Please log in to begin.</h1>
                <a href="/signin"><button>Click to login</button></a>
            </div>
        );
    }

    //RENDER
    //Authentication results, determine page display based on authentication status
    let isAuthenticated = authenticationDetails != null ? authenticationDetails.isAuthenticated : false;
    let resultPage = isAuthenticated ? authenticatedUserDisplay() : unauthenticatedUserDisplay();

    //While connecting with backend to get whether user is authenticated
    if (loading) {
        return (
            <div>
                <h1>Loading..</h1>
            </div>
        );
    }
    else
        return resultPage

   
}
