# API

The API is a collection of reusable functions that helps to reduce the size of a package, or for developers to communicate with Commander externally. As the API is exposed to the server context, please be aware of backdoors, as they may have codes to intervene Commander.

# Reasons to use

There are many reasons to use the API over a custom implementation when available, not just to maintain consistency across every packages in your Commander installation, but also for your own goods when making packages for Commander. Here's a few of the reasons to use the API:

- Consistency

By using the API for your packages, this creates a higher consistency between each other, ensuring the quality remains the same.

- Less duplicates

Write less line for the same functionality -- The API is a collection of reusable functions, in which your packages can make use of the API to do a Commander-specific task (fetching administrator info, etc), without writing the implementation again and again for each package.

- Safer

The API is constantly maintained by the Commander team, your packages always stay up-to-date and safe-to-use when we update the API. A custom implementation has to be maintained by the one who coded it, and when there is an update for Commander which affects the implementation, then the package is likely to be affected.

## Methods
### Players
#### sendModal
!!! abstract "`BindableEvent` API.Players.sendModal(`player` Player, `string?` Title)" 
    Sends a modal request to the defined user, asking for a string input. Returns a BindableEvent which fires upon interaction by the user.

#### sendList
!!! abstract "`void` API.Players.sendList(`player` Player, `string` Title, `Array` List)" 
    Sends a window request with a list, displaying the content found in the array.

#### executeWithPrefix
!!! abstract "`boolean` API.Players.executeWithPrefix(`player` Player, `string` Target, `function` Callback)" 
    Calls the defined callback for the defined Target, can be a player name/Id, or a prefix (all, others)

    Returns a boolean which indicates whether is the target present or not.

#### getPlayerByName
!!! abstract "`Player?` API.Players.getPlayerByName(`string` Player)" 
    Gets the player by its name, this only works when the player is ingame.

    Returns the player object if present, otherwise nil.

#### getPlayerByNamePartial
!!! abstract "`Player?` API.Players.getPlayerByNamePartial(`string` Player, `string?` Title)" 
    Gets the player by a part of its name, this only works when the player is ingame.

    Returns the player object if present, otherwise nil.

#### getCharacter
!!! abstract "`Model?` API.Players.getCharacter(`player` Player)"
    A safer implementation to retrieve the player character, only returns it if the character is loaded.

#### getUserIdFromName
!!! abstract "`number|string` API.Players.getUserIdFromName(`string` Name)" 
    Returns the UserId from its name if the User is present.

    Returns a string if the operation failed.

#### filterString
!!! abstract "`boolean, string` API.Players.filterString(`player` From, `string?` Content)"
    Sends a content filter request to Roblox, returns the status of the request, along with the result or the error messsage if the operation failed.

#### message
!!! abstract "`void` API.Players.message(`Player|string` To, `string` From, `string` Content, `number?` Duration)
    Sends a centered message to the corresponding player(s), filter the content manually if needed.

#### hint
!!! abstract "`void` API.Players.hint(`Player|string` To, `string` From, `string` Content, `number?` Duration)
    Sends a less-disturbing notification to the corresponding player(s), filter the content manually if needed.

#### notify
!!! abstract "`void` API.Players.notify(`Player|string` To, `string` From, `string` Content)
    Sends a notification that is not time limited, at the bottom right corner.

    If you are looking for an option for user to interact with the notification, use `notifyWithAction`

#### notifyWithAction
!!! abstract "`BindableEvent` API.Players.notify(`Player|string` To, `string` Type, `string` From, `string` Content)
    Like `notify`, but this returns a `BindableEvent`, which fires upon interaction ends.

#### setTransparency
!!! abstract "`void` API.Players.setTransparency(`Model` Character, `number` Alpha)
    Sets the transparency of a character.

#### checkPermission
!!! abstract "`boolean` API.Players.checkPermission(`number` Player, `string` CommandName)
    Checks if the user is allowed to run the specific command, returns a boolean that indicates the status.

#### getAdminStatus
!!! abstract "`boolean` API.Players.getAdminStatus(`number` Player)
    Checks if user is allowed to use Commander.

#### getAdminLevel
!!! abstract "`string?` API.Players.getAdminLevel(`number` Player)
    Gets user's level of authorization, returns `void` if the user is not authorized.

#### getAdmins
!!! abstract "`void` API.Players.getAdmins()
    Fetches a list of administrators defined in the Settings module

#### getAvailableAdmins
!!! abstract "`number` API.Players.getAvailableAdmins()
    Returns a number of administrators available in that server

#### listenToPlayerAdded
!!! abstract "`void` API.Players.listenToPlayerAdded(`function` Callback)
    Registers a callback to PlayerAdded event

### Global API

If you plan to integrate your game's system with Commander, you can consider to use our global API, stored in the `_G` environment with name `CommanderAPI`.

The global API is not available for clients context however, only communicate with Commander in server context as it's safer.

Here is the list of all available methods in the global API, the reference of the methods are exactly the same as the one in the builtin API unless specified.

- checkHasPermission
- checkAdmin
- getAdminLevel
- getAvailableAdmins
- getAdminStatus
- getAdmins