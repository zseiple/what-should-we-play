// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.


class FriendList {

    constructor(listElem) {
        this._friends = [];
        this._listElem = listElem
        this._MAX_USERS = 8;
    }

    get numUsers() { return _friends.length; }

    //listElem is an outer list
    AddFriendToList(friendSteamID) {
        if (numUsers + 1 > this._MAX_USERS) {
            alert("Reached Max number of Friends ( you're too popular ): )")
            return;
        }

        $(_listElem).append(
            '<li class="friend">'
            + '<div class ="friend-img">' + friendName + '</li>'
            + '<button type="button" class="friend-entry">Delete</button>'
            + '</li>'
        );
        this._friends.push(newUsername);

    }

    //listElem is the button calling this function
    RemoveUsernameFromList(listElem) {
        if (numUsers - 1 < 0)
            return;

        const currUser = $(listElem).siblings('li').text();
        this._friends.splice(this._friends.indexOf(currUser), 1);
        $(listElem).parent('div').remove();
    
    }

    

    GetUsernameJSONs() {
        //no usernames
        if (numUsers < 1)
            return null;


    }

}

function showFilter
